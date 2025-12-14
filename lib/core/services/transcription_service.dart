import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for transcribing audio using OpenAI Whisper API
class TranscriptionService {
  late final Dio _dio;
  static const String _whisperEndpoint =
      'https://api.openai.com/v1/audio/transcriptions';

  TranscriptionService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }

  /// Get API key from environment
  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  /// Transcribe audio file to text
  /// [audioPath] - Path to audio file
  /// [language] - Language code (default: 'uz' for Uzbek)
  /// Returns transcribed text or null on failure
  Future<String?> transcribeAudio(
    String audioPath, {
    String language = 'uz',
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('TranscriptionService: API key not found');
      return null;
    }

    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        debugPrint('TranscriptionService: Audio file not found: $audioPath');
        return null;
      }

      final fileName = audioPath.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath, filename: fileName),
        'model': 'whisper-1',
        'language': language,
        'response_format': 'text',
      });

      final response = await _dio.post(
        _whisperEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data.toString().trim();
      } else {
        debugPrint('TranscriptionService: API error ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('TranscriptionService: Dio error: ${e.message}');
      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('TranscriptionService: Error: $e');
      return null;
    }
  }

  /// Transcribe with timestamps (verbose JSON response)
  Future<TranscriptionResult?> transcribeWithTimestamps(
    String audioPath, {
    String language = 'uz',
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return null;
    }

    try {
      final file = File(audioPath);
      if (!await file.exists()) return null;

      final fileName = audioPath.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath, filename: fileName),
        'model': 'whisper-1',
        'language': language,
        'response_format': 'verbose_json',
        'timestamp_granularities[]': 'segment',
      });

      final response = await _dio.post(
        _whisperEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TranscriptionResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('TranscriptionService: Error with timestamps: $e');
      return null;
    }
  }
}

/// Result model for transcription with timestamps
class TranscriptionResult {
  final String text;
  final String language;
  final double duration;
  final List<TranscriptionSegment> segments;

  TranscriptionResult({
    required this.text,
    required this.language,
    required this.duration,
    required this.segments,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] ?? '',
      language: json['language'] ?? '',
      duration: (json['duration'] ?? 0).toDouble(),
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((s) => TranscriptionSegment.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class TranscriptionSegment {
  final int id;
  final double start;
  final double end;
  final String text;

  TranscriptionSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] ?? 0,
      start: (json['start'] ?? 0).toDouble(),
      end: (json['end'] ?? 0).toDouble(),
      text: json['text'] ?? '',
    );
  }
}
