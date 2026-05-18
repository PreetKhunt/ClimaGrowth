import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PesticideDosageCalc extends StatefulWidget {
  const PesticideDosageCalc({super.key});

  @override
  State<PesticideDosageCalc> createState() => _PesticideDosageCalcState();
}

class _PesticideDosageCalcState extends State<PesticideDosageCalc> {
  final areaCtrl = TextEditingController();
  final concentrationCtrl = TextEditingController();
  final sprayerCapacityCtrl = TextEditingController();

  String? _areaError;
  String? _concError;
  String? _sprayerError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final area = double.tryParse(areaCtrl.text.trim());
    final concentration = double.tryParse(concentrationCtrl.text.trim());
    final sprayerCap = double.tryParse(sprayerCapacityCtrl.text.trim());

    final areaErr =
        (area == null || area <= 0) ? 'Enter a valid positive number' : null;
    final concErr = (concentration == null || concentration <= 0 || concentration > 100)
        ? 'Enter a valid concentration (0–100%)'
        : null;
    final sprayerErr =
        (sprayerCap == null || sprayerCap <= 0) ? 'Enter a valid positive capacity' : null;

    if (areaErr != null || concErr != null || sprayerErr != null) {
      setState(() {
        _areaError = areaErr;
        _concError = concErr;
        _sprayerError = sprayerErr;
        _result = null;
      });
      return;
    }

    final waterNeeded = area! * 500; // 500 L per acre standard
    final pesticidesNeeded = (waterNeeded * concentration!) / 100; // mL
    final numSprays = (waterNeeded / sprayerCap!).ceil();

    debugPrint(
      'PesticideDosage: area=${area}acres, concentration=$concentration%, '
      'sprayerCap=${sprayerCap}L, water=${waterNeeded.toStringAsFixed(0)}L, '
      'pesticide=${pesticidesNeeded.toStringAsFixed(2)}mL, sprays=$numSprays',
    );

    setState(() {
      _areaError = null;
      _concError = null;
      _sprayerError = null;
      _result = {
        'pesticide': pesticidesNeeded.toStringAsFixed(2),
        'water': waterNeeded.toStringAsFixed(0),
        'sprays': numSprays.toString(),
        'safety':
            'PPE required: Gloves, Mask, Eye protection\nRe-entry interval: 24 hours',
      };
    });
  }

  @override
  void dispose() {
    areaCtrl.dispose();
    concentrationCtrl.dispose();
    sprayerCapacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesticide Dosage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: areaCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Area (acres)',
                      errorText: _areaError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: concentrationCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Concentration (%)',
                      hintText: 'e.g. 2',
                      errorText: _concError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sprayerCapacityCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Sprayer Tank Capacity (liters)',
                      hintText: 'e.g. 16',
                      errorText: _sprayerError,
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
                      child: const Text('Calculate Dosage'),
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
                    Text('Application Guide',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Pesticide Needed', '${_result!['pesticide']} mL'),
                    _resultRow('Water Needed', '${_result!['water']} L'),
                    _resultRow('Number of Tank Fills', _result!['sprays']),
                    const Divider(),
                    Text('Safety',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      _result!['safety'],
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: kCoral),
                    ),
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
