import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:recorder/features/recorder/controllers/settings_controller.dart';
import 'package:recorder/features/recorder/widgets/settings_item.dart';
import 'package:recorder/features/recorder/widgets/language_option_item.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        title: TextWidget(
          text: AppLocalizations.of(context)!.settingsTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ColorClass.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(refSize * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Items
            // Settings Items
            SettingsItem(
              title: AppLocalizations.of(context)!.language,
              icon: Icons.language,
              refSize: refSize,
              onTap: () =>
                  _showLanguageBottomSheet(context, controller, refSize),
            ),
            SizedBox(height: refSize * 0.03),
            SettingsItem(
              title: AppLocalizations.of(context)!.audioFormat,
              icon: Icons.audio_file,
              refSize: refSize,
              onTap: () => _showFormatBottomSheet(context, controller, refSize),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  void _showFormatBottomSheet(
    BuildContext context,
    SettingsController controller,
    double refSize,
  ) {
    final content = _buildFormatContent(context, controller, refSize);

    if (_isDesktop) {
      // Use Dialog on Desktop to avoid overflow
      Get.dialog(
        Dialog(
          backgroundColor: ColorClass.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            child: content,
          ),
        ),
      );
    } else {
      // Use BottomSheet on Mobile
      showModalBottomSheet(
        context: context,
        backgroundColor: ColorClass.darkBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(refSize * 0.05),
            child: content,
          );
        },
      );
    }
  }

  Widget _buildFormatContent(
    BuildContext context,
    SettingsController controller,
    double refSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(
          text: AppLocalizations.of(context)!.audioFormat,
          textColor: ColorClass.white,
          fontSize: _isDesktop ? 20 : refSize * 0.05,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: _isDesktop ? 24 : refSize * 0.05),
        _buildFormatOption(
          context,
          controller,
          AudioEncoder.aacLc,
          AppLocalizations.of(context)!.formatAacLc,
          refSize,
        ),
        _buildFormatOption(
          context,
          controller,
          AudioEncoder.opus,
          AppLocalizations.of(context)!.formatOpus,
          refSize,
        ),
        _buildFormatOption(
          context,
          controller,
          AudioEncoder.wav,
          AppLocalizations.of(context)!.formatWav,
          refSize,
        ),
        SizedBox(height: _isDesktop ? 8 : refSize * 0.05),
      ],
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    SettingsController controller,
    AudioEncoder encoder,
    String title,
    double refSize,
  ) {
    return Obx(() {
      final isSelected = controller.currentEncoder.value == encoder;

      return GestureDetector(
        onTap: () {
          controller.changeEncoder(encoder);
          Navigator.pop(context);
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

  void _showLanguageBottomSheet(
    BuildContext context,
    SettingsController controller,
    double refSize,
  ) {
    final content = _buildLanguageContent(context, controller, refSize);

    if (_isDesktop) {
      // Use Dialog on Desktop to avoid overflow
      Get.dialog(
        Dialog(
          backgroundColor: ColorClass.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            child: content,
          ),
        ),
      );
    } else {
      // Use BottomSheet on Mobile
      showModalBottomSheet(
        context: context,
        backgroundColor: ColorClass.darkBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(refSize * 0.05),
            child: content,
          );
        },
      );
    }
  }

  Widget _buildLanguageContent(
    BuildContext context,
    SettingsController controller,
    double refSize,
  ) {
    // On desktop use fixed sizes, on mobile use refSize
    final double desktopRefSize = 400;
    final double effectiveRefSize = _isDesktop ? desktopRefSize : refSize;
    final VoidCallback closeAction = _isDesktop
        ? Get.back
        : () => Navigator.pop(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(
          text: AppLocalizations.of(context)!.language,
          textColor: ColorClass.white,
          fontSize: _isDesktop ? 20 : refSize * 0.05,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: _isDesktop ? 24 : refSize * 0.05),
        LanguageOptionItem(
          title: AppLocalizations.of(context)!.english,
          locale: const Locale('en'),
          controller: controller,
          refSize: effectiveRefSize,
          onTap: closeAction,
        ),
        LanguageOptionItem(
          title: AppLocalizations.of(context)!.uzbek,
          locale: const Locale('uz'),
          controller: controller,
          refSize: effectiveRefSize,
          onTap: closeAction,
        ),
        LanguageOptionItem(
          title: AppLocalizations.of(context)!.russian,
          locale: const Locale('ru'),
          controller: controller,
          refSize: effectiveRefSize,
          onTap: closeAction,
        ),
        SizedBox(height: _isDesktop ? 8 : refSize * 0.05),
      ],
    );
  }
}
