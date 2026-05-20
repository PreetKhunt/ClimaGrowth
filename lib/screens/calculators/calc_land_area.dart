import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LandAreaCalc extends StatefulWidget {
  const LandAreaCalc({super.key});

  @override
  State<LandAreaCalc> createState() => _LandAreaCalcState();
}

class _LandAreaCalcState extends State<LandAreaCalc> {
  final valueCtrl = TextEditingController();
  String fromUnit = 'acres';
  String toUnit = 'hectares';
  String? _valueError;
  double? _result;

  // All conversions via sqm as base unit.
  // Gujarat bigha: 1 hectare = 4 bigha → 1 bigha = 2500 sqm
  static const Map<String, double> _toSqm = {
    'acres': 4046.86,
    'hectares': 10000.0,
    'bigha': 2500.0,
    'guntha': 101.17,
    'sqm': 1.0,
  };

  void _calculate() {
    final value = double.tryParse(valueCtrl.text.trim());
    final valueErr =
        (value == null || value <= 0) ? 'Enter a valid positive number' : null;

    if (valueErr != null) {
      setState(() {
        _valueError = valueErr;
        _result = null;
      });
      return;
    }

    final fromFactor = _toSqm[fromUnit]!;
    final toFactor = _toSqm[toUnit]!;
    final resultValue = value! * fromFactor / toFactor;

    debugPrint(
      'LandArea: $value $fromUnit = ${resultValue.toStringAsFixed(6)} $toUnit '
      '(via sqm: ${(value * fromFactor).toStringAsFixed(2)} m²)',
    );

    setState(() {
      _valueError = null;
      _result = resultValue;
    });
  }

  @override
  void dispose() {
    valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Land Area Converter')),
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
                    controller: valueCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Enter value',
                      errorText: _valueError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: fromUnit,
                          onChanged: (v) =>
                              setState(() => fromUnit = v ?? 'acres'),
                          items: _toSqm.keys
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: kAmber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: toUnit,
                          onChanged: (v) =>
                              setState(() => toUnit = v ?? 'hectares'),
                          items: _toSqm.keys
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Convert'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gujarat bigha = 2500 m² (¼ hectare)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
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
                    Text('Conversion Result',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            valueCtrl.text,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                    color: kAmber,
                                    fontWeight: FontWeight.w700),
                          ),
                          Text(fromUnit,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          const Icon(Icons.arrow_downward_rounded),
                          const SizedBox(height: 8),
                          Text(
                            _result!.toStringAsFixed(4),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                    color: kAmber,
                                    fontWeight: FontWeight.w700),
                          ),
                          Text(toUnit,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
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
}
