import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/supply_product.dart';
import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late PaymentService _paymentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = createPaymentService();
    _paymentService.onSuccess = _onPaymentSuccess;
    _paymentService.onError = _onPaymentError;
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(String paymentId, String orderId) async {
    if (!mounted) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final newOrderId = const Uuid().v4();
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(newOrderId)
          .set({
        'orderId': newOrderId,
        'userId': user?.uid ?? 'guest',
        'paymentId': paymentId,
        'items': cart.items
            .map((e) => {
                  'id': e.product.id,
                  'name': e.product.name,
                  'price': e.product.price,
                  'quantity': e.quantity,
                })
            .toList(),
        'subtotal': cart.totalPrice,
        'totalAmount': cart.totalPrice,
        'paymentStatus': 'paid',
        'orderStatus': 'placed',
        'placedAt': FieldValue.serverTimestamp(),
        'expectedDelivery':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
      });

      cart.clear();

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: newOrderId)),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order save failed: $e')),
        );
      }
    }
  }

  void _onPaymentError(String error) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handlePayNow() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    _paymentService.openCheckout(
      amountInRupees: cart.totalPrice,
      description: 'Order of ${cart.items.length} items',
      customerName: user?.displayName ?? 'Farmer',
      customerEmail: user?.email ?? 'test@climagrowth.com',
      customerPhone: user?.phoneNumber ?? '9999999999',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              Expanded(child: _buildItemsList(cart)),
              _buildPriceSummary(cart),
              _buildCheckoutButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse Market to add items',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Market'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(CartProvider cart) {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildCartItemCard(cart.items[index], cart),
    );
  }

  Widget _buildCartItemCard(CartItem item, CartProvider cart) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border.all(color: const Color.fromRGBO(0, 0, 0, 0.07), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.product.photoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.inventory_2_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.brand,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.product.price.toInt()}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quantity selector and remove
          Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => cart.remove(item.product.id),
                  child: Text(
                    'Remove',
                    style: TextStyle(fontSize: 12, color: Colors.red[600]),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () =>
                            cart.updateQty(item.product.id, item.quantity - 1),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(Icons.remove, size: 14),
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () =>
                            cart.updateQty(item.product.id, item.quantity + 1),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(Icons.add, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border.all(color: const Color.fromRGBO(0, 0, 0, 0.07), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${cart.totalPrice.toStringAsFixed(0)}'),
          const Divider(height: 16),
          _summaryRow('Delivery', 'Free', isHighlight: true),
          const Divider(height: 16),
          _summaryRow(
            'Total',
            '₹${cart.totalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isHighlight = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? Colors.green : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.w700,
            color: isTotal ? const Color(0xFFE55934) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _isProcessing ? null : _handlePayNow,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: _isProcessing
                  ? const Color(0xFFE55934).withOpacity(0.7)
                  : const Color(0xFFE55934),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Place Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
