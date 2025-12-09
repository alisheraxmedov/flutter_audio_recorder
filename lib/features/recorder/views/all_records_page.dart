import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class AllRecordsPage extends StatelessWidget {
  const AllRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecorderController>();
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        title: TextWidget(
          text: l10n.allRecordsTitle,
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ColorClass.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return Center(
            child: TextWidget(
              text: l10n.noRecordsFound,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.035,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(refSize * 0.05),
          itemCount: controller.records.length,
          itemBuilder: (context, index) {
            final path = controller.records[index];
            final name = path.split('/').last;

            return _buildRecordExpansionTile(
              context: context,
              controller: controller,
              path: path,
              name: name,
              refSize: refSize,
              l10n: l10n,
            );
          },
        );
      }),
    );
  }

  Widget _buildRecordExpansionTile({
    required BuildContext context,
    required RecorderController controller,
    required String path,
    required String name,
    required double refSize,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.04),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: refSize * 0.035,
            vertical: refSize * 0.02,
          ),
          leading: Icon(
            Icons.audiotrack,
            color: ColorClass.glowBlue,
            size: refSize * 0.06,
          ),
          title: TextWidget(
            text: name,
            textColor: ColorClass.white,
            fontSize: refSize * 0.035,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: ColorClass.textSecondary,
            size: refSize * 0.06,
          ),
          iconColor: ColorClass.glowBlue,
          collapsedIconColor: ColorClass.textSecondary,
          childrenPadding: EdgeInsets.symmetric(
            horizontal: refSize * 0.04,
            vertical: refSize * 0.03,
          ),
          children: [
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                _buildActionButton(
                  icon: Icons.pause,
                  color: ColorClass.glowBlue,
                  refSize: refSize,
                  onTap: () {
                    // TODO: Implement play/pause
                  },
                ),
                // Edit/Rename button
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.orangeAccent,
                  refSize: refSize,
                  onTap: () => _showRenameDialog(
                    context,
                    controller,
                    path,
                    name,
                    refSize,
                    l10n,
                  ),
                ),
                // Delete button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.redAccent,
                  refSize: refSize,
                  onTap: () => _confirmDelete(
                    context,
                    controller,
                    path,
                    name,
                    refSize,
                    l10n,
                  ),
                ),
                // Share button
                _buildActionButton(
                  icon: Icons.ios_share,
                  color: ColorClass.glowBlue,
                  refSize: refSize,
                  onTap: () => _shareFile(path),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double refSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(refSize * 0.03),
      child: Container(
        padding: EdgeInsets.all(refSize * 0.03),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(refSize * 0.03),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: refSize * 0.04),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RecorderController controller,
    String path,
    String name,
    double refSize,
    AppLocalizations l10n,
  ) {
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
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final file = File(path);
                if (await file.exists()) {
                  await file.delete();
                  controller.records.remove(path);
                }
              } catch (e) {
                // Silent fail
              }
            },
            child: Text(
              l10n.delete,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareFile(String path) async {
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
    } catch (e) {
      // Silent fail
    }
  }

  void _showRenameDialog(
    BuildContext context,
    RecorderController controller,
    String path,
    String currentName,
    double refSize,
    AppLocalizations l10n,
  ) {
    // Extract file extension
    final extension = currentName.contains('.')
        ? '.${currentName.split('.').last}'
        : '';
    final nameWithoutExtension = currentName.contains('.')
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
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isEmpty) {
                return;
              }

              Get.back();

              try {
                final file = File(path);
                if (await file.exists()) {
                  final directory = file.parent.path;
                  final newPath = '$directory/$newName$extension';

                  // Check if file with new name already exists
                  if (await File(newPath).exists()) {
                    return;
                  }

                  await file.rename(newPath);

                  // Update the records list
                  final index = controller.records.indexOf(path);
                  if (index != -1) {
                    controller.records[index] = newPath;
                  }
                }
              } catch (e) {
                // Silent fail
              }
            },
            child: Text(
              l10n.rename,
              style: TextStyle(
                color: ColorClass.glowBlue,
                fontSize: refSize * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
