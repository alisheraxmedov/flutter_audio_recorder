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

  Future<Directory> getRecordingsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Not supported on web');
    }
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory recordsDir = Directory('${appDir.path}/recordings');
    if (!await recordsDir.exists()) {
      await recordsDir.create(recursive: true);
    }
    return recordsDir;
  }

  // Start Recording
  Future<void> start({
    required String fileName,
    required AudioEncoder encoder,
    String? directoryPath,
  }) async {
    try {
      if (await hasPermission()) {
        String filePath = '';

        if (!kIsWeb) {
          final dir = directoryPath != null
              ? Directory(directoryPath)
              : await getRecordingsDirectory();
          filePath = '${dir.path}/$fileName';
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

  // Get Entities (Files & Folders)
  Future<List<FileSystemEntity>> getEntities(String path) async {
    if (kIsWeb) return [];
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        final List<FileSystemEntity> entities = dir.listSync();
        // Sort: Folders first, then Files. Within type, sort by date (newest first)
        entities.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          // Both same type, sort by modified date
          return b.statSync().modified.compareTo(a.statSync().modified);
        });
        return entities;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print("Error listing entities: $e");
      }
      return [];
    }
  }

  // Create Folder
  Future<void> createFolder(String name, String parentPath) async {
    if (kIsWeb) return;
    try {
      final newDir = Directory('$parentPath/$name');
      if (!await newDir.exists()) {
        await newDir.create();
      }
    } catch (e) {
      print("Error creating folder: $e");
      rethrow;
    }
  }

  // Rename Entity
  Future<void> renameEntity(String path, String newName) async {
    if (kIsWeb) return;
    try {
      final entity = FileSystemEntity.isDirectorySync(path)
          ? Directory(path)
          : File(path);

      if (await entity.exists()) {
        final parent = entity.parent.path;
        // Keep extension if file
        String newPath = '$parent/$newName';

        await entity.rename(newPath);
      }
    } catch (e) {
      print("Error renaming entity: $e");
      rethrow;
    }
  }

  // Move Entity
  Future<void> moveEntity(String sourcePath, String destinationPath) async {
    if (kIsWeb) return;
    try {
      final entity = FileSystemEntity.isDirectorySync(sourcePath)
          ? Directory(sourcePath)
          : File(sourcePath);

      if (await entity.exists()) {
        final name = sourcePath.split(Platform.pathSeparator).last;
        final newPath = '$destinationPath/$name';
        await entity.rename(newPath);
      }
    } catch (e) {
      print("Error moving entity: $e");
      rethrow;
    }
  }
}
