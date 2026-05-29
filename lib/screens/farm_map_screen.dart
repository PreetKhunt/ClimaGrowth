import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

// ── Persistent farm storage ───────────────────────────────────────────────────
class FarmLocationStore {
  static const _kName = 'farm_name';
  static const _kLat = 'farm_lat';
  static const _kLng = 'farm_lng';
  static const _kArea = 'farm_area_acres';

  static Future<Map<String, dynamic>?> load() async {
    final p = await SharedPreferences.getInstance();
    final lat = p.getDouble(_kLat);
    final lng = p.getDouble(_kLng);
    if (lat == null || lng == null) return null;
    return {
      'name': p.getString(_kName) ?? 'My Farm',
      'lat': lat,
      'lng': lng,
      'areaAcres': p.getDouble(_kArea),
    };
  }

  static Future<void> save({
    required String name,
    required double lat,
    required double lng,
    double? areaAcres,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name);
    await p.setDouble(_kLat, lat);
    await p.setDouble(_kLng, lng);
    if (areaAcres != null) await p.setDouble(_kArea, areaAcres);
  }
}

// ── HTTP geocoding (works on all platforms including web) ─────────────────────
class _Geocoder {
  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$lat,$lng&key=$kGoogleMapsApiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          if (results.isNotEmpty) {
            return results[0]['formatted_address'] as String;
          }
        }
      }
    } catch (_) {}
    return '';
  }

  static Future<LatLng?> forwardGeocode(String query) async {
    try {
      final encoded = Uri.encodeComponent('$query, Gujarat, India');
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=$encoded&key=$kGoogleMapsApiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final loc = (data['results'] as List<dynamic>)[0]['geometry']['location'];
          return LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
        }
      }
    } catch (_) {}
    return null;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class FarmMapScreen extends StatefulWidget {
  const FarmMapScreen({super.key});

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  GoogleMapController? _ctrl;
  MapType _mapType = MapType.satellite;
  LatLng _center = const LatLng(22.2354, 73.0842); // Padra default
  bool _mapReady = false;

  bool _drawingMode = false;
  final List<LatLng> _boundaryPoints = [];
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  double _calculatedAcres = 0;

  final _searchCtrl = TextEditingController();
  bool _gpsLoading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _ctrl?.dispose();
    super.dispose();
  }

  // ── Load existing farm ────────────────────────────────────────────────────
  Future<void> _loadSaved() async {
    final data = await FarmLocationStore.load();
    if (data == null || !mounted) return;
    final pos = LatLng(data['lat'] as double, data['lng'] as double);
    setState(() {
      _center = pos;
      _markers = {
        Marker(
          markerId: const MarkerId('saved'),
          position: pos,
          infoWindow: InfoWindow(title: data['name'] as String),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        )
      };
    });
  }

  // ── GPS ───────────────────────────────────────────────────────────────────
  Future<void> _goToMyLocation() async {
    setState(() => _gpsLoading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _snack('Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = loc);
      _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(loc, 17));
    } catch (e) {
      _snack('Could not get location');
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    final loc = await _Geocoder.forwardGeocode(q);
    if (loc != null) {
      setState(() => _center = loc);
      _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(loc, 16));
    } else {
      _snack('Location not found');
    }
  }

  // ── Boundary drawing ──────────────────────────────────────────────────────
  void _onMapTap(LatLng point) {
    if (!_drawingMode) return;
    setState(() {
      _boundaryPoints.add(point);
      _markers = Set.from(_markers)
        ..add(Marker(
          markerId: MarkerId('pt_${_boundaryPoints.length}'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          anchor: const Offset(0.5, 0.5),
        ));
      if (_boundaryPoints.length >= 3) {
        _polygons = {
          Polygon(
            polygonId: const PolygonId('field'),
            points: _boundaryPoints,
            strokeColor: kCineGreen,
            strokeWidth: 2,
            fillColor: kCineGreen.withOpacity(0.18),
          ),
        };
        _calculatedAcres = _polygonAreaAcres(_boundaryPoints);
      }
    });
  }

  double _polygonAreaAcres(List<LatLng> pts) {
    if (pts.length < 3) return 0;
    const r = 6371000.0;
    double area = 0;
    for (int i = 0; i < pts.length; i++) {
      final j = (i + 1) % pts.length;
      final lat1 = pts[i].latitude * math.pi / 180;
      final lat2 = pts[j].latitude * math.pi / 180;
      final dLng = (pts[j].longitude - pts[i].longitude) * math.pi / 180;
      area += dLng * (2 + math.sin(lat1) + math.sin(lat2));
    }
    return (area * r * r / 2).abs() / 4046.86;
  }

  void _clearBoundary() {
    setState(() {
      _boundaryPoints.clear();
      _polygons = {};
      _markers = _markers
          .where((m) => !m.markerId.value.startsWith('pt_'))
          .toSet();
      _calculatedAcres = 0;
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _saveFarm() async {
    setState(() => _saving = true);
    String placeName = 'My Farm';
    final addr = await _Geocoder.reverseGeocode(_center.latitude, _center.longitude);
    if (addr.isNotEmpty) {
      // Use first two components (locality, district)
      final parts = addr.split(',');
      placeName = parts.take(2).map((s) => s.trim()).join(', ');
    }

    final nameCtrl = TextEditingController(text: placeName);
    if (!mounted) return;

    final farmName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCineSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Name Your Farm',
            style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_calculatedAcres > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kCineGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kCineGreen.withOpacity(0.3)),
                ),
                child: Text(
                  'Field area: ${_calculatedAcres.toStringAsFixed(2)} acres',
                  style: GoogleFonts.outfit(color: kCineGreen, fontWeight: FontWeight.w600),
                ),
              ),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. North Field',
                hintStyle: TextStyle(color: kCineTextDim),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kCineBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kCineGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: kCineTextSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kCineGreen,
              foregroundColor: kCineBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: Text('Save', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (farmName == null || farmName.isEmpty) {
      setState(() => _saving = false);
      return;
    }

    await FarmLocationStore.save(
      name: farmName,
      lat: _center.latitude,
      lng: _center.longitude,
      areaAcres: _calculatedAcres > 0 ? _calculatedAcres : null,
    );

    _snack('Farm saved!');
    if (mounted) Navigator.pop(context, _center);
    setState(() => _saving = false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCineBg,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            mapType: _mapType,
            onMapCreated: (c) {
              _ctrl = c;
              if (mounted) setState(() => _mapReady = true);
            },
            onCameraMove: (pos) => _center = pos.target,
            onTap: _onMapTap,
            markers: _markers,
            polygons: _polygons,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),

          // ── Map loading indicator ─────────────────────────────────────────
          if (!_mapReady)
            Container(
              color: kCineBg,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(
                        color: kCineGreen, strokeWidth: 2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading satellite map…',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // ── Center crosshair (non-drawing mode) ──────────────────────────
          if (!_drawingMode)
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2, height: 20,
                      color: kCineGreen.withOpacity(0.9),
                    ),
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kCineGreen,
                        boxShadow: [BoxShadow(color: kGlowGreen, blurRadius: 12)],
                      ),
                    ),
                    Container(
                      width: 2, height: 20,
                      color: kCineGreen.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),

          // ── Search bar ───────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: kCineSurface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kCineBorder),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search village, farm or place...',
                            hintStyle: GoogleFonts.outfit(color: kCineTextDim, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search_rounded, color: kCineGreen),
                        onPressed: _search,
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
          ),

          // ── Map-type & GPS buttons ────────────────────────────────────────
          Positioned(
            right: 16, top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _MapBtn(
                  heroTag: 'layers',
                  icon: Icons.layers_rounded,
                  tooltip: 'Map type',
                  onTap: () => setState(() {
                    _mapType = _mapType == MapType.satellite
                        ? MapType.hybrid
                        : _mapType == MapType.hybrid
                            ? MapType.normal
                            : MapType.satellite;
                  }),
                ),
                const SizedBox(height: 10),
                _MapBtn(
                  heroTag: 'gps',
                  icon: _gpsLoading ? Icons.hourglass_empty_rounded : Icons.my_location_rounded,
                  tooltip: 'My location',
                  onTap: _gpsLoading ? null : _goToMyLocation,
                ),
              ],
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),

          // ── Area chip ─────────────────────────────────────────────────────
          if (_drawingMode && _calculatedAcres > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kCineGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: kGlowGreen, blurRadius: 16)],
                ),
                child: Text(
                  '${_calculatedAcres.toStringAsFixed(2)} acres',
                  style: GoogleFonts.syne(
                    fontSize: 14, fontWeight: FontWeight.w800, color: kCineBg),
                ),
              ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
            ),

          // ── Bottom controls ───────────────────────────────────────────────
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCineSurface.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kCineBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Draw boundary row
                      Row(
                        children: [
                          Expanded(
                            child: _CtrlButton(
                              label: _drawingMode ? 'Done Drawing' : 'Draw Boundary',
                              icon: _drawingMode ? Icons.check_circle_rounded : Icons.edit_rounded,
                              color: _drawingMode ? kCineBlue : kCineTextSub,
                              onTap: () => setState(() {
                                _drawingMode = !_drawingMode;
                              }),
                            ),
                          ),
                          if (_drawingMode && _boundaryPoints.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            _CtrlButton(
                              label: 'Clear',
                              icon: Icons.clear_rounded,
                              color: kCineOrange,
                              onTap: _clearBoundary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mark farm button
                      GestureDetector(
                        onTap: _saving ? null : _saveFarm,
                        child: AnimatedContainer(
                          duration: 200.ms,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kCineGreen, Color(0xFF00CC6A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: kGlowGreen, blurRadius: 20, offset: const Offset(0, 6))],
                          ),
                          child: Center(
                            child: _saving
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.agriculture_rounded, color: Colors.black, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Mark This as My Farm',
                                          style: GoogleFonts.syne(
                                            fontSize: 15, fontWeight: FontWeight.w800, color: kCineBg)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable FAB-style map button ───────────────────────────────────────
class _MapBtn extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _MapBtn({
    required this.heroTag,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: kCineSurface.withOpacity(0.95),
            shape: BoxShape.circle,
            border: Border.all(color: kCineBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
          ),
          child: Icon(icon, color: kCineGreen, size: 20),
        ),
      ),
    );
  }
}

// ── Bottom panel control button ───────────────────────────────────────────────
class _CtrlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CtrlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
