import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedAvatar extends StatefulWidget {
  final double size;
  final bool isThinking;

  const AnimatedAvatar({
    super.key,
    this.size = 32,
    this.isThinking = false,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Listenable _mergedAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _mergedAnimation = Listenable.merge([_rotationController, _pulseController]);

    if (widget.isThinking) {
      _startThinkingAnimations();
    }
  }

  @override
  void didUpdateWidget(AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isThinking != oldWidget.isThinking) {
      if (widget.isThinking) {
        _startThinkingAnimations();
      } else {
        _stopThinkingAnimations();
      }
    }
  }

  void _startThinkingAnimations() {
    if (!mounted) return;
    _rotationController.duration = const Duration(milliseconds: 1200);
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _stopThinkingAnimations() {
    if (!mounted) return;
    _rotationController.duration = const Duration(seconds: 20);
    _rotationController.repeat();
    _pulseController.stop();
    _pulseController.animateTo(0, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarPath = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    return AnimatedBuilder(
      animation: _mergedAnimation,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: child,
          ),
        );
      },
      child: ClipOval(
        child: Image.asset(
          avatarPath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: widget.size,
            height: widget.size,
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Icon(Icons.face),
          ),
        ),
      ),
    );
  }
}
