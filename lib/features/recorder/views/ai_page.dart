import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/ai_analysis_service.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/ai_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

/// AI Transcription and Analysis Page - Split Layout Design
class AiPage extends StatefulWidget {
  final String audioPath;

  const AiPage({super.key, required this.audioPath});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  late final AiController controller;
  late final AudioPlayerService _audioPlayer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AiController());
    _audioPlayer = Get.find<AudioPlayerService>();
    controller.loadAudio(widget.audioPath);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    Get.delete<AiController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final refSize = size.shortestSide.clamp(400.0, 800.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      body: Row(
        children: [
          // LEFT PANEL - Audio Section
          Container(
            width: size.width * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorClass.glowPurple.withValues(alpha: 0.15),
                  ColorClass.darkBackground,
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: ColorClass.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: _buildAudioSection(refSize),
          ),

          // RIGHT PANEL - Transcription & Analysis
          Expanded(child: _buildTranscriptionSection(refSize)),
        ],
      ),
    );
  }

  /// Left panel: Audio player and controls
  Widget _buildAudioSection(double refSize) {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.02,
            vertical: refSize * 0.015,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: ColorClass.white,
                  size: refSize * 0.035,
                ),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Obx(
                  () => TextWidget(
                    text: controller.audioName.value,
                    textColor: ColorClass.white,
                    fontSize: refSize * 0.028,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Audio Visualization / Icon
        Container(
          width: refSize * 0.25,
          height: refSize * 0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ColorClass.glowBlue.withValues(alpha: 0.3),
                ColorClass.glowPurple.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: ColorClass.glowPurple.withValues(alpha: 0.3),
                blurRadius: refSize * 0.05,
                spreadRadius: refSize * 0.01,
              ),
            ],
          ),
          child: Icon(
            Icons.graphic_eq,
            color: ColorClass.white,
            size: refSize * 0.12,
          ),
        ),

        SizedBox(height: refSize * 0.04),

        // Audio Player Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildPlayButton(refSize)],
        ),

        SizedBox(height: refSize * 0.05),

        // Transcribe Button
        Obx(() {
          final hasTranscription = controller.hasTranscription.value;
          final isTranscribing = controller.isTranscribing.value;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: refSize * 0.03),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isTranscribing
                    ? null
                    : () => controller.transcribe(),
                icon: isTranscribing
                    ? SizedBox(
                        width: refSize * 0.03,
                        height: refSize * 0.03,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorClass.white,
                        ),
                      )
                    : Icon(
                        hasTranscription ? Icons.refresh : Icons.auto_awesome,
                        size: refSize * 0.035,
                      ),
                label: TextWidget(
                  text: isTranscribing
                      ? 'Transcribing...'
                      : hasTranscription
                      ? 'Re-transcribe'
                      : 'Transcribe Audio',
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.025,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorClass.glowBlue,
                  foregroundColor: ColorClass.white,
                  padding: EdgeInsets.symmetric(vertical: refSize * 0.025),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(refSize * 0.015),
                  ),
                ),
              ),
            ),
          );
        }),

        const Spacer(),

        // Export buttons
        Padding(
          padding: EdgeInsets.all(refSize * 0.02),
          child: Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  'TXT',
                  Icons.description_outlined,
                  () async {
                    final path = await controller.exportAsText();
                    if (path != null) Get.snackbar('Exported', 'Saved: $path');
                  },
                  refSize,
                ),
              ),
              SizedBox(width: refSize * 0.01),
              Expanded(
                child: _buildExportButton('MD', Icons.code, () async {
                  final path = await controller.exportAsMarkdown();
                  if (path != null) Get.snackbar('Exported', 'Saved: $path');
                }, refSize),
              ),
            ],
          ),
        ),

        SizedBox(height: refSize * 0.02),
      ],
    );
  }

  Widget _buildPlayButton(double refSize) {
    return Obx(() {
      final isPlaying = _audioPlayer.isPlaying.value;
      return GestureDetector(
        onTap: () async {
          if (isPlaying) {
            await _audioPlayer.stop();
          } else {
            await _audioPlayer.play(widget.audioPath);
          }
        },
        child: Container(
          width: refSize * 0.1,
          height: refSize * 0.1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorClass.white,
            boxShadow: [
              BoxShadow(
                color: ColorClass.white.withValues(alpha: 0.3),
                blurRadius: refSize * 0.02,
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: ColorClass.darkBackground,
            size: refSize * 0.06,
          ),
        ),
      );
    });
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    double refSize,
  ) {
    return Obx(() {
      final enabled = controller.hasTranscription.value;
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: refSize * 0.015),
          decoration: BoxDecoration(
            color: enabled
                ? ColorClass.buttonBg
                : ColorClass.buttonBg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(refSize * 0.01),
            border: Border.all(
              color: ColorClass.white.withValues(alpha: enabled ? 0.1 : 0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? ColorClass.white : ColorClass.textSecondary,
                size: refSize * 0.025,
              ),
              SizedBox(width: refSize * 0.01),
              TextWidget(
                text: label,
                textColor: enabled
                    ? ColorClass.white
                    : ColorClass.textSecondary,
                fontSize: refSize * 0.02,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Right panel: Transcription text and AI analysis
  Widget _buildTranscriptionSection(double refSize) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(refSize * 0.02),
          decoration: BoxDecoration(
            color: ColorClass.buttonBg,
            border: Border(
              bottom: BorderSide(
                color: ColorClass.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.text_snippet,
                color: ColorClass.glowBlue,
                size: refSize * 0.035,
              ),
              SizedBox(width: refSize * 0.01),
              TextWidget(
                text: 'Transcription',
                textColor: ColorClass.white,
                fontSize: refSize * 0.03,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              // Copy button
              Obx(() {
                if (controller.transcribedText.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: Icon(
                    Icons.copy,
                    color: ColorClass.textSecondary,
                    size: refSize * 0.03,
                  ),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: controller.transcribedText.value),
                    );
                    Get.snackbar('Copied', 'Text copied to clipboard');
                  },
                );
              }),
            ],
          ),
        ),

        // Error message
        Obx(() {
          if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            margin: EdgeInsets.all(refSize * 0.015),
            padding: EdgeInsets.all(refSize * 0.015),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(refSize * 0.01),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.3),
              ),
            ),
            child: TextWidget(
              text: controller.errorMessage.value,
              textColor: Colors.redAccent,
              fontSize: refSize * 0.02,
            ),
          );
        }),

        // Transcription content
        Expanded(
          flex: 3,
          child: Obx(() {
            if (controller.transcribedText.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic_none,
                      size: refSize * 0.1,
                      color: ColorClass.textSecondary.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: refSize * 0.02),
                    TextWidget(
                      text: 'Click "Transcribe Audio" to start',
                      textColor: ColorClass.textSecondary,
                      fontSize: refSize * 0.022,
                    ),
                  ],
                ),
              );
            }

            return Container(
              margin: EdgeInsets.all(refSize * 0.015),
              padding: EdgeInsets.all(refSize * 0.02),
              decoration: BoxDecoration(
                color: ColorClass.buttonBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(refSize * 0.015),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      controller.transcribedText.value,
                      style: TextStyle(
                        color: ColorClass.white,
                        fontSize: refSize * 0.024,
                        height: 1.6,
                      ),
                    ),
                    // Tags
                    if (controller.suggestedTags.isNotEmpty) ...[
                      SizedBox(height: refSize * 0.02),
                      Wrap(
                        spacing: refSize * 0.008,
                        runSpacing: refSize * 0.008,
                        children: controller.suggestedTags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: refSize * 0.012,
                                  vertical: refSize * 0.006,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorClass.glowPurple.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    refSize * 0.008,
                                  ),
                                ),
                                child: TextWidget(
                                  text: '#$tag',
                                  textColor: ColorClass.glowPurple,
                                  fontSize: refSize * 0.016,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),

        // AI Analysis Section
        Container(
          decoration: BoxDecoration(
            color: ColorClass.buttonBg,
            border: Border(
              top: BorderSide(color: ColorClass.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analysis header
              Padding(
                padding: EdgeInsets.all(refSize * 0.015),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: ColorClass.glowPurple,
                      size: refSize * 0.03,
                    ),
                    SizedBox(width: refSize * 0.01),
                    TextWidget(
                      text: 'AI Analysis',
                      textColor: ColorClass.white,
                      fontSize: refSize * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              // Analysis mode buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: refSize * 0.015),
                child: Row(
                  children: AnalysisMode.values
                      .map(
                        (mode) => Padding(
                          padding: EdgeInsets.only(right: refSize * 0.01),
                          child: _buildAnalysisModeButton(mode, refSize),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: refSize * 0.01),

              // Analysis result
              Obx(() {
                if (controller.isAnalyzing.value) {
                  return Padding(
                    padding: EdgeInsets.all(refSize * 0.03),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorClass.glowPurple,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (controller.analysisResult.isEmpty) {
                  return SizedBox(height: refSize * 0.01);
                }
                return Container(
                  width: double.infinity,
                  height: refSize * 0.2,
                  margin: EdgeInsets.all(refSize * 0.015),
                  padding: EdgeInsets.all(refSize * 0.015),
                  decoration: BoxDecoration(
                    color: ColorClass.glowPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(refSize * 0.01),
                    border: Border.all(
                      color: ColorClass.glowPurple.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      controller.analysisResult.value,
                      style: TextStyle(
                        color: ColorClass.white,
                        fontSize: refSize * 0.02,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisModeButton(AnalysisMode mode, double refSize) {
    final icons = {
      AnalysisMode.summarize: Icons.summarize,
      AnalysisMode.simplify: Icons.lightbulb_outline,
      AnalysisMode.actionItems: Icons.checklist,
      AnalysisMode.format: Icons.format_align_left,
    };

    final labels = {
      AnalysisMode.summarize: 'Summary',
      AnalysisMode.simplify: 'Simplify',
      AnalysisMode.actionItems: 'Actions',
      AnalysisMode.format: 'Format',
    };

    return Obx(() {
      final isSelected = controller.currentMode.value == mode;
      final hasText = controller.transcribedText.isNotEmpty;

      return GestureDetector(
        onTap: hasText && !controller.isAnalyzing.value
            ? () => controller.analyze(mode)
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.02,
            vertical: refSize * 0.012,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorClass.glowPurple
                : hasText
                ? ColorClass.darkBackground
                : ColorClass.darkBackground.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(refSize * 0.01),
            border: Border.all(
              color: isSelected
                  ? ColorClass.glowPurple
                  : hasText
                  ? ColorClass.white.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[mode],
                color: isSelected
                    ? ColorClass.white
                    : hasText
                    ? ColorClass.textSecondary
                    : ColorClass.textSecondary.withValues(alpha: 0.3),
                size: refSize * 0.025,
              ),
              SizedBox(width: refSize * 0.008),
              TextWidget(
                text: labels[mode]!,
                textColor: isSelected
                    ? ColorClass.white
                    : hasText
                    ? ColorClass.textSecondary
                    : ColorClass.textSecondary.withValues(alpha: 0.3),
                fontSize: refSize * 0.018,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
    });
  }
}
