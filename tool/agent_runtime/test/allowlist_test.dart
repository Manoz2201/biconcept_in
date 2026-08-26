import 'dart:convert';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class ScriptedClient extends http.BaseClient {
  ScriptedClient(this.responses);

  final List<http.Response> responses;
  int calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = responses[calls];
    calls += 1;
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  test('SEO allowlist accepts copy and seo assets only', () {
    expect(isSeoAllowlisted('assets/seo/pages.json'), isTrue);
    expect(isSeoAllowlisted('assets/seo/runs/2026.json'), isTrue);
    expect(isSeoAllowlisted('web/sitemap.xml'), isTrue);
    expect(isSeoAllowlisted('web/index.html'), isTrue);
    expect(isSeoAllowlisted('lib/content/copy.dart'), isTrue);
    expect(isSeoAllowlisted('lib/data/appwrite_config.dart'), isFalse);
    expect(isSeoAllowlisted('lib/features/admin/admin_login_page.dart'), isFalse);
  });

  test('withJob runs the body when APPWRITE_API_KEY is absent', () async {
    final result = await withJob(
      agentId: 'market',
      title: 'progress',
      body: (writer, jobId) async {
        expect(writer, isNull);
        expect(jobId, isNull);
        return 10;
      },
    );
    expect(result, 10);
  });

  test('postGeminiGenerate retries 503 then succeeds', () async {
    final client = ScriptedClient([
      http.Response('{"error":{"code":503}}', 503),
      http.Response('{"candidates":[]}', 200),
    ]);
    final response = await postGeminiGenerate(
      httpClient: client,
      apiKey: 'test',
      model: 'gemini-3.6-flash',
      body: const {'contents': []},
      attemptsPerModel: 2,
      fallbackModels: const [],
      sleep: (_) async {},
    );
    expect(client.calls, 2);
    expect(response.statusCode, 200);
  });
}
