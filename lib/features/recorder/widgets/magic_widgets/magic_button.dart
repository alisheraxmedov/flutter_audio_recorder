import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

/// A Flutter recreation of the CSS button in this folder.
class MagicButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double width;
  final double height;
  final double fontSize;

  const MagicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 25),
    required this.width,
    required this.height,
    required this.fontSize,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton> {
  bool _hovered = false;
  bool _pressed = false;

  static const _gradient = LinearGradient(
    colors: [
      ColorClass.trackGreen,
      ColorClass.glowPurple,
      ColorClass.glowBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _innerColor = ColorClass.buttonBg;

  void _setHover(bool value) {
    if (_hovered == value) return;
    setState(() {
      _hovered = value;
    });
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Glow layer (matches CSS :after blur)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Main button with press-driven border shift
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.all(_pressed ? 4 : 2),
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Transform.translate(
                offset: _pressed ? const Offset(0, 1) : Offset.zero,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _innerColor.withOpacity(_hovered ? 0.7 : 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: widget.padding,
                  child: TextWidget(
                    text: widget.label,
                    textColor: ColorClass.white,
                    fontSize: widget.fontSize,
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
