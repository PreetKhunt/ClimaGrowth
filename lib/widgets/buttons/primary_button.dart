import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../utils/constants.dart';

/// 40px terracotta gradient primary CTA button with hand cursor and scale animation.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final PhosphorIconData? leadingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height = 40.0,
    this.leadingIcon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 0.97).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
  );
  late final Animation<double> _arrowX =
      Tween<double>(begin: 0.0, end: 6.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );
  late final Animation<double> _shadow =
      Tween<double>(begin: 20.0, end: 6.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _active => widget.onPressed != null && !widget.loading;

  void _onDown(TapDownDetails _) {
    if (!_active) return;
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onUp(TapUpDetails _) {
    if (!_active) return;
    _ctrl.reverse();
    widget.onPressed!();
  }

  void _onCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _onDown,
        onTapUp: _onUp,
        onTapCancel: _onCancel,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: _active
                    ? const LinearGradient(
                        colors: kButtonGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: _active ? null : kBgTertiary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _active
                    ? [
                        BoxShadow(
                          color: kAmber.withAlpha(80),
                          blurRadius: _shadow.value,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leadingIcon != null) ...[
                    PhosphorIcon(widget.leadingIcon!,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: widget.loading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _active ? Colors.white : kTextMuted,
                            ),
                          ),
                  ),
                  if (!widget.loading)
                    Transform.translate(
                      offset: Offset(_arrowX.value, 0),
                      child: PhosphorIcon(
                        PhosphorIcons.arrowRight(),
                        size: 16,
                        color: _active ? Colors.white : kTextMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
