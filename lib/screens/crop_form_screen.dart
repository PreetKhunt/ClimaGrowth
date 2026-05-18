import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/recommendations_provider.dart';
import '../providers/soil_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/loading_overlay.dart';

class CropFormScreen extends StatefulWidget {
  const CropFormScreen({super.key});

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropCtrl = TextEditingController();
  final _prevCropCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();

  String _irrigationMethod = 'Drip irrigation';
  String _soilType = 'Black cotton';

  static const _irrigationMethods = [
    'Bore water',
    'Canal',
    'Drip irrigation',
    'Sprinkler',
    'Rainwater',
  ];
  static const _soilTypes = [
    'Loamy',
    'Sandy',
    'Clay',
    'Black cotton',
    'Red laterite',
  ];
  static const _commonCrops = [
    'Cotton', 'Wheat', 'Rice', 'Tomato', 'Cabbage', 'Groundnut',
    'Sugarcane', 'Moong Dal', 'Bajra', 'Jowar', 'Spinach', 'Brinjal',
    'Onion', 'Garlic', 'Potato', 'Chilli', 'Turmeric', 'Coriander',
  ];

  @override
  void dispose() {
    _cropCtrl.dispose();
    _prevCropCtrl.dispose();
    _farmSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recProvider = context.watch<RecommendationsProvider>();
    final weather = context.read<WeatherProvider>().weather;
    final soil = context.read<SoilProvider>().soil;
    final tt = Theme.of(context).textTheme;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Crop Input Form'),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(kPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto-fetched data banner
                  _autofetchBanner(weather, soil, tt),

                  const SizedBox(height: 20),

                  _sectionTitle(tt, 'Farm Details'),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _irrigationMethod,
                    decoration: const InputDecoration(
                      labelText: 'Irrigation Method',
                      prefixIcon: Icon(Icons.shower_rounded),
                    ),
                    items: _irrigationMethods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _irrigationMethod = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _soilType,
                    decoration: const InputDecoration(
                      labelText: 'Soil Type',
                      prefixIcon: Icon(Icons.layers_rounded),
                    ),
                    items: _soilTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _soilType = v!),
                  ),
                  const SizedBox(height: 12),

                  // Crop autocomplete
                  Autocomplete<String>(
                    optionsBuilder: (v) => v.text.isEmpty
                        ? const []
                        : _commonCrops.where(
                            (c) => c.toLowerCase().contains(v.text.toLowerCase()),
                          ),
                    onSelected: (c) => _cropCtrl.text = c,
                    fieldViewBuilder: (ctx, ctrl, fn, _) {
                      _cropCtrl.addListener(() {
                        if (_cropCtrl.text != ctrl.text) ctrl.text = _cropCtrl.text;
                      });
                      return TextFormField(
                        controller: ctrl,
                        focusNode: fn,
                        validator: (v) => Validators.required(v, 'Crop to grow'),
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Crop to Grow',
                          hintText: 'e.g. Cotton, Wheat, Tomato',
                          prefixIcon: Icon(Icons.eco_rounded),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Previous crop autocomplete (optional)
                  Autocomplete<String>(
                    optionsBuilder: (v) => v.text.isEmpty
                        ? const []
                        : _commonCrops.where(
                            (c) => c.toLowerCase().contains(v.text.toLowerCase()),
                          ),
                    onSelected: (c) => _prevCropCtrl.text = c,
                    fieldViewBuilder: (ctx, ctrl, fn, _) {
                      return TextFormField(
                        controller: ctrl,
                        focusNode: fn,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Previous Crop (optional)',
                          hintText: 'e.g. Spinach, Tomato',
                          prefixIcon: Icon(Icons.history_rounded),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _farmSizeCtrl,
                    validator: Validators.farmSize,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Farm Size',
                      hintText: '1.5',
                      prefixIcon: Icon(Icons.landscape_outlined),
                      suffixText: 'acres',
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Location row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryGreen.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(kRadiusSmall),
                      border: Border.all(color: kPrimaryGreen.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: kPrimaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location: ${context.read<LocationProvider>().village}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kPrimaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: recProvider.loading ? null : _submit,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Generate Recommendations'),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Full-screen loading overlay
        if (recProvider.loading) const LoadingOverlay(),
      ],
    );
  }

  Widget _autofetchBanner(weather, soil, TextTheme tt) {
    if (weather == null && soil == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_outlined, color: kPrimaryGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Auto-fetched farm data',
                style: tt.titleMedium?.copyWith(color: kPrimaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (weather != null)
            _dataRow(Icons.thermostat_outlined,
                '${weather.temperature.toStringAsFixed(1)}°C  •  ${weather.humidity.toStringAsFixed(0)}% humidity  •  ${weather.condition}'),
          if (soil != null)
            _dataRow(Icons.layers_outlined,
                'Soil moisture: ${soil.moistureLevel.toStringAsFixed(0)}%  •  ${soil.healthStatus}'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _dataRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kTextSecondaryLight),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: kTextSecondaryLight)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(TextTheme tt, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: kPrimaryGreen,
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(title, style: tt.titleLarge?.copyWith(color: kPrimaryGreen)),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    await context.read<RecommendationsProvider>().generate(
          crop: _cropCtrl.text.trim(),
          soilType: _soilType,
          irrigationMethod: _irrigationMethod,
          previousCrop: _prevCropCtrl.text.trim(),
          farmSize: double.tryParse(_farmSizeCtrl.text) ?? 1.0,
        );

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/recommendations',
      arguments: {'crop': _cropCtrl.text.trim()},
    );
  }
}
