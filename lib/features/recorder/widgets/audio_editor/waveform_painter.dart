import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double startSelection; // 0.0 to 1.0
  final double endSelection; // 0.0 to 1.0
  final double playbackProgress; // 0.0 to 1.0
  final Color waveColor;
  final Color selectedWaveColor;
  final Color selectionColor;

  WaveformPainter({
    required this.samples,
    required this.startSelection,
    required this.endSelection,
    this.playbackProgress = 0.0, // Default 0
    this.waveColor = Colors.grey,
    this.selectedWaveColor = ColorClass.glowBlue,
    this.selectionColor = const Color(0x332196F3),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width;
    final double height = size.height;
    final double midY = height / 2;

    // Spacing between bars
    final double barWidth = width / samples.length;

    // Draw selection background
    final double selectionStartX = width * startSelection;
    final double selectionEndX = width * endSelection;

    final selectionRect = Rect.fromLTRB(
      selectionStartX,
      0,
      selectionEndX,
      height,
    );

    canvas.drawRect(selectionRect, Paint()..color = selectionColor);

    for (int i = 0; i < samples.length; i++) {
      final double x = i * barWidth;
      final double amplitude = samples[i];
      // amplitude is 0.0 to 1.0
      // Scale amplitude to height (leaving some padding)
      final double barHeight = (height * 0.8) * amplitude;

      final double top = midY - (barHeight / 2);
      final double bottom = midY + (barHeight / 2);

      // Determine color based on whether this bar is inside selection
      final double barCenterRatio = i / samples.length;
      final bool isSelected =
          barCenterRatio >= startSelection && barCenterRatio <= endSelection;

      paint.color = isSelected ? selectedWaveColor : waveColor;

      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }

    // DRAW PLAYBACK HEAD
    if (playbackProgress > 0.0) {
      final double headX = width * playbackProgress;
      final headPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0; // Slightly thicker
      canvas.drawLine(Offset(headX, 0), Offset(headX, height), headPaint);

      // Optional: Red Dot at top
      canvas.drawCircle(
        Offset(headX, 0),
        4.0,
        Paint()..color = Colors.redAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    // If samples changed or selection changed
    return oldDelegate.samples != samples ||
        oldDelegate.startSelection != startSelection ||
        oldDelegate.endSelection != endSelection;
  }
}
