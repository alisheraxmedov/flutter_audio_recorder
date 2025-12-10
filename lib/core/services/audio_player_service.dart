import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

/// Service for audio playback using audioplayers package.
/// Supports all common audio formats (AAC, MP3, WAV, FLAC, OGG, etc.)
/// Works on Android, iOS, Linux, Windows, macOS, and Web.
class AudioPlayerService extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  // Observables
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentPath = ''.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  // Track if audio completed
  bool _isCompleted = false;

  @override
  void onInit() {
    super.onInit();
    _initListeners();
  }

  void _initListeners() {
    // Listen to player state changes
    _player.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;

      if (state == PlayerState.completed) {
        // Reset when playback completes
        position.value = Duration.zero;
        isPlaying.value = false;
        _isCompleted = true;
      }
    });

    // Listen to position changes
    _player.onPositionChanged.listen((pos) {
      position.value = pos;
    });

    // Listen to duration changes
    _player.onDurationChanged.listen((dur) {
      duration.value = dur;
    });
  }

  /// Load and play audio file
  Future<void> play(String path) async {
    try {
      isLoading.value = true;

      // If different file OR same file that completed, reload it
      if (currentPath.value != path || _isCompleted) {
        await _player.setSourceDeviceFile(path);
        currentPath.value = path;
        _isCompleted = false;
      }

      await _player.resume();
    } catch (e) {
      print('Error playing audio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause(String path) async {
    if (currentPath.value == path && isPlaying.value) {
      await pause();
    } else {
      await play(path);
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    position.value = Duration.zero;
    currentPath.value = '';
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Check if this path is currently playing
  bool isCurrentlyPlaying(String path) {
    return currentPath.value == path && isPlaying.value;
  }

  /// Get formatted position string (MM:SS)
  String get formattedPosition {
    final pos = position.value;
    final minutes = pos.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = pos.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get formatted duration string (MM:SS)
  String get formattedDuration {
    final dur = duration.value;
    final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Get progress as double (0.0 to 1.0)
  double get progress {
    if (duration.value.inMilliseconds == 0) return 0.0;
    return position.value.inMilliseconds / duration.value.inMilliseconds;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
