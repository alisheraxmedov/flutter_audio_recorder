import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:record/record.dart';

class SettingsController extends GetxController {
  // Available locales
  static final locales = [
    const Locale('en'),
    const Locale('uz'),
    const Locale('ru'),
  ];

  // Available Encoders
  static final encoders = [
    AudioEncoder.aacLc,
    AudioEncoder.opus,
    AudioEncoder.wav,
  ];

  // Current locale
  Rx<Locale> currentLocale = const Locale('en').obs;

  // Current Encoder
  Rx<AudioEncoder> currentEncoder = AudioEncoder.aacLc.obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Load saved settings from storage
    if (Get.locale != null) {
      currentLocale.value = Get.locale!;
    }
  }

  void changeLanguage(Locale locale) {
    if (!locales.contains(locale)) return;
    Get.updateLocale(locale);
    currentLocale.value = locale;
    // TODO: Save to storage
  }

  void changeEncoder(AudioEncoder encoder) {
    if (!encoders.contains(encoder)) return;
    currentEncoder.value = encoder;
    // TODO: Save to storage
  }

  String getEncoderExt(AudioEncoder encoder) {
    switch (encoder) {
      case AudioEncoder.aacLc:
        return 'm4a';
      case AudioEncoder.opus:
        return 'ogg';
      case AudioEncoder.wav:
      case AudioEncoder.pcm16bits:
        return 'wav';
      case AudioEncoder.flac:
        return 'flac';
      default:
        return 'm4a';
    }
  }
}
