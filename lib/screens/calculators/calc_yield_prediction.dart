import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class YieldPredictionCalc extends StatefulWidget {
  const YieldPredictionCalc({super.key});

  @override
  State<YieldPredictionCalc> createState() => _YieldPredictionCalcState();
}

class _YieldPredictionCalcState extends State<YieldPredictionCalc> {
  final areaCtrl = TextEditingController();
  String crop = 'wheat';
  String soilHealth = 'good';
  String irrigationType = 'drip';
  String? _areaError;
  Map<String, dynamic>? _result;

  // Base yield per acre in quintals (national average)
  static const Map<String, double> _baseYields = {
    'wheat': 17.0,
    'rice': 22.0,
    'cotton': 8.0,
    'tomato': 100.0,
  };

  void _calculate() {
    final area = double.tryParse(areaCtrl.text.trim());
    final areaErr =
        (area == null || area <= 0) ? 'Enter a valid positive number' : null;

    if (areaErr != null) {
      setState(() {
        _areaError = areaErr;
        _result = null;
      });
      return;
    }

    double yieldPerAcre = _baseYields[crop] ?? 17.0;

    // Soil health modifier
    switch (soilHealth) {
      case 'poor':
        yieldPerAcre *= 0.70;
        break;
      case 'fair':
        yieldPerAcre *= 0.85;
        break;
      case 'excellent':
        yieldPerAcre *= 1.20;
        break;
      default: // good
        break;
    }

    // Irrigation modifier
    switch (irrigationType) {
      case 'flood':
        yieldPerAcre *= 0.80;
        break;
      case 'sprinkler':
        yieldPerAcre *= 1.10;
        break;
      case 'drip':
        yieldPerAcre *= 1.30;
        break;
    }

    final totalYield = yieldPerAcre * area!;
    final confidence = soilHealth == 'good' || soilHealth == 'excellent'
        ? '85%'
        : '70%';

    debugPrint(
      'YieldPrediction: crop=$crop, area=${area}acres, soilHealth=$soilHealth, '
      'irrigation=$irrigationType, yieldPerAcre=${yieldPerAcre.toStringAsFixed(1)}qtl, '
      'totalYield=${totalYield.toStringAsFixed(0)}qtl, confidence=$confidence',
    );

    setState(() {
      _areaError = null;
      _result = {
        'perAcre': yieldPerAcre.toStringAsFixed(1),
        'yield': totalYield.toStringAsFixed(0),
        'confidence': confidence,
      };
    });
  }

  @override
  void dispose() {
    areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yield Prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: crop,
                    onChanged: (v) => setState(() => crop = v ?? 'wheat'),
                    items: _baseYields.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Crop',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  DropdownButtonFormField<String>(
                    initialValue: soilHealth,
                    onChanged: (v) =>
                        setState(() => soilHealth = v ?? 'good'),
                    items: ['poor', 'fair', 'good', 'excellent']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Soil Health',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: irrigationType,
                    onChanged: (v) =>
                        setState(() => irrigationType = v ?? 'drip'),
                    items: ['flood', 'sprinkler', 'drip']
                        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Irrigation Type',
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
                      child: const Text('Predict Yield'),
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
                    Text('Yield Forecast',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Per Acre', '${_result!['perAcre']} qtl'),
                    _resultRow('Total Yield', '${_result!['yield']} qtl'),
                    _resultRow('Confidence', _result!['confidence']),
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
