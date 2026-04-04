import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final double borderRadius;
  final EdgeInsets padding;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call(); // Call onTap ONLY here
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: NeumorphicContainer(
          isPressed: _isPressed,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          child: widget.accentColor != null
              ? Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: IconThemeData(color: widget.accentColor),
                  ),
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
    );
  }
}
