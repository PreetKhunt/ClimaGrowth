import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  // Hardcoded admin credentials for demo
  static const _adminEmail = 'khuntpreet12@gmail.com';
  static const _adminPass = 'Preet12.!';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (_emailCtrl.text.trim() == _adminEmail && _passCtrl.text == _adminPass) {
      if (mounted) Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } else {
      setState(() { _error = 'Invalid admin credentials.'; });
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: kPhotoSchemes, fit: BoxFit.cover),
          Container(
            color: const Color(0xCC000000),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / title
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: kGlassColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kGlassBorder),
                          ),
                          child: const Center(
                            child: Icon(Icons.admin_panel_settings_rounded,
                                color: kAmber, size: 36),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Admin Panel',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('ClimaGrowth · Restricted Access',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 32),
                    // Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: kGlassColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kGlassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _field('Admin Email', _emailCtrl,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 14),
                              _field('Password', _passCtrl,
                                  icon: Icons.lock_outline_rounded,
                                  obscure: _obscure,
                                  suffixIcon: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _obscure = !_obscure),
                                      child: Icon(
                                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.white54, size: 20,
                                      ),
                                    ),
                                  )),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: kCoral.withAlpha(40),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: kCoral, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_error!,
                                            style: const TextStyle(color: kCoral, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _loading ? null : _login,
                                  child: Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: kButtonGradient),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: Colors.white))
                                          : const Text('Sign In',
                                              style: TextStyle(color: Colors.white,
                                                  fontSize: 15, fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('← Back to App',
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          cursorColor: kAmber,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}
