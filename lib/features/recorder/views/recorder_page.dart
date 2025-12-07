import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/circle_button.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/features/recorder/widgets/wave_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate logic
    final controller = Get.find<RecorderController>();
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide;

    return Scaffold(
      backgroundColor: ColorClass.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextWidget(
          text: AppLocalizations.of(context)!.appTitle,
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
          WaveWidget(controller: controller, size: refSize * 0.8),
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
          Obx(() {
            String statusText;
            switch (controller.status.value) {
              case RecorderStatus.ready:
                statusText = AppLocalizations.of(context)!.statusReady;
                break;
              case RecorderStatus.recording:
                statusText = AppLocalizations.of(context)!.statusRecording;
                break;
              case RecorderStatus.paused:
                statusText = AppLocalizations.of(context)!.statusRecording;
                break;
              case RecorderStatus.saved:
                statusText = AppLocalizations.of(
                  context,
                )!.statusSaved(controller.savedFilePath.value);
                break;
            }
            return TextWidget(
              text: statusText,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.035,
            );
          }),
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
          SizedBox(height: size.height * 0.15),
        ],
      ),
    );
  }
}
