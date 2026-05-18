import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProfitMarginCalc extends StatefulWidget {
  const ProfitMarginCalc({super.key});

  @override
  State<ProfitMarginCalc> createState() => _ProfitMarginCalcState();
}

class _ProfitMarginCalcState extends State<ProfitMarginCalc> {
  // Expense controllers (optional, default 0)
  final seedCtrl = TextEditingController();
  final fertilizerCtrl = TextEditingController();
  final laborCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final transportCtrl = TextEditingController();

  // Revenue controllers (required)
  final areaCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();

  String? _areaError;
  String? _priceError;
  String? _quantityError;
  Map<String, dynamic>? _result;

  void _calculate() {
    // Expenses are optional – treat blank/invalid as 0
    final seed = double.tryParse(seedCtrl.text.trim()) ?? 0;
    final fertilizer = double.tryParse(fertilizerCtrl.text.trim()) ?? 0;
    final labor = double.tryParse(laborCtrl.text.trim()) ?? 0;
    final water = double.tryParse(waterCtrl.text.trim()) ?? 0;
    final transport = double.tryParse(transportCtrl.text.trim()) ?? 0;

    // Revenue fields are required
    final area = double.tryParse(areaCtrl.text.trim());
    final price = double.tryParse(priceCtrl.text.trim());
    final quantity = double.tryParse(quantityCtrl.text.trim());

    final areaErr =
        (area == null || area <= 0) ? 'Enter a valid positive number' : null;
    final priceErr =
        (price == null || price <= 0) ? 'Enter a valid positive number' : null;
    final quantityErr =
        (quantity == null || quantity <= 0) ? 'Enter a valid positive number' : null;

    if (areaErr != null || priceErr != null || quantityErr != null) {
      setState(() {
        _areaError = areaErr;
        _priceError = priceErr;
        _quantityError = quantityErr;
        _result = null;
      });
      return;
    }

    final totalCost = seed + fertilizer + labor + water + transport;
    final totalRevenue = price! * quantity!;
    final netProfit = totalRevenue - totalCost;
    final profitPerAcre = netProfit / area!;
    final breakEvenPrice = totalCost / quantity; // per unit
    final marginPct = totalRevenue > 0 ? (netProfit / totalRevenue * 100) : 0.0;

    debugPrint(
      'ProfitMargin: area=${area}acres, qty=${quantity}units, price=₹$price/unit, '
      'totalCost=₹${totalCost.toStringAsFixed(0)}, revenue=₹${totalRevenue.toStringAsFixed(0)}, '
      'profit=₹${netProfit.toStringAsFixed(0)}, margin=${marginPct.toStringAsFixed(1)}%',
    );

    setState(() {
      _areaError = null;
      _priceError = null;
      _quantityError = null;
      _result = {
        'cost': totalCost.toStringAsFixed(0),
        'revenue': totalRevenue.toStringAsFixed(0),
        'profit': netProfit.toStringAsFixed(0),
        'perAcre': profitPerAcre.toStringAsFixed(0),
        'breakEven': breakEvenPrice.toStringAsFixed(0),
        'margin': marginPct.toStringAsFixed(1),
      };
    });
  }

  @override
  void dispose() {
    seedCtrl.dispose();
    fertilizerCtrl.dispose();
    laborCtrl.dispose();
    waterCtrl.dispose();
    transportCtrl.dispose();
    areaCtrl.dispose();
    priceCtrl.dispose();
    quantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profit Margin Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expenses (₹) – leave blank if zero',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  _expenseField(seedCtrl, 'Seeds'),
                  const SizedBox(height: 8),
                  _expenseField(fertilizerCtrl, 'Fertilizer'),
                  const SizedBox(height: 8),
                  _expenseField(laborCtrl, 'Labor'),
                  const SizedBox(height: 8),
                  _expenseField(waterCtrl, 'Water'),
                  const SizedBox(height: 8),
                  _expenseField(transportCtrl, 'Transport'),
                  const SizedBox(height: 16),
                  Text('Revenue (₹) – required',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: areaCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Area (acres) *',
                      errorText: _areaError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price per unit (₹) *',
                      errorText: _priceError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantityCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quantity sold (units) *',
                      errorText: _quantityError,
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
                    Text('Profit Analysis',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Total Cost', '₹${_result!['cost']}'),
                    _resultRow('Total Revenue', '₹${_result!['revenue']}'),
                    const Divider(),
                    _resultRow('Net Profit', '₹${_result!['profit']}'),
                    _resultRow('Profit Margin', '${_result!['margin']}%'),
                    _resultRow('Profit per Acre', '₹${_result!['perAcre']}'),
                    _resultRow('Break-even Price/unit', '₹${_result!['breakEven']}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _expenseField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
