import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LoanEMICalc extends StatefulWidget {
  const LoanEMICalc({super.key});

  @override
  State<LoanEMICalc> createState() => _LoanEMICalcState();
}

class _LoanEMICalcState extends State<LoanEMICalc> {
  final loanCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final tenureCtrl = TextEditingController();

  String? _loanError;
  String? _rateError;
  String? _tenureError;
  Map<String, dynamic>? _result;

  void _calculate() {
    final p = double.tryParse(loanCtrl.text.trim());
    final annualRate = double.tryParse(rateCtrl.text.trim());
    final n = int.tryParse(tenureCtrl.text.trim());

    final loanErr =
        (p == null || p <= 0) ? 'Enter a valid positive amount' : null;
    final rateErr =
        (annualRate == null || annualRate < 0) ? 'Enter a valid rate (0 or above)' : null;
    final tenureErr =
        (n == null || n <= 0) ? 'Enter a valid positive number of months' : null;

    if (loanErr != null || rateErr != null || tenureErr != null) {
      setState(() {
        _loanError = loanErr;
        _rateError = rateErr;
        _tenureError = tenureErr;
        _result = null;
      });
      return;
    }

    final r = annualRate! / 12 / 100; // monthly interest rate

    double emi;
    if (r == 0) {
      // Interest-free loan: simple division
      emi = p! / n!;
    } else {
      // EMI = P × r × (1+r)^n / ((1+r)^n − 1)
      final compound = pow(1 + r, n!).toDouble();
      emi = p! * r * compound / (compound - 1);
    }

    final totalPayable = emi * n;
    final totalInterest = totalPayable - p;

    debugPrint(
      'LoanEMI: principal=₹$p, annualRate=$annualRate%, monthlyRate=$r, '
      'n=${n}months, EMI=₹${emi.toStringAsFixed(0)}, '
      'totalInterest=₹${totalInterest.toStringAsFixed(0)}, '
      'totalPayable=₹${totalPayable.toStringAsFixed(0)}',
    );

    setState(() {
      _loanError = null;
      _rateError = null;
      _tenureError = null;
      _result = {
        'emi': emi.toStringAsFixed(0),
        'interest': totalInterest.toStringAsFixed(0),
        'total': totalPayable.toStringAsFixed(0),
        'n': n,
      };
    });
  }

  @override
  void dispose() {
    loanCtrl.dispose();
    rateCtrl.dispose();
    tenureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan EMI Calculator')),
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
                    controller: loanCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Loan Amount (₹)',
                      errorText: _loanError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rateCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Annual Interest Rate (%)',
                      hintText: 'e.g. 9',
                      errorText: _rateError,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tenureCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tenure (months)',
                      hintText: 'e.g. 24 for 2 years',
                      errorText: _tenureError,
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
                      child: const Text('Calculate EMI'),
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
                    Text('EMI Breakdown',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _resultRow('Monthly EMI', '₹${_result!['emi']}'),
                    _resultRow('Total Interest', '₹${_result!['interest']}'),
                    _resultRow('Total Payable', '₹${_result!['total']}'),
                    _resultRow('Tenure', '${_result!['n']} months'),
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
