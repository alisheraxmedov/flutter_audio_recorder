//  Widget used in: lib/features/recorder/views/all_records_page.dart
//
//

import 'package:flutter/material.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class FolderTile extends StatelessWidget {
  final RecorderController controller;
  final String path;
  final String name;
  final double refSize;
  final AppLocalizations l10n;
  final VoidCallback onLongPress;

  const FolderTile({
    super.key,
    required this.controller,
    required this.path,
    required this.name,
    required this.refSize,
    required this.l10n,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.04),
      decoration: BoxDecoration(
        color: ColorClass.buttonBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(color: ColorClass.borderLight),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: refSize * 0.04,
          vertical: refSize * 0.015,
        ),
        leading: Icon(
          Icons.folder_open_rounded,
          color: ColorClass.folderIcon,
          size: refSize * 0.07,
        ),
        title: TextWidget(
          text: name,
          textColor: ColorClass.white,
          fontSize: refSize * 0.035,
          fontWeight: FontWeight.w500,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: ColorClass.textSecondary,
          size: refSize * 0.035,
        ),
        onTap: () => controller.openFolder(path),
        onLongPress: onLongPress,
      ),
    );
  }
}
