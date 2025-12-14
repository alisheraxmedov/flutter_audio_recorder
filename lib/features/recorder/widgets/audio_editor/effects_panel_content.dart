import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recorder/core/constants/app_colors.dart';
import 'package:recorder/features/recorder/controllers/audio_editor_controller.dart';
import 'package:recorder/features/recorder/models/audio_effect_settings.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';

/// Effects Panel Widget for Audio Editor - Compact Layout
class EffectsPanelContent extends StatelessWidget {
  final double refSize;
  final AudioEditorController controller;

  const EffectsPanelContent({
    super.key,
    required this.refSize,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: refSize * 0.015,
        vertical: refSize * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speed & Pitch in compact rows
          _buildCompactSlider(
            label: "Speed",
            valueObs: controller.speedFactor,
            min: 0.25,
            max: 4.0,
          ),
          _buildCompactSlider(
            label: "Pitch",
            valueObs: controller.pitchFactor,
            min: 0.5,
            max: 2.0,
          ),

          SizedBox(height: refSize * 0.01),

          // Toggles in a single row using chips
          Wrap(
            spacing: refSize * 0.01,
            runSpacing: refSize * 0.008,
            children: [
              _buildToggleChip("Norm", controller.enableNormalize),
              _buildToggleChip("Silence", controller.enableTrimSilence),
              _buildToggleChip("DeNoise", controller.enableNoiseGate),
            ],
          ),

          SizedBox(height: refSize * 0.015),

          // Presets in a row
          Row(
            children: [
              TextWidget(
                text: "Preset:",
                textColor: ColorClass.textSecondary,
                fontSize: refSize * 0.018,
              ),
              SizedBox(width: refSize * 0.01),
              _buildPresetChip("None", AudioPreset.none),
              SizedBox(width: refSize * 0.008),
              _buildPresetChip("Podcast", AudioPreset.podcast),
              SizedBox(width: refSize * 0.008),
              _buildPresetChip("Voice", AudioPreset.clearVoice),
            ],
          ),

          SizedBox(height: refSize * 0.02),

          // Apply & Reset in ONE ROW
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => controller.applyEffects(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.glowBlue,
                    foregroundColor: ColorClass.white,
                    padding: EdgeInsets.symmetric(vertical: refSize * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(refSize * 0.01),
                    ),
                  ),
                  child: TextWidget(
                    text: "Apply",
                    textColor: ColorClass.white,
                    fontSize: refSize * 0.022,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: refSize * 0.01),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => controller.resetEffects(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorClass.textSecondary,
                    side: BorderSide(
                      color: ColorClass.white.withValues(alpha: 0.2),
                    ),
                    padding: EdgeInsets.symmetric(vertical: refSize * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(refSize * 0.01),
                    ),
                  ),
                  child: TextWidget(
                    text: "Reset",
                    textColor: ColorClass.textSecondary,
                    fontSize: refSize * 0.02,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact slider with label and value on same line
  Widget _buildCompactSlider({
    required String label,
    required RxDouble valueObs,
    required double min,
    required double max,
  }) {
    return Obx(() {
      final value = valueObs.value;
      return Row(
        children: [
          SizedBox(
            width: refSize * 0.08,
            child: TextWidget(
              text: label,
              textColor: ColorClass.textSecondary,
              fontSize: refSize * 0.018,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: ColorClass.glowBlue,
                inactiveTrackColor: ColorClass.buttonBg,
                thumbColor: ColorClass.white,
                overlayColor: ColorClass.glowBlue.withValues(alpha: 0.2),
                trackHeight: refSize * 0.008,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: refSize * 0.015,
                ),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: (v) => valueObs.value = v,
              ),
            ),
          ),
          SizedBox(
            width: refSize * 0.06,
            child: TextWidget(
              text: "${value.toStringAsFixed(1)}x",
              textColor: ColorClass.white,
              fontSize: refSize * 0.018,
            ),
          ),
        ],
      );
    });
  }

  /// Toggle chip (selectable tile style)
  Widget _buildToggleChip(String label, RxBool valueObs) {
    return GestureDetector(
      onTap: () => valueObs.value = !valueObs.value,
      child: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.015,
            vertical: refSize * 0.008,
          ),
          decoration: BoxDecoration(
            color: valueObs.value ? ColorClass.glowBlue : ColorClass.buttonBg,
            borderRadius: BorderRadius.circular(refSize * 0.01),
            border: Border.all(
              color: valueObs.value
                  ? ColorClass.glowBlue
                  : ColorClass.white.withValues(alpha: 0.1),
            ),
          ),
          child: TextWidget(
            text: label,
            textColor: valueObs.value
                ? ColorClass.white
                : ColorClass.textSecondary,
            fontSize: refSize * 0.018,
            fontWeight: valueObs.value ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Preset chip (selectable tile style)
  Widget _buildPresetChip(String label, AudioPreset preset) {
    return GestureDetector(
      onTap: () => controller.selectPreset(preset),
      child: Obx(() {
        final isSelected = controller.currentPreset.value == preset;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: refSize * 0.012,
            vertical: refSize * 0.006,
          ),
          decoration: BoxDecoration(
            color: isSelected ? ColorClass.glowPurple : ColorClass.buttonBg,
            borderRadius: BorderRadius.circular(refSize * 0.008),
            border: Border.all(
              color: isSelected
                  ? ColorClass.glowPurple
                  : ColorClass.white.withValues(alpha: 0.1),
            ),
          ),
          child: TextWidget(
            text: label,
            textColor: isSelected ? ColorClass.white : ColorClass.textSecondary,
            fontSize: refSize * 0.016,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }),
    );
  }
}
