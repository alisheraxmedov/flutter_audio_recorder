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

class RenameDialog extends StatelessWidget {
  const RenameDialog({super.key});

  static void show(
    BuildContext context, {
    required RecorderController controller,
    required String path,
    required String currentName,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    final isDirectory = FileSystemEntity.isDirectorySync(path);
    final extension = !isDirectory && currentName.contains('.')
        ? '.${currentName.split('.').last}'
        : '';
    final nameWithoutExtension = !isDirectory && currentName.contains('.')
        ? currentName.substring(0, currentName.lastIndexOf('.'))
        : currentName;

    final textController = TextEditingController(text: nameWithoutExtension);

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.renameRecording,
          textColor: ColorClass.white,
          fontSize: refSize * 0.04,
          fontWeight: FontWeight.bold,
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: ColorClass.white, fontSize: refSize * 0.035),
          decoration: InputDecoration(
            hintText: l10n.enterNewName,
            hintStyle: TextStyle(
              color: ColorClass.textSecondary.withValues(alpha: 0.5),
              fontSize: refSize * 0.03,
            ),
            suffixText: extension,
            suffixStyle: TextStyle(
              color: ColorClass.textSecondary,
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
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isEmpty) return;

              Get.back();

              try {
                // For files, append extension. For folders, just newName.
                final fullName = '$newName$extension';

                final parent = Directory(path).parent.path;
                final newPath = '$parent/$fullName';

                final entity = isDirectory ? Directory(newPath) : File(newPath);

                if (await entity.exists()) return;

                if (isDirectory) {
                  await Directory(path).rename(newPath);
                } else {
                  await File(path).rename(newPath);
                  // Update metadata path for files
                  await controller.renameEntityMetadata(path, newPath);
                }

                await controller.refreshList();
              } catch (e) {
                // Silent fail
              }
            },
            child: TextWidget(
              text: l10n.rename,
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
    return const SizedBox.shrink();
  }
}
