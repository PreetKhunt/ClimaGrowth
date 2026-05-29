import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Full-screen animated background with drifting glow orbs and particles.
/// Wraps any child widget without blocking interaction.
class AmbientBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const AmbientBackground({
    super.key,
    required this.child,
    this.showParticles = true,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kCineBg),
        if (widget.showParticles)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _AmbientPainter(_ctrl.value),
                size: Size.infinite,
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _AmbientPainter extends CustomPainter {
  final double t; // 0.0 → 1.0, repeating

  _AmbientPainter(this.t);

  // Pre-computed static particle data (seeded so layout is deterministic)
  static const int _pCount = 40;
  static final _rng = math.Random(7);
  static final _px     = List<double>.generate(_pCount, (_) => _rng.nextDouble());
  static final _py     = List<double>.generate(_pCount, (_) => _rng.nextDouble());
  static final _psize  = List<double>.generate(_pCount, (_) => _rng.nextDouble() * 1.6 + 0.4);
  static final _pspeed = List<double>.generate(_pCount, (_) => _rng.nextDouble() * 0.18 + 0.04);
  static final _pphase = List<double>.generate(_pCount, (_) => _rng.nextDouble() * math.pi * 2);
  static final _ptype  = List<int>.generate(_pCount, (i) => i % 4); // 0=green 1=blue 2=purple 3=white

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * math.pi * 2;

    // ── Large glow orbs ──────────────────────────────────────────────────────
    _drawOrb(canvas, size,
      cx: 0.82 + math.cos(angle * 0.65) * 0.04,
      cy: 0.10 + math.sin(angle * 0.65) * 0.06,
      rf: 0.30, color: kCineGreen.withOpacity(0.07));

    _drawOrb(canvas, size,
      cx: 0.06 + math.sin(angle * 0.45) * 0.05,
      cy: 0.42 + math.cos(angle * 0.45) * 0.08,
      rf: 0.38, color: kCineBlue.withOpacity(0.05));

    _drawOrb(canvas, size,
      cx: 0.50 + math.cos(angle * 0.30) * 0.07,
      cy: 0.88 + math.sin(angle * 0.30) * 0.03,
      rf: 0.42, color: kCinePurple.withOpacity(0.04));

    _drawOrb(canvas, size,
      cx: 0.25 + math.sin(angle * 0.55) * 0.04,
      cy: 0.65 + math.cos(angle * 0.55) * 0.05,
      rf: 0.22, color: kCineOrange.withOpacity(0.03));

    // ── Particles ────────────────────────────────────────────────────────────
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _pCount; i++) {
      final drift   = (t * _pspeed[i] + _pphase[i] / (2 * math.pi)) % 1.0;
      final x       = (_px[i] + math.sin(angle + _pphase[i]) * 0.015) * size.width;
      final rawY    = ((_py[i] - drift * 0.20) % 1.0);
      final y       = rawY * size.height;
      final opacity = (math.sin(angle * 1.5 + _pphase[i]) * 0.5 + 0.5) * 0.28 + 0.04;

      paint.color = switch (_ptype[i]) {
        0 => kCineGreen.withOpacity(opacity),
        1 => kCineBlue.withOpacity(opacity * 0.7),
        2 => kCinePurple.withOpacity(opacity * 0.6),
        _ => Colors.white.withOpacity(opacity * 0.25),
      };
      canvas.drawCircle(Offset(x, y), _psize[i], paint);
    }
  }

  void _drawOrb(Canvas canvas, Size size, {
    required double cx, required double cy,
    required double rf,  required Color color,
  }) {
    final center = Offset(cx * size.width, cy * size.height);
    final radius = rf * (size.width + size.height) / 2;
    canvas.drawCircle(
      center, radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.t != t;
}
