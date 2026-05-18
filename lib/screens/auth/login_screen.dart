import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _otpSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: kBgPrimary,
      body: Stack(
        children: [
          // Ambient orb top-right
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kAccentGreen.withOpacity(0.14), Colors.transparent],
                ),
              ),
            ),
          ),
          // Ambient orb bottom-left
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kSkyBlue.withOpacity(0.10), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Logo + title
                  _Header().animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                  const SizedBox(height: 36),

                  // Glass form card
                  _GlassFormCard(
                    tabs: _tabs,
                    formKey: _formKey,
                    emailTab: _emailTab(auth),
                    otpTab: _otpTab(auth),
                  ).animate(delay: 150.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

                  // Error banner
                  if (auth.error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: auth.error!, onDismiss: auth.clearError)
                        .animate()
                        .fadeIn(duration: 300.ms),
                  ],

                  const SizedBox(height: 20),

                  // Demo mode
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Try Demo (No Login Required)'),
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.dmSans(fontSize: 14, color: kTextMuted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: kAccentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailTab(AuthProvider auth) {
    return Column(
      children: [
        TextFormField(
          controller: _emailCtrl,
          validator: Validators.email,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.dmSans(color: kTextPrimary),
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: kAccentGreen),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passCtrl,
          validator: Validators.password,
          obscureText: _obscure,
          style: GoogleFonts.dmSans(color: kTextPrimary),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: kAccentGreen),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: kTextMuted,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.dmSans(color: kAccentGreen, fontSize: 13),
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: auth.loading ? null : _signInEmail,
          child: auth.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Login'),
        ),
      ],
    );
  }

  Widget _otpTab(AuthProvider auth) {
    return Column(
      children: [
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.dmSans(color: kTextPrimary),
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            prefixText: '+91 ',
            prefixIcon: Icon(Icons.phone_outlined, color: kAccentGreen),
          ),
        ),
        if (_otpSent) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            style: GoogleFonts.dmSans(color: kTextPrimary),
            decoration: const InputDecoration(
              labelText: 'Enter OTP',
              prefixIcon: Icon(Icons.sms_outlined, color: kAccentGreen),
              counterText: '',
            ),
          ),
        ],
        const Spacer(),
        ElevatedButton(
          onPressed: auth.loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
          child: auth.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_otpSent ? 'Verify & Login' : 'Send OTP'),
        ),
      ],
    );
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final ok = await context.read<AuthProvider>().signInWithEmail(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length < 10) return;
    HapticFeedback.mediumImpact();
    final phone = '+91${_phoneCtrl.text.trim()}';
    await context.read<AuthProvider>().verifyPhone(
      phone: phone,
      codeSent: (vid, _) => setState(() {
        _verificationId = vid;
        _otpSent = true;
      }),
      verificationFailed: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null || _otpCtrl.text.length != 6) return;
    HapticFeedback.mediumImpact();
    final ok = await context.read<AuthProvider>().confirmOtp(
      _verificationId!,
      _otpCtrl.text,
    );
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glowing icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF0A3D20), Color(0xFF0A2410)],
            ),
            border: Border.all(color: kAccentGreen.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(color: kAccentGreen.withOpacity(0.25), blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: const Icon(Icons.eco_rounded, size: 36, color: kAccentGreen),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Colors.white, kMint, kAccentGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(b),
          child: Text(
            'ClimaGrowth',
            style: GoogleFonts.sora(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Farming with AI',
          style: GoogleFonts.dmSans(fontSize: 13, color: kTextMuted),
        ),
      ],
    );
  }
}

class _GlassFormCard extends StatelessWidget {
  final TabController tabs;
  final GlobalKey<FormState> formKey;
  final Widget emailTab;
  final Widget otpTab;

  const _GlassFormCard({
    required this.tabs,
    required this.formKey,
    required this.emailTab,
    required this.otpTab,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              // Tabs
              TabBar(
                controller: tabs,
                labelColor: kAccentGreen,
                unselectedLabelColor: kTextMuted,
                indicatorColor: kAccentGreen,
                dividerColor: Colors.white.withOpacity(0.08),
                labelStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
                tabs: const [
                  Tab(text: 'Email Login'),
                  Tab(text: 'OTP Login'),
                ],
              ),
              Container(height: 1, color: Colors.white.withOpacity(0.06)),
              Padding(
                padding: const EdgeInsets.all(kPaddingLarge),
                child: Form(
                  key: formKey,
                  child: SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: tabs,
                      children: [emailTab, otpTab],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kDangerRed.withOpacity(0.10),
        borderRadius: BorderRadius.circular(kRadiusSmall),
        border: Border.all(color: kDangerRed.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: kDangerRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(color: kDangerRed, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: kDangerRed, size: 18),
          ),
        ],
      ),
    );
  }
}
