import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CropInsuranceCalc extends StatefulWidget {
  const CropInsuranceCalc({super.key});

  @override
  State<CropInsuranceCalc> createState() => _CropInsuranceCalcState();
}

class _CropInsuranceCalcState extends State<CropInsuranceCalc> {
  final areaCtrl = TextEditingController();
  String season = 'kharif';
  String crop = 'rice';
  String? _areaError;
  Map<String, dynamic>? _result;

  // PMFBY standard Sum Insured per acre (₹) by crop
  // Source: PMFBY guidelines – approximate MSP × threshold yield
  static const Map<String, double> _siPerAcre = {
    'rice': 35000,
    'wheat': 30000,
    'cotton': 45000,
    'groundnut': 25000,
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

    final siPerAcre = _siPerAcre[crop] ?? 35000.0;
    final totalSI = area! * siPerAcre; // total sum insured
    // PMFBY farmer premium: max 1.5% for kharif & rabi food crops
    const farmerRate = 0.015;
    final farmerPremium = totalSI * farmerRate;
    // Govt subsidises the rest of the actuarial premium (approx 10–15%)
    final govtSubsidy = totalSI * 0.13; // illustrative 13%
    final deadline =
        season == 'kharif' ? 'July 31' : 'December 31';

    debugPrint(
      'CropInsurance: area=${area}acres, crop=$crop, season=$season, '
      'SI/acre=₹$siPerAcre, totalSI=₹${totalSI.toStringAsFixed(0)}, '
      'farmerPremium=₹${farmerPremium.toStringAsFixed(0)}, '
      'govtSubsidy≈₹${govtSubsidy.toStringAsFixed(0)}, deadline=$deadline',
    );

    setState(() {
      _areaError = null;
      _result = {
        'si': totalSI.toStringAsFixed(0),
        'farmer': farmerPremium.toStringAsFixed(0),
        'govt': govtSubsidy.toStringAsFixed(0),
        'rate': '1.5%',
        'deadline': deadline,
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
      appBar: AppBar(title: const Text('Crop Insurance (PMFBY)')),
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
                    value: season,
                    onChanged: (v) => setState(() => season = v ?? 'kharif'),
                    items: ['kharif', 'rabi']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Season',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: crop,
                    onChanged: (v) => setState(() => crop = v ?? 'rice'),
                    items: _siPerAcre.keys
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Calculate Premium'),
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
                    Text('PMFBY Insurance Details',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Sum Insured (coverage)', '₹${_result!['si']}'),
                    _resultRow(
                        'Your Premium (${_result!['rate']})', '₹${_result!['farmer']}'),
                    _resultRow(
                        'Govt Subsidy (approx)', '₹${_result!['govt']}'),
                    const Divider(),
                    _resultRow('Enrollment Deadline', _result!['deadline']),
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
