import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:recorder/core/services/audio_editing_service.dart';
import 'package:recorder/core/services/audio_player_service.dart';

class AudioEditorController extends GetxController {
  final AudioEditingService _editingService = AudioEditingService();
  final AudioPlayerService _audioPlayer = Get.find<AudioPlayerService>();

  RxList<double> waveform = <double>[].obs;
  RxBool isLoading = false.obs;
  RxString filePath = "".obs;

  // Metadata
  RxString fileName = "".obs;
  RxString fileFormat = "".obs;
  RxString fileSize = "".obs;

  // Export Options
  RxString exportFileName = "".obs;
  RxString exportPath = "".obs;

  // Selection State (0.0 to 1.0 relative to total duration)
  RxDouble startSelection = 0.0.obs;
  RxDouble endSelection = 1.0.obs;

  // Total duration of the file in milliseconds
  RxInt totalDurationMs = 0.obs;

  // Computed properties for UI
  int get startMs => (startSelection.value * totalDurationMs.value).toInt();
  int get endMs => (endSelection.value * totalDurationMs.value).toInt();

  void loadFile(String path) async {
    filePath.value = path;
    isLoading.value = true;

    final file = File(path);
    fileName.value = file.uri.pathSegments.last;
    fileFormat.value = fileName.value.split('.').last.toUpperCase();

    // Size logic
    try {
      final sizeBytes = await file.length();
      fileSize.value = _formatBytes(sizeBytes);
    } catch (e) {
      fileSize.value = "Unknown";
    }

    // Default export name
    exportFileName.value = "edited_${fileName.value}";
    exportPath.value = file.parent.path;

    try {
      totalDurationMs.value = await _editingService.getDurationMs(path);
      waveform.value = await _editingService.extractWaveform(path);
    } catch (e) {
      debugPrint("Error loading file: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Pick a new file (replaces current or adds to track in future)
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      loadFile(result.files.single.path!);
    }
  }

  void updateSelection(double start, double end) {
    if (start >= 0 && end <= 1.0 && start < end) {
      startSelection.value = start;
      endSelection.value = end;
    }
  }

  // Update Selection from Text Input (e.g. "00:05.50")
  void updateSelectionFromText(String startText, String endText) {
    // Basic parsing logic (MM:SS.ms)
    // This is simplified; ideally use a robust parser.
    int? start = _parseTime(startText);
    int? end = _parseTime(endText);

    if (start != null && end != null && totalDurationMs > 0) {
      double sPct = (start / totalDurationMs.value).clamp(0.0, 1.0);
      double ePct = (end / totalDurationMs.value).clamp(0.0, 1.0);
      if (sPct < ePct) {
        startSelection.value = sPct;
        endSelection.value = ePct;
      }
    }
  }

  int? _parseTime(String text) {
    try {
      // Format MM:SS.mm
      final parts = text.split(':');
      if (parts.length == 2) {
        int m = int.parse(parts[0]);
        double s = double.parse(parts[1]);
        return (m * 60 * 1000 + s * 1000).toInt();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void playPreview() async {
    if (_audioPlayer.isPlaying.value) {
      await _audioPlayer.stop();
      return;
    }

    final Duration start = Duration(milliseconds: startMs);
    final Duration end = Duration(milliseconds: endMs);

    await _audioPlayer.play(filePath.value);
    await _audioPlayer.seek(start);

    final durationToPlay = end - start;
    Timer(durationToPlay, () async {
      if (_audioPlayer.isPlaying.value) {
        await _audioPlayer.stop();
      }
    });
  }

  Future<void> trimAudio() async {
    isLoading.value = true;
    final success = await _editingService.trim(
      filePath.value,
      startMs / 1000.0,
      endMs / 1000.0,
    );
    isLoading.value = false;
    if (success != null) {
      Get.back();
    }
  }

  Future<void> cutAudio() async {
    isLoading.value = true;
    final success = await _editingService.cut(
      filePath.value,
      startMs / 1000.0,
      endMs / 1000.0,
    );
    isLoading.value = false;
    if (success != null) {
      Get.back();
    }
  }

  String formatTime(int ms) {
    if (ms < 0) ms = 0;
    final duration = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMillis = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, "0");
    return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMillis";
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    double v = bytes.toDouble();
    int index = 0;
    while (v >= 1024 && index < suffixes.length - 1) {
      v /= 1024;
      index++;
    }
    return '${v.toStringAsFixed(1)} ${suffixes[index]}';
  }
}
