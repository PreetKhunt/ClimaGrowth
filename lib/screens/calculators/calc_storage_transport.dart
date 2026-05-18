import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StorageTransportCalc extends StatefulWidget {
  const StorageTransportCalc({super.key});

  @override
  State<StorageTransportCalc> createState() => _StorageTransportCalcState();
}

class _StorageTransportCalcState extends State<StorageTransportCalc> {
  final quantityCtrl = TextEditingController();
  final monthsCtrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  String storageType = 'warehouse';
  String crop = 'wheat';

  String? _quantityError;
  String? _monthsError;
  String? _distanceError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final quantity = double.tryParse(quantityCtrl.text.trim());
    final months = int.tryParse(monthsCtrl.text.trim());
    final distance = double.tryParse(distanceCtrl.text.trim());

    final quantityErr =
        (quantity == null || quantity <= 0) ? 'Enter a valid positive number' : null;
    final monthsErr =
        (months == null || months <= 0) ? 'Enter a valid positive number of months' : null;
    final distanceErr =
        (distance == null || distance < 0) ? 'Enter 0 or a positive distance' : null;

    if (quantityErr != null || monthsErr != null || distanceErr != null) {
      setState(() {
        _quantityError = quantityErr;
        _monthsError = monthsErr;
        _distanceError = distanceErr;
        _result = null;
      });
      return;
    }

    // Storage cost: ₹5/quintal/month (warehouse), ₹8/quintal/month (cold storage)
    final ratePerQtlMonth = storageType == 'warehouse' ? 5.0 : 8.0;
    final storageCost = quantity! * ratePerQtlMonth * months!;

    // Transport cost: ₹10/quintal per 100 km
    final transportCost = quantity * 10.0 * (distance! / 100.0);
    final totalCost = storageCost + transportCost;

    // Minimum holding period recommendation
    const optimalTime = 'Hold 4–6 weeks after harvest for best price';

    debugPrint(
      'StorageTransport: crop=$crop, quantity=${quantity}qtl, months=$months, '
      'storageType=$storageType, distance=${distance}km, '
      'storageCost=₹${storageCost.toStringAsFixed(0)}, '
      'transportCost=₹${transportCost.toStringAsFixed(0)}, '
      'totalCost=₹${totalCost.toStringAsFixed(0)}',
    );

    setState(() {
      _quantityError = null;
      _monthsError = null;
      _distanceError = null;
      _result = {
        'storage': storageCost.toStringAsFixed(0),
        'transport': transportCost.toStringAsFixed(0),
        'total': totalCost.toStringAsFixed(0),
        'optimalTime': optimalTime,
      };
    });
  }

  @override
  void dispose() {
    quantityCtrl.dispose();
    monthsCtrl.dispose();
    distanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage & Transport')),
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
                    value: crop,
                    onChanged: (v) => setState(() => crop = v ?? 'wheat'),
                    items: ['wheat', 'rice', 'cotton', 'groundnut']
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
                    controller: quantityCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quantity (quintals)',
                      errorText: _quantityError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: monthsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Storage Duration (months)',
                      errorText: _monthsError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: storageType,
                    onChanged: (v) =>
                        setState(() => storageType = v ?? 'warehouse'),
                    items: [
                      const DropdownMenuItem(
                          value: 'warehouse', child: Text('Warehouse – ₹5/qtl/mo')),
                      const DropdownMenuItem(
                          value: 'cold_storage',
                          child: Text('Cold Storage – ₹8/qtl/mo')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Storage Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: distanceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Distance to Market (km)',
                      hintText: 'Enter 0 if no transport',
                      errorText: _distanceError,
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
                      child: const Text('Calculate Cost'),
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
                    Text('Cost Breakdown',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Storage Cost', '₹${_result!['storage']}'),
                    _resultRow('Transport Cost', '₹${_result!['transport']}'),
                    const Divider(),
                    _resultRow('Total Cost', '₹${_result!['total']}'),
                    _resultRow('Advisory', _result!['optimalTime']),
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
