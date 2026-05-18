import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/buttons/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showGetStarted = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _showGetStarted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed farm photo
          CachedNetworkImage(
            imageUrl: kPhotoSplash,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
          ),
          // Dark overlay — bottom-heavy for text legibility
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xCC000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Brand mark
                Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(b),
                      child: Text(
                        'ClimaGrowth',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 10),
                    Text(
                      'Smart farming, beautifully done.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                  ],
                ),
                const Spacer(flex: 2),
                // Get Started button — only shows after auth check
                AnimatedOpacity(
                  opacity: _showGetStarted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kPaddingLarge),
                    child: PrimaryButton(
                      label: 'Get Started',
                      onPressed: _showGetStarted
                          ? () => Navigator.pushReplacementNamed(context, '/login')
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Demo link
                AnimatedOpacity(
                  opacity: _showGetStarted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: _showGetStarted
                        ? () => Navigator.pushReplacementNamed(context, '/home')
                        : null,
                    child: Text(
                      'Try without account →',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: kAmberLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Loading indicator while checking auth
                if (!_showGetStarted)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(kAmber),
                        minHeight: 2,
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
