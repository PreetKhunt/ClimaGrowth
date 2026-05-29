import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Premium glassmorphism card with optional glow border and backdrop blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final Color? glowColor;
  final double radius;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blur = 16,
    this.color,
    this.borderColor,
    this.glowColor,
    this.radius = 24,
    this.shadows,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    (color ?? kCineCard).withOpacity(
                        (color ?? kCineCard).opacity == 0
                            ? 0.05
                            : (color ?? kCineCard).opacity),
                    kCineCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? kCineBorder,
              width: 1,
            ),
            boxShadow: shadows ??
                (glowColor != null
                    ? [
                        BoxShadow(
                          color: glowColor!.withOpacity(0.15),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: card),
      );
    }
    return card;
  }
}

// ── Gradient text ─────────────────────────────────────────────────────────────

/// Renders text with a horizontal gradient shader.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.colors = const [kCineGreen, kCineBlue],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────────────────────

/// Pulsing "live" indicator pill.
class StatusPill extends StatefulWidget {
  final String label;
  final Color color;

  const StatusPill({super.key, required this.label, this.color = kCineGreen});

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 1800.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: widget.color.withOpacity(0.28), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.5 + _ctrl.value * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_ctrl.value * 0.8),
                    blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.color,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glow button ───────────────────────────────────────────────────────────────

/// Full-width CTA button with soft glow shadow.
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color glowColor;
  final IconData? icon;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = kCineGreen,
    this.glowColor = kGlowGreen,
    this.icon,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) { if (enabled) setState(() => _hovered = true); },
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: 180.ms,
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [widget.color, widget.color.withOpacity(0.80)]
                  : [kCineTextDim, kCineTextDim],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: widget.glowColor
                          .withOpacity(_hovered ? 0.55 : 0.28),
                      blurRadius: _hovered ? 28 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: kCineBg, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.syne(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kCineBg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Metric chip ───────────────────────────────────────────────────────────────

/// Small inline metric — used inside dashboard cards.
class MetricChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const MetricChip({
    super.key,
    required this.value,
    required this.label,
    this.color = kCineGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10, color: color, fontWeight: FontWeight.w600,
              letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}
