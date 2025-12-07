import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:recorder/features/recorder/widgets/wave_widget.dart';
import 'package:recorder/l10n/app_localizations.dart';

class RecorderBody extends StatelessWidget {
  final RecorderController controller;
  final double refSize;

  const RecorderBody({
    super.key,
    required this.controller,
    required this.refSize,
  });

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder if we want to be responsive to the available space
    // inside the Desktop/Mobile view.
    return Column(
      children: [
        SizedBox(height: refSize * 0.05),
        // Timer
        Obx(
          () => TextWidget(
            text: controller.duration.value,
            textColor: ColorClass.white,
            fontSize: refSize * 0.10,
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
        SizedBox(height: refSize * 0.01),
        // Metadata / Status
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
        SizedBox(height: refSize * 0.05),
      ],
    );
  }
}
