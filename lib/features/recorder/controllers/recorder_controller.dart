import 'dart:async';
import 'package:recorder/core/utils/file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:recorder/core/services/recorder_service.dart';
import 'package:recorder/l10n/app_localizations.dart';

enum RecorderStatus { ready, recording, paused, saved }

class RecorderController extends GetxController {
  final RecorderService _recorderService = RecorderService();

  // Observables
  RxString duration = "00:00:00".obs;
  RxString recordName = "Record 1".obs;
  Rx<RecorderStatus> status = RecorderStatus.ready.obs;
  RxString savedFilePath = "".obs;
  RxBool isRecording = false.obs;
  RxBool isPaused = false.obs;

  Timer? _timer;
  int _seconds = 0;

  @override
  void onClose() {
    _timer?.cancel();
    _recorderService.dispose();
    super.onClose();
  }

  // Toggle Recording (Start/Stop)
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      // If currently recording, stop it
      await stopRecording();
    } else {
      // If not recording, start it
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (await _recorderService.hasPermission()) {
      // Reset timer
      _seconds = 0;
      duration.value = "00:00:00";

      // Generate unique name
      final fileName = 'fs_recorder_${DateTime.now().millisecondsSinceEpoch}.m4a';
      recordName.value = fileName;
      status.value = RecorderStatus.recording;

      await _recorderService.start(fileName: fileName);

      isRecording.value = true;
      isPaused.value = false;

      _startTimer();
    } else {
      if (Get.context != null) {
        final loc = AppLocalizations.of(Get.context!)!;
        Get.snackbar(loc.permissionDeniedTitle, loc.permissionDeniedMessage);
      } else {
        Get.snackbar(
          "Permission Denied",
          "Microphone permission is required to record audio.",
        );
      }
    }
  }

  Future<void> stopRecording() async {
    final path = await _recorderService.stop();
    isRecording.value = false;
    isPaused.value = false;
    _timer?.cancel();

    if (path != null) {
      status.value = RecorderStatus.saved;
      savedFilePath.value = path;
      print("Recorded file path: $path");

      // Trigger save/download
      await saveFile(path, recordName.value);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      final durationObj = Duration(seconds: _seconds);
      // Format duration HH:MM:SS
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(durationObj.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(durationObj.inSeconds.remainder(60));
      String twoDigitHours = twoDigits(durationObj.inHours);

      duration.value = "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    });
  }
}
