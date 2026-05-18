import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/constants.dart';

/// 32×32 icon button with hand cursor, border, and terracotta press state.
class IconActionButton extends StatefulWidget {
  final PhosphorIconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final String? badge;

  const IconActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.badge,
  });

  @override
  State<IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<IconActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          setState(() => _pressed = true);
          _ctrl.forward();
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          _ctrl.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          _ctrl.reverse();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: kAnimFast,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _pressed ? kAmberLight : kBgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _pressed ? kAmber.withAlpha(100) : kBorder,
                ),
              ),
              child: Center(
                child: PhosphorIcon(
                  widget.icon,
                  size: 16,
                  color: _pressed
                      ? kAmberDark
                      : (widget.iconColor ?? kTextPrimary),
                ),
              ),
            ),
            if (widget.badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: kCoral,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                  child: Text(
                    widget.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
