import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';

class CustomBottomNavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const CustomBottomNavItem({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.glowBlue.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? ColorClass.glowBlue : ColorClass.textSecondary,
          size: MediaQuery.of(context).size.shortestSide * 0.07,
        ),
      ),
    );
  }
}
