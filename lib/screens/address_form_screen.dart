import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/address_model.dart';
import '../providers/address_provider.dart';
import '../utils/constants.dart';

class AddressFormScreen extends StatefulWidget {
  final DeliveryAddress? existing;

  const AddressFormScreen({super.key, this.existing});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _pincode;
  late final TextEditingController _addr1;
  late final TextEditingController _addr2;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _state;

  String _type = 'Home';
  bool _isDefault = false;
  bool _gpsLoading = false;
  bool _pincodeLoading = false;
  double? _lat, _lng;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name     = TextEditingController(text: e?.fullName ?? '');
    _mobile   = TextEditingController(text: e?.mobile ?? '');
    _pincode  = TextEditingController(text: e?.pincode ?? '');
    _addr1    = TextEditingController(text: e?.addressLine1 ?? '');
    _addr2    = TextEditingController(text: e?.addressLine2 ?? '');
    _landmark = TextEditingController(text: e?.landmark ?? '');
    _city     = TextEditingController(text: e?.city ?? '');
    _state    = TextEditingController(text: e?.state ?? '');
    _type      = e?.addressType ?? 'Home';
    _isDefault = e?.isDefault ?? false;
    _lat       = e?.latitude;
    _lng       = e?.longitude;

    _pincode.addListener(() {
      if (_pincode.text.length == 6) _fetchPincode(_pincode.text);
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _mobile, _pincode, _addr1, _addr2, _landmark, _city, _state]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Pincode auto-fill ─────────────────────────────────────────────────────
  Future<void> _fetchPincode(String pin) async {
    setState(() => _pincodeLoading = true);
    try {
      final res = await http.get(
          Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        if (data[0]['Status'] == 'Success') {
          final po = (data[0]['PostOffice'] as List<dynamic>)[0];
          _city.text  = po['District'] as String;
          _state.text = po['State'] as String;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _pincodeLoading = false);
  }

  // ── GPS fill ──────────────────────────────────────────────────────────────
  Future<void> _useGpsLocation() async {
    setState(() => _gpsLoading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _snack('Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _lat = pos.latitude;
      _lng = pos.longitude;

      // Reverse geocode via Google Maps API
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=${pos.latitude},${pos.longitude}&key=$kGoogleMapsApiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final comps = (data['results'] as List<dynamic>)[0]['address_components'] as List<dynamic>;
          String house = '', street = '', sublocal = '', city = '', state = '', pin = '';
          for (final c in comps) {
            final types = (c['types'] as List<dynamic>).cast<String>();
            final short = c['short_name'] as String;
            if (types.contains('street_number')) house = short;
            if (types.contains('route')) street = short;
            if (types.contains('sublocality_level_1')) sublocal = short;
            if (types.contains('locality')) city = short;
            if (types.contains('administrative_area_level_1')) state = short;
            if (types.contains('postal_code')) pin = short;
          }
          if (mounted) setState(() {
            if (house.isNotEmpty || street.isNotEmpty) {
              _addr1.text = '$house $street'.trim();
            }
            if (sublocal.isNotEmpty) _addr2.text = sublocal;
            if (city.isNotEmpty) _city.text = city;
            if (state.isNotEmpty) _state.text = state;
            if (pin.isNotEmpty) _pincode.text = pin;
          });
        }
      }
    } catch (_) {
      _snack('Could not get location');
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddressProvider>();
    final address = DeliveryAddress(
      id: widget.existing?.id ?? const Uuid().v4(),
      fullName: _name.text.trim(),
      mobile: _mobile.text.trim(),
      pincode: _pincode.text.trim(),
      addressLine1: _addr1.text.trim(),
      addressLine2: _addr2.text.trim(),
      landmark: _landmark.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      addressType: _type,
      latitude: _lat,
      longitude: _lng,
      isDefault: _isDefault,
    );
    if (widget.existing == null) {
      await provider.add(address);
    } else {
      await provider.update(address);
    }
    if (mounted) Navigator.pop(context, address);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: kCineBg,
      appBar: AppBar(
        backgroundColor: kCineSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Address' : 'Add New Address',
          style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // GPS fill button
            GestureDetector(
              onTap: _gpsLoading ? null : _useGpsLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kCineBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kCineBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    if (_gpsLoading)
                      const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: kCineBlue))
                    else
                      Icon(Icons.my_location_rounded, color: kCineBlue, size: 20),
                    const SizedBox(width: 10),
                    Text('Use current GPS location',
                        style: GoogleFonts.outfit(color: kCineBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 20),

            // Fields
            _Field(ctrl: _name, label: 'Full Name', hint: 'Farmer name',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            _gap,
            _Field(ctrl: _mobile, label: 'Mobile Number', hint: '10-digit mobile',
                keyboard: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (v) => v == null || v.length != 10 ? 'Enter valid 10-digit number' : null),
            _gap,

            // Pincode + loader
            _Field(
              ctrl: _pincode, label: 'Pincode', hint: '6-digit pincode',
              keyboard: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              validator: (v) => v == null || v.length != 6 ? 'Enter valid 6-digit pincode' : null,
              suffix: _pincodeLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: kCineGreen)))
                  : null,
            ),
            _gap,
            _Field(ctrl: _addr1, label: 'House / Building / Farm Name', hint: 'Address Line 1',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            _gap,
            _Field(ctrl: _addr2, label: 'Area / Street (optional)', hint: 'Address Line 2'),
            _gap,
            _Field(ctrl: _landmark, label: 'Landmark (optional)', hint: 'Near school, temple…'),
            _gap,
            Row(
              children: [
                Expanded(child: _Field(ctrl: _city, label: 'City / District', hint: 'City',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
                const SizedBox(width: 12),
                Expanded(child: _Field(ctrl: _state, label: 'State', hint: 'State',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
              ],
            ),
            const SizedBox(height: 24),

            // Address type
            Text('Address Type',
                style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: ['Home', 'Farm', 'Other'].map((t) {
                final sel = _type == t;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: 180.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? kCineGreen.withOpacity(0.15) : kCineCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? kCineGreen : kCineBorder,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_typeIcon(t), color: sel ? kCineGreen : kCineTextSub, size: 16),
                          const SizedBox(width: 6),
                          Text(t,
                              style: GoogleFonts.outfit(
                                color: sel ? kCineGreen : kCineTextSub,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Default toggle
            GestureDetector(
              onTap: () => setState(() => _isDefault = !_isDefault),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: 180.ms,
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: _isDefault ? kCineGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _isDefault ? kCineGreen : kCineBorder, width: 1.5),
                    ),
                    child: _isDefault
                        ? const Icon(Icons.check, color: Colors.black, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text('Set as default delivery address',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 54,
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
                  child: Text(
                    isEdit ? 'Update Address' : 'Save Address',
                    style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: kCineBg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget get _gap => const SizedBox(height: 14);

  static IconData _typeIcon(String t) => switch (t) {
    'Home' => Icons.home_rounded,
    'Farm' => Icons.agriculture_rounded,
    _ => Icons.location_on_rounded,
  };
}

// ── Shared field widget ───────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboard,
    this.inputFormatters,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
              color: kCineTextSub, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: kCineTextDim, fontSize: 14),
            suffixIcon: suffix,
            filled: true,
            fillColor: kCineCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kCineBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kCineGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kCineOrange),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kCineOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
