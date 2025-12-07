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

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        title: TextWidget(
          text: AppLocalizations.of(context)!.allRecordsTitle,
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
              text: AppLocalizations.of(context)!.noRecordsFound,
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
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.03),
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(refSize * 0.025),
            decoration: BoxDecoration(
              color: ColorClass.glowBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.audiotrack,
              color: ColorClass.glowBlue,
              size: refSize * 0.05,
            ),
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
                    Get.snackbar('Play', 'Playing: $name');
                  },
                ),
                // Delete button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.redAccent,
                  refSize: refSize,
                  onTap: () => _confirmDelete(context, controller, path, name),
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
        child: Icon(icon, color: color, size: refSize * 0.06),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RecorderController controller,
    String path,
    String name,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ColorClass.darkBackground,
        title: TextWidget(
          text: 'Delete Recording?',
          textColor: ColorClass.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: TextWidget(
          text: 'Are you sure you want to delete "$name"?',
          textColor: ColorClass.textSecondary,
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ColorClass.textSecondary),
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
                  Get.snackbar('Deleted', '$name has been deleted');
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete file');
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
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
      Get.snackbar('Error', 'Failed to share file');
    }
  }
}
