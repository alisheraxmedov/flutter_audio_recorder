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
  Future<void> start({required String fileName}) async {
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

        // Check for supported encoder
        AudioEncoder encoder = AudioEncoder.aacLc;
        if (!await _audioRecorder.isEncoderSupported(encoder)) {
          encoder = AudioEncoder.opus;
          if (!await _audioRecorder.isEncoderSupported(encoder)) {
            encoder = AudioEncoder.wav;
          }
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
}
