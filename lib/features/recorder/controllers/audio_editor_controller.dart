import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:recorder/core/services/audio_editing_service.dart';
import 'package:recorder/features/recorder/widgets/text_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder/core/services/audio_player_service.dart';
import 'package:recorder/core/constants/app_colors.dart';
// import 'package:recorder/features/recorder/controllers/recorder_controller.dart';
// import 'package:recorder/features/recorder/models/track_data.dart'; // Defined in file for now or imported if separate.
// Since I created a separate file but also redefined it in the controller file during the previous step (oops), I should actually REMOVE the duplicate definition from the controller and keep the import.
import 'package:recorder/features/recorder/models/track_data.dart';

class AudioEditorController extends GetxController {
  final AudioEditingService _editingService = AudioEditingService();
  final AudioPlayerService _audioPlayer = Get.find<AudioPlayerService>();

  // Tracks State
  final RxList<TrackData> tracks = <TrackData>[
    TrackData(id: 0),
    TrackData(id: 1),
    TrackData(id: 2),
  ].obs;

  // Active Track Logic
  final RxInt activeTrackIndex = 0.obs;
  TrackData get activeTrack => tracks[activeTrackIndex.value];

  // Playback State
  final RxDouble playbackProgress =
      0.0.obs; // 0.0 to 1.0 relative to active track
  Worker? _playerWorker;

  RxBool isLoading = false.obs;

  // Export Options (Linked to Active Track or Global?)
  // Customarily linked to active track editing
  RxString exportFileName = "".obs;
  RxString exportPath = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Sync Playback Progress
    _playerWorker = ever(_audioPlayer.position, (pos) {
      if (activeTrack.totalDurationMs.value > 0) {
        final progress = pos.inMilliseconds / activeTrack.totalDurationMs.value;
        playbackProgress.value = progress.clamp(0.0, 1.0);
      } else {
        playbackProgress.value = 0.0;
      }
    });

    // Sync Export Name when active track changes
    ever(activeTrackIndex, (_) {
      if (activeTrack.fileName.value != "Empty") {
        exportFileName.value = "edited_${activeTrack.fileName.value}";
      }
    });
  }

  @override
  void onClose() {
    _playerWorker?.dispose();
    super.onClose();
  }

  void setActiveTrack(int index) {
    if (index >= 0 && index < tracks.length) {
      activeTrackIndex.value = index;
    }
  }

  void loadFile(String path, {int? trackIndex}) async {
    int targetIndex = trackIndex ?? activeTrackIndex.value;
    final track = tracks[targetIndex];

    isLoading.value = true;

    final file = File(path);
    track.filePath.value = path;
    track.fileName.value = file.uri.pathSegments.last;
    track.fileFormat.value = track.fileName.value.split('.').last.toUpperCase();

    // Size logic
    try {
      final sizeBytes = await file.length();
      track.fileSize.value = _formatBytes(sizeBytes);
    } catch (e) {
      track.fileSize.value = "Unknown";
    }

    // Default export name (only if active)
    if (targetIndex == activeTrackIndex.value) {
      exportFileName.value = "edited_${track.fileName.value}";
      exportPath.value = file.parent.path;
    }

    try {
      track.totalDurationMs.value = await _editingService.getDurationMs(path);
      track.waveform.value = await _editingService.extractWaveform(path);
      // Reset selection
      track.startSelection.value = 0.0;
      track.endSelection.value = 1.0;
    } catch (e) {
      debugPrint("Error loading file: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Pick a new file for the ACTIVE track
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
      activeTrack.startSelection.value = start;
      activeTrack.endSelection.value = end;
    }
  }

  // Update Selection from Text Input (e.g. "00:05.50")
  void updateSelectionFromText(String startText, String endText) {
    int? start = _parseTime(startText);
    int? end = _parseTime(endText);
    final duration = activeTrack.totalDurationMs.value;

    if (start != null && end != null && duration > 0) {
      double sPct = (start / duration).clamp(0.0, 1.0);
      double ePct = (end / duration).clamp(0.0, 1.0);
      if (sPct < ePct) {
        activeTrack.startSelection.value = sPct;
        activeTrack.endSelection.value = ePct;
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

    if (activeTrack.filePath.isEmpty) return;

    final Duration start = Duration(milliseconds: activeTrack.startMs);
    final Duration end = Duration(milliseconds: activeTrack.endMs);

    await _audioPlayer.play(activeTrack.filePath.value);
    await _audioPlayer.seek(start);

    final durationToPlay = end - start;
    Timer(durationToPlay, () async {
      if (_audioPlayer.isPlaying.value) {
        await _audioPlayer.stop();
      }
    });
  }

  Future<void> trimAudio() async {
    if (activeTrack.filePath.isEmpty) return;

    isLoading.value = true;
    final success = await _editingService.trim(
      activeTrack.filePath.value,
      activeTrack.startMs / 1000.0,
      activeTrack.endMs / 1000.0,
    );
    isLoading.value = false;
    if (success != null) {
      Get.back();
    }
  }

  Future<void> cutAudio() async {
    if (activeTrack.filePath.isEmpty) return;

    isLoading.value = true;
    final success = await _editingService.cut(
      activeTrack.filePath.value,
      activeTrack.startMs / 1000.0,
      activeTrack.endMs / 1000.0,
    );
    isLoading.value = false;
    if (success != null) {
      Get.back();
    }
  }

  Future<void> mergeAndExport() async {
    // 1. Gather valid segments
    final segments = <AudioSegment>[];
    for (final track in tracks) {
      if (track.filePath.isNotEmpty) {
        segments.add(
          AudioSegment(
            filePath: track.filePath.value,
            startSec: track.startMs / 1000.0,
            endSec: track.endMs / 1000.0,
          ),
        );
      }
    }

    if (segments.isEmpty) {
      Get.snackbar("Error", "No tracks to merge");
      return;
    }

    isLoading.value = true;

    try {
      // 2. Determine Output Path
      // Use active track's directory or default
      String dir = exportPath.value;
      if (dir.isEmpty && activeTrack.filePath.isNotEmpty) {
        dir = File(activeTrack.filePath.value).parent.path;
      }
      if (dir.isEmpty) {
        // Fallback
        dir = (await getApplicationDocumentsDirectory()).path;
      }

      final name = exportFileName.value.isNotEmpty
          ? exportFileName.value
          : "merged_${DateTime.now().millisecondsSinceEpoch}.wav";

      // Ensure extension
      String fullPath = '$dir/$name';
      if (!fullPath.toLowerCase().endsWith('.wav')) {
        // Force WAV for now or keep extension?
        // Plan didn't specify format, but safer to use .wav or .mp3 based on encoder.
        // Let's rely on ffmpeg auto-detection from extension, default .wav if none.
        if (!name.contains('.')) fullPath += ".wav";
      }

      // 3. Call Service
      final successPath = await _editingService.mergeAudioSegments(
        segments,
        fullPath,
      );

      if (successPath != null) {
        Get.snackbar("Success", "Merged audio saved to $successPath");
        // Optional: Open it or Go back
        // Get.back();
      } else {
        Get.snackbar("Error", "Failed to merge audio");
      }
    } catch (e) {
      debugPrint("Merge logic error: $e");
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- UI Helpers & Folder Selection ---

  Color getTrackColor(int index) {
    switch (index % 3) {
      case 0:
        return ColorClass.trackBlue;
      case 1:
        return ColorClass.trackGreen;
      case 2:
        return ColorClass.trackOrange;
      default:
        return ColorClass.white;
    }
  }

  void selectExportFolder() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/recordings');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      // List directories
      final entities = dir.listSync();
      final folders = entities.whereType<Directory>().toList();

      // 3. Show Dialog
      final size = MediaQuery.of(
        Get.context!,
      ).size; // Use context for size as per rule
      final refSize = size.shortestSide.clamp(0.0, 500.0);

      Get.defaultDialog(
        title: "Select Folder",
        backgroundColor: ColorClass.buttonBg, // Use AppColors
        titleStyle: TextStyle(
          color: ColorClass.white,
          fontSize: refSize * 0.035,
          fontFamily: 'Inter',
        ),
        content: SizedBox(
          height: size.height * 0.4,
          width: double.maxFinite,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: folders.length + 1,
            separatorBuilder: (context, index) =>
                Divider(color: ColorClass.white.withValues(alpha: 0.1)),
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return ListTile(
                  leading: Icon(
                    Icons.home,
                    color: ColorClass.white,
                    size: refSize * 0.035,
                  ),
                  title: TextWidget(
                    text: "Main Recordings",
                    textColor: ColorClass.white,
                    fontSize: refSize * 0.03,
                  ),
                  onTap: () {
                    exportPath.value = dir.path;
                    Get.back();
                  },
                );
              }
              final folder = folders[i - 1];
              final name = folder.path.split(Platform.pathSeparator).last;
              return ListTile(
                leading: Icon(
                  Icons.folder,
                  color: ColorClass.folderIcon, // Use AppColors
                  size: refSize * 0.035,
                ),
                title: TextWidget(
                  text: name,
                  textColor: ColorClass.white,
                  fontSize: refSize * 0.03,
                ),
                onTap: () {
                  exportPath.value = folder.path;
                  Get.back();
                },
              );
            },
          ),
        ),
        radius: 10,
      );
    } catch (e) {
      debugPrint("Error selecting folder: $e");
      Get.snackbar(
        "Error",
        "Could not load folders: $e",
        colorText: ColorClass.white,
        backgroundColor: ColorClass.buttonBg,
      );
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
