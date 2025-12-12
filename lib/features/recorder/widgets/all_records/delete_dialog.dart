// Widget used in: lib/features/recorder/views/all_records_page.dart
//
//

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key});

  static void show(
    BuildContext context, {
    required RecorderController controller,
    required String path,
    required String name,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.deleteRecordingTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextWidget(
          text: l10n.deleteRecordingMessage(name),
          textColor: ColorClass.textSecondary,
          fontSize: refSize * 0.03,
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
            onPressed: () async {
              Get.back();
              try {
                final entity = FileSystemEntity.isDirectorySync(path)
                    ? Directory(path)
                    : File(path);
                if (await entity.exists()) {
                  await entity.delete(recursive: true);
                  await controller.deleteEntityMetadata(path);
                  await controller.refreshList();
                }
              } catch (e) {
                // Silent fail
              }
            },
            child: TextWidget(
              text: l10n.delete,
              textColor: ColorClass.deleteIcon,
              fontSize: refSize * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
