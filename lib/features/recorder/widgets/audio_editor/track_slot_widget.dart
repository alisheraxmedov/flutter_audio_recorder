import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/models/track_data.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/editor_mini_button.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/waveform_painter.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class TrackSlotWidget extends StatelessWidget {
  final double refSize;
  final TrackData track;
  final bool isActive;
  final AudioEditorController controller;

  const TrackSlotWidget({
    super.key,
    required this.refSize,
    required this.track,
    required this.isActive,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = controller.getTrackColor(track.id);

    return GestureDetector(
      onTap: () {
        controller.setActiveTrack(track.id);
      },
      onDoubleTap: () {
        controller.setActiveTrack(track.id);
        controller.pickFile();
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorClass.buttonBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(refSize * 0.03),
          border: Border.all(
            color: isActive
                ? trackColor.withValues(alpha: 0.8)
                : ColorClass.white.withValues(alpha: 0.05),
            width: isActive ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Track Header (Top Bar)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: refSize * 0.02,
                vertical: refSize * 0.015,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? trackColor.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(refSize * 0.03),
                  topRight: Radius.circular(refSize * 0.03),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: ColorClass.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Icon + Name
                  Icon(
                    Icons.graphic_eq,
                    color: isActive ? trackColor : Colors.grey,
                    size: refSize * 0.03,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => TextWidget(
                        text: "Track ${track.id + 1}: ${track.fileName.value}",
                        fontSize: refSize * 0.020,
                        textColor: ColorClass.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Controls (M, S)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EditorMiniButton(
                        label: "M",
                        color: Colors.redAccent,
                        refSize: refSize,
                      ),
                      SizedBox(width: 4),
                      EditorMiniButton(
                        label: "S",
                        color: Colors.yellow,
                        refSize: refSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Track Content (Waveform) - Full Width
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(() {
                    if (track.waveform.isEmpty) {
                      return Center(
                        child: TextWidget(
                          text: "No Data (Drop File / Double Click)",
                          fontSize: refSize * 0.03,
                          textColor: ColorClass.textSecondary,
                        ),
                      );
                    }
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (!isActive) return;
                        controller.setActiveTrack(track.id);

                        final double dx = details.localPosition.dx;
                        final pct = (dx / constraints.maxWidth).clamp(0.0, 1.0);

                        if (isActive) {
                          double distStart = (pct - track.startSelection.value)
                              .abs();
                          double distEnd = (pct - track.endSelection.value)
                              .abs();
                          if (distStart < distEnd) {
                            controller.updateSelection(
                              pct,
                              track.endSelection.value,
                            );
                          } else {
                            controller.updateSelection(
                              track.startSelection.value,
                              pct,
                            );
                          }
                        }
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: WaveformPainter(
                          samples: track.waveform,
                          startSelection: track.startSelection.value,
                          endSelection: track.endSelection.value,
                          playbackProgress: isActive
                              ? controller.playbackProgress.value
                              : 0.0,
                          waveColor: trackColor.withValues(alpha: 0.2),
                          selectedWaveColor: isActive
                              ? trackColor
                              : ColorClass.white,
                          selectionColor: isActive
                              ? trackColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
