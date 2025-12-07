import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/settings_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:get/get.dart';

class LanguageOptionItem extends StatelessWidget {
  final String title;
  final Locale locale;
  final SettingsController controller;
  final double refSize;
  final VoidCallback? onTap;

  const LanguageOptionItem({
    super.key,
    required this.title,
    required this.locale,
    required this.controller,
    required this.refSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected =
          controller.currentLocale.value.languageCode == locale.languageCode;

      return GestureDetector(
        onTap: () {
          controller.changeLanguage(locale);
          if (onTap != null) onTap!();
        },
        child: Container(
          margin: EdgeInsets.only(bottom: refSize * 0.03),
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.05,
            vertical: refSize * 0.03,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorClass.glowBlue.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: ColorClass.glowBlue, width: 1.5)
                : Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              TextWidget(
                text: title,
                textColor: isSelected
                    ? ColorClass.white
                    : ColorClass.textSecondary,
                fontSize: refSize * 0.04,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: ColorClass.glowBlue,
                  size: refSize * 0.05,
                ),
            ],
          ),
        ),
      );
    });
  }
}
