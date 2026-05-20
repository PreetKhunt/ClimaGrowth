import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/constants.dart';

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
    final cs = Theme.of(context).colorScheme;
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
                color: _pressed ? cs.primary.withAlpha(30) : cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _pressed ? cs.primary.withAlpha(100) : cs.outlineVariant,
                ),
              ),
              child: Center(
                child: PhosphorIcon(
                  widget.icon,
                  size: 16,
                  color: _pressed
                      ? cs.primary
                      : (widget.iconColor ?? cs.onSurface),
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
