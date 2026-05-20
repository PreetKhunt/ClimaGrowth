import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class WaterRequirementCalc extends StatefulWidget {
  const WaterRequirementCalc({super.key});

  @override
  State<WaterRequirementCalc> createState() => _WaterRequirementCalcState();
}

class _WaterRequirementCalcState extends State<WaterRequirementCalc> {
  final sizeCtrl = TextEditingController();
  final et0Ctrl = TextEditingController(text: '5.0');
  String stage = 'vegetative';
  String soilType = 'loamy';

  String? _sizeError;
  String? _et0Error;
  Map<String, dynamic>? _result;

  // Crop coefficient by growth stage (FAO-56 typical values)
  double get _kc {
    if (stage == 'vegetative') return 0.60;
    if (stage == 'flowering') return 0.85;
    return 1.05; // fruiting/maturity
  }

  void _calculate() {
    final size = double.tryParse(sizeCtrl.text.trim());
    final et0 = double.tryParse(et0Ctrl.text.trim());

    final sizeErr = (size == null || size <= 0) ? 'Enter a valid positive number' : null;
    final et0Err = (et0 == null || et0 <= 0) ? 'Enter a valid positive number' : null;

    if (sizeErr != null || et0Err != null) {
      setState(() {
        _sizeError = sizeErr;
        _et0Error = et0Err;
        _result = null;
      });
      return;
    }

    // Formula: liters/day = Kc × ET₀ (mm/day) × area (m²)
    // Because 1 mm over 1 m² = 1 liter
    final kc = _kc;
    final areaSqm = size! * 4046.0;
    final totalLiters = kc * et0! * areaSqm;
    final perPlant = totalLiters / 500; // 500 plants/acre estimate

    // Irrigation interval hint based on soil type
    final intervalDays = soilType == 'clay' ? 3 : soilType == 'sandy' ? 1 : 2;

    final hour = DateTime.now().hour;
    final recommendedTime = (hour >= 6 && hour < 10)
        ? 'Early morning (best – now!)'
        : (hour >= 16 && hour < 18)
            ? 'Evening (good)'
            : 'Early morning preferred';

    debugPrint(
      'WaterRequirement: size=${size}acres, areaSqm=${areaSqm.toStringAsFixed(0)}m², '
      'Kc=$kc, ET0=${et0}mm/day, stage=$stage, soil=$soilType, '
      'result=${totalLiters.toStringAsFixed(0)} liters/day',
    );

    setState(() {
      _sizeError = null;
      _et0Error = null;
      _result = {
        'kc': kc.toStringAsFixed(2),
        'total': totalLiters.toStringAsFixed(0),
        'perPlant': perPlant.toStringAsFixed(1),
        'interval': '$intervalDays days ($soilType soil)',
        'time': recommendedTime,
      };
    });
  }

  @override
  void dispose() {
    sizeCtrl.dispose();
    et0Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Requirement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Input Fields',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sizeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Farm Size (acres)',
                      errorText: _sizeError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: stage,
                    onChanged: (v) => setState(() => stage = v ?? 'vegetative'),
                    items: ['vegetative', 'flowering', 'fruiting']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Growth Stage  ·  Kc = ${_kc.toStringAsFixed(2)}',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: et0Ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Reference ET₀ (mm/day) – India default: 5.0',
                      errorText: _et0Error,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: soilType,
                    onChanged: (v) => setState(() => soilType = v ?? 'loamy'),
                    items: ['clay', 'loamy', 'sandy']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Soil Type (affects irrigation interval)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Card(
              color: kAmber.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Results',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Crop Coefficient (Kc)', _result!['kc']),
                    _resultRow('Total Water Needed', '${_result!['total']} L/day'),
                    _resultRow('Per Plant (~500/acre)', '${_result!['perPlant']} L'),
                    _resultRow('Irrigation Interval', _result!['interval']),
                    _resultRow('Best Watering Time', _result!['time']),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
