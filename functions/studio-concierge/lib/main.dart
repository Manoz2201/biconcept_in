import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:studio_concierge/agent.dart';

Future<dynamic> main(final context) async {
  try {
    final userId = '${context.req.headers['x-appwrite-user-id'] ?? ''}';
    if (userId.isEmpty) {
      return context.res.json({'reply': 'Sign in required.'}, status: 401);
    }

    final payload = _payload(context);
    final message = '${payload['message'] ?? ''}'.trim();
    if (message.isEmpty) {
      return context.res.json({'reply': 'Send a message.'});
    }

    final geminiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
    final apiKey = Platform.environment['APPWRITE_API_KEY'] ??
        Platform.environment['APPWRITE_FUNCTION_API_KEY'] ?? '';
    final publishAll = wantsPublishAllListings(message);
    if (apiKey.isEmpty || (geminiKey.isEmpty && !publishAll)) {
      return context.res.json({'reply': 'Concierge is missing Function secrets.'});
    }

    final endpoint = Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ??
        Platform.environment['APPWRITE_ENDPOINT'] ??
        'https://sgp.cloud.appwrite.io/v1';
    final projectId = Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ??
        Platform.environment['APPWRITE_PROJECT_ID'] ??
        '6a8de2d2003a8c9f54fe';
    final databaseId = Platform.environment['APPWRITE_DATABASE_ID'] ?? 'biconcept';

    final tables = TablesDB(
      Client().setEndpoint(endpoint).setProject(projectId).setKey(apiKey),
    );
    final jobs = JobTracker(tables: tables, databaseId: databaseId);
    var jobId = '';
    try {
      jobId = await jobs.start(jobId: '${payload['jobId'] ?? ''}');
    } catch (error) {
      context.error('job start: $error');
    }

    try {
      final agent = ConciergeAgent(
        gemini: HttpGemini(
          apiKey: geminiKey.isEmpty ? 'unused' : geminiKey,
          model: Platform.environment['GEMINI_MODEL'] ?? 'gemini-3.6-flash',
        ),
        cms: AppwriteCms(tables: tables, databaseId: databaseId),
      );
      final reply = await agent.handle(message);
      await _finishJob(jobs, jobId, ok: true, summary: reply);
      return context.res.json({'reply': reply});
    } catch (error) {
      final reply = friendlyConciergeError(error);
      await _finishJob(jobs, jobId, ok: false, summary: reply);
      return context.res.json({'reply': reply});
    }
  } catch (error) {
    context.error('$error');
    return context.res.json({'reply': friendlyConciergeError(error)});
  }
}

Future<void> _finishJob(JobTracker jobs, String jobId, {required bool ok, required String summary}) async {
  if (jobId.isEmpty) return;
  try {
    await jobs.finish(
      jobId,
      ok: ok,
      summary: summary.length > 180 ? '${summary.substring(0, 180)}…' : summary,
    );
  } catch (_) {}
}

Map<String, dynamic> _payload(dynamic context) {
  try {
    final json = context.req.bodyJson;
    if (json is Map) return Map<String, dynamic>.from(json);
  } catch (_) {}
  final body = context.req.body;
  if (body is Map) return Map<String, dynamic>.from(body);
  if (body is String && body.trim().isNotEmpty) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}
