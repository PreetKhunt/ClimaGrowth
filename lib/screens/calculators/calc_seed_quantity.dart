import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SeedQuantityCalc extends StatefulWidget {
  const SeedQuantityCalc({super.key});

  @override
  State<SeedQuantityCalc> createState() => _SeedQuantityCalcState();
}

class _SeedQuantityCalcState extends State<SeedQuantityCalc> {
  final areaCtrl = TextEditingController();
  final rowSpacingCtrl = TextEditingController();
  final plantSpacingCtrl = TextEditingController();

  String? _areaError;
  String? _rowError;
  String? _plantError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final area = double.tryParse(areaCtrl.text.trim());
    final rowSpacing = double.tryParse(rowSpacingCtrl.text.trim());
    final plantSpacing = double.tryParse(plantSpacingCtrl.text.trim());

    final areaErr =
        (area == null || area <= 0) ? 'Enter a valid positive number' : null;
    final rowErr = (rowSpacing == null || rowSpacing <= 0)
        ? 'Enter a valid positive spacing'
        : null;
    final plantErr = (plantSpacing == null || plantSpacing <= 0)
        ? 'Enter a valid positive spacing'
        : null;

    if (areaErr != null || rowErr != null || plantErr != null) {
      setState(() {
        _areaError = areaErr;
        _rowError = rowErr;
        _plantError = plantErr;
        _result = null;
      });
      return;
    }

    final areaSqm = area! * 4047.0; // acres to m²
    // Convert cm to m for spacing; plants per m² = 1 / (rowM × plantM)
    final rowM = rowSpacing! / 100.0;
    final plantM = plantSpacing! / 100.0;
    final plantsPerSqm = 1.0 / (rowM * plantM);
    final totalPlants = areaSqm * plantsPerSqm;
    final seedsNeeded = totalPlants * 1.1; // 10% buffer for germination loss
    final cost = seedsNeeded * 2; // approx ₹2 per seed

    debugPrint(
      'SeedQuantity: area=${area}acres, rowSpacing=${rowSpacing}cm, '
      'plantSpacing=${plantSpacing}cm, plantsPerSqm=${plantsPerSqm.toStringAsFixed(2)}, '
      'totalPlants=${totalPlants.toStringAsFixed(0)}, seeds=${seedsNeeded.toStringAsFixed(0)}, '
      'cost=₹${cost.toStringAsFixed(0)}',
    );

    setState(() {
      _areaError = null;
      _rowError = null;
      _plantError = null;
      _result = {
        'plants': totalPlants.toStringAsFixed(0),
        'seeds': seedsNeeded.toStringAsFixed(0),
        'cost': cost.toStringAsFixed(0),
      };
    });
  }

  @override
  void dispose() {
    areaCtrl.dispose();
    rowSpacingCtrl.dispose();
    plantSpacingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seed Quantity Calculator')),
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
                    controller: rowSpacingCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Row Spacing (cm)',
                      hintText: 'e.g. 60',
                      errorText: _rowError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: plantSpacingCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Plant Spacing (cm)',
                      hintText: 'e.g. 45',
                      errorText: _plantError,
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
                    Text('Seed Requirements',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Total Plants', _result!['plants']),
                    _resultRow('Seeds Needed (+10% buffer)', _result!['seeds']),
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
