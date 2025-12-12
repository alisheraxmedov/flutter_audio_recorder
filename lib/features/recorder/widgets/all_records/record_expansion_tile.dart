import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class RecordExpansionTile extends StatefulWidget {
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
  State<RecordExpansionTile> createState() => _RecordExpansionTileState();
}

class _RecordExpansionTileState extends State<RecordExpansionTile> {
  bool _isHovered = false;
  final AudioPlayerService _audioPlayer = Get.find<AudioPlayerService>();

  @override
  Widget build(BuildContext context) {
    final metadata = widget.controller.getMetadata(widget.path);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Obx(() {
        final isPlaying = _audioPlayer.currentPath.value == widget.path;
        final isPaused = isPlaying && !_audioPlayer.isPlaying.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: widget.refSize * 0.02),
          padding: EdgeInsets.symmetric(
            horizontal: widget.refSize * 0.03,
            vertical: widget.refSize * 0.02,
          ),
          decoration: BoxDecoration(
            color: _isHovered || isPlaying
                ? ColorClass.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.refSize * 0.02),
            border: Border.all(
              color: isPlaying
                  ? ColorClass.glowBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // 1. Play/Pause Button
                  GestureDetector(
                    onTap: () => _audioPlayer.togglePlayPause(widget.path),
                    child: Container(
                      padding: EdgeInsets.all(widget.refSize * 0.02),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPlaying
                            ? ColorClass.glowBlue
                            : ColorClass.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        isPlaying && !isPaused
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: ColorClass.white,
                        size: widget.refSize * 0.05,
                      ),
                    ),
                  ),
                  SizedBox(width: widget.refSize * 0.04),

                  // 2. Info (Title & Subtitle)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: widget.name,
                          textColor: isPlaying
                              ? ColorClass.glowBlue
                              : ColorClass.white,
                          fontSize: widget.refSize * 0.035,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (metadata != null) ...[
                          SizedBox(height: widget.refSize * 0.01),
                          TextWidget(
                            text:
                                '${metadata.formattedDuration} • ${metadata.formattedSize} • ${metadata.createdAt.toString().substring(0, 10)}',
                            textColor: ColorClass.textSecondary,
                            fontSize: widget.refSize * 0.025,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 3. Actions (Desktop Hover or Mobile Menu)
                  if (!kIsWeb &&
                      (Platform.isLinux ||
                          Platform.isMacOS ||
                          Platform.isWindows))
                    _buildDesktopActions(isPlaying)
                  else
                    _buildMobileMenu(widget.refSize),
                ],
              ),

              // 4. Progress Bar (Only when playing)
              if (isPlaying) ...[
                SizedBox(height: widget.refSize * 0.02),
                _buildProgressBar(widget.refSize),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDesktopActions(bool isPlaying) {
    // Show actions if hovered or playing
    bool showActions = _isHovered || isPlaying;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: showActions ? 1.0 : 0.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconButton(
            Icons.edit_outlined,
            ColorClass.white,
            widget.onRename,
            "Rename",
          ),
          _iconButton(
            Icons.drive_file_move_outline,
            ColorClass.white,
            widget.onMove,
            "Move",
          ),
          _iconButton(
            Icons.share_outlined,
            ColorClass.white,
            () => widget.onShare(widget.path),
            "Share",
          ),
          _iconButton(
            Icons.delete_outline,
            ColorClass.deleteIcon,
            widget.onDelete,
            "Delete",
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    Color color,
    VoidCallback onTap,
    String tooltip,
  ) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: widget.refSize * 0.045),
      onPressed: onTap,
    );
  }

  Widget _buildMobileMenu(double refSize) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: ColorClass.textSecondary,
        size: refSize * 0.05,
      ),
      color: ColorClass.buttonBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(refSize * 0.03),
      ),
      onSelected: (value) {
        switch (value) {
          case 'rename':
            widget.onRename();
            break;
          case 'move':
            widget.onMove();
            break;
          case 'share':
            widget.onShare(widget.path);
            break;
          case 'delete':
            widget.onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        _popupItem('rename', Icons.edit_outlined, widget.l10n.rename),
        _popupItem('move', Icons.drive_file_move_outline, "Move"),
        _popupItem('share', Icons.share_outlined, "Share"),
        _popupItem(
          'delete',
          Icons.delete_outline,
          widget.l10n.delete,
          color: ColorClass.deleteIcon,
        ),
      ],
    );
  }

  PopupMenuItem<String> _popupItem(
    String value,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final itemColor = color ?? ColorClass.white;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: itemColor, size: widget.refSize * 0.04),
          SizedBox(width: widget.refSize * 0.03),
          Text(
            text,
            style: TextStyle(color: itemColor, fontSize: widget.refSize * 0.03),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double refSize) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: refSize * 0.01,
            ),
            trackHeight: 2,
            activeTrackColor: ColorClass.glowBlue,
            inactiveTrackColor: ColorClass.white.withValues(alpha: 0.1),
            thumbColor: ColorClass.glowBlue,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: _audioPlayer.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds:
                    (value * _audioPlayer.duration.value.inMilliseconds)
                        .toInt(),
              );
              _audioPlayer.seek(newPosition);
            },
          ),
        ),
        SizedBox(height: refSize * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: _audioPlayer.formattedPosition,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.022,
            ),
            TextWidget(
              text: _audioPlayer.formattedDuration,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.022,
            ),
          ],
        ),
      ],
    );
  }
}
