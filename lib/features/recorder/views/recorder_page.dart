import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/circle_button.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate logic
    final controller = Get.put(RecorderController());
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextWidget(
          text: 'Voice Recorder',
          textColor: ColorClass.white,
          fontSize: refSize * 0.045,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: ColorClass.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.05),
          // Timer
          Obx(
            () => TextWidget(
              text: controller.duration.value,
              textColor: ColorClass.white,
              fontSize: refSize * 0.10, // Responsive font size
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Glowing Visualizer (Circle)
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer/Back Glow
              Container(
                width: refSize * 0.55,
                height: refSize * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColorClass.glowPurple.withValues(alpha: 0.3),
                      ColorClass.darkBackground.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // The Ring
              Container(
                width: refSize * 0.45,
                height: refSize * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ColorClass.glowPurple, ColorClass.glowBlue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorClass.glowBlue.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: ColorClass.glowPurple.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorClass.darkBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Record Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => TextWidget(
                  text: controller.recordName.value,
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: refSize * 0.02),
              Icon(
                Icons.edit_outlined,
                color: ColorClass.textSecondary,
                size: refSize * 0.045,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          // Metadata
          Obx(
            () => TextWidget(
              text: controller.recordInfo.value,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.035,
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Stop Button (Left)
              CircleButton(
                icon: Icons.stop,
                onTap: () => controller.stopRecording(),
                size: refSize * 0.12,
                iconColor: ColorClass.white,
                bgColor: ColorClass.buttonBg,
              ),
              // Main Record/Pause Button
              Container(
                width: refSize * 0.18,
                height: refSize * 0.18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorClass.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isRecording.value ? Icons.pause : Icons.mic,
                      color: Colors.black,
                      size: refSize * 0.08,
                    ),
                    onPressed: () => controller.toggleRecording(),
                  ),
                ),
              ),
              // Close Button (Right)
              CircleButton(
                icon: Icons.close,
                onTap: () {},
                size: refSize * 0.12,
                iconColor: ColorClass.white,
                bgColor: ColorClass.buttonBg,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.05),
          // Bottom Navigation Pill
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: refSize * 0.05,
              vertical: size.height * 0.025,
            ),
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.02,
              horizontal: refSize * 0.1,
            ),
            decoration: BoxDecoration(
              color: ColorClass.buttonBg.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(refSize * 0.1),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(
                  CupertinoIcons.list_bullet,
                  color: ColorClass.textSecondary,
                ), // Records List
                Icon(
                  CupertinoIcons.mic_fill,
                  color: ColorClass.white,
                ), // Record (Current)
                Icon(
                  CupertinoIcons.settings,
                  color: ColorClass.textSecondary,
                ), // Settings
              ],
            ),
          ),
          SizedBox(height: size.height * 0.012),
        ],
      ),
    );
  }
}
