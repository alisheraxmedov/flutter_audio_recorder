// Widget used in: lib/features/recorder/views/all_records_page.dart
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class CreateFolderDialog extends StatelessWidget {
  final RecorderController controller;
  final double refSize;
  final AppLocalizations l10n;

  const CreateFolderDialog({
    super.key,
    required this.controller,
    required this.refSize,
    required this.l10n,
  });

  static void show(
    BuildContext context, {
    required RecorderController controller,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.newFolder,
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: ColorClass.white, fontSize: refSize * 0.035),
          decoration: InputDecoration(
            hintText: l10n.folderName,
            hintStyle: TextStyle(
              color: ColorClass.textSecondary.withValues(alpha: 0.5),
              fontSize: refSize * 0.03,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.textSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(refSize * 0.02),
              borderSide: const BorderSide(color: ColorClass.glowBlue),
            ),
            filled: true,
            fillColor: ColorClass.buttonBg,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextWidget(
              text: l10n.cancel,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.03,
            ),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                controller.createFolder(name);
              }
              Get.back();
            },
            child: TextWidget(
              text: l10n.create,
              textColor: ColorClass.glowBlue,
              fontSize: refSize * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Using static show method
  }
}
