import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/address_model.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import 'address_form_screen.dart';
import 'address_list_screen.dart';
import 'order_success_screen.dart';

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
  int _step = 0;
  String _payMethod = 'upi';
  DeliveryAddress? _selectedAddress;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AddressProvider>();
      await provider.load();
      if (mounted) setState(() => _selectedAddress = provider.defaultAddress);
    });
  }

  // ── Navigation helpers ────────────────────────────────────────────────────
  void _next() {
    if (_step == 1 && _selectedAddress == null) {
      _snack('Please select a delivery address');
      return;
    }
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit()),
        backgroundColor: kCineSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Order placement ───────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      _snack('Please select a delivery address');
      return;
    }
    setState(() => _isSaving = true);

    try {
      final orderId = const Uuid().v4();
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': user?.uid ?? 'guest',
        'items': widget.items,
        'subtotal': widget.totalAmount,
        'totalAmount': widget.totalAmount,
        'paymentMethod': _payMethod,
        'paymentStatus': 'pending',
        'orderStatus': 'placed',
        'deliveryAddress': {
          'fullName': _selectedAddress!.fullName,
          'mobile': _selectedAddress!.mobile,
          'address': _selectedAddress!.formatted,
          'addressLine1': _selectedAddress!.addressLine1,
          'addressLine2': _selectedAddress!.addressLine2,
          'landmark': _selectedAddress!.landmark,
          'city': _selectedAddress!.city,
          'state': _selectedAddress!.state,
          'pincode': _selectedAddress!.pincode,
          'type': _selectedAddress!.addressType,
          'latitude': _selectedAddress!.latitude,
          'longitude': _selectedAddress!.longitude,
        },
        'placedAt': FieldValue.serverTimestamp(),
        'expectedDelivery': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 5))),
      });

      final cart = context.read<CartProvider>();
      cart.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: orderId)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _snack('Order save failed: $e');
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCineBg,
      appBar: AppBar(
        backgroundColor: kCineSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout',
            style: GoogleFonts.syne(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(current: _step),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: 300.ms,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(0.08, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _stepContent(),
              ),
            ),
          ),

          // Bottom nav
          _BottomNav(
            step: _step,
            canProceed: _step != 1 || _selectedAddress != null,
            isSaving: _isSaving,
            onBack: _back,
            onNext: _next,
            onPay: _placeOrder,
          ),
        ],
      ),
    );
  }

  Widget _stepContent() {
    return switch (_step) {
      0 => _CartReviewStep(items: widget.items, total: widget.totalAmount),
      1 => _AddressStep(
          selected: _selectedAddress,
          onChanged: (addr) => setState(() => _selectedAddress = addr),
        ),
      2 => _PaymentStep(
          selected: _payMethod,
          total: widget.totalAmount,
          onChanged: (m) => setState(() => _payMethod = m),
        ),
      _ => _OrderReviewStep(
          items: widget.items,
          total: widget.totalAmount,
          payMethod: _payMethod,
          address: _selectedAddress,
          onChangeAddress: () => setState(() => _step = 1),
        ),
    };
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  static const _labels = ['Cart', 'Address', 'Payment', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCineSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final step = i ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: 300.ms,
                height: 2,
                color: step < current ? kCineGreen : kCineBorder,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: 250.ms,
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? kCineGreen
                      : active
                          ? kCineGreen.withOpacity(0.15)
                          : kCineCard,
                  border: Border.all(
                    color: active || done ? kCineGreen : kCineBorder,
                    width: active ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : Text('${idx + 1}',
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? kCineGreen : kCineTextDim,
                          )),
                ),
              ),
              const SizedBox(height: 4),
              Text(_labels[idx],
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: active || done ? kCineGreen : kCineTextDim,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  )),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step 1: Cart review ───────────────────────────────────────────────────────
class _CartReviewStep extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double total;

  const _CartReviewStep({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...items.map((item) => _CinematicListTile(
              title: item['name'] as String? ?? '',
              subtitle: '₹${item['price']} × ${item['quantity']}',
              trailing: '₹${(item['price'] as num) * (item['quantity'] as num)}',
            )),
        const SizedBox(height: 12),
        _SummaryCard(subtotal: total),
      ],
    );
  }
}

// ── Step 2: Address ───────────────────────────────────────────────────────────
class _AddressStep extends StatelessWidget {
  final DeliveryAddress? selected;
  final ValueChanged<DeliveryAddress?> onChanged;

  const _AddressStep({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add new address button
        GestureDetector(
          onTap: () async {
            final addr = await Navigator.push<DeliveryAddress>(
              context,
              MaterialPageRoute(builder: (_) => const AddressFormScreen()),
            );
            if (addr != null) onChanged(addr);
          },
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: kCineGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kCineGreen.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: kCineGreen, size: 20),
                const SizedBox(width: 8),
                Text('Add New Address',
                    style: GoogleFonts.syne(
                        color: kCineGreen, fontWeight: FontWeight.w700, fontSize: 14)),
              ],
            ),
          ),
        ),

        if (addresses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.location_off_outlined, color: kCineTextDim, size: 48),
                  const SizedBox(height: 12),
                  Text('No saved addresses.\nAdd one above to continue.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: kCineTextSub)),
                ],
              ),
            ),
          )
        else ...[
          Text('Saved Addresses',
              style: GoogleFonts.outfit(
                  color: kCineTextSub, fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...addresses.map((a) {
            final isSel = selected?.id == a.id;
            return GestureDetector(
              onTap: () => onChanged(a),
              child: AnimatedContainer(
                duration: 180.ms,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSel ? kCineGreen.withOpacity(0.08) : kCineCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? kCineGreen : kCineBorder,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: 180.ms,
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel ? kCineGreen : Colors.transparent,
                        border: Border.all(
                            color: isSel ? kCineGreen : kCineBorder, width: 2),
                      ),
                      child: isSel
                          ? const Icon(Icons.check, color: Colors.black, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.fullName,
                                  style: GoogleFonts.syne(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: kCineCard,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(a.addressType,
                                    style: GoogleFonts.outfit(
                                        color: kCineTextSub,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(a.mobile,
                              style: GoogleFonts.outfit(
                                  color: kCineTextDim, fontSize: 12)),
                          Text(a.formatted,
                              style: GoogleFonts.outfit(
                                  color: kCineTextSub, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () async {
              final addr = await Navigator.push<DeliveryAddress>(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddressListScreen(selectMode: true)),
              );
              if (addr != null) onChanged(addr);
            },
            icon: Icon(Icons.list_rounded, color: kCineBlue, size: 16),
            label: Text('Manage all addresses',
                style: GoogleFonts.outfit(color: kCineBlue, fontSize: 13)),
          ),
        ],
      ],
    );
  }
}

// ── Step 3: Payment ───────────────────────────────────────────────────────────
class _PaymentStep extends StatelessWidget {
  final String selected;
  final double total;
  final ValueChanged<String> onChanged;

  const _PaymentStep({
    required this.selected,
    required this.total,
    required this.onChanged,
  });

  static const _methods = [
    ('upi', 'UPI / QR', 'Fast & Secure', Icons.qr_code_rounded),
    ('card', 'Card', 'Visa, Mastercard', Icons.credit_card_rounded),
    ('netbanking', 'Net Banking', 'All major banks', Icons.account_balance_rounded),
    ('wallet', 'Digital Wallet', 'Paytm, GPay', Icons.account_balance_wallet_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._methods.map((m) {
          final isSel = selected == m.$1;
          return GestureDetector(
            onTap: () => onChanged(m.$1),
            child: AnimatedContainer(
              duration: 180.ms,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSel ? kCineGreen.withOpacity(0.08) : kCineCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSel ? kCineGreen : kCineBorder,
                    width: isSel ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isSel ? kCineGreen : kCineTextSub).withOpacity(0.12),
                    ),
                    child: Icon(m.$4,
                        color: isSel ? kCineGreen : kCineTextSub, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.$2,
                            style: GoogleFonts.syne(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text(m.$3,
                            style: GoogleFonts.outfit(
                                color: kCineTextSub, fontSize: 12)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: 180.ms,
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? kCineGreen : Colors.transparent,
                      border: Border.all(
                          color: isSel ? kCineGreen : kCineBorder, width: 2),
                    ),
                    child: isSel
                        ? const Icon(Icons.check, color: Colors.black, size: 12)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
        if (total < 5000)
          GestureDetector(
            onTap: () => onChanged('cod'),
            child: AnimatedContainer(
              duration: 180.ms,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected == 'cod' ? kCineOrange.withOpacity(0.08) : kCineCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected == 'cod' ? kCineOrange : kCineBorder,
                    width: selected == 'cod' ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (selected == 'cod' ? kCineOrange : kCineTextSub)
                          .withOpacity(0.12),
                    ),
                    child: Icon(Icons.local_shipping_rounded,
                        color: selected == 'cod' ? kCineOrange : kCineTextSub,
                        size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cash on Delivery',
                            style: GoogleFonts.syne(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text('Pay when delivered',
                            style: GoogleFonts.outfit(
                                color: kCineTextSub, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Step 4: Order review ──────────────────────────────────────────────────────
class _OrderReviewStep extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final String payMethod;
  final DeliveryAddress? address;
  final VoidCallback onChangeAddress;

  const _OrderReviewStep({
    required this.items,
    required this.total,
    required this.payMethod,
    required this.address,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    final gst = total * 0.05;
    final delivery = total > 1000 ? 0.0 : 50.0;
    final finalTotal = total + gst + delivery;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Delivery address card
        if (address != null)
          _CineCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: kCineGreen, size: 18),
                    const SizedBox(width: 8),
                    Text('Deliver to',
                        style: GoogleFonts.syne(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onChangeAddress,
                      child: Text('Change',
                          style: GoogleFonts.outfit(
                              color: kCineGreen, fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(address!.fullName,
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(address!.mobile,
                    style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 13)),
                Text(address!.formatted,
                    style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 14),

        // Items
        _CineCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items',
                  style: GoogleFonts.syne(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 10),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item['name']} × ${item['quantity']}',
                              style: GoogleFonts.outfit(
                                  color: kCineTextSub, fontSize: 13)),
                        ),
                        Text(
                          '₹${(item['price'] as num) * (item['quantity'] as num)}',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Totals
        _CineCard(
          child: Column(
            children: [
              _SummaryRow('Subtotal', '₹${total.toStringAsFixed(0)}'),
              _SummaryRow('GST (5%)', '₹${gst.toStringAsFixed(0)}'),
              _SummaryRow('Delivery', delivery == 0 ? 'Free' : '₹50'),
              Divider(color: kCineBorder, height: 20),
              _SummaryRow('Total', '₹${finalTotal.toStringAsFixed(0)}', bold: true),
              const SizedBox(height: 6),
              _SummaryRow('Payment', payMethod.toUpperCase(), accent: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int step;
  final bool canProceed;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onPay;

  const _BottomNav({
    required this.step,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.onPay,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCineSurface,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: kCineCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kCineBorder),
                  ),
                  child: Center(
                    child: Text('Back',
                        style: GoogleFonts.syne(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          if (step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: (canProceed && !isSaving) ? (step == 3 ? onPay : onNext) : null,
              child: AnimatedContainer(
                duration: 200.ms,
                height: 50,
                decoration: BoxDecoration(
                  gradient: canProceed
                      ? const LinearGradient(
                          colors: [kCineGreen, Color(0xFF00CC6A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: canProceed ? null : kCineTextDim,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canProceed
                      ? [BoxShadow(color: kGlowGreen, blurRadius: 16, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Center(
                  child: isSaving && step == 3
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2),
                        )
                      : Text(
                          step == 3 ? 'Pay Now' : 'Continue',
                          style: GoogleFonts.syne(
                              color: kCineBg,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared UI components ──────────────────────────────────────────────────────
class _CineCard extends StatelessWidget {
  final Widget child;
  const _CineCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCineCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCineBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CinematicListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _CinematicListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _CineCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle,
                      style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 12)),
                ],
              ),
            ),
            Text(trailing,
                style: GoogleFonts.syne(
                    color: kCineGreen, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double subtotal;
  const _SummaryCard({required this.subtotal});

  @override
  Widget build(BuildContext context) {
    final gst = subtotal * 0.05;
    final delivery = subtotal > 1000 ? 0.0 : 50.0;
    return _CineCard(
      child: Column(
        children: [
          _SummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          _SummaryRow('GST (5%)', '₹${gst.toStringAsFixed(0)}'),
          _SummaryRow('Delivery', delivery == 0 ? 'Free' : '₹50'),
          Divider(color: kCineBorder, height: 20),
          _SummaryRow('Total', '₹${(subtotal + gst + delivery).toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool accent;

  const _SummaryRow(this.label, this.value, {this.bold = false, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: kCineTextSub,
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: GoogleFonts.syne(
                  color: accent ? kCineBlue : bold ? Colors.white : kCineTextSub,
                  fontSize: bold ? 16 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }
}
