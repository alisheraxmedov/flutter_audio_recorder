import 'dart:async';
import 'dart:io';
import 'package:recorder/core/utils/file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:recorder/core/services/recorder_service.dart';
import 'package:recorder/core/services/metadata_service.dart';
import 'package:recorder/l10n/app_localizations.dart';
import 'package:recorder/features/recorder/controllers/settings_controller.dart';
import 'package:recorder/features/recorder/models/audio_metadata.dart';
import 'package:recorder/features/recorder/models/sort_option.dart';

enum RecorderStatus { ready, recording, paused, saved }

class RecorderController extends GetxController {
  final RecorderService _recorderService = RecorderService();
  final MetadataService _metadataService = MetadataService();
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

  // Sorting State
  Rx<SortOption> currentSortOption = SortOption.dateNew.obs;
  RxMap<String, AudioMetadata> metadataCache = <String, AudioMetadata>{}.obs;

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
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (await _recorderService.hasPermission()) {
      _seconds = 0;
      duration.value = "00:00:00";

      final encoder = _settingsController.currentEncoder.value;
      final ext = _settingsController.getEncoderExt(encoder);

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
      _loadMetadataCache();
      await refreshList();
    } catch (e) {
      print("Error initializing folder system: $e");
    }
  }

  void _loadMetadataCache() {
    final all = _metadataService.getAll();
    metadataCache.assignAll(all);
  }

  Future<void> refreshList() async {
    if (currentPath.value.isEmpty) return;
    final list = await _recorderService.getEntities(currentPath.value);
    entities.assignAll(list);
    _applySorting();
  }

  /// Apply sorting to file list
  void _applySorting() {
    final files = entities.whereType<File>().toList();
    final folders = entities.whereType<Directory>().toList();

    files.sort((a, b) {
      switch (currentSortOption.value) {
        case SortOption.dateNew:
          return b.statSync().modified.compareTo(a.statSync().modified);
        case SortOption.dateOld:
          return a.statSync().modified.compareTo(b.statSync().modified);
        case SortOption.nameAsc:
          return a.path.split('/').last.compareTo(b.path.split('/').last);
        case SortOption.nameDesc:
          return b.path.split('/').last.compareTo(a.path.split('/').last);
      }
    });

    // Folders always on top
    entities.assignAll([...folders, ...files]);
  }

  /// Change sort option
  void changeSortOption(SortOption option) {
    currentSortOption.value = option;
    _applySorting();
  }

  /// Get metadata for file
  AudioMetadata? getMetadata(String path) {
    return metadataCache[path];
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
    _ampTimer?.cancel();
    amplitude.value = 0.0;

    if (path != null) {
      status.value = RecorderStatus.saved;
      savedFilePath.value = path;
      print("Recorded file path: $path");

      // Trigger save/download
      await saveFile(path, recordName.value);

      // Save metadata
      await _saveRecordingMetadata(path);

      // Refresh list
      await refreshList();
    }
  }

  /// Save metadata for recorded audio
  Future<void> _saveRecordingMetadata(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;

      final stat = await file.stat();
      final durationMs = _seconds * 1000; // Duration from timer

      final metadata = AudioMetadata(
        path: path,
        name: path.split('/').last,
        durationMs: durationMs,
        sizeBytes: stat.size,
        createdAt: stat.modified,
      );

      await _metadataService.save(metadata);
      metadataCache[path] = metadata;
    } catch (e) {
      print("Error saving metadata: $e");
    }
  }

  Future<void> moveEntity(String source, String target) async {
    await _recorderService.moveEntity(source, target);
    // Update metadata path if exists
    final name = source.split('/').last;
    final newPath = '$target/$name';
    await _metadataService.updatePath(source, newPath);
    metadataCache.remove(source);
    _loadMetadataCache();
    await refreshList();
  }

  /// Delete metadata when entity is deleted
  Future<void> deleteEntityMetadata(String path) async {
    await _metadataService.delete(path);
    metadataCache.remove(path);
  }

  /// Update metadata path when entity is renamed
  Future<void> renameEntityMetadata(String oldPath, String newPath) async {
    await _metadataService.updatePath(oldPath, newPath);
    metadataCache.remove(oldPath);
    _loadMetadataCache();
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      final durationObj = Duration(seconds: _seconds);
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(durationObj.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(durationObj.inSeconds.remainder(60));
      String twoDigitHours = twoDigits(durationObj.inHours);

      duration.value = "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    });

    _ampTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (isRecording.value && !isPaused.value) {
        final amp = await _recorderService.getAmplitude();
        double currentDb = amp.current;
        if (currentDb < -60) currentDb = -60;
        if (currentDb > 0) currentDb = 0;

        double norm = 1 - (currentDb / -60);
        amplitude.value = norm.clamp(0.0, 1.0);
      }
    });
  }
}
