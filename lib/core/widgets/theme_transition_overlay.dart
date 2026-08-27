import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThemeTransitionOverlay {
  static void show(BuildContext context, {required bool isDarkTarget}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ThemeTransitionWidget(
        isDarkTarget: isDarkTarget,
        onComplete: () {
          entry.remove();
        },
      ),
    );

    overlayState.insert(entry);
  }
}

class _ThemeTransitionWidget extends StatefulWidget {
  final bool isDarkTarget;
  final VoidCallback onComplete;

  const _ThemeTransitionWidget({
    required this.isDarkTarget,
    required this.onComplete,
  });

  @override
  State<_ThemeTransitionWidget> createState() => _ThemeTransitionWidgetState();
}

class _ThemeTransitionWidgetState extends State<_ThemeTransitionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _radialAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _radialAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTarget;
    final size = MediaQuery.of(context).size;
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = (1.0 - _fadeAnimation.value).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radial Expanding Background Wave
                CustomPaint(
                  size: size,
                  painter: _RadialWavePainter(
                    progress: _radialAnimation.value,
                    maxRadius: maxRadius,
                    isDark: isDark,
                  ),
                ),

                // Twinkling stars for dark mode transition
                if (isDark) ..._buildStars(size),

                // Central Animated Sun or Moon Pop Unit
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.8),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                                : const Color(0xFFFDE047).withValues(alpha: 0.6),
                            blurRadius: 70,
                            spreadRadius: 25,
                          ),
                        ],
                      ),
                      child: isDark ? _buildMoonIcon() : _buildSunIcon(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStars(Size size) {
    final random = math.Random(42);
    return List.generate(12, (index) {
      final dx = (random.nextDouble() - 0.5) * size.width * 0.8;
      final dy = (random.nextDouble() - 0.5) * size.height * 0.8;
      final starSize = 4.0 + random.nextDouble() * 6.0;
      final delay = random.nextDouble() * 0.4;
      final starOpacity = ((_controller.value - delay) / 0.6).clamp(0.0, 1.0);

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: starOpacity,
          child: Icon(
            Icons.star_rounded,
            color: const Color(0xFFFDE047),
            size: starSize,
          ),
        ),
      );
    });
  }

  Widget _buildSunIcon() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFEF08A),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.wb_sunny_rounded,
            size: 80,
            color: Colors.white,
          ),
          // Sun Ray Beams
          ...List.generate(8, (i) {
            final angle = (i * math.pi / 4);
            return Transform.rotate(
              angle: angle,
              child: Container(
                width: 4,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoonIcon() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF818CF8),
            Color(0xFF4F46E5),
            Color(0xFF1E1B4B),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.nightlight_round,
          size: 75,
          color: Color(0xFFFDE047),
        ),
      ),
    );
  }
}

class _RadialWavePainter extends CustomPainter {
  final double progress;
  final double maxRadius;
  final bool isDark;

  _RadialWavePainter({
    required this.progress,
    required this.maxRadius,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final currentRadius = maxRadius * progress;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? const [
                Color(0xFF111726),
                Color(0xFF0B0F17),
              ]
            : const [
                Color(0xFFFFFFFF),
                Color(0xFFF3F4F6),
              ],
      ).createShader(
        Rect.fromCircle(center: center, radius: currentRadius > 0 ? currentRadius : 1),
      );

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
