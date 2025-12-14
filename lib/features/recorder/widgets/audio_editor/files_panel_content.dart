import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class FilesPanelContent extends StatelessWidget {
  final double refSize;
  final AudioEditorController controller;
  final TextEditingController exportNameController;

  const FilesPanelContent({
    super.key,
    required this.refSize,
    required this.controller,
    required this.exportNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextWidget(
          text: "Loaded Tracks",
          fontSize: refSize * 0.025,
          textColor: ColorClass.textSecondary,
        ),
        SizedBox(height: refSize * 0.02),

        Expanded(
          child: Obx(() {
            // Check if there are any tracks with actual files loaded
            final hasLoadedTracks = controller.tracks.any(
              (t) => t.filePath.isNotEmpty,
            );

            if (!hasLoadedTracks) {
              return Center(
                child: TextWidget(
                  text:
                      "No tracks loaded.\nDrag & Drop files or Double Click on track slots.",
                  fontSize: refSize * 0.02,
                  textColor: ColorClass.textSecondary,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.separated(
              itemCount: controller.tracks.length,
              separatorBuilder: (context, index) {
                if (controller.tracks[index].filePath.isEmpty) return SizedBox.shrink();
                return SizedBox(height: refSize * 0.015);
              },
              itemBuilder: (context, index) {
                final track = controller.tracks[index];
                if (track.filePath.isEmpty) return SizedBox.shrink();

                final color = controller.getTrackColor(index);

                return Container(
                  padding: EdgeInsets.all(refSize * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.audio_file,
                        color: color,
                        size: refSize * 0.035,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextWidget(
                          text: "Track ${index + 1}: ${track.fileName.value}",
                          fontSize: refSize * 0.025,
                          textColor: ColorClass.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        TextWidget(
          text: "Export Name",
          fontSize: refSize * 0.025,
          textColor: ColorClass.textSecondary,
        ),
        SizedBox(height: refSize * 0.01),
        TextField(
          controller: exportNameController,
          onChanged: (val) => controller.exportFileName.value = val,
          style: TextStyle(
            color: ColorClass.white,
            fontSize: refSize * 0.025,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorClass.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ColorClass.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorClass.glowBlue),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            suffixIcon: Icon(
              Icons.edit,
              size: refSize * 0.03,
              color: ColorClass.textSecondary,
            ),
          ),
        ),
        SizedBox(height: refSize * 0.02),
        TextWidget(
          text: "Path",
          fontSize: refSize * 0.025,
          textColor: ColorClass.textSecondary,
        ),
        SizedBox(height: refSize * 0.01),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextWidget(
                    text: controller.exportPath.value,
                    fontSize: refSize * 0.02,
                    textColor: ColorClass.textSecondary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.selectExportFolder(),
                  child: Icon(
                    Icons.folder_open,
                    size: refSize * 0.045,
                    color: ColorClass.glowBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: refSize * 0.03),
      ],
    );
  }
}
