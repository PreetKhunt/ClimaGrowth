import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: kSunnyGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kPaddingLarge),
            child: _sent ? _sentState(tt) : _formState(auth, tt),
          ),
        ),
      ),
    );
  }

  Widget _formState(AuthProvider auth, TextTheme tt) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(kPaddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kRadius),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_reset_rounded, size: 60, color: kPrimaryGreen),
                const SizedBox(height: 16),
                Text('Forgot Password?', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen)),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: tt.bodyMedium?.copyWith(color: kTextSecondaryLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: auth.loading ? null : _submit,
                  child: auth.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send Reset Link'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _sentState(TextTheme tt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 80, color: kPrimaryGreen)
            .animate()
            .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('Email Sent!', style: tt.displayMedium?.copyWith(color: kPrimaryGreen)),
        const SizedBox(height: 12),
        Text(
          'Check your inbox at ${_emailCtrl.text} and follow the instructions to reset your password.',
          style: tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().sendPasswordReset(_emailCtrl.text.trim());
    setState(() => _sent = true);
  }
}
