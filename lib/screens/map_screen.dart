import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;
  MapType _mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final target = LatLng(loc.lat, loc.lon);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Map'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_mapType == MapType.normal ? Icons.satellite_alt_rounded : Icons.map_outlined),
            tooltip: _mapType == MapType.normal ? 'Satellite View' : 'Standard View',
            onPressed: () => setState(() {
              _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 14),
            mapType: _mapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('farm'),
                position: target,
                infoWindow: InfoWindow(
                  title: loc.village,
                  snippet: 'Your Farm Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            },
            onMapCreated: (ctrl) => _mapCtrl = ctrl,
          ),

          // Location info overlay
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(kRadius),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: kPrimaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.village, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${loc.lat.toStringAsFixed(4)}, ${loc.lon.toStringAsFixed(4)}',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _centerOnFarm,
                    icon: const Icon(Icons.my_location_rounded, size: 16),
                    label: const Text('My Farm'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map type badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _mapType == MapType.normal ? 'Standard' : 'Satellite',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _centerOnFarm() {
    final loc = context.read<LocationProvider>();
    _mapCtrl?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.lat, loc.lon), zoom: 15),
      ),
    );
  }
}
