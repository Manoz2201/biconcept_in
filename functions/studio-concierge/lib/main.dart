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
    if (geminiKey.isEmpty || apiKey.isEmpty) {
      return context.res.json({'reply': 'Concierge is missing Function secrets.'}, status: 500);
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
    final jobId = await jobs.start(jobId: '${payload['jobId'] ?? ''}');

    try {
      final agent = ConciergeAgent(
        gemini: HttpGemini(
          apiKey: geminiKey,
          model: Platform.environment['GEMINI_MODEL'] ?? 'gemini-3.6-flash',
        ),
        cms: AppwriteCms(tables: tables, databaseId: databaseId),
      );
      final reply = await agent.handle(message);
      await jobs.finish(jobId, ok: true, summary: reply.length > 180 ? '${reply.substring(0, 180)}…' : reply);
      return context.res.json({'reply': reply});
    } catch (error) {
      await jobs.finish(jobId, ok: false, summary: error.toString());
      rethrow;
    }
  } catch (error) {
    context.error('$error');
    return context.res.json({'reply': 'Concierge failed: $error'}, status: 500);
  }
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
