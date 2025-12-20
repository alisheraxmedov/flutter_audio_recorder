import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color iconColor;
  final Color bgColor;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
    required this.iconColor,
    required this.bgColor,
    this.border,
    this.iconSize,
  });

  final BoxBorder? border;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: border,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        iconSize: iconSize ?? 24.0,
        onPressed: onTap,
      ),
    );
  }
}
