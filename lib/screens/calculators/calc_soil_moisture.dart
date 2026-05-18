import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SoilMoistureCalc extends StatefulWidget {
  const SoilMoistureCalc({super.key});

  @override
  State<SoilMoistureCalc> createState() => _SoilMoistureCalcState();
}

class _SoilMoistureCalcState extends State<SoilMoistureCalc> {
  final currentMoistureCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  String soilType = 'loamy';

  String? _moistureError;
  String? _areaError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final currentMoisture = double.tryParse(currentMoistureCtrl.text.trim());
    final area = double.tryParse(areaCtrl.text.trim());

    final moistureErr = (currentMoisture == null ||
            currentMoisture < 0 ||
            currentMoisture > 100)
        ? 'Enter moisture % between 0 and 100'
        : null;
    final areaErr =
        (area == null || area <= 0) ? 'Enter a valid positive number' : null;

    if (moistureErr != null || areaErr != null) {
      setState(() {
        _moistureError = moistureErr;
        _areaError = areaErr;
        _result = null;
      });
      return;
    }

    double optimalMin, optimalMax;
    switch (soilType) {
      case 'clay':
        optimalMin = 40;
        optimalMax = 60;
        break;
      case 'sandy':
        optimalMin = 25;
        optimalMax = 35;
        break;
      default: // loamy
        optimalMin = 35;
        optimalMax = 50;
    }

    String status;
    if (currentMoisture! < optimalMin) {
      status = 'Dry – irrigate now';
    } else if (currentMoisture > optimalMax) {
      status = 'Wet – skip next irrigation';
    } else {
      status = 'Optimal – no action needed';
    }

    // Litres to bring to optimal midpoint, clamped to 0 if already optimal/wet
    final targetMoisture = (optimalMin + optimalMax) / 2;
    final deficit = targetMoisture - currentMoisture;
    final areaSqm = area! * 4046.0;
    // 1% moisture over 1 m² of soil to 0.3m depth ≈ 3 litres (simplified)
    final litresNeeded =
        deficit > 0 ? (deficit / 100) * areaSqm * 3.0 : 0.0;

    debugPrint(
      'SoilMoisture: soil=$soilType, current=$currentMoisture%, '
      'optimal=$optimalMin–$optimalMax%, area=${area}acres, '
      'deficit=$deficit%, status=$status, water=${litresNeeded.toStringAsFixed(0)}L',
    );

    setState(() {
      _moistureError = null;
      _areaError = null;
      _result = {
        'current': '${currentMoisture.toStringAsFixed(1)}%',
        'optimal': '$optimalMin% – $optimalMax%',
        'status': status,
        'litres': litresNeeded.toStringAsFixed(0),
      };
    });
  }

  @override
  void dispose() {
    currentMoistureCtrl.dispose();
    areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil Moisture')),
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
                    value: soilType,
                    onChanged: (v) => setState(() => soilType = v ?? 'loamy'),
                    items: ['clay', 'loamy', 'sandy']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Soil Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: currentMoistureCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Current Moisture (%)',
                      hintText: '0–100',
                      errorText: _moistureError,
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Check Moisture'),
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
                    Text('Moisture Status',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Current Moisture', _result!['current']),
                    _resultRow('Optimal Range', _result!['optimal']),
                    _resultRow('Status', _result!['status']),
                    const Divider(),
                    _resultRow(
                      'Water to Add',
                      int.parse(_result!['litres']) > 0
                          ? '${_result!['litres']} L'
                          : 'None needed',
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
