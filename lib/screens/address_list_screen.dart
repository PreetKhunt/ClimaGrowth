import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../providers/address_provider.dart';
import '../utils/constants.dart';
import 'address_form_screen.dart';

class AddressListScreen extends StatefulWidget {
  /// Pass true from checkout to enable "select" mode (returns chosen address).
  final bool selectMode;

  const AddressListScreen({super.key, this.selectMode = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    final addresses = provider.addresses;

    return Scaffold(
      backgroundColor: kCineBg,
      appBar: AppBar(
        backgroundColor: kCineSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.selectMode ? 'Select Delivery Address' : 'My Addresses',
          style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (widget.selectMode && _selectedId != null)
            TextButton(
              onPressed: _confirmSelection,
              child: Text('CONFIRM',
                  style: GoogleFonts.syne(color: kCineGreen, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Add new address button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _addNew,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: kCineGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCineGreen.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_rounded, color: kCineGreen, size: 20),
                    const SizedBox(width: 8),
                    Text('Add New Address',
                        style: GoogleFonts.syne(
                          color: kCineGreen, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          if (addresses.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_outlined, color: kCineTextDim, size: 48),
                    const SizedBox(height: 14),
                    Text('No saved addresses',
                        style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Add your farm or home delivery address',
                        style: GoogleFonts.outfit(color: kCineTextDim, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final a = addresses[i];
                  final selected = _selectedId == a.id;
                  return _AddressCard(
                    address: a,
                    selectMode: widget.selectMode,
                    isSelected: selected,
                    index: i,
                    onTap: () {
                      if (widget.selectMode) {
                        setState(() => _selectedId = a.id);
                      }
                    },
                    onEdit: () => _editAddress(a),
                    onDelete: () => _deleteAddress(a),
                    onSetDefault: () => context.read<AddressProvider>().setDefault(a.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    final addr = context.read<AddressProvider>().addresses
        .firstWhere((a) => a.id == _selectedId);
    Navigator.pop(context, addr);
  }

  Future<void> _addNew() async {
    final addr = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );
    if (addr != null && widget.selectMode) {
      setState(() => _selectedId = addr.id);
    }
  }

  Future<void> _editAddress(DeliveryAddress a) async {
    await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(builder: (_) => AddressFormScreen(existing: a)),
    );
  }

  Future<void> _deleteAddress(DeliveryAddress a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCineSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Address?',
            style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('This address will be removed permanently.',
            style: GoogleFonts.outfit(color: kCineTextSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: kCineTextSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kCineOrange, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AddressProvider>().delete(a.id);
      if (_selectedId == a.id) setState(() => _selectedId = null);
    }
  }
}

// ── Address card widget ───────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool selectMode;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  static IconData _icon(String t) => switch (t) {
    'Farm' => Icons.agriculture_rounded,
    'Home' => Icons.home_rounded,
    _ => Icons.location_on_rounded,
  };

  static Color _typeColor(String t) => switch (t) {
    'Farm' => kCineGreen,
    'Home' => kCineBlue,
    _ => kCinePurple,
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(address.addressType);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : kCineCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : address.isDefault ? color.withOpacity(0.4) : kCineBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon orb
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Icon(_icon(address.addressType), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(address.addressType.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 9, fontWeight: FontWeight.w800,
                                    color: color, letterSpacing: 0.8)),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kCineGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('DEFAULT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9, fontWeight: FontWeight.w800,
                                      color: kCineGreen, letterSpacing: 0.8)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(address.fullName,
                            style: GoogleFonts.syne(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(address.mobile,
                            style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(address.formatted,
                            style: GoogleFonts.outfit(color: kCineTextSub, fontSize: 12),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),

                        // Action row
                        Row(
                          children: [
                            if (!address.isDefault)
                              _ActionChip(
                                label: 'Set Default',
                                icon: Icons.star_border_rounded,
                                color: kCineOrange,
                                onTap: onSetDefault,
                              ),
                            const Spacer(),
                            _ActionChip(
                              label: 'Edit',
                              icon: Icons.edit_rounded,
                              color: kCineBlue,
                              onTap: onEdit,
                            ),
                            const SizedBox(width: 8),
                            _ActionChip(
                              label: 'Delete',
                              icon: Icons.delete_outline_rounded,
                              color: kCineOrange,
                              onTap: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Select radio
                  if (selectMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AnimatedContainer(
                        duration: 180.ms,
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? color : Colors.transparent,
                          border: Border.all(color: isSelected ? color : kCineBorder, width: 2),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.black, size: 14)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).slideY(begin: 0.15);
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.outfit(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
