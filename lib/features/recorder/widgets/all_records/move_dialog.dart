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

class MoveDialog extends StatelessWidget {
  const MoveDialog({super.key});

  static void show(
    BuildContext context, {
    required RecorderController controller,
    required String srcPath,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    // Get list of folders in current directory to allow moving INTO them
    final folders = controller.entities.whereType<Directory>().toList();
    // Exclude the source itself if it's a directory we are trying to move
    folders.removeWhere((dir) => dir.path == srcPath);

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(refSize * 0.03),
        ),
        title: TextWidget(
          text: l10n.moveTo,
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
          fontWeight: FontWeight.bold,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (controller.canGoBack)
                ListTile(
                  leading: const Icon(
                    Icons.arrow_upward,
                    color: ColorClass.glowBlue,
                  ),
                  title: TextWidget(
                    text: l10n.extractFromFolder,
                    textColor: ColorClass.white,
                    fontSize: refSize * 0.035,
                  ),
                  onTap: () {
                    final parent = Directory(
                      controller.currentPath.value,
                    ).parent.path;
                    controller.moveEntity(srcPath, parent);
                    Get.back();
                  },
                ),
              if (folders.isEmpty && !controller.canGoBack)
                Padding(
                  padding: EdgeInsets.all(refSize * 0.02),
                  child: TextWidget(
                    text: l10n.noFolders,
                    textColor: ColorClass.textSecondary,
                    fontSize: refSize * 0.03,
                    textAlign: TextAlign.center,
                  ),
                ),
              ...folders.map((folder) {
                final folderName = folder.path
                    .split(Platform.pathSeparator)
                    .last;
                return ListTile(
                  leading: const Icon(
                    Icons.folder,
                    color: ColorClass.folderIcon,
                  ),
                  title: TextWidget(
                    text: folderName,
                    textColor: ColorClass.white,
                    fontSize: refSize * 0.035,
                  ),
                  onTap: () {
                    controller.moveEntity(srcPath, folder.path);
                    Get.back();
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextWidget(
              text: l10n.cancel,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.035,
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
