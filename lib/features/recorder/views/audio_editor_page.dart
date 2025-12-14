import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/editor_control_button.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/editor_side_panel.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/track_slot_widget.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/files_panel_content.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/info_panel_content.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/effects_panel_content.dart';
import 'package:recorder/features/recorder/views/ai_page.dart';

class AudioEditorPage extends StatefulWidget {
  final String? filePath;

  const AudioEditorPage({super.key, this.filePath});

  @override
  State<AudioEditorPage> createState() => _AudioEditorPageState();
}

class _AudioEditorPageState extends State<AudioEditorPage> {
  late final AudioEditorController controller;

  // Controllers for editable fields
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _exportNameController = TextEditingController();

  Worker? _activeTrackWorker;
  Worker? _exportNameWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AudioEditorController());
    if (widget.filePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadFile(widget.filePath!);
      });
    }

    // Sync text fields when active track changes
    _activeTrackWorker = ever(controller.activeTrackIndex, (_) {
      _updateTextFields();
      _bindSelectionListeners();
    });

    _bindSelectionListeners();

    // Sync export name
    _exportNameWorker = ever(controller.exportFileName, (_) {
      if (_exportNameController.text != controller.exportFileName.value) {
        _exportNameController.text = controller.exportFileName.value;
      }
    });
  }

  Worker? _startWorker;
  Worker? _endWorker;

  void _bindSelectionListeners() {
    _startWorker?.dispose();
    _endWorker?.dispose();

    final track = controller.activeTrack;
    _updateTextFields(); // Initial update on switch

    _startWorker = ever(track.startSelection, (_) {
      if (mounted && !_startController.selection.isValid) {
        _startController.text = controller.formatTime(
          controller.activeTrack.startMs,
        );
      }
    });

    _endWorker = ever(track.endSelection, (_) {
      if (mounted && !_endController.selection.isValid) {
        _endController.text = controller.formatTime(
          controller.activeTrack.endMs,
        );
      }
    });
  }

  void _updateTextFields() {
    if (!mounted) return;
    _startController.text = controller.formatTime(
      controller.activeTrack.startMs,
    );
    _endController.text = controller.formatTime(controller.activeTrack.endMs);
  }

  @override
  void dispose() {
    _activeTrackWorker?.dispose();
    _exportNameWorker?.dispose();
    _startWorker?.dispose();
    _endWorker?.dispose();

    Get.delete<AudioEditorController>();
    _startController.dispose();
    _endController.dispose();
    _exportNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // LEFT PANEL (Files & Export)
                      EditorSidePanel(
                        width: size.width * 0.25,
                        refSize: refSize,
                        title: "Files",
                        child: FilesPanelContent(
                          refSize: refSize,
                          controller: controller,
                          exportNameController: _exportNameController,
                        ),
                      ),

                      // CENTER (Multi-Track)
                      Expanded(
                        child: DropTarget(
                          onDragDone: (detail) {
                            if (detail.files.isNotEmpty) {
                              controller.loadFile(detail.files.first.path);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(refSize * 0.02),
                            child: Column(
                              children: [
                                SizedBox(height: refSize * 0.02),

                                // Tracks Stack
                                Expanded(
                                  child: Obx(
                                    () => Column(
                                      children: controller.tracks.map((track) {
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              bottom: refSize * 0.02,
                                            ),
                                            child: DropTarget(
                                              onDragDone: (detail) {
                                                if (detail.files.isNotEmpty) {
                                                  controller.setActiveTrack(
                                                    track.id,
                                                  );
                                                  controller.loadFile(
                                                    detail.files.first.path,
                                                    trackIndex: track.id,
                                                  );
                                                }
                                              },
                                              child: TrackSlotWidget(
                                                refSize: refSize,
                                                track: track,
                                                isActive:
                                                    controller
                                                        .activeTrackIndex
                                                        .value ==
                                                    track.id,
                                                controller: controller,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // RIGHT PANELS (Info & Effects)
                      SizedBox(
                        width: size.width * 0.25,
                        child: Column(
                          children: [
                            // Info Panel (top)
                            Expanded(
                              flex: 1,
                              child: EditorSidePanel(
                                width: double.infinity,
                                refSize: refSize,
                                title: "Info",
                                child: InfoPanelContent(
                                  refSize: refSize,
                                  controller: controller,
                                  startController: _startController,
                                  endController: _endController,
                                ),
                              ),
                            ),
                            // Effects Panel (bottom)
                            Expanded(
                              flex: 1,
                              child: EditorSidePanel(
                                width: double.infinity,
                                refSize: refSize,
                                title: "Effects",
                                child: EffectsPanelContent(
                                  refSize: refSize,
                                  controller: controller,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // BOTTOM PANEL
                Container(
                  height: refSize * 0.2,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  decoration: BoxDecoration(
                    color: ColorClass.buttonBg,
                    border: Border(
                      top: BorderSide(
                        color: ColorClass.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EditorControlButton(
                        icon: Icons.content_cut,
                        onTap: () => controller.trimAudio(),
                        refSize: refSize,
                        color: Colors.redAccent,
                        bgColor: Colors.transparent,
                      ),
                      SizedBox(width: refSize * 0.06),

                      SizedBox(
                        width: refSize * 0.15,
                        height: refSize * 0.15,
                        child: FloatingActionButton(
                          onPressed: () => controller.playPreview(),
                          backgroundColor: ColorClass.white,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: refSize * 0.08,
                          ),
                        ),
                      ),

                      SizedBox(width: refSize * 0.06),
                      EditorControlButton(
                        icon: Icons.cut_outlined,
                        onTap: () => controller.cutAudio(),
                        refSize: refSize,
                        color: ColorClass.white,
                        bgColor: Colors.transparent,
                      ),
                      SizedBox(width: refSize * 0.06),
                      EditorControlButton(
                        icon: Icons.merge,
                        onTap: () => controller.mergeAndExport(),
                        refSize: refSize,
                        color: ColorClass.glowBlue,
                        bgColor: Colors.transparent,
                      ),
                      SizedBox(width: refSize * 0.06),
                      // AI Button
                      EditorControlButton(
                        icon: Icons.auto_awesome,
                        onTap: () {
                          if (controller.activeTrack.filePath.isNotEmpty) {
                            Get.to(
                              () => AiPage(
                                audioPath:
                                    controller.activeTrack.filePath.value,
                              ),
                            );
                          } else {
                            Get.snackbar('Error', 'No audio file loaded');
                          }
                        },
                        refSize: refSize,
                        color: ColorClass.glowPurple,
                        bgColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loading Overlay
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ColorClass.glowBlue,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
