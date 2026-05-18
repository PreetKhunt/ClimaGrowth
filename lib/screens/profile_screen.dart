import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget _glass({required Widget child, double radius = 20, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kGlassSigma, sigmaY: kGlassSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: kGlassColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: kGlassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _circleBtn({required VoidCallback onTap, required Widget icon}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: _glass(
          radius: 18,
          child: SizedBox(width: 36, height: 36, child: Center(child: icon)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: kPhotoSplash, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x44000000), Color(0xCC000000)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _circleBtn(
                        onTap: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                      const Spacer(),
                      _circleBtn(
                        onTap: () => _showEditSheet(context, auth, user),
                        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      _heroCard(user),
                      const SizedBox(height: 16),
                      _statsRow(user),
                      const SizedBox(height: 16),
                      _infoSection(
                        title: 'Personal Info',
                        items: [
                          (Icons.person_outline_rounded, 'Name',
                              user?.name.isNotEmpty == true ? user!.name : '—'),
                          (Icons.phone_outlined, 'Mobile',
                              user?.mobile.isNotEmpty == true ? user!.mobile : '—'),
                          (Icons.email_outlined, 'Email',
                              user?.email.isNotEmpty == true ? user!.email : '—'),
                          (Icons.location_on_outlined, 'Village', user?.village ?? 'Padra, Gujarat'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoSection(
                        title: 'Farm Details',
                        items: [
                          (Icons.landscape_outlined, 'Farm Size',
                              Formatters.acres(user?.farmSizeAcres ?? 1.0)),
                          (Icons.language_outlined, 'Language',
                              kLanguages[user?.language ?? 'en'] ?? 'English'),
                          (Icons.wb_sunny_outlined, 'Theme', _themeLabel(user?.theme)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _actionsSection(context, auth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(String? theme) {
    switch (theme) {
      case 'dark': return 'Dark';
      case 'system': return 'System';
      default: return 'Light';
    }
  }

  // ── Hero card ──────────────────────────────────────────────────────────────
  Widget _heroCard(UserModel? user) {
    final initials = user?.name.trim().isNotEmpty == true
        ? user!.name.trim().split(RegExp(r'\s+')).map((w) => w[0].toUpperCase()).take(2).join()
        : 'F';

    return _glass(
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          // Avatar with gradient ring
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kAmber, kIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A2B3C)),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 14),
          Text(
            user?.name.isNotEmpty == true ? user!.name : 'Farmer',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ).animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white60, size: 14),
              const SizedBox(width: 3),
              Text(
                user?.village.isNotEmpty == true ? user!.village : 'Padra, Gujarat',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ).animate(delay: 130.ms).fadeIn(),
          const SizedBox(height: 5),
          Text(
            'Member since ${Formatters.date(user?.createdAt ?? DateTime.now())}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ).animate(delay: 180.ms).fadeIn(),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _statsRow(UserModel? user) {
    return Row(
      children: [
        _statCard(
          value: user?.farmSizeAcres.toStringAsFixed(1) ?? '—',
          label: 'Acres',
          icon: Icons.landscape_outlined,
        ),
        const SizedBox(width: 10),
        _statCard(
          value: kLanguages[user?.language ?? 'en']?.split(' ').first ?? 'EN',
          label: 'Language',
          icon: Icons.language_outlined,
        ),
        const SizedBox(width: 10),
        _statCard(
          value: _themeLabel(user?.theme),
          label: 'Theme',
          icon: Icons.brightness_4_outlined,
        ),
      ],
    ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.12);
  }

  Widget _statCard({required String value, required String label, required IconData icon}) {
    return Expanded(
      child: _glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: kAmber, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Info sections ──────────────────────────────────────────────────────────
  Widget _infoSection({
    required String title,
    required List<(IconData, String, String)> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 1.2,
            ),
          ),
        ),
        _glass(
          radius: 16,
          child: Column(
            children: items.asMap().entries.map((e) {
              final (icon, label, value) = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Icon(icon, color: kAmber, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(value,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (e.key < items.length - 1)
                    const Divider(height: 1, color: Color(0x28FFFFFF), indent: 50),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Actions section ────────────────────────────────────────────────────────
  Widget _actionsSection(BuildContext context, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              color: Colors.white54, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 1.2,
            ),
          ),
        ),
        _glass(
          radius: 16,
          child: Column(
            children: [
              _actionRow(
                icon: Icons.settings_outlined, label: 'Settings',
                color: kOceanTeal,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const Divider(height: 1, color: Color(0x28FFFFFF), indent: 50),
              _actionRow(
                icon: Icons.help_outline_rounded, label: 'Help & Support',
                color: kForestSage,
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
              const Divider(height: 1, color: Color(0x28FFFFFF), indent: 50),
              _actionRow(
                icon: Icons.logout_rounded, label: 'Sign Out',
                color: kCoral, labelColor: kCoral,
                onTap: () => _confirmSignOut(context, auth),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String label,
    required Color color,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor ?? Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs / sheets ───────────────────────────────────────────────────────
  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, AuthProvider auth, UserModel? user) {
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final mobileCtrl = TextEditingController(text: user.mobile);
    final villageCtrl = TextEditingController(text: user.village);
    double farmSize = user.farmSizeAcres;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2B3C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Edit Profile',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _sheetField('Name', nameCtrl),
                const SizedBox(height: 12),
                _sheetField('Mobile', mobileCtrl, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _sheetField('Village', villageCtrl),
                const SizedBox(height: 16),
                Text(
                  'Farm Size: ${farmSize.toStringAsFixed(1)} acres',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Slider(
                  value: farmSize,
                  min: 0.5, max: 100,
                  divisions: 199,
                  activeColor: kAmber,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setS(() => farmSize = v),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = user.copyWith(
                        name: nameCtrl.text.trim(),
                        mobile: mobileCtrl.text.trim(),
                        village: villageCtrl.text.trim(),
                        farmSizeAcres: farmSize,
                      );
                      await auth.updateProfile(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAmber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
