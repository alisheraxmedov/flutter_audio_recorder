import 'dart:io';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AudioEditingService {
  /// Extract Duration in MS using FFprobe
  Future<int> getDurationMs(String path) async {
    try {
      if (!kIsWeb &&
          (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        // Parse duration from ffmpeg output on desktop
        // Command: ffmpeg -i input 2>&1 | grep "Duration"
        // Or just run -i and parse stderr
        final result = await Process.run('ffmpeg', ['-i', path]);
        final output = result.stderr.toString();
        final durationMatch = RegExp(
          r"Duration: (\d+):(\d+):(\d+\.\d+)",
        ).firstMatch(output);
        if (durationMatch != null) {
          final h = int.parse(durationMatch.group(1)!);
          final m = int.parse(durationMatch.group(2)!);
          final s = double.parse(durationMatch.group(3)!);
          return (h * 3600 * 1000 + m * 60 * 1000 + s * 1000).toInt();
        }
        return 0;
      } else {
        final session = await FFprobeKit.getMediaInformation(path);
        final info = session.getMediaInformation();
        final durationStr = info?.getDuration();
        if (durationStr != null) {
          return (double.parse(durationStr) * 1000).toInt();
        }
      }
    } catch (e) {
      debugPrint("Error getting duration: $e");
    }
    return 0;
  }

  /// Extracts waveform data from an audio file.
  Future<List<double>> extractWaveform(
    String path, {
    int samplesPerSecond = 20,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputRawPath =
          '${tempDir.path}/waveform_${DateTime.now().millisecondsSinceEpoch}.raw';

      final command =
          '-y -i "$path" -ac 1 -ar 1000 -f s16le -c:a pcm_s16le "$outputRawPath"';

      bool success = await _runFFmpeg(command);

      if (!success) {
        debugPrint("FFmpeg extraction failed");
        return [];
      }

      final file = File(outputRawPath);
      if (!await file.exists()) return [];

      final bytes = await file.readAsBytes();
      await file.delete();

      return _processRawData(bytes, samplesPerSecond);
    } catch (e) {
      debugPrint("Error extracting waveform: $e");
      return [];
    }
  }

  /// TRIM: Keep only [startSec] to [endSec]
  Future<String?> trim(String path, double startSec, double endSec) async {
    try {
      final dir = File(path).parent.path;
      final ext = path.split('.').last;
      final name = path.split(RegExp(r'[/\\]')).last.split('.').first;
      final outputPath = '$dir/${name}_trimmed.$ext';

      // Command: -ss START -to END -i INPUT -c copy OUTPUT
      // Using -c copy for speed (might be imprecise for MP3 but good for M4A/AAC often)
      // If issues, remove -c copy to re-encode (slower but precise)
      final command = '-y -ss $startSec -to $endSec -i "$path" "$outputPath"';

      final success = await _runFFmpeg(command);
      return success ? outputPath : null;
    } catch (e) {
      debugPrint("Trim error: $e");
      return null;
    }
  }

  /// CUT: Remove [startSec] to [endSec] (Keep 0-start + end-total)
  Future<String?> cut(String path, double startSec, double endSec) async {
    // Need to create 2 segments and concat
    try {
      final tempDir = await getTemporaryDirectory();
      final part1Path =
          '${tempDir.path}/part1_cut.wav'; // Intermediate WAV for safety
      final part2Path = '${tempDir.path}/part2_cut.wav';

      // Setup output
      final dir = File(path).parent.path;
      final ext = path.split('.').last;
      final name = path.split(RegExp(r'[/\\]')).last.split('.').first;
      final outputPath = '$dir/${name}_cut.$ext';

      // 1. Extract Part 1 (0 to start)
      final cmd1 = '-y -i "$path" -t $startSec "$part1Path"';
      if (!await _runFFmpeg(cmd1)) return null;

      // 2. Extract Part 2 (end to total)
      final cmd2 = '-y -ss $endSec -i "$path" "$part2Path"';
      if (!await _runFFmpeg(cmd2)) return null;

      // 3. Concat
      // filter_complex "[0:0][1:0]concat=n=2:v=0:a=1[out]" -map "[out]"
      final cmd3 =
          '-y -i "$part1Path" -i "$part2Path" -filter_complex "[0:0][1:0]concat=n=2:v=0:a=1[out]" -map "[out]" "$outputPath"';

      final success = await _runFFmpeg(cmd3);

      // Cleanup temp
      File(part1Path).delete().ignore();
      File(part2Path).delete().ignore();

      return success ? outputPath : null;
    } catch (e) {
      debugPrint("Cut error: $e");
      return null;
    }
  }

  Future<bool> _runFFmpeg(String command) async {
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      try {
        final args = _parseCommandArgs(command);
        final result = await Process.run('ffmpeg', args);
        if (result.exitCode != 0) {
          debugPrint('FFmpeg (Desktop) Error: ${result.stderr}');
          return false;
        }
        return true;
      } catch (e) {
        debugPrint('FFmpeg (Desktop) Exception: $e');
        return false;
      }
    } else {
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      return ReturnCode.isSuccess(returnCode);
    }
  }

  List<double> _processRawData(Uint8List bytes, int samplesPerSecond) {
    final int sampleSize = 2;
    final int totalSamples = bytes.length ~/ sampleSize;
    int chunkSize = 1000 ~/ samplesPerSecond;
    if (chunkSize < 1) chunkSize = 1;

    List<double> amplitudes = [];
    final buffer = ByteData.sublistView(bytes);

    for (int i = 0; i < totalSamples; i += chunkSize) {
      double sum = 0;
      int count = 0;
      for (int j = 0; j < chunkSize && (i + j) < totalSamples; j++) {
        int sample = buffer.getInt16((i + j) * 2, Endian.little);
        sum += sample.abs();
        count++;
      }
      if (count > 0) {
        double avg = sum / count;
        amplitudes.add((avg / 32768.0).clamp(0.0, 1.0));
      }
    }
    return amplitudes;
  }

  List<String> _parseCommandArgs(String command) {
    List<String> args = [];
    RegExp regex = RegExp(r'[^\s"]+|"([^"]*)"');
    Iterable<Match> matches = regex.allMatches(command);
    for (Match match in matches) {
      if (match.group(1) != null) {
        args.add(match.group(1)!);
      } else {
        args.add(match.group(0)!);
      }
    }
    return args;
  }

  /// MERGE: Combine multiple segments into one file
  Future<String?> mergeAudioSegments(
    List<AudioSegment> segments,
    String outputPath,
  ) async {
    if (segments.isEmpty) return null;

    try {
      // Inputs
      // ffmpeg -i file1 -i file2 ...
      // Filter
      // [0:0]trim=start=S1:end=E1,asetpts=PTS-STARTPTS[v0];
      // [1:0]trim=start=S2:end=E2,asetpts=PTS-STARTPTS[v1];
      // [v0][v1]concat=n=2:v=0:a=1[out]

      final sb = StringBuffer();
      final inputs = <String>[];
      final filters = <String>[];
      final tracks = <String>[];

      for (int i = 0; i < segments.length; i++) {
        final seg = segments[i];
        inputs.add('-i');
        inputs.add('"${seg.filePath}"');

        // Filter for this segment
        // start and end are in seconds
        // Use 'atrim' for audio, otherwise 'trim' defaults to video or mixed
        filters.add(
          '[$i:0]atrim=start=${seg.startSec}:end=${seg.endSec},asetpts=PTS-STARTPTS[a$i]',
        );
        tracks.add('[a$i]');
      }

      final filterComplex =
          '${filters.join(';')};${tracks.join('')}concat=n=${segments.length}:v=0:a=1[out]';

      // Build command
      sb.write('-y '); // overwrite
      for (final inp in inputs) {
        sb.write('$inp ');
      }
      sb.write('-filter_complex "$filterComplex" -map "[out]" "$outputPath"');

      final success = await _runFFmpeg(sb.toString());
      return success ? outputPath : null;
    } catch (e) {
      debugPrint("Merge error: $e");
      return null;
    }
  }
}

class AudioSegment {
  final String filePath;
  final double startSec;
  final double endSec;

  AudioSegment({
    required this.filePath,
    required this.startSec,
    required this.endSec,
  });
}
