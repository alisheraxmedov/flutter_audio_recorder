import 'package:flutter/material.dart';

class EditorControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double refSize;
  final Color color;
  final Color bgColor;

  const EditorControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.refSize,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: refSize * 0.1,
        height: refSize * 0.1,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: refSize * 0.05),
      ),
    );
  }
}
