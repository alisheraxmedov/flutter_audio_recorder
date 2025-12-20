import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/ai_analysis_service.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/ai_controller.dart';
import 'package:recorder/features/recorder/widgets/magic_widgets/magic_button.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/features/recorder/widgets/circle_button.dart';

class AiPage extends StatefulWidget {
  final String audioPath;

  const AiPage({super.key, required this.audioPath});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  late final AiController controller;
  late final AudioPlayerService _audioPlayer;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    controller = Get.put(AiController());
    _audioPlayer = Get.find<AudioPlayerService>();
    controller.loadAudio(widget.audioPath);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _audioPlayer.prepare(widget.audioPath); // Preload duration

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _glowController.dispose();
    Get.delete<AiController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final refSize = size.shortestSide.clamp(300.0, 800.0);

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      // Stack for background ambient effects
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: _buildAmbientOrb(refSize, ColorClass.glowPurple),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildAmbientOrb(refSize, ColorClass.glowBlue),
          ),

          // Main Glassmorphic Content
          SafeArea(
            child: _isDesktop
                ? _buildMagicDesktopLayout(size, refSize)
                : _buildMagicMobileLayout(size, refSize),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientOrb(double refSize, Color color) {
    return Container(
      width: refSize * 1.5,
      height: refSize * 1.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.15), ColorClass.transparent],
        ),
      ),
    );
  }

  /// DESKTOP LAYOUT - High Tech Dashboard Style
  Widget _buildMagicDesktopLayout(Size size, double refSize) {
    return Row(
      children: [
        Container(
          width: size.width * 0.28,
          margin: EdgeInsets.all(refSize * 0.02),
          padding: EdgeInsets.all(refSize * 0.03),
          decoration: _magicDecoration(refSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleButton(
                icon: Icons.arrow_back,
                onTap: () => Get.back(),
                size: refSize * 0.08,
                bgColor: ColorClass.white.withValues(alpha: 0.1),
                iconColor: ColorClass.white,
                iconSize: refSize * 0.04,
              ),
              SizedBox(height: refSize * 0.01),
              Obx(
                () => TextWidget(
                  text: controller.audioName.value,
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.022,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                ),
              ),

              const Spacer(),

              // Magic Orb Visualization
              Center(child: _buildMagicOrbWrapper(refSize * 0.15)),

              const Spacer(),

              // Compact Player Controls
              _buildCompactPlayer(refSize),

              SizedBox(height: refSize * 0.03),
              const Divider(color: ColorClass.borderLight),
              SizedBox(height: refSize * 0.03),

              // Quick Analysis Buttons
              _buildAnalysisButtonsGrid(refSize),
            ],
          ),
        ),

        // RIGHT CONTENT - Transcription Board (75%)
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              top: refSize * 0.02,
              bottom: refSize * 0.02,
              right: refSize * 0.02,
            ),
            decoration: _magicDecoration(refSize),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header
                _buildTranscriptionHeader(refSize),

                // Main Content
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildTranscriptionContent(refSize)),
                      // Optional Right Sidebar for Analysis (if exists)
                      Obx(() {
                        if (controller.analysisResult.isEmpty) return const SizedBox();
                        return Container(
                          width: size.width * 0.25,
                          decoration: BoxDecoration(
                            border: const Border(
                              left: BorderSide(color: ColorClass.borderLight),
                            ),
                            color: ColorClass.black.withValues(alpha: 0.2),
                          ),
                          child: _buildAnalysisResultPanel(refSize),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// MOBILE LAYOUT - Modern Sheet Style
  Widget _buildMagicMobileLayout(Size size, double refSize) {
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.04,
            vertical: refSize * 0.02,
          ),
          child: Row(
            children: [
              CircleButton(
                icon: Icons.arrow_back,
                onTap: () => Get.back(),
                size: refSize * 0.08,
                bgColor: ColorClass.white.withValues(alpha: 0.1),
                iconColor: ColorClass.white,
                iconSize: refSize * 0.04,
              ),
              SizedBox(width: refSize * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "AI STUDIO",
                      textColor: ColorClass.glowPurple,
                      fontSize: refSize * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                    Obx(
                      () => TextWidget(
                        text: controller.audioName.value,
                        textColor: ColorClass.white,
                        fontSize: refSize * 0.035,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMagicOrbWrapper(refSize * 0.12),
            ],
          ),
        ),

        // Compact Player Bar (Very minimalist)
        Container(
          margin: EdgeInsets.symmetric(horizontal: refSize * 0.04),
          padding: EdgeInsets.symmetric(
            vertical: refSize * 0.02,
            horizontal: refSize * 0.04,
          ),
          decoration: BoxDecoration(
            color: ColorClass.buttonBg.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(refSize * 0.1),
            border: Border.all(color: ColorClass.borderLight),
          ),
          child: _buildCompactPlayer(refSize),
        ),

        SizedBox(height: refSize * 0.02),

        // Main Transcription Area (Expanded)
        Expanded(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: refSize * 0.02),
            decoration: _magicDecoration(refSize),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    dividerColor: ColorClass.transparent,
                    indicatorColor: ColorClass.glowBlue,
                    labelColor: ColorClass.glowBlue,
                    unselectedLabelColor: ColorClass.textSecondary,
                    tabs: [
                      Tab(text: "TRANSCRIPT"),
                      Tab(text: "AI INSIGHTS"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTranscriptionContent(refSize),
                        _buildMobileAnalysisTab(refSize),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Action Bar
        _buildMobileBottomBar(refSize),
      ],
    );
  }

  // --- COMPONENTS ---

  BoxDecoration _magicDecoration(double refSize) {
    return BoxDecoration(
      color: ColorClass.buttonBg.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(refSize * 0.025),
      border: Border.all(color: ColorClass.white.withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(
          color: ColorClass.black.withValues(alpha: 0.2),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  Widget _buildMagicOrbWrapper(double size) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorClass.glowPurple, ColorClass.glowBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: ColorClass.glowPurple.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: ColorClass.glowBlue.withValues(
                  alpha: _glowAnimation.value,
                ),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              color: ColorClass.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactPlayer(double refSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: refSize * 0.02),
      child: Row(
        children: [
          // Play/Pause Button
          Obx(() {
            return CircleButton(
              icon: _audioPlayer.isPlaying.value
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              onTap: () {
                if (_audioPlayer.isPlaying.value) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play(widget.audioPath);
                }
              },
              size: refSize * 0.09,
              bgColor: ColorClass.transparent,
              iconColor: ColorClass.white,
              iconSize: refSize * 0.05,
            );
          }),

          SizedBox(width: refSize * 0.03),

          // Slider & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                Obx(() {
                  final position = _audioPlayer.position.value;
                  final duration = _audioPlayer.duration.value;
                  final progress = duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0;
                  return LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: ColorClass.white.withValues(alpha: 0.1),
                    color: ColorClass.glowBlue,
                    borderRadius: BorderRadius.circular(2),
                    minHeight: refSize * 0.01,
                  );
                }),
                SizedBox(height: refSize * 0.01),
                // Time Text
                Obx(() {
                  final position = _audioPlayer.position.value;
                  final duration = _audioPlayer.duration.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: _formatDuration(position),
                        textColor: ColorClass.white,
                        fontSize: refSize * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                      TextWidget(
                        text: _formatDuration(duration),
                        textColor: ColorClass.textSecondary,
                        fontSize: refSize * 0.02,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionHeader(double refSize) {
    return Container(
      padding: EdgeInsets.all(refSize * 0.03),
      decoration: const BoxDecoration(
        color: ColorClass.transparent,
        border: Border(bottom: BorderSide(color: ColorClass.borderLight)),
      ),
      child: Row(
        children: [
          Icon(Icons.notes, color: ColorClass.glowBlue, size: refSize * 0.04),
          SizedBox(width: refSize * 0.02),
          TextWidget(
            text: "TRANSCRIPT",
            textColor: ColorClass.white,
            fontWeight: FontWeight.bold,
            fontSize: refSize * 0.025,
          ),
          const Spacer(),
          _buildActionButton(Icons.copy, "Copy", () => _copyText(), refSize),
          SizedBox(width: refSize * 0.02),
          _buildActionButton(
            Icons.download,
            "Export",
            () => _showExportOptions(refSize),
            refSize,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionContent(double refSize) {
    return Obx(() {
      if (controller.isTranscribing.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ColorClass.glowPurple),
              SizedBox(height: refSize * 0.04),
              TextWidget(
                text: "AI is listening...",
                textColor: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
            ],
          ),
        );
      }

      if (controller.transcribedText.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.graphic_eq,
                size: refSize * 0.1,
                color: ColorClass.white.withValues(alpha: 0.1),
              ),
              SizedBox(height: refSize * 0.02),
              TextWidget(
                text: "Ready to Transcribe",
                textColor: ColorClass.textSecondary,
                fontSize: refSize * 0.03,
              ),
              SizedBox(height: refSize * 0.04),
              MagicButton(
                label: "START TRANSCRIPTION",
                onPressed: () => controller.transcribe(),
                padding: EdgeInsets.symmetric(
                  vertical: refSize * 0.015,
                  horizontal: refSize * 0.025,
                ),
                width: refSize * 0.5,
                height: refSize * 0.07,
                fontSize: refSize * 0.02,
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(refSize * 0.04),
        children: [
          SelectableText(
            controller.transcribedText.value,
            style: TextStyle(
              color: ColorClass.white.withValues(alpha: 0.9),
              fontSize: refSize * 0.035,
              height: 1.8,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: refSize * 0.04),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.suggestedTags
                .map(
                  (tag) => Chip(
                    label: TextWidget(
                      text: "#$tag",
                      textColor: ColorClass.glowPurple,
                      fontSize: refSize * 0.02,
                    ),
                    backgroundColor: ColorClass.glowPurple.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: const TextStyle(color: ColorClass.glowPurple),
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }

  // ================================================================================

  Widget _buildMobileAnalysisTab(double refSize) {
    return Padding(
      padding: EdgeInsets.all(refSize * 0.03),
      child: Column(
        children: [
          _buildAnalysisButtonsGrid(refSize),
          SizedBox(height: refSize * 0.04),
          Expanded(child: _buildAnalysisResultPanel(refSize)),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultPanel(double refSize) {
    return Obx(() {
      if (controller.isAnalyzing.value) {
        return const Center(
          child: CircularProgressIndicator(color: ColorClass.glowBlue),
        );
      }
      if (controller.analysisResult.isEmpty) {
        return Center(
          child: TextWidget(
            text: "Select a magic tool to analyze",
            textColor: ColorClass.textSecondary.withValues(alpha: 0.5),
            fontSize: refSize * 0.03,
          ),
        );
      }
      return Container(
        padding: EdgeInsets.all(refSize * 0.03),
        decoration: BoxDecoration(
          color: ColorClass.glowPurple.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorClass.glowPurple.withValues(alpha: 0.2),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: ColorClass.glowBlue,
                    size: refSize * 0.04,
                  ),
                  const SizedBox(width: 8),
                  TextWidget(
                    text: "INSIGHTS",
                    textColor: ColorClass.glowBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: refSize * 0.03,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SelectableText(
                controller.analysisResult.value,
                style: TextStyle(
                  color: ColorClass.white,
                  fontSize: refSize * 0.032,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAnalysisButtonsGrid(double refSize) {
    return Wrap(
      spacing: refSize * 0.015,
      runSpacing: refSize * 0.015,
      alignment: WrapAlignment.center,
      children: AnalysisMode.values.map((mode) {
        return MagicButton(
          label: controller.getModeDisplayName(mode),
          onPressed: () => controller.analyze(mode),
          padding: EdgeInsets.symmetric(
            vertical: refSize * 0.0,
            horizontal: refSize * 0.0,
          ),
          width: refSize * 0.15,
          height: refSize * 0.06,
          fontSize: refSize * 0.012,
        );
      }).toList(),
    );
  }

  Widget _buildMobileBottomBar(double refSize) {
    return Container(
      padding: EdgeInsets.all(refSize * 0.04),
      decoration: const BoxDecoration(
        color: ColorClass.darkBackground,
        border: Border(top: BorderSide(color: ColorClass.borderLight)),
      ),
      child: Obx(() {
        final hasText = controller.hasTranscription.value;
        if (!hasText) return const SizedBox.shrink();

        return Row(
          children: [
            Expanded(
              child: MagicButton(
                label: "RE-TRANSCRIBE",
                onPressed: () => controller.transcribe(),
                padding: EdgeInsets.symmetric(
                  vertical: refSize * 0.015,
                  horizontal: refSize * 0.025,
                ),
                width: refSize * 0.2,
                height: refSize * 0.05,
                fontSize: refSize * 0.02,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MagicButton(
                label: "EXPORT",
                onPressed: () => _showExportOptions(refSize),
                padding: EdgeInsets.symmetric(
                  vertical: refSize * 0.015,
                  horizontal: refSize * 0.025,
                ),
                width: refSize * 0.2,
                height: refSize * 0.05,
                fontSize: refSize * 0.02,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
    double refSize,
  ) {
    return IconButton(
      icon: Icon(icon, color: ColorClass.textSecondary, size: refSize * 0.04),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }

  void _copyText() {
    if (controller.transcribedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: controller.transcribedText.value));
    Get.snackbar(
      "Magic",
      "Text copied to clipboard",
      colorText: ColorClass.white,
      backgroundColor: ColorClass.glowPurple.withValues(alpha: 0.8),
    );
  }

  void _showExportOptions(double refSize) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ColorClass.buttonBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.description,
                color: ColorClass.folderIcon,
              ),
              title: const TextWidget(
                text: "Export as Text (.txt)",
                textColor: ColorClass.white,
                fontSize: 16,
              ),
              onTap: () async {
                Get.back();
                final path = await controller.exportAsText();
                if (path != null) Get.snackbar("Success", "Saved to $path");
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: ColorClass.glowBlue),
              title: const TextWidget(
                text: "Export as Markdown (.md)",
                textColor: ColorClass.white,
                fontSize: 16,
              ),
              onTap: () async {
                Get.back();
                final path = await controller.exportAsMarkdown();
                if (path != null) Get.snackbar("Success", "Saved to $path");
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
