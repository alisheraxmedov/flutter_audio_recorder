import 'package:get_storage/get_storage.dart';
import 'package:recorder/features/recorder/models/audio_metadata.dart';

/// Service for managing audio metadata via GetStorage.
/// This service performs CRUD operations.
class MetadataService {
  static const String _storageKey = 'audio_metadata';
  late final GetStorage _storage;

  MetadataService() {
    _storage = GetStorage();
  }

  /// Get all metadata
  Map<String, AudioMetadata> getAll() {
    final Map<String, dynamic>? rawData = _storage.read<Map<String, dynamic>>(
      _storageKey,
    );
    if (rawData == null) return {};

    return rawData.map((key, value) {
      return MapEntry(
        key,
        AudioMetadata.fromJson(Map<String, dynamic>.from(value)),
      );
    });
  }

  /// Get single metadata by path
  AudioMetadata? get(String path) {
    final all = getAll();
    return all[path];
  }

  /// Save new metadata or update existing
  Future<void> save(AudioMetadata metadata) async {
    final all = getAll();
    all[metadata.path] = metadata;
    await _writeAll(all);
  }

  /// Delete metadata
  Future<void> delete(String path) async {
    final all = getAll();
    all.remove(path);
    await _writeAll(all);
  }

  /// Update metadata when path changes (rename/move)
  Future<void> updatePath(String oldPath, String newPath) async {
    final all = getAll();
    final metadata = all[oldPath];
    if (metadata != null) {
      all.remove(oldPath);
      final newName = newPath.split('/').last;
      all[newPath] = metadata.copyWith(path: newPath, name: newName);
      await _writeAll(all);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String path) async {
    final all = getAll();
    final metadata = all[path];
    if (metadata != null) {
      all[path] = metadata.copyWith(isFavorite: !metadata.isFavorite);
      await _writeAll(all);
    }
  }

  /// Write all data to storage
  Future<void> _writeAll(Map<String, AudioMetadata> data) async {
    final jsonData = data.map((key, value) => MapEntry(key, value.toJson()));
    await _storage.write(_storageKey, jsonData);
  }

  /// Clean orphaned metadata (files that no longer exist)
  Future<void> cleanOrphanedMetadata(List<String> existingPaths) async {
    final all = getAll();
    final pathSet = existingPaths.toSet();
    all.removeWhere((key, value) => !pathSet.contains(key));
    await _writeAll(all);
  }
}
