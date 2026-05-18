import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class FertilizerCalc extends StatefulWidget {
  const FertilizerCalc({super.key});

  @override
  State<FertilizerCalc> createState() => _FertilizerCalcState();
}

class _FertilizerCalcState extends State<FertilizerCalc> {
  final areaCtrl = TextEditingController();
  String stage = 'vegetative';
  String? _areaError;
  Map<String, dynamic>? _result;

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

    double urea, dap, potash;
    if (stage == 'vegetative') {
      urea = area! * 200;
      dap = area * 100;
      potash = area * 50;
    } else if (stage == 'flowering') {
      urea = area! * 100;
      dap = area * 150;
      potash = area * 150;
    } else {
      // fruiting
      urea = area! * 50;
      dap = area * 50;
      potash = area * 200;
    }

    final total = urea + dap + potash;
    // Approx cost: Urea ₹0.40/g, DAP ₹0.60/g, Potash ₹0.50/g
    final cost = (urea * 0.4) + (dap * 0.6) + (potash * 0.5);

    debugPrint(
      'Fertilizer: area=${area}acres, stage=$stage, '
      'urea=${urea.toStringAsFixed(0)}kg, dap=${dap.toStringAsFixed(0)}kg, '
      'potash=${potash.toStringAsFixed(0)}kg, total=${total.toStringAsFixed(0)}kg, '
      'cost=₹${cost.toStringAsFixed(0)}',
    );

    setState(() {
      _areaError = null;
      _result = {
        'urea': urea.toStringAsFixed(0),
        'dap': dap.toStringAsFixed(0),
        'potash': potash.toStringAsFixed(0),
        'total': total.toStringAsFixed(0),
        'cost': cost.toStringAsFixed(0),
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
      appBar: AppBar(title: const Text('Fertilizer Calculator')),
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
                  DropdownButtonFormField<String>(
                    value: stage,
                    onChanged: (v) => setState(() => stage = v ?? 'vegetative'),
                    items: ['vegetative', 'flowering', 'fruiting']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Growth Stage',
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
                    Text('Fertilizer Breakdown',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Urea', '${_result!['urea']} kg'),
                    _resultRow('DAP', '${_result!['dap']} kg'),
                    _resultRow('Potash', '${_result!['potash']} kg'),
                    const Divider(),
                    _resultRow('Total', '${_result!['total']} kg'),
                    _resultRow('Estimated Cost', '₹${_result!['cost']}'),
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
