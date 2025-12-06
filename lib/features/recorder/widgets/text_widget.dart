import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double? width;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final FontStyle fontStyle;
  final Color textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TextWidget({
    super.key,
    required this.text,
    required this.fontSize,
    this.width,
    this.fontWeight = FontWeight.normal,
    this.letterSpacing = 0.0,
    this.fontStyle = FontStyle.normal,
    this.textColor = ColorClass.black,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style:
          Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            fontFamily: "Inter",
            color: textColor,
            fontStyle: fontStyle,
          ) ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            fontFamily: "Inter",
            color: textColor,
            fontStyle: fontStyle,
          ),
    );

    if (width != null) {
      return SizedBox(width: width, child: textWidget);
    }

    return textWidget;
  }
}
