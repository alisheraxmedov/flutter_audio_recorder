// Widget used in: lib/features/recorder/views/all_records_page.dart
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/all_records/delete_dialog.dart';
import 'package:recorder/features/recorder/widgets/all_records/rename_dialog.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class FolderOptionsSheet extends StatelessWidget {
  const FolderOptionsSheet({super.key});

  static void show(
    BuildContext context, {
    required RecorderController controller,
    required String path,
    required String name,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(refSize * 0.05),
        decoration: BoxDecoration(
          color: ColorClass.darkBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(refSize * 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: name,
              textColor: ColorClass.white,
              fontSize: refSize * 0.04,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: refSize * 0.04),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: ColorClass.editIcon,
              ),
              title: TextWidget(
                text: l10n.rename,
                textColor: ColorClass.white,
                fontSize: refSize * 0.035,
              ),
              onTap: () {
                Get.back();
                RenameDialog.show(
                  context,
                  controller: controller,
                  path: path,
                  currentName: name,
                  refSize: refSize,
                  l10n: l10n,
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: ColorClass.deleteIcon,
              ),
              title: TextWidget(
                text: l10n.delete,
                textColor: ColorClass.white,
                fontSize: refSize * 0.035,
              ),
              onTap: () {
                Get.back();
                DeleteDialog.show(
                  context,
                  controller: controller,
                  path: path,
                  name: name,
                  refSize: refSize,
                  l10n: l10n,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
