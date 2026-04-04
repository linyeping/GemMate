import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../stores/theme_store.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isPressed;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double depth;
  final double blurRadius;
  final Color? accentBorderColor;
  final double? width;
  final double? height;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.isPressed = false,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.depth = 4.0,
    this.blurRadius = 8.0,
    this.accentBorderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    
    // Dynamically calculate colors based on current scheme and brightness
    // This avoids static variable race conditions
    final themeStore = ThemeStore();
    final colors = GemmaStudyTheme.getNeumorphicColors(themeStore.currentScheme, isDark);
    
    final highlightColor = colors.high;
    final shadowColor = colors.shadow;

    // Use lerp for high performance color calculation
    final fillColor = isPressed 
        ? Color.lerp(backgroundColor, Colors.black, 0.05)! 
        : backgroundColor;

    final shadows = isPressed 
      ? [
          BoxShadow(
            color: shadowColor,
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: blurRadius / 2,
          ),
          BoxShadow(
            color: highlightColor,
            offset: Offset(depth / 2, depth / 2),
            blurRadius: blurRadius / 2,
          ),
        ]
      : [
          BoxShadow(
            color: highlightColor,
            offset: Offset(-depth, -depth),
            blurRadius: blurRadius,
          ),
          BoxShadow(
            color: shadowColor,
            offset: Offset(depth, depth),
            blurRadius: blurRadius,
          ),
        ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: accentBorderColor != null
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentBorderColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        bottomLeft: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: child),
                ],
              ),
            )
          : child,
    );
  }
}
