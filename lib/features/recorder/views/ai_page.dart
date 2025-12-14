import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/ai_analysis_service.dart';
import 'package:recorder/features/recorder/controllers/ai_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

/// AI Transcription and Analysis Page
class AiPage extends StatefulWidget {
  final String audioPath;

  const AiPage({super.key, required this.audioPath});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  late final AiController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AiController());
    controller.loadAudio(widget.audioPath);
  }

  @override
  void dispose() {
    Get.delete<AiController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final refSize = size.shortestSide.clamp(0.0, 500.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        backgroundColor: ColorClass.buttonBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorClass.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => TextWidget(
            text: controller.audioName.value,
            textColor: ColorClass.white,
            fontSize: refSize * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // Export menu
          PopupMenuButton<String>(
            icon: Icon(Icons.download, color: ColorClass.white),
            color: ColorClass.buttonBg,
            onSelected: (value) async {
              String? path;
              if (value == 'txt') {
                path = await controller.exportAsText();
              } else if (value == 'md') {
                path = await controller.exportAsMarkdown();
              }
              if (path != null) {
                Get.snackbar('Exported', 'Saved to: $path');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'txt',
                child: TextWidget(
                  text: 'Export as TXT',
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.025,
                ),
              ),
              PopupMenuItem(
                value: 'md',
                child: TextWidget(
                  text: 'Export as Markdown',
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.025,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Transcribe Button
            Obx(() {
              if (!controller.hasTranscription.value) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(refSize * 0.03),
                  child: ElevatedButton.icon(
                    onPressed: controller.isTranscribing.value
                        ? null
                        : () => controller.transcribe(),
                    icon: controller.isTranscribing.value
                        ? SizedBox(
                            width: refSize * 0.04,
                            height: refSize * 0.04,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorClass.white,
                            ),
                          )
                        : Icon(Icons.mic, size: refSize * 0.05),
                    label: TextWidget(
                      text: controller.isTranscribing.value
                          ? 'Transcribing...'
                          : 'Transcribe Audio',
                      textColor: ColorClass.white,
                      fontSize: refSize * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.glowBlue,
                      foregroundColor: ColorClass.white,
                      padding: EdgeInsets.symmetric(
                        vertical: refSize * 0.03,
                        horizontal: refSize * 0.05,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(refSize * 0.02),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Error message
            Obx(() {
              if (controller.errorMessage.isNotEmpty) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: refSize * 0.03),
                  padding: EdgeInsets.all(refSize * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(refSize * 0.01),
                  ),
                  child: TextWidget(
                    text: controller.errorMessage.value,
                    textColor: Colors.redAccent,
                    fontSize: refSize * 0.022,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Transcription Text
            Expanded(
              child: Obx(() {
                if (controller.transcribedText.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.text_snippet_outlined,
                          size: refSize * 0.15,
                          color: ColorClass.textSecondary,
                        ),
                        SizedBox(height: refSize * 0.02),
                        TextWidget(
                          text: 'Transcription will appear here',
                          textColor: ColorClass.textSecondary,
                          fontSize: refSize * 0.025,
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(refSize * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transcription header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Transcription',
                            textColor: ColorClass.glowBlue,
                            fontSize: refSize * 0.028,
                            fontWeight: FontWeight.w600,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: ColorClass.textSecondary,
                              size: refSize * 0.04,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: controller.transcribedText.value,
                                ),
                              );
                              Get.snackbar(
                                'Copied',
                                'Text copied to clipboard',
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: refSize * 0.01),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(refSize * 0.02),
                        decoration: BoxDecoration(
                          color: ColorClass.buttonBg,
                          borderRadius: BorderRadius.circular(refSize * 0.015),
                        ),
                        child: SelectableText(
                          controller.transcribedText.value,
                          style: TextStyle(
                            color: ColorClass.white,
                            fontSize: refSize * 0.025,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Tags
                      if (controller.suggestedTags.isNotEmpty) ...[
                        SizedBox(height: refSize * 0.02),
                        Wrap(
                          spacing: refSize * 0.01,
                          runSpacing: refSize * 0.01,
                          children: controller.suggestedTags
                              .map(
                                (tag) => Chip(
                                  label: TextWidget(
                                    text: tag,
                                    textColor: ColorClass.white,
                                    fontSize: refSize * 0.018,
                                  ),
                                  backgroundColor: ColorClass.glowPurple,
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // Analysis Section
                      SizedBox(height: refSize * 0.03),
                      TextWidget(
                        text: 'AI Analysis',
                        textColor: ColorClass.glowBlue,
                        fontSize: refSize * 0.028,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: refSize * 0.015),

                      // Analysis mode buttons
                      Wrap(
                        spacing: refSize * 0.01,
                        runSpacing: refSize * 0.01,
                        children: AnalysisMode.values.map((mode) {
                          return _buildAnalysisModeButton(mode, refSize);
                        }).toList(),
                      ),

                      // Analysis result
                      Obx(() {
                        if (controller.isAnalyzing.value) {
                          return Padding(
                            padding: EdgeInsets.all(refSize * 0.04),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorClass.glowBlue,
                              ),
                            ),
                          );
                        }
                        if (controller.analysisResult.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: refSize * 0.02),
                            padding: EdgeInsets.all(refSize * 0.02),
                            decoration: BoxDecoration(
                              color: ColorClass.buttonBg,
                              borderRadius: BorderRadius.circular(
                                refSize * 0.015,
                              ),
                              border: Border.all(
                                color: ColorClass.glowPurple.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: SelectableText(
                              controller.analysisResult.value,
                              style: TextStyle(
                                color: ColorClass.white,
                                fontSize: refSize * 0.024,
                                height: 1.5,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisModeButton(AnalysisMode mode, double refSize) {
    final icons = {
      AnalysisMode.summarize: Icons.summarize,
      AnalysisMode.simplify: Icons.auto_fix_high,
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
      return GestureDetector(
        onTap: controller.isAnalyzing.value
            ? null
            : () => controller.analyze(mode),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.025,
            vertical: refSize * 0.015,
          ),
          decoration: BoxDecoration(
            color: isSelected ? ColorClass.glowPurple : ColorClass.buttonBg,
            borderRadius: BorderRadius.circular(refSize * 0.01),
            border: Border.all(
              color: isSelected
                  ? ColorClass.glowPurple
                  : ColorClass.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[mode],
                color: isSelected ? ColorClass.white : ColorClass.textSecondary,
                size: refSize * 0.035,
              ),
              SizedBox(width: refSize * 0.01),
              TextWidget(
                text: labels[mode]!,
                textColor: isSelected
                    ? ColorClass.white
                    : ColorClass.textSecondary,
                fontSize: refSize * 0.02,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
    });
  }
}
