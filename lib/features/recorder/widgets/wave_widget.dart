import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';

class WaveWidget extends StatefulWidget {
  final RecorderController controller;
  final double size;

  const WaveWidget({super.key, required this.controller, required this.size});

  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double amplitude = widget.controller.amplitude.value; // 0.0 to 1.0

      return Stack(
        alignment: Alignment.center,
        children: [
          // Sunburst Rays
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: SunburstPainter(
                  amplitude: amplitude,
                  rotation: _rotationController.value * 2 * math.pi,
                  color: ColorClass.glowBlue,
                ),
              );
            },
          ),

          // Central Ring (Static base)
          Container(
            width: widget.size * 0.45,
            height: widget.size * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ColorClass.glowPurple, ColorClass.glowBlue],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorClass.glowBlue.withValues(
                    alpha: 0.5 + (amplitude * 0.3),
                  ),
                  blurRadius: 20 + (amplitude * 20),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorClass.darkBackground,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class SunburstPainter extends CustomPainter {
  final double amplitude;
  final double rotation;
  final Color color;

  SunburstPainter({
    required this.amplitude,
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Inner radius matches the container (size * 0.45 / 2)
    final radius = size.width * 0.225;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final int rayCount = 40;
    final double angleStep = (2 * math.pi) / rayCount;
    final double maxRayLength = (size.width / 2) - radius - 5; // -5 padding

    for (int i = 0; i < rayCount; i++) {
      final double angle = (i * angleStep) + rotation;

      // Dynamic length based on amplitude and variation
      final double variance = math.sin(i * 3) * 0.2; // -0.2 to 0.2
      // Base length factor: when silence, rays are short. When loud, long.
      // Silence (amp=0): factor = 0.1
      // Loud (amp=1): factor = 1.0
      double lengthFactor = 0.15 + (amplitude * 0.85);
      lengthFactor = lengthFactor * (1.0 + variance);

      final double rayLength = maxRayLength * lengthFactor;
      final double opacity = (0.2 + (amplitude * 0.8)).clamp(0.0, 1.0);

      paint.color = color.withValues(alpha: opacity);
      paint.strokeWidth = 2 + (amplitude * 3);

      final endX = center.dx + (radius + rayLength) * math.cos(angle);
      final endY = center.dy + (radius + rayLength) * math.sin(angle);

      final startX = center.dx + radius * math.cos(angle);
      final startY = center.dy + radius * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SunburstPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.rotation != rotation;
  }
}
