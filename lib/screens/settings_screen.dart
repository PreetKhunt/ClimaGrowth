import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: kPhotoSchemes, fit: BoxFit.cover),
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
                      const SizedBox(width: 12),
                      const Text('Settings',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      _sectionLabel('APPEARANCE'),
                      _glassSection([
                        _langTile(context, settings),
                        _divider(),
                        _switchTile(
                          icon: Icons.brightness_4_outlined,
                          label: 'Dark Mode',
                          value: settings.darkMode,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setDarkMode(v);
                          },
                        ),
                        _divider(),
                        _navTile(
                          context,
                          icon: Icons.palette_rounded,
                          label: 'UI Designer',
                          color: kAmber,
                          route: '/ui-designer',
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _sectionLabel('AI ASSISTANT'),
                      _glassSection([
                        _switchTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Concise Responses',
                          value: settings.conciseResponses,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setConciseResponses(v);
                          },
                        ),
                        _divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Text(
                            'ON: Short 1–3 sentence answers for simple questions.\nOFF: Allows detailed explanations (up to ~800 words).',
                            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _sectionLabel('NOTIFICATIONS'),
                      _glassSection([
                        _switchTile(
                          icon: Icons.thunderstorm_outlined,
                          label: 'Weather Alerts',
                          value: settings.notifPrefs[kNotifWeather] ?? true,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setNotifPref(kNotifWeather, v);
                          },
                        ),
                        _divider(),
                        _switchTile(
                          icon: Icons.water_drop_outlined,
                          label: 'Irrigation Reminders',
                          value: settings.notifPrefs[kNotifIrrigation] ?? true,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setNotifPref(kNotifIrrigation, v);
                          },
                        ),
                        _divider(),
                        _switchTile(
                          icon: Icons.tips_and_updates_outlined,
                          label: 'Farming Tips',
                          value: settings.notifPrefs[kNotifTips] ?? true,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setNotifPref(kNotifTips, v);
                          },
                        ),
                        _divider(),
                        _switchTile(
                          icon: Icons.storefront_outlined,
                          label: 'Market Updates',
                          value: settings.notifPrefs[kNotifMarket] ?? true,
                          onChanged: (v) {
                            HapticFeedback.lightImpact();
                            settings.setNotifPref(kNotifMarket, v);
                          },
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _sectionLabel('ACCOUNT'),
                      _glassSection([
                        _navTile(
                          context,
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          color: kOceanTeal,
                          route: '/profile',
                        ),
                        _divider(),
                        _navTile(
                          context,
                          icon: Icons.help_outline_rounded,
                          label: 'Help & Support',
                          color: kForestSage,
                          route: '/help',
                        ),
                        _divider(),
                        _navTile(
                          context,
                          icon: Icons.info_outline_rounded,
                          label: 'About ClimaGrowth',
                          color: kSunsetOrange,
                          onTap: () => _showAbout(context),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _sectionLabel('DANGER ZONE'),
                      _glassSection([
                        _dangerTile(
                          context,
                          icon: Icons.logout_rounded,
                          label: 'Sign Out',
                          color: kAmber,
                          onTap: () => _confirmLogout(context, auth),
                        ),
                        _divider(),
                        _dangerTile(
                          context,
                          icon: Icons.delete_forever_rounded,
                          label: 'Delete Account',
                          color: kCoral,
                          onTap: () => _confirmDelete(context, auth),
                        ),
                      ]),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'ClimaGrowth v1.0.0 · Padra, Gujarat, India',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ),
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Widget _glass({required Widget child, double radius = 16, EdgeInsetsGeometry? padding}) {
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

  static Widget _circleBtn({required VoidCallback onTap, required Widget icon}) {
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

  static Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
              color: Colors.white54, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 1.2,
            )),
      );

  static Widget _glassSection(List<Widget> children) => _glass(
        radius: 16,
        child: Column(children: children),
      );

  static Widget _divider() =>
      const Divider(height: 1, color: Color(0x28FFFFFF), indent: 50);

  static Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Builder(
      builder: (context) {
        final primary = Theme.of(context).colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: primary,
                activeTrackColor: primary.withAlpha(80),
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _langTile(BuildContext context, SettingsProvider settings) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showLangPicker(context, settings),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.language_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Language',
                    style: TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Text(kLanguages[settings.language] ?? 'English',
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  static void _showLangPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2B3C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white30, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Language',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...kLanguages.entries.map((e) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      settings.setLanguage(e.key);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Text(e.value,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          if (settings.language == e.key)
                            Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    String? route,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.pushNamed(context, route!),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
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
              Text(label,
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color.withAlpha(150), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context, AuthProvider auth) {
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

  void _confirmDelete(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This permanently deletes your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ClimaGrowth'),
        content: const Text(
            'Version 1.0.0\n\nAI-powered farming assistant for Gujarat farmers.\n\nBuilt with Flutter · Powered by Gemini AI · Data from Open-Meteo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
