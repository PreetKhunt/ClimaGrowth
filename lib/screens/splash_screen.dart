import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/cinematic/ambient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showGetStarted = false;
  late final AnimationController _logoCtrl;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: 1600.ms)..forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(3200.ms);
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
      backgroundColor: kCineBg,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _LogoSection(ctrl: _logoCtrl),
              const Spacer(flex: 3),
              _BottomSection(showGetStarted: _showGetStarted),
              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo section ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final AnimationController ctrl;
  const _LogoSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow ring + monogram
        _GlowRing()
            .animate()
            .fadeIn(duration: 700.ms)
            .scale(begin: const Offset(0.75, 0.75), curve: Curves.easeOutBack),

        const SizedBox(height: 36),

        // App name — shimmer-gradient reveal
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFD0D8E8), Colors.white],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'ClimaGrowth',
            style: GoogleFonts.syne(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.8,
            ),
          ),
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 700.ms)
            .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 10),

        // Sub-title — tracked out caps
        Text(
          'CLIMATE  INTELLIGENCE  PLATFORM',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: kCineTextSub,
            letterSpacing: 3.8,
          ),
        ).animate(delay: 650.ms).fadeIn(duration: 600.ms),

        const SizedBox(height: 8),

        // Version pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: kCineCard,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: kCineBorder, width: 1),
          ),
          child: Text(
            'v2.0 · Powered by Gemini AI',
            style: GoogleFonts.figtree(
              fontSize: 11, color: kCineTextDim, fontWeight: FontWeight.w500),
          ),
        ).animate(delay: 900.ms).fadeIn(duration: 500.ms),
      ],
    );
  }
}

// Glow ring with "CG" monogram
class _GlowRing extends StatefulWidget {
  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: 2400.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final glow = 0.25 + _pulse.value * 0.40;
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [kCineGreen, kCineBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: kCineGreen.withOpacity(glow),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: kCineBlue.withOpacity(glow * 0.6),
                blurRadius: 56,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'CG',
              style: GoogleFonts.syne(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: kCineBg,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Bottom section ────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final bool showGetStarted;
  const _BottomSection({required this.showGetStarted});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 500.ms,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      child: showGetStarted
          ? _GetStarted(key: const ValueKey('cta'))
          : _Initializing(key: const ValueKey('init')),
    );
  }
}

// Animated loading state
class _Initializing extends StatefulWidget {
  const _Initializing({super.key});

  @override
  State<_Initializing> createState() => _InitializingState();
}

class _InitializingState extends State<_Initializing> {
  static const _msgs = [
    'Connecting to climate systems...',
    'Loading weather intelligence...',
    'Syncing farm data...',
    'Almost ready...',
  ];
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() async {
    while (mounted) {
      await Future.delayed(780.ms);
      if (mounted) setState(() => _idx = (_idx + 1) % _msgs.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin scanning progress bar
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              backgroundColor: kCineCard,
              valueColor: const AlwaysStoppedAnimation<Color>(kCineGreen),
              minHeight: 2,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: 350.ms,
          child: Text(
            _msgs[_idx],
            key: ValueKey(_idx),
            style: GoogleFonts.figtree(
              fontSize: 13, color: kCineTextSub, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ).animate(delay: 600.ms).fadeIn(duration: 500.ms);
  }
}

// Get-started CTA
class _GetStarted extends StatelessWidget {
  const _GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlowCTAButton(
            label: 'Get Started',
            color: kCineGreen,
            glowColor: kGlowGreen,
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 14),
          _GlowCTAButton(
            label: 'Explore without account',
            color: Colors.transparent,
            glowColor: Colors.transparent,
            textColor: kCineTextSub,
            borderColor: kCineBorder,
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ],
      ),
    );
  }
}

class _GlowCTAButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color glowColor;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _GlowCTAButton({
    required this.label,
    required this.color,
    required this.glowColor,
    this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  State<_GlowCTAButton> createState() => _GlowCTAButtonState();
}

class _GlowCTAButtonState extends State<_GlowCTAButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.color == Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_)  => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 180.ms,
          height: 56,
          decoration: BoxDecoration(
            gradient: isGhost
                ? null
                : LinearGradient(
                    colors: _hovered
                        ? [const Color(0xFF00CC6A), kCineGreen]
                        : [kCineGreen, const Color(0xFF00CC6A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: isGhost ? kCineCard : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.borderColor ?? Colors.transparent,
              width: 1,
            ),
            boxShadow: isGhost
                ? null
                : [
                    BoxShadow(
                      color: widget.glowColor
                          .withOpacity(_hovered ? 0.55 : 0.30),
                      blurRadius: _hovered ? 28 : 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.textColor ?? kCineBg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
