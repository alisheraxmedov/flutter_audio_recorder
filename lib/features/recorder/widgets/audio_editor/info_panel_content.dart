import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

class InfoPanelContent extends StatelessWidget {
  final double refSize;
  final AudioEditorController controller;
  final TextEditingController startController;
  final TextEditingController endController;

  const InfoPanelContent({
    super.key,
    required this.refSize,
    required this.controller,
    required this.startController,
    required this.endController,
  });

  void _submitSelection() {
    controller.updateSelectionFromText(
      startController.text,
      endController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _infoRow(
            "Format",
            controller.activeTrack.fileFormat.value,
            refSize,
          ),
        ),
        Obx(
          () =>
              _infoRow("Size", controller.activeTrack.fileSize.value, refSize),
        ),
        Obx(
          () => _infoRow(
            "Duration",
            controller.formatTime(controller.activeTrack.totalDurationMs.value),
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

        _timeInput("Start", startController, refSize),
        SizedBox(height: refSize * 0.015),
        _timeInput("End", endController, refSize),
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
}
