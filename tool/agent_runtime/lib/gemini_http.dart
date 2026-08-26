import 'dart:convert';

import 'package:http/http.dart' as http;

typedef GeminiSleeper = Future<void> Function(Duration duration);

Future<void> _defaultSleep(Duration duration) => Future<void>.delayed(duration);

/// POST generateContent with backoff on 429/503 and a fallback model.
Future<http.Response> postGeminiGenerate({
  required http.Client httpClient,
  required String apiKey,
  required String model,
  required Object body,
  List<String> fallbackModels = const ['gemini-2.5-flash'],
  int attemptsPerModel = 4,
  GeminiSleeper sleep = _defaultSleep,
}) async {
  final models = [model, ...fallbackModels.where((name) => name != model)];
  http.Response? last;
  for (final name in models) {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$name:generateContent?key=$apiKey',
    );
    for (var attempt = 0; attempt < attemptsPerModel; attempt++) {
      last = await httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (last.statusCode >= 200 && last.statusCode < 300) return last;
      final retryable = last.statusCode == 429 || last.statusCode == 503;
      if (!retryable) break;
      await sleep(Duration(milliseconds: 800 * (attempt + 1) * (attempt + 1)));
    }
    if (last != null && last.statusCode != 404 && last.statusCode != 429 && last.statusCode != 503) {
      throw StateError('Gemini HTTP ${last.statusCode}: ${last.body}');
    }
  }
  throw StateError('Gemini HTTP ${last?.statusCode ?? 0}: ${last?.body ?? 'empty response'}');
}
