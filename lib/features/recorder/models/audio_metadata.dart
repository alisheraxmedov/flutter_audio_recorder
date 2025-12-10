/// Audio recording metadata model.
/// Stored in JSON format in GetStorage.
class AudioMetadata {
  final String path;
  final String name;
  final int durationMs;
  final int sizeBytes;
  final DateTime createdAt;
  final bool isFavorite;

  AudioMetadata({
    required this.path,
    required this.name,
    required this.durationMs,
    required this.sizeBytes,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// Create object from JSON
  factory AudioMetadata.fromJson(Map<String, dynamic> json) {
    return AudioMetadata(
      path: json['path'] as String,
      name: json['name'] as String,
      durationMs: json['durationMs'] as int,
      sizeBytes: json['sizeBytes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'durationMs': durationMs,
      'sizeBytes': sizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  /// Create copy (immutable pattern)
  AudioMetadata copyWith({
    String? path,
    String? name,
    int? durationMs,
    int? sizeBytes,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return AudioMetadata(
      path: path ?? this.path,
      name: name ?? this.name,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Get formatted duration (MM:SS)
  String get formattedDuration {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get formatted size (KB/MB)
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
