import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final double refSize;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    required this.refSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: refSize * 0.05,
          vertical: refSize * 0.04,
        ),
        decoration: BoxDecoration(
          color: ColorClass.buttonBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorClass.white, size: refSize * 0.06),
            SizedBox(width: refSize * 0.04),
            TextWidget(
              text: title,
              textColor: ColorClass.white,
              fontSize: refSize * 0.04,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorClass.textSecondary,
              size: refSize * 0.04,
            ),
          ],
        ),
      ),
    );
  }
}
