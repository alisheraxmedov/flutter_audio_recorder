import 'package:flutter/material.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class EditorMiniButton extends StatelessWidget {
  final String label;
  final Color color;
  final double refSize;

  const EditorMiniButton({
    super.key,
    required this.label,
    required this.color,
    required this.refSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: refSize * 0.04,
      height: refSize * 0.04,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: TextWidget(
        text: label,
        fontSize: refSize * 0.02,
        textColor: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
