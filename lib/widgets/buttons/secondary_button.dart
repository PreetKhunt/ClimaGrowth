import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../utils/constants.dart';

class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PhosphorIconData? icon;
  final bool arrowUpRight;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.arrowUpRight = false,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
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
      Tween<double>(begin: 0.0, end: 4.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );
  bool _pressed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _ctrl.reverse();
    widget.onPressed?.call();
  }

  void _onCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final arrowIcon = widget.arrowUpRight
        ? PhosphorIcons.arrowUpRight()
        : PhosphorIcons.arrowRight();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onDown,
        onTapUp: _onUp,
        onTapCancel: _onCancel,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: AnimatedContainer(
              duration: kAnimFast,
              height: 36,
              decoration: BoxDecoration(
                color: _pressed ? secondary.withAlpha(30) : Colors.transparent,
                border: Border.all(color: secondary, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    PhosphorIcon(widget.icon!, size: 18, color: secondary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(_arrowX.value, 0),
                    child: PhosphorIcon(arrowIcon, size: 18, color: secondary),
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
