import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Analysis modes for AI text processing
enum AnalysisMode { summarize, simplify, actionItems, format }

/// Service for AI-powered text analysis using OpenAI GPT-4o-mini
class AiAnalysisService {
  late final Dio _dio;
  static const String _chatEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  AiAnalysisService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  /// Get API key from environment
  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  /// Get system prompt based on analysis mode
  String _getSystemPrompt(AnalysisMode mode) {
    switch (mode) {
      case AnalysisMode.summarize:
        return '''You are a professional summarizer. 
Create a concise summary of the provided text in 2-3 sentences.
Focus on the main points and key information.
Respond in the same language as the input text.''';

      case AnalysisMode.simplify:
        return '''You are an expert at explaining complex topics simply.
Rewrite the provided text in simple, easy-to-understand language.
Explain it like you're talking to a 5-year-old (ELI5).
Respond in the same language as the input text.''';

      case AnalysisMode.actionItems:
        return '''You are a professional assistant.
Extract all action items, tasks, and conclusions from the provided text.
Format them as a numbered list.
If no clear action items exist, identify key decisions or conclusions.
Respond in the same language as the input text.''';

      case AnalysisMode.format:
        return '''You are a Markdown formatting expert.
Format the provided text into clean, well-structured Markdown.
Use appropriate headers, lists, and emphasis.
Preserve all original information while improving readability.
Respond in the same language as the input text.''';
    }
  }

  /// Analyze text using specified mode
  /// Returns analyzed text or null on failure
  Future<String?> analyze(String text, AnalysisMode mode) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('AiAnalysisService: API key not found');
      return null;
    }

    if (text.trim().isEmpty) {
      debugPrint('AiAnalysisService: Empty text provided');
      return null;
    }

    try {
      final response = await _dio.post(
        _chatEndpoint,
        data: {
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt(mode)},
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          return choices[0]['message']['content']?.toString().trim();
        }
      }

      debugPrint('AiAnalysisService: API error ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('AiAnalysisService: Dio error: ${e.message}');
      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('AiAnalysisService: Error: $e');
      return null;
    }
  }

  /// Convenience methods for each analysis mode
  Future<String?> summarize(String text) =>
      analyze(text, AnalysisMode.summarize);
  Future<String?> simplify(String text) => analyze(text, AnalysisMode.simplify);
  Future<String?> extractActionItems(String text) =>
      analyze(text, AnalysisMode.actionItems);
  Future<String?> formatAsMarkdown(String text) =>
      analyze(text, AnalysisMode.format);

  /// Auto-tag audio based on transcription content
  Future<List<String>> suggestTags(String transcription) async {
    if (_apiKey == null || transcription.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _dio.post(
        _chatEndpoint,
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a tagging assistant.
Analyze the text and suggest 2-5 relevant tags.
Return ONLY the tags as a comma-separated list, nothing else.
Example: meeting, project, deadline, budget''',
            },
            {'role': 'user', 'content': transcription},
          ],
          'temperature': 0.5,
          'max_tokens': 50,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        if (content != null) {
          return content
              .toString()
              .split(',')
              .map((tag) => tag.trim().toLowerCase())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('AiAnalysisService: Tag suggestion error: $e');
      return [];
    }
  }
}
