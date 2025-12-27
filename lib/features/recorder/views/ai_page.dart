import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/core/services/ai_analysis_service.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/features/recorder/controllers/ai_controller.dart';
import 'package:recorder/features/recorder/widgets/app_dialog.dart';
import 'package:recorder/features/recorder/widgets/magic_widgets/magic_button.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

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
    _audioPlayer.prepare(widget.audioPath);
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
      backgroundColor: const Color(0xFF0F172A), // Deep Slate Navy
      body: Stack(
        children: [
          SafeArea(
            child: _isDesktop
                ? _buildMagicDesktopLayout(size, refSize)
                : _buildMagicMobileLayout(size, refSize),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicDesktopLayout(Size size, double refSize) {
    return Row(
      children: [
        // Sidebar - Dynamic (original 200px)
        Container(
          width: refSize * 0.25,
          margin: EdgeInsets.all(refSize * 0.01),
          padding: EdgeInsets.all(refSize * 0.01),
          decoration: BoxDecoration(
            color: const Color(
              0xFF1E293B,
            ).withValues(alpha: 0.5), // Slate 800 transparent
            borderRadius: BorderRadius.circular(refSize * 0.01),
            border: Border.all(color: ColorClass.white10, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Block - Compact
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back,
                        color: ColorClass.white70,
                        size: refSize * 0.02,
                      ),
                    ),
                  ),
                  SizedBox(width: refSize * 0.01),
                  Expanded(
                    child: Obx(
                      () => TextWidget(
                        text: controller.audioName.value,
                        textColor: ColorClass.white70,
                        fontSize: refSize * 0.015,
                        fontWeight: FontWeight.w500,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: refSize * 0.02),

              // AI Actions (Thin Buttons)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildAnalysisButtonsVertical(refSize),
                ),
              ),

              SizedBox(height: refSize * 0.01),

              // Player Block - Linear & Compact
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: refSize * 0.01,
                  vertical: refSize * 0.005,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: ColorClass.white10, width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildHorizontalWaveform(refSize),
                    SizedBox(height: refSize * 0.005),
                    _buildCompactPlayer(refSize),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main Workspace
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              top: refSize * 0.01,
              bottom: refSize * 0.01,
              right: refSize * 0.01,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(refSize * 0.015),
              border: Border.all(color: ColorClass.white10, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(refSize * 0.015),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Column(
                  children: [
                    _buildTranscriptionHeader(refSize),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildTranscriptionContent(refSize)),
                          // Optional Right Panel (Analysis)
                          Obx(() {
                            if (controller.analysisResult.isEmpty) {
                              return const SizedBox();
                            }
                            return Container(
                              width: refSize * 0.44,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: ColorClass.white10,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: _buildAnalysisResultPanel(refSize),
                            );
                          }),
                        ],
                      ),
                    ),
                    _buildStatusBar(refSize),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMagicMobileLayout(Size size, double refSize) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.04,
            vertical: refSize * 0.02,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: ColorClass.white,
                  size: refSize * 0.06,
                ),
                onPressed: () => Get.back(),
              ),
              SizedBox(width: refSize * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: "AI STUDIO",
                      textColor: ColorClass.neonPurple,
                      fontSize: refSize * 0.045,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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
              _buildPlasmaOrb(refSize * 0.15),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: refSize * 0.04),
          child: _glassMorphicContainer(
            padding: EdgeInsets.symmetric(
              vertical: refSize * 0.02,
              horizontal: refSize * 0.04,
            ),
            borderRadius: refSize * 0.1,
            refSize: refSize,
            child: _buildCompactPlayer(refSize),
          ),
        ),
        SizedBox(height: refSize * 0.02),
        Expanded(
          child: _glassMorphicContainer(
            margin: EdgeInsets.symmetric(horizontal: refSize * 0.02),
            refSize: refSize,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    dividerColor: ColorClass.transparent,
                    indicatorColor: ColorClass.neonTeal,
                    labelColor: ColorClass.neonTeal,
                    unselectedLabelColor: ColorClass.white30,
                    labelStyle: TextStyle(
                      fontSize: refSize * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
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
        _buildMobileBottomBar(refSize),
      ],
    );
  }

  Widget _glassMorphicContainer({
    required Widget child,
    double blur = 20.0,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    double? refSize,
  }) {
    final effectiveBorderRadius =
        borderRadius ?? (refSize != null ? refSize * 0.05 : 24.0);
    return Container(
      width: width,
      height: height,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: ColorClass.white.withValues(alpha: 0.1),
          width: refSize != null ? refSize * 0.002 : 1,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: refSize != null ? refSize * 0.001 : 0.5,
                decoration: BoxDecoration(
                  color: ColorClass.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorClass.white.withValues(alpha: 0.05),
                      ColorClass.transparent,
                      ColorClass.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildPlasmaOrb(double size) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final scale = 1.0 + (_glowAnimation.value - 0.2) * 0.2;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [ColorClass.neonPurple, ColorClass.neonTeal],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorClass.neonPurple.withValues(
                    alpha: _glowAnimation.value,
                  ),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.1,
                ),
              ],
            ),
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

  Widget _buildHorizontalWaveform(double refSize) {
    return SizedBox(
      height: refSize * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(40, (index) {
          // Create a wave pattern
          final height =
              refSize * 0.0125 +
              (refSize *
                  0.03 *
                  (index % 2 == 0 ? 0.5 : 1.0) *
                  (index % 5 == 0 ? 1.5 : 0.8));

          return Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              width: 3,
              height: height.clamp(4.0, refSize * 0.045),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ColorClass.neonBlue, ColorClass.neonPurple],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.neonBlue.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompactPlayer(double refSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Obx(
              () => IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _audioPlayer.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: refSize * 0.04,
                  color: ColorClass.white,
                ),
                onPressed: () => _audioPlayer.isPlaying.value
                    ? _audioPlayer.pause()
                    : _audioPlayer.play(widget.audioPath),
              ),
            ),
            SizedBox(width: refSize * 0.01),
            Expanded(
              child: Obx(() {
                final duration = _audioPlayer.duration.value;
                final progress = duration.inMilliseconds > 0
                    ? _audioPlayer.position.value.inMilliseconds /
                          duration.inMilliseconds
                    : 0.0;
                return LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: ColorClass.white10,
                  color: ColorClass.neonBlue,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                );
              }),
            ),
          ],
        ),
        SizedBox(height: refSize * 0.005),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: _formatDuration(_audioPlayer.position.value),
                textColor: ColorClass.white60,
                fontSize: refSize * 0.0125,
              ),
              TextWidget(
                text: _formatDuration(_audioPlayer.duration.value),
                textColor: ColorClass.white60,
                fontSize: refSize * 0.0125,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisButtonsVertical(double refSize) {
    final colors = [
      ColorClass.neonTeal,
      ColorClass.neonPurple,
      ColorClass.neonGreen,
      ColorClass.neonAmber,
    ];
    return Column(
      children: List.generate(AnalysisMode.values.length, (index) {
        final mode = AnalysisMode.values[index];
        return Padding(
          padding: EdgeInsets.only(bottom: refSize * 0.01),
          child: _MagneticNeonButton(
            label: controller.getModeDisplayName(mode),
            color: colors[index % colors.length],
            onPressed: () => controller.analyze(mode),
            refSize: refSize,
            isCompact: true,
          ),
        );
      }),
    );
  }

  Widget _buildTranscriptionHeader(double refSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: refSize * 0.02,
        vertical: refSize * 0.015,
      ),
      decoration: BoxDecoration(
        color: ColorClass.white.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(color: ColorClass.white10, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          TextWidget(
            text: "TRANSCRIPT",
            textColor: ColorClass.white70,
            fontWeight: FontWeight.w600,
            fontSize: refSize * 0.016,
            letterSpacing: 0.5,
          ),
          SizedBox(width: refSize * 0.01),
          // Tiny Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: refSize * 0.0075,
              vertical: refSize * 0.0025,
            ),
            decoration: BoxDecoration(
              color: ColorClass.neonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(refSize * 0.005),
              border: Border.all(
                color: ColorClass.neonGreen.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: refSize * 0.005,
                  height: refSize * 0.005,
                  decoration: const BoxDecoration(
                    color: ColorClass.neonGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: refSize * 0.005),
                TextWidget(
                  text: "READY",
                  textColor: ColorClass.neonGreen,
                  fontSize: refSize * 0.011,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // _buildAiReadyBadge removed

  Widget _buildTranscriptionContent(double refSize) {
    return Obx(() {
      if (controller.isTranscribing.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: refSize * 0.03,
                height: refSize * 0.03,
                child: CircularProgressIndicator(
                  color: ColorClass.neonTeal,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(height: refSize * 0.015),
              TextWidget(
                text: "Listening...",
                textColor: ColorClass.white54,
                fontSize: refSize * 0.015,
              ),
            ],
          ),
        );
      }
      if (controller.transcribedText.isEmpty) {
        return Stack(
          children: [
            Positioned(
              top: refSize * 0.02,
              left: refSize * 0.02,
              child: TextWidget(
                text: "Ready to transcribe...",
                textColor: ColorClass.white24,
                fontSize: refSize * 0.016,
              ),
            ),
            Positioned(
              bottom: refSize * 0.02,
              left: refSize * 0.02,
              right: refSize * 0.02,
              child: _buildPrimaryActionButton(refSize),
            ),
          ],
        );
      }
      return Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(refSize * 0.02),
            children: [
              SelectableText(
                controller.transcribedText.value,
                style: TextStyle(
                  color: ColorClass.white,
                  fontSize: refSize * 0.016,
                  height: 1.5,
                  fontFamily: 'Inter',
                  fontStyle: FontStyle.normal,
                ),
              ),
              SizedBox(height: refSize * 0.075),
            ],
          ),
          if (!controller.isTranscribing.value)
            Positioned(
              bottom: refSize * 0.02,
              left: refSize * 0.02,
              right: refSize * 0.02,
              child: _buildPrimaryActionButton(refSize),
            ),
        ],
      );
    });
  }

  Widget _buildPrimaryActionButton(double refSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MagicButton(
                label: "Copy",
                onPressed: _copyText,
                width: refSize * 0.11,
                height: refSize * 0.045,
                fontSize: refSize * 0.014,
              ),
              SizedBox(width: refSize * 0.01),
              MagicButton(
                label: "Export",
                onPressed: () => _showExportOptions(refSize),
                width: refSize * 0.11,
                height: refSize * 0.045,
                fontSize: refSize * 0.014,
              ),
            ],
          ),
        ),
        MagicButton(
          label: "START",
          onPressed: () => controller.transcribe(),
          width: refSize * 0.18,
          height: refSize * 0.06,
          fontSize: refSize * 0.02,
        ),
      ],
    );
  }

  Widget _buildMobileAnalysisTab(double refSize) =>
      _buildAnalysisResultPanel(refSize);
  Widget _buildAnalysisResultPanel(double refSize) => Obx(() {
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(refSize * 0.01),
          bottomLeft: Radius.circular(refSize * 0.01),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: refSize * 0.02,
              vertical: refSize * 0.015,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorClass.white10, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "ANALYSIS",
                  textColor: ColorClass.white54,
                  fontSize: refSize * 0.0125,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
                Icon(
                  Icons.auto_awesome,
                  size: refSize * 0.015,
                  color: ColorClass.neonPurple,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(refSize * 0.02),
              child: SelectableText(
                controller.analysisResult.value,
                style: TextStyle(
                  color: ColorClass.white70,
                  fontSize: refSize * 0.015,
                  height: 1.6,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
  Widget _buildMobileBottomBar(double refSize) => Container(
    padding: EdgeInsets.all(refSize * 0.03),
    child: _buildAnalysisButtonsVertical(refSize),
  );

  Widget _buildStatusBar(double refSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: refSize * 0.02,
        vertical: refSize * 0.005,
      ),
      decoration: BoxDecoration(
        color: ColorClass.white.withValues(alpha: 0.02),
        border: Border(top: BorderSide(color: ColorClass.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildStatusItem("Ln 1, Col 1", refSize),
          const Spacer(),
          _buildStatusItem("Word Count: 0", refSize),
          SizedBox(width: refSize * 0.02),
          _buildStatusItem("UTF-8", refSize),
          SizedBox(width: refSize * 0.02),
          _buildStatusItem("Dart", refSize),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String text, double refSize) {
    return TextWidget(
      text: text,
      textColor: ColorClass.white38,
      fontSize: refSize * 0.0125,
    );
  }

  void _copyText() {
    if (controller.transcribedText.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: controller.transcribedText.value));
    Get.snackbar(
      "Magic",
      "Text copied to clipboard",
      colorText: ColorClass.white,
      backgroundColor: ColorClass.neonPurple.withValues(alpha: 0.8),
    );
  }

  void _showExportOptions(double refSize) {
    AppDialog.custom(
      context: context,
      width: refSize * 0.8,
      showCloseIcon: true,
      backgroundColor: ColorClass.darkNavy,
      borderColor: ColorClass.neonTeal.withValues(alpha: 0.3),
      padding: EdgeInsets.all(refSize * 0.04),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                color: ColorClass.neonTeal,
                size: refSize * 0.05,
              ),
              SizedBox(width: refSize * 0.02),
              TextWidget(
                text: "EXPORT TRANSCRIPTION",
                textColor: ColorClass.white,
                fontSize: refSize * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: refSize * 0.03),
          DialogOptionTile(
            icon: Icons.description_outlined,
            title: "Export as Text (.txt)",
            subtitle: "Plain text format",
            color: ColorClass.neonBlue,
            onTap: () async {
              Navigator.of(context).pop();
              final path = await controller.exportAsText();
              if (path != null) {
                Get.snackbar(
                  "Success",
                  "Saved to $path",
                  colorText: ColorClass.white,
                  backgroundColor: ColorClass.green.withValues(alpha: 0.6),
                );
              }
            },
          ),
          SizedBox(height: refSize * 0.02),
          DialogOptionTile(
            icon: Icons.article_outlined,
            title: "Export as Markdown (.md)",
            subtitle: "Formatted markdown",
            color: ColorClass.neonPurple,
            onTap: () async {
              Navigator.of(context).pop();
              final path = await controller.exportAsMarkdown();
              if (path != null) {
                Get.snackbar(
                  "Success",
                  "Saved to $path",
                  colorText: ColorClass.white,
                  backgroundColor: ColorClass.green.withValues(alpha: 0.6),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

class _MagneticNeonButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final double refSize;
  final bool isCompact; // Added for compact mode
  const _MagneticNeonButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.refSize,
    this.isCompact = false,
  });
  @override
  State<_MagneticNeonButton> createState() => _MagneticNeonButtonState();
}

class _MagneticNeonButtonState extends State<_MagneticNeonButton>
    with SingleTickerProviderStateMixin {
  Offset _mousePos = Offset.zero;
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final offset = _hovering ? _mousePos * 0.1 : Offset.zero;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      onHover: (e) {
        final rb = context.findRenderObject() as RenderBox;
        final local = rb.globalToLocal(e.position);
        setState(
          () => _mousePos = Offset(
            local.dx - rb.size.width / 2,
            local.dy - rb.size.height / 2,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            height: widget.isCompact ? 36 : null,
            padding: EdgeInsets.symmetric(
              vertical: widget.isCompact ? 0 : widget.refSize * 0.03,
              horizontal: widget.isCompact ? 12 : widget.refSize * 0.04,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hovering
                  ? widget.color.withValues(alpha: 0.1) // Subtle hover
                  : ColorClass.transparent,
              borderRadius: BorderRadius.circular(
                widget.isCompact ? 6 : widget.refSize * 0.015,
              ),
              border: Border.all(
                color: _hovering
                    ? widget.color.withValues(alpha: 0.6)
                    : widget.color.withValues(alpha: 0.3),
                width: 0.5, // Thin border
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Wrap content
              children: [
                // Small indicator dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: widget.isCompact ? 8 : widget.refSize * 0.02),
                Flexible(
                  child: TextWidget(
                    text: widget.label,
                    textColor: ColorClass.white70,
                    fontSize: widget.isCompact ? 11 : widget.refSize * 0.025,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
