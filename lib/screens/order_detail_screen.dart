import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: ListView(
        padding: const EdgeInsets.all(kPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(order['orderId'] ?? 'N/A',
                              style: Theme.of(context).textTheme.labelLarge),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kForestSage.withAlpha(50),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          order['orderStatus']?.toUpperCase() ?? 'PLACED',
                          style: const TextStyle(
                              color: kForestSage,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeline',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _timelineItem('Order Placed', true, context),
                  _timelineItem(
                      'Packed', order['orderStatus'] != 'placed', context),
                  _timelineItem(
                      'Shipped',
                      order['orderStatus'] == 'shipped' ||
                          order['orderStatus'] == 'delivered',
                      context),
                  _timelineItem('Delivered',
                      order['orderStatus'] == 'delivered', context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(order['items']?[0]?['name'] ?? 'Product'),
                    subtitle:
                        Text('Qty: ${order['items']?[0]?['quantity'] ?? 1}'),
                    trailing: Text('₹${order['items']?[0]?['price'] ?? 0}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Address',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(order['address'] ?? 'N/A',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Breakdown',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _paymentRow('Subtotal', order['subtotal']?.toString() ?? '0',
                      context),
                  _paymentRow(
                      'GST (5%)',
                      ((order['subtotal'] ?? 0) * 0.05).toStringAsFixed(0),
                      context),
                  _paymentRow('Delivery', '0', context),
                  const Divider(),
                  _paymentRow(
                      'Total', order['total']?.toString() ?? '0', context,
                      bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (order['orderStatus'] != 'delivered' &&
              order['orderStatus'] != 'cancelled')
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled')),
                ),
                child: const Text('Cancel Order'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, bool completed, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: completed ? kForestSage : kTextMuted,
            child: completed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, BuildContext context,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text('₹$value',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}
