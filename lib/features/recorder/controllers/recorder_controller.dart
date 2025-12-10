import 'dart:async';
import 'dart:io';
import 'package:recorder/core/utils/file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:recorder/core/services/recorder_service.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:recorder/features/recorder/controllers/settings_controller.dart';

enum RecorderStatus { ready, recording, paused, saved }

class RecorderController extends GetxController {
  final RecorderService _recorderService = RecorderService();
  final SettingsController _settingsController = Get.find<SettingsController>();

  // Observables
  RxString duration = "00:00:00".obs;
  RxString recordName = "Record 1".obs;
  Rx<RecorderStatus> status = RecorderStatus.ready.obs;
  RxString savedFilePath = "".obs;
  RxBool isRecording = false.obs;
  RxBool isPaused = false.obs;

  // Folder Management State
  RxList<FileSystemEntity> entities = <FileSystemEntity>[].obs;
  RxString currentPath = "".obs;
  Directory? _rootDir;

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

      // Get settings
      final encoder = _settingsController.currentEncoder.value;
      final ext = _settingsController.getEncoderExt(encoder);

      // Generate unique name
      final fileName =
          'fs_recorder_${DateTime.now().millisecondsSinceEpoch}.$ext';
      recordName.value = fileName;
      status.value = RecorderStatus.recording;

      await _recorderService.start(
        fileName: fileName,
        encoder: encoder,
        directoryPath: currentPath.value.isNotEmpty ? currentPath.value : null,
      );

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

  RxDouble amplitude = 0.0.obs;
  Timer? _ampTimer;

  // RxList<String> records = <String>[].obs; // REPLACED by entities

  @override
  void onInit() {
    super.onInit();
    _initFolderSystem();
  }

  Future<void> _initFolderSystem() async {
    try {
      if (GetPlatform.isWeb) return;
      _rootDir = await _recorderService.getRecordingsDirectory();
      currentPath.value = _rootDir!.path;
      await refreshList();
    } catch (e) {
      print("Error initializing folder system: $e");
    }
  }

  Future<void> refreshList() async {
    if (currentPath.value.isEmpty) return;
    final list = await _recorderService.getEntities(currentPath.value);
    entities.assignAll(list);
  }

  Future<void> createFolder(String name) async {
    if (currentPath.value.isEmpty) return;
    await _recorderService.createFolder(name, currentPath.value);
    await refreshList();
  }

  void openFolder(String path) {
    currentPath.value = path;
    refreshList();
  }

  bool get canGoBack {
    if (_rootDir == null || currentPath.value.isEmpty) return false;
    return currentPath.value != _rootDir!.path;
  }

  void goBack() {
    if (!canGoBack) return;
    final parent = Directory(currentPath.value).parent;
    currentPath.value = parent.path;
    refreshList();
  }

  Future<void> stopRecording() async {
    final path = await _recorderService.stop();
    isRecording.value = false;
    isPaused.value = false;
    _timer?.cancel();
    _ampTimer?.cancel(); // Stop polling amplitude
    amplitude.value = 0.0;

    if (path != null) {
      status.value = RecorderStatus.saved;
      savedFilePath.value = path;
      print("Recorded file path: $path");

      // Trigger save/download
      await saveFile(path, recordName.value);

      // Refresh list
      await refreshList();
    }
  }

  Future<void> moveEntity(String source, String target) async {
    await _recorderService.moveEntity(source, target);
    await refreshList();
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

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

    _ampTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (isRecording.value && !isPaused.value) {
        final amp = await _recorderService.getAmplitude();
        // Normalize dB (-60 to 0) to 0.0 to 1.0 range
        // Typical speech is around -20 to -5 dB
        double currentDb = amp.current;
        if (currentDb < -60) currentDb = -60;
        if (currentDb > 0) currentDb = 0;

        // Linear normalization
        // -60 -> 0.0
        // 0 -> 1.0
        double norm = 1 - (currentDb / -60);
        amplitude.value = norm.clamp(0.0, 1.0);
      }
    });
  }
}
