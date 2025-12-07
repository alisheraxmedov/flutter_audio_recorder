import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Check and Request Permission
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  // Start Recording
  Future<void> start({
    required String fileName,
    required AudioEncoder encoder,
  }) async {
    try {
      if (await hasPermission()) {
        String filePath = '';

        if (!kIsWeb) {
          final Directory appDir = await getApplicationDocumentsDirectory();
          final Directory recordsDir = Directory('${appDir.path}/recordings');
          if (!await recordsDir.exists()) {
            await recordsDir.create(recursive: true);
          }
          filePath = '${recordsDir.path}/$fileName';
        }

        // Check if encoder is supported, fallback if needed
        if (!await _audioRecorder.isEncoderSupported(encoder)) {
          print("Encoder $encoder not supported, falling back to AAC");
          encoder = AudioEncoder.aacLc;
        }

        await _audioRecorder.start(
          RecordConfig(encoder: encoder),
          path: filePath,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error starting record: $e");
      }
    }
  }

  // Stop Recording
  Future<String?> stop() async {
    final path = await _audioRecorder.stop();
    return path;
  }

  // Pause Recording
  Future<void> pause() async {
    await _audioRecorder.pause();
  }

  // Resume Recording
  Future<void> resume() async {
    await _audioRecorder.resume();
  }

  // Dispose
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }

  // Get Amplitude (for wave visualizer)
  Future<Amplitude> getAmplitude() async {
    return await _audioRecorder.getAmplitude();
  }

  // Is Recording Stream
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  // Get All Recordings
  Future<List<String>> getAllRecordings() async {
    if (kIsWeb) {
      // On Web, we can't easily list files unless we use IndexedDB or similar.
      // For now, return empty list or manage via state in Controller.
      return [];
    } else {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory recordsDir = Directory('${appDir.path}/recordings');
        if (await recordsDir.exists()) {
          // List files and sort by modification date (newest first)
          final List<FileSystemEntity> entities = recordsDir.listSync();
          final List<File> files = entities.whereType<File>().toList();

          files.sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );

          return files.map((e) => e.path).toList();
        }
        return [];
      } catch (e) {
        if (kDebugMode) {
          print("Error listing recordings: $e");
        }
        return [];
      }
    }
  }
}
