import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SolarPumpCalc extends StatefulWidget {
  const SolarPumpCalc({super.key});

  @override
  State<SolarPumpCalc> createState() => _SolarPumpCalcState();
}

class _SolarPumpCalcState extends State<SolarPumpCalc> {
  final depthCtrl = TextEditingController();
  final waterNeedCtrl = TextEditingController();
  final sunshineCtrl = TextEditingController();
  final headCtrl = TextEditingController();

  String? _depthError;
  String? _waterError;
  String? _sunshineError;
  String? _headError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final depth = double.tryParse(depthCtrl.text.trim());
    final waterNeed = double.tryParse(waterNeedCtrl.text.trim());
    final sunshine = double.tryParse(sunshineCtrl.text.trim());
    final head = double.tryParse(headCtrl.text.trim());

    final depthErr =
        (depth == null || depth <= 0) ? 'Enter a valid positive depth' : null;
    final waterErr =
        (waterNeed == null || waterNeed <= 0) ? 'Enter a valid positive value' : null;
    final sunshineErr = (sunshine == null || sunshine <= 0 || sunshine > 24)
        ? 'Enter sunshine hours between 0 and 24'
        : null;
    final headErr =
        (head == null || head < 0) ? 'Enter 0 or a positive head value' : null;

    if (depthErr != null || waterErr != null ||
        sunshineErr != null || headErr != null) {
      setState(() {
        _depthError = depthErr;
        _waterError = waterErr;
        _sunshineError = sunshineErr;
        _headError = headErr;
        _result = null;
      });
      return;
    }

    // Convert depth from feet to meters (1 ft = 0.3048 m)
    final depthM = depth! * 0.3048;
    final totalHead = depthM + head!; // total dynamic head in meters
    // Power needed: P(kW) = (flow m³/s × head m × density × g) / efficiency
    // Simplified: HP = (water_m3/day × head_m) / (270 × efficiency)
    // water_m3/day = waterNeed / 1000
    final waterM3 = waterNeed! / 1000.0;
    const efficiency = 0.60; // 60% pump efficiency
    final pumpKW = (waterM3 * totalHead * 9.81) / (3600 * efficiency);
    final pumpHP = pumpKW / 0.746;
    // Solar panel kW needed = pump kW / sunshine hours
    final panelKW = pumpKW / sunshine!;
    // Cost estimate
    final cost = pumpHP * 50000 + panelKW * 100000;
    final payback = cost / 15000; // ₹15000/year savings on diesel

    debugPrint(
      'SolarPump: depth=${depth}ft (${depthM.toStringAsFixed(1)}m), '
      'waterNeed=${waterNeed}L/day (${waterM3.toStringAsFixed(2)}m³), '
      'head=${head}m, totalHead=${totalHead.toStringAsFixed(1)}m, sunshine=${sunshine}h, '
      'pumpHP=${pumpHP.toStringAsFixed(2)}, panelKW=${panelKW.toStringAsFixed(2)}, '
      'cost=₹${cost.toStringAsFixed(0)}, payback=${payback.toStringAsFixed(1)}yrs',
    );

    setState(() {
      _depthError = null;
      _waterError = null;
      _sunshineError = null;
      _headError = null;
      _result = {
        'pumpHP': pumpHP.toStringAsFixed(1),
        'panelKW': panelKW.toStringAsFixed(2),
        'cost': cost.toStringAsFixed(0),
        'payback': payback.toStringAsFixed(1),
      };
    });
  }

  @override
  void dispose() {
    depthCtrl.dispose();
    waterNeedCtrl.dispose();
    sunshineCtrl.dispose();
    headCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solar Pump Sizing')),
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
                    controller: depthCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Water Table Depth (ft)',
                      hintText: 'e.g. 100',
                      errorText: _depthError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: waterNeedCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Daily Water Need (liters)',
                      hintText: 'e.g. 10000',
                      errorText: _waterError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sunshineCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Peak Sunshine Hours / Day',
                      hintText: 'e.g. 6',
                      errorText: _sunshineError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: headCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Delivery Head (meters)',
                      hintText: 'e.g. 5  (0 if pumping to ground level)',
                      errorText: _headError,
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
                      child: const Text('Size System'),
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
                    Text('System Specification',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Pump Size Required', '${_result!['pumpHP']} HP'),
                    _resultRow('Solar Panel Capacity', '${_result!['panelKW']} kW'),
                    _resultRow('Estimated Cost', '₹${_result!['cost']}'),
                    _resultRow('Payback Period', '${_result!['payback']} years'),
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
