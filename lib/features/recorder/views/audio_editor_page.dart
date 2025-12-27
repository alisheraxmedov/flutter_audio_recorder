import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/widgets/circle_button.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/editor_side_panel.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/track_slot_widget.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/files_panel_content.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/info_panel_content.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/effects_panel_content.dart';
import 'package:recorder/features/recorder/views/ai_page.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

// Desktop uchun conditional import
import 'package:recorder/core/utils/drop_target_stub.dart'
    if (dart.library.io) 'package:recorder/core/utils/drop_target_helper.dart'
    as drop_helper;

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

  // Platform tekshiruvi
  bool get _isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

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

  Future<void> _pickAudioFile({int? trackIndex}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        if (trackIndex != null) {
          controller.setActiveTrack(trackIndex);
          controller.loadFile(path, trackIndex: trackIndex);
        } else {
          controller.loadFile(path);
        }
      }
    }
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
            _isDesktop
                ? _buildDesktopLayout(context, size, refSize)
                : _buildMobileLayout(context, size, refSize),

            // Loading Overlay
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      color: ColorClass.black54,
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

  Widget _buildDesktopLayout(BuildContext context, Size size, double refSize) {
    return Column(
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

              // CENTER (Multi-Track) - Desktop DropTarget
              Expanded(
                child: drop_helper.buildDropTarget(
                  onFileDrop: (path) => controller.loadFile(path),
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
                                    child: drop_helper.buildDropTarget(
                                      onFileDrop: (path) {
                                        controller.setActiveTrack(track.id);
                                        controller.loadFile(
                                          path,
                                          trackIndex: track.id,
                                        );
                                      },
                                      child: TrackSlotWidget(
                                        refSize: refSize,
                                        track: track,
                                        isActive:
                                            controller.activeTrackIndex.value ==
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
        _buildBottomControlPanel(size, refSize),
      ],
    );
  }

  /// Mobile uchun layout - Tab based design (Desktop funksiyalari bilan)
  Widget _buildMobileLayout(BuildContext context, Size size, double refSize) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // AppBar with Tabs
          Container(
            color: ColorClass.buttonBg,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: refSize * 0.04,
                      vertical: refSize * 0.02,
                    ),
                    child: Row(
                      children: [
                        TextWidget(
                          text: 'Audio Editor',
                          textColor: ColorClass.white,
                          fontSize: refSize * 0.05,
                          fontWeight: FontWeight.w600,
                        ),
                        const Spacer(),
                        // Add File Button
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: ColorClass.glowBlue,
                            size: refSize * 0.06,
                          ),
                          onPressed: () => _pickAudioFile(),
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  TabBar(
                    indicatorColor: ColorClass.glowBlue,
                    labelColor: ColorClass.white,
                    unselectedLabelColor: ColorClass.textSecondary,
                    labelStyle: TextStyle(fontSize: refSize * 0.035),
                    tabs: const [
                      Tab(text: 'Tracks'),
                      Tab(text: 'Info'),
                      Tab(text: 'Effects'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // TAB 1: Tracks
                _buildMobileTracksTab(size, refSize),

                // TAB 2: Info Panel
                SingleChildScrollView(
                  padding: EdgeInsets.all(refSize * 0.04),
                  child: InfoPanelContent(
                    refSize: refSize,
                    controller: controller,
                    startController: _startController,
                    endController: _endController,
                  ),
                ),

                // TAB 3: Effects Panel
                SingleChildScrollView(
                  padding: EdgeInsets.all(refSize * 0.04),
                  child: EffectsPanelContent(
                    refSize: refSize,
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM CONTROL PANEL
          _buildBottomControlPanel(size, refSize),
        ],
      ),
    );
  }

  /// Mobile Tracks Tab
  Widget _buildMobileTracksTab(Size size, double refSize) {
    return Column(
      children: [
        // Files Panel (compact)
        Container(
          margin: EdgeInsets.all(refSize * 0.03),
          padding: EdgeInsets.all(refSize * 0.03),
          decoration: BoxDecoration(
            color: ColorClass.buttonBg,
            borderRadius: BorderRadius.circular(refSize * 0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Export Name',
                    textColor: ColorClass.textSecondary,
                    fontSize: refSize * 0.03,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _exportNameController,
                      style: TextStyle(
                        color: ColorClass.white,
                        fontSize: refSize * 0.035,
                      ),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) =>
                          controller.exportFileName.value = value,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tracks List
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: refSize * 0.03),
              itemCount: controller.tracks.length,
              itemBuilder: (context, index) {
                final track = controller.tracks[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: refSize * 0.02),
                  child: SizedBox(
                    height:
                        refSize *
                        0.35, // Aniq height berish - RenderFlex xatosi tuzatildi
                    child: GestureDetector(
                      onTap: () => controller.setActiveTrack(track.id),
                      onLongPress: () => _pickAudioFile(trackIndex: track.id),
                      child: TrackSlotWidget(
                        refSize: refSize,
                        track: track,
                        isActive: controller.activeTrackIndex.value == track.id,
                        controller: controller,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Umumiy bottom control panel
  Widget _buildBottomControlPanel(Size size, double refSize) {
    return Container(
      height: refSize * 0.18,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        border: Border(
          top: BorderSide(color: ColorClass.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Trim
          CircleButton(
            icon: Icons.content_cut,
            onTap: () => controller.trimAudio(),
            size: refSize * 0.1,
            iconColor: ColorClass.redAccent,
            bgColor: ColorClass.transparent,
            border: Border.all(
              color: ColorClass.redAccent.withValues(alpha: 0.5),
            ),
            iconSize: refSize * 0.05,
          ),

          // Play
          CircleButton(
            icon: Icons.play_arrow,
            onTap: () => controller.playPreview(),
            size: refSize * 0.13,
            bgColor: ColorClass.white,
            iconColor: ColorClass.black,
            iconSize: refSize * 0.07,
          ),

          // Cut
          CircleButton(
            icon: Icons.cut_outlined,
            onTap: () => controller.cutAudio(),
            size: refSize * 0.1,
            iconColor: ColorClass.white,
            bgColor: ColorClass.transparent,
            border: Border.all(color: ColorClass.white.withValues(alpha: 0.5)),
            iconSize: refSize * 0.05,
          ),

          // Merge
          CircleButton(
            icon: Icons.merge,
            onTap: () => controller.mergeAndExport(),
            size: refSize * 0.1,
            iconColor: ColorClass.glowBlue,
            bgColor: ColorClass.transparent,
            border: Border.all(
              color: ColorClass.glowBlue.withValues(alpha: 0.5),
            ),
            iconSize: refSize * 0.05,
          ),

          // AI Button
          CircleButton(
            icon: Icons.auto_awesome,
            onTap: () {
              if (controller.activeTrack.filePath.isNotEmpty) {
                Get.to(
                  transition: Transition.fadeIn,
                  duration: Duration(milliseconds: 500),
                  () {
                    return AiPage(
                      audioPath: controller.activeTrack.filePath.value,
                    );
                  },
                );
              } else {
                Get.snackbar('Error', 'No audio file loaded');
              }
            },
            size: refSize * 0.1,
            iconColor: ColorClass.glowPurple,
            bgColor: ColorClass.transparent,
            border: Border.all(
              color: ColorClass.glowPurple.withValues(alpha: 0.5),
            ),
            iconSize: refSize * 0.05,
          ),
        ],
      ),
    );
  }
}
