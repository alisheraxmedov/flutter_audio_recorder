import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/widgets/audio_editor/waveform_painter.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class AudioEditorPage extends StatefulWidget {
  final String filePath;

  const AudioEditorPage({super.key, required this.filePath});

  @override
  State<AudioEditorPage> createState() => _AudioEditorPageState();
}

class _AudioEditorPageState extends State<AudioEditorPage> {
  late final AudioEditorController controller;

  // Controllers for editable fields
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _exportNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(AudioEditorController());
    controller.loadFile(widget.filePath);

    // Sync text fields when selection changes programmatically (e.g. dragging)
    ever(controller.startSelection, (_) {
      if (!_startController.selection.isValid) {
        _startController.text = controller.formatTime(controller.startMs);
      }
    });
    ever(controller.endSelection, (_) {
      if (!_endController.selection.isValid) {
        _endController.text = controller.formatTime(controller.endMs);
      }
    });
    // Sync export name
    ever(controller.exportFileName, (_) {
      if (_exportNameController.text != controller.exportFileName.value) {
        _exportNameController.text = controller.exportFileName.value;
      }
    });
  }

  @override
  void dispose() {
    Get.delete<AudioEditorController>();
    _startController.dispose();
    _endController.dispose();
    _exportNameController.dispose();
    super.dispose();
  }

  void _submitSelection() {
    controller.updateSelectionFromText(
      _startController.text,
      _endController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorClass.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => TextWidget(
            // Granular Obx for title
            text: controller.fileName.value,
            textColor: ColorClass.white,
            fontSize: refSize * 0.035,
          ),
        ),
        centerTitle: true,
      ),
      // Removed top-level Obx wrapper to avoid "Improper Use" error
      // Use Obx only where specific observables are read.
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // LEFT PANEL (Files & Export)
                    _buildSidePanel(
                      width: size.width * 0.25,
                      refSize: refSize,
                      title: "Files",
                      child: _buildFilesContent(
                        refSize,
                      ), // Contains internal Obx
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
                                child: Column(
                                  children: [
                                    // Track 1 (Active)
                                    Expanded(
                                      child: _buildTrackSlot(
                                        refSize: refSize,
                                        trackName: "Track 1",
                                        color: ColorClass.glowBlue,
                                        isActive: true,
                                      ),
                                    ),
                                    SizedBox(height: refSize * 0.02),
                                    // Track 2 (Empty)
                                    Expanded(
                                      child: _buildTrackSlot(
                                        refSize: refSize,
                                        trackName: "Track 2",
                                        color: Colors.purpleAccent,
                                        isActive: false,
                                      ),
                                    ),
                                    SizedBox(height: refSize * 0.02),
                                    // Track 3 (Empty)
                                    Expanded(
                                      child: _buildTrackSlot(
                                        refSize: refSize,
                                        trackName: "Track 3",
                                        color: Colors.orangeAccent,
                                        isActive: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // RIGHT PANEL (Info & Selection)
                    _buildSidePanel(
                      width: size.width * 0.25,
                      refSize: refSize,
                      title: "Info",
                      child: _buildInfoContent(
                        refSize,
                      ), // Contains internal Obx
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
                    _controlButton(
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
                    _controlButton(
                      icon: Icons.cut_outlined,
                      onTap: () => controller.cutAudio(),
                      refSize: refSize,
                      color: ColorClass.white,
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
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double refSize,
    required Color color,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: refSize * 0.1,
        height: refSize * 0.1,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: refSize * 0.05),
      ),
    );
  }

  Widget _buildSidePanel({
    required double width,
    required double refSize,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(vertical: refSize * 0.02),
      decoration: BoxDecoration(
        color: ColorClass.buttonBg,
        border: Border(
          right: title == "Files"
              ? BorderSide(color: ColorClass.white.withValues(alpha: 0.1))
              : BorderSide.none,
          left: title == "Info"
              ? BorderSide(color: ColorClass.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(refSize * 0.03),
            color: Colors.black.withValues(alpha: 0.2),
            child: TextWidget(
              text: title,
              fontSize: refSize * 0.03,
              textColor: ColorClass.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(refSize * 0.03),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesContent(double refSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => controller.pickFile(),
          icon: Icon(
            Icons.add,
            color: ColorClass.glowBlue,
            size: refSize * 0.035,
          ),
          label: TextWidget(
            text: "Add File",
            fontSize: refSize * 0.025,
            textColor: ColorClass.glowBlue,
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ColorClass.glowBlue.withValues(alpha: 0.5)),
            padding: EdgeInsets.symmetric(vertical: refSize * 0.02),
          ),
        ),
        SizedBox(height: refSize * 0.03),

        TextWidget(
          text: "Project Files",
          fontSize: refSize * 0.025,
          textColor: ColorClass.textSecondary,
        ),
        SizedBox(height: refSize * 0.01),
        Obx(
          () => Container(
            padding: EdgeInsets.all(refSize * 0.02),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorClass.glowBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.audio_file,
                  color: ColorClass.white,
                  size: refSize * 0.035,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextWidget(
                    text: controller.fileName.value,
                    fontSize: refSize * 0.025,
                    textColor: ColorClass.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        Spacer(),

        TextWidget(
          text: "Export Name",
          fontSize: refSize * 0.025,
          textColor: ColorClass.textSecondary,
        ),
        SizedBox(height: refSize * 0.01),
        TextField(
          controller: _exportNameController,
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
                Icon(
                  Icons.folder,
                  size: refSize * 0.03,
                  color: ColorClass.textSecondary,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: refSize * 0.03),
        ElevatedButton(
          onPressed: () => Get.back(), // Placeholder
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorClass.glowBlue,
            padding: EdgeInsets.symmetric(vertical: refSize * 0.025),
          ),
          child: TextWidget(
            text: "Export Audio",
            fontSize: refSize * 0.025,
            textColor: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContent(double refSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => _infoRow("Format", controller.fileFormat.value, refSize)),
        Obx(() => _infoRow("Size", controller.fileSize.value, refSize)),
        Obx(
          () => _infoRow(
            "Duration",
            controller.formatTime(controller.totalDurationMs.value),
            refSize,
          ),
        ),
        Divider(
          color: ColorClass.white.withValues(alpha: 0.1),
          height: refSize * 0.05,
        ),

        TextWidget(
          text: "Selection Range",
          fontSize: refSize * 0.025,
          textColor: ColorClass.glowBlue,
        ),
        SizedBox(height: refSize * 0.02),

        _timeInput("Start", _startController, refSize),
        SizedBox(height: refSize * 0.015),
        _timeInput("End", _endController, refSize),
      ],
    );
  }

  Widget _timeInput(String label, TextEditingController ctrl, double refSize) {
    return Row(
      children: [
        SizedBox(
          width: refSize * 0.1,
          child: TextWidget(
            text: label,
            fontSize: refSize * 0.025,
            textColor: ColorClass.textSecondary,
          ),
        ),
        Expanded(
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => _submitSelection(),
            style: TextStyle(
              color: ColorClass.white,
              fontSize: refSize * 0.025,
              fontFamily: 'Monospace',
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
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorClass.glowBlue),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, double refSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: refSize * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            text: label,
            fontSize: refSize * 0.025,
            textColor: ColorClass.textSecondary,
          ),
          TextWidget(
            text: value,
            fontSize: refSize * 0.025,
            textColor: ColorClass.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackSlot({
    required double refSize,
    required String trackName,
    required Color color,
    bool isActive = false,
  }) {
    Widget slotContent = Container(
      decoration: BoxDecoration(
        color: ColorClass.buttonBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(refSize * 0.03),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.5)
              : ColorClass.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Track Header (Left)
          Container(
            width: refSize * 0.25,
            padding: EdgeInsets.all(refSize * 0.02),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(refSize * 0.03),
              ),
              border: Border(
                right: BorderSide(
                  color: ColorClass.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq, color: color, size: refSize * 0.03),
                    SizedBox(width: 4),
                    Expanded(
                      child: TextWidget(
                        text: trackName,
                        fontSize: refSize * 0.025,
                        textColor: ColorClass.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    _miniButton("M", Colors.redAccent, refSize),
                    SizedBox(width: 4),
                    _miniButton("S", Colors.yellow, refSize),
                  ],
                ),
              ],
            ),
          ),

          // Track Content (Waveform)
          Expanded(
            child: isActive
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      // WRAP THIS IN OBX TO REACT TO WAVEFORM & SELECTION CHANGES
                      return Obx(() {
                        if (controller.waveform.isEmpty) {
                          return Center(
                            child: TextWidget(
                              text: "No Data",
                              fontSize: refSize * 0.03,
                              textColor: ColorClass.textSecondary,
                            ),
                          );
                        }
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final double dx = details.localPosition.dx;
                            final pct = (dx / constraints.maxWidth).clamp(
                              0.0,
                              1.0,
                            );
                            double distStart =
                                (pct - controller.startSelection.value).abs();
                            double distEnd =
                                (pct - controller.endSelection.value).abs();
                            if (distStart < distEnd) {
                              controller.updateSelection(
                                pct,
                                controller.endSelection.value,
                              );
                            } else {
                              controller.updateSelection(
                                controller.startSelection.value,
                                pct,
                              );
                            }
                          },
                          child: CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: WaveformPainter(
                              samples: controller.waveform,
                              startSelection: controller.startSelection.value,
                              endSelection: controller.endSelection.value,
                              waveColor: ColorClass.white.withValues(
                                alpha: 0.2,
                              ),
                              selectedWaveColor: ColorClass.glowBlue,
                              selectionColor: ColorClass.glowBlue.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  )
                : Container(
                    alignment: Alignment.center,
                    child: TextWidget(
                      text: "Empty Track",
                      fontSize: refSize * 0.02,
                      textColor: ColorClass.textSecondary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );

    return slotContent;
  }

  Widget _miniButton(String label, Color color, double refSize) {
    return Container(
      width: refSize * 0.04,
      height: refSize * 0.04,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: TextWidget(
        text: label,
        fontSize: refSize * 0.02,
        textColor: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
