// Widget used in: lib/features/recorder/views/all_records_page.dart
//
//

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class RecordExpansionTile extends StatelessWidget {
  final BuildContext context;
  final RecorderController controller;
  final String path;
  final String name;
  final double refSize;
  final AppLocalizations l10n;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final Function(String) onShare;

  const RecordExpansionTile({
    super.key,
    required this.context,
    required this.controller,
    required this.path,
    required this.name,
    required this.refSize,
    required this.l10n,
    required this.onRename,
    required this.onMove,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Get.find<AudioPlayerService>();

    return Container(
      margin: EdgeInsets.only(bottom: refSize * 0.04),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(color: ColorClass.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: ColorClass.transparent),
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
          subtitle: Builder(
            builder: (context) {
              final metadata = controller.getMetadata(path);
              if (metadata == null) return const SizedBox.shrink();
              return TextWidget(
                text:
                    '${metadata.formattedDuration} • ${metadata.formattedSize}',
                textColor: ColorClass.textSecondary,
                fontSize: refSize * 0.025,
              );
            },
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
            // Progress indicator when playing
            Obx(() {
              if (audioPlayer.currentPath.value == path) {
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: refSize * 0.015,
                        ),
                        trackHeight: refSize * 0.008,
                        activeTrackColor: ColorClass.glowBlue,
                        inactiveTrackColor: ColorClass.textSecondary.withValues(
                          alpha: 0.3,
                        ),
                        thumbColor: ColorClass.glowBlue,
                      ),
                      child: Slider(
                        value: audioPlayer.progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds:
                                (value *
                                        audioPlayer
                                            .duration
                                            .value
                                            .inMilliseconds)
                                    .toInt(),
                          );
                          audioPlayer.seek(newPosition);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: audioPlayer.formattedPosition,
                          textColor: ColorClass.textSecondary,
                          fontSize: refSize * 0.025,
                        ),
                        TextWidget(
                          text: audioPlayer.formattedDuration,
                          textColor: ColorClass.textSecondary,
                          fontSize: refSize * 0.025,
                        ),
                      ],
                    ),
                    SizedBox(height: refSize * 0.02),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                Obx(
                  () => _buildActionButton(
                    icon: audioPlayer.isCurrentlyPlaying(path)
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: ColorClass.glowBlue,
                    refSize: refSize,
                    onTap: () => audioPlayer.togglePlayPause(path),
                  ),
                ),
                // Edit/Rename button
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: ColorClass.editIcon,
                  refSize: refSize,
                  onTap: onRename,
                ),
                // Move button
                _buildActionButton(
                  icon: Icons.drive_file_move_outline,
                  color: ColorClass.moveIcon,
                  refSize: refSize,
                  onTap: onMove,
                ),
                // Delete button
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: ColorClass.deleteIcon,
                  refSize: refSize,
                  onTap: onDelete,
                ),
                // Share button
                _buildActionButton(
                  icon: Icons.ios_share,
                  color: ColorClass.glowBlue,
                  refSize: refSize,
                  onTap: () => onShare(path),
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
}
