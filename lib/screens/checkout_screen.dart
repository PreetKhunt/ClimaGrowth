import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int activeStep = 0;
  String selectedPaymentMethod = 'upi';

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: activeStep,
        onStepContinue: activeStep < 3
            ? () => setState(() => activeStep++)
            : () => _completeOrder(),
        onStepCancel:
            activeStep > 0 ? () => setState(() => activeStep--) : null,
        steps: [
          Step(
            title: const Text('Cart Review'),
            content: _buildCartReview(),
            isActive: activeStep >= 0,
          ),
          Step(
            title: const Text('Delivery Address'),
            content: _buildAddressForm(),
            isActive: activeStep >= 1,
          ),
          Step(
            title: const Text('Payment Method'),
            content: _buildPaymentOptions(),
            isActive: activeStep >= 2,
          ),
          Step(
            title: const Text('Order Review'),
            content: _buildOrderReview(),
            isActive: activeStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCartReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.items.map((item) => ListTile(
              title: Text(item['name']),
              subtitle: Text('₹${item['price']} x ${item['quantity']}'),
              trailing: Text('₹${item['price'] * item['quantity']}'),
            )),
        const Divider(),
        ListTile(
          title: const Text('Total'),
          trailing: Text(
            '₹${widget.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: mobileCtrl,
          decoration: InputDecoration(
            labelText: 'Mobile',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: pincodeCtrl,
          decoration: InputDecoration(
            labelText: 'Pincode',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: landmarkCtrl,
          decoration: InputDecoration(
            labelText: 'Landmark',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cityCtrl,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: stateCtrl,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _paymentMethodCard(
            'upi', 'UPI', 'Fast & Secure', Icons.qr_code_rounded),
        _paymentMethodCard('card', 'Credit/Debit Card', 'Visa, Mastercard',
            Icons.credit_card_rounded),
        _paymentMethodCard('netbanking', 'Net Banking', 'All major banks',
            Icons.account_balance_rounded),
        _paymentMethodCard('wallet', 'Digital Wallet', 'Paytm, Google Pay',
            Icons.account_balance_wallet_rounded),
        if (widget.totalAmount < 5000)
          _paymentMethodCard('cod', 'Cash on Delivery', 'Pay on delivery',
              Icons.local_shipping_rounded),
      ],
    );
  }

  Widget _paymentMethodCard(
      String value, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: kAmber),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Radio<String>(
            value: value,
            groupValue: selectedPaymentMethod,
            onChanged: (v) => setState(() => selectedPaymentMethod = v!),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderReview() {
    double gst = widget.totalAmount * 0.05;
    double delivery = widget.totalAmount > 1000 ? 0 : 50;
    double finalTotal = widget.totalAmount + gst + delivery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _summaryRow('Subtotal', '₹${widget.totalAmount.toStringAsFixed(0)}'),
        _summaryRow('GST (5%)', '₹${gst.toStringAsFixed(0)}'),
        _summaryRow('Delivery', '₹${delivery.toStringAsFixed(0)}'),
        const Divider(),
        _summaryRow('Final Total', '₹${finalTotal.toStringAsFixed(0)}',
            bold: true),
        const SizedBox(height: 20),
        Text('Payment Method: ${selectedPaymentMethod.toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              // Integrate Razorpay here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing payment...')),
              );
            },
            child: const Text('Pay Now'),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  void _completeOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    pincodeCtrl.dispose();
    addressCtrl.dispose();
    landmarkCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    super.dispose();
  }
}
