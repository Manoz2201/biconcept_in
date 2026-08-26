import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

class QueuedJob {
  const QueuedJob({
    required this.id,
    required this.agentId,
    required this.title,
    required this.payload,
  });

  final String id;
  final String agentId;
  final String title;
  final String payload;
}

class JobWriter {
  JobWriter({
    required String endpoint,
    required String projectId,
    required String apiKey,
    required this.databaseId,
    this.tableId = 'agent_jobs',
  }) : _tables = TablesDB(
          Client()
              .setEndpoint(endpoint)
              .setProject(projectId)
              .setKey(apiKey),
        );

  final String databaseId;
  final String tableId;
  final TablesDB _tables;

  Future<String> start({
    required String agentId,
    required String title,
    String? jobId,
    String payload = '',
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    if (jobId != null && jobId.isNotEmpty) {
      await _tables.updateRow(
        databaseId: databaseId,
        tableId: tableId,
        rowId: jobId,
        data: {
          'status': 'running',
          'progress': 10,
          'startedAt': now,
          'summary': 'Running…',
        },
      );
      return jobId;
    }
    final row = await _tables.createRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: ID.unique(),
      data: {
        'agentId': agentId,
        'title': title,
        'status': 'running',
        'progress': 10,
        'summary': 'Started',
        'log': '',
        'payload': payload,
        'startedAt': now,
        'finishedAt': '',
      },
      permissions: [
        Permission.read(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    return row.$id;
  }

  Future<void> progress(String jobId, int percent, {String? summary, String? log}) {
    return _tables.updateRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: jobId,
      data: {
        'progress': percent.clamp(0, 99),
        'status': 'running',
        if (summary != null) 'summary': summary,
        if (log != null) 'log': log,
      },
    );
  }

  Future<void> succeed(String jobId, {required String summary, String log = ''}) {
    return _tables.updateRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: jobId,
      data: {
        'status': 'succeeded',
        'progress': 100,
        'summary': summary,
        'log': log,
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<void> fail(String jobId, Object error) {
    return _tables.updateRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: jobId,
      data: {
        'status': 'failed',
        'progress': 100,
        'summary': 'Failed',
        'log': error.toString(),
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<List<QueuedJob>> listQueued({int limit = 8}) async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: tableId,
      queries: [
        Query.equal('status', 'queued'),
        Query.orderAsc('\$createdAt'),
        Query.limit(limit),
      ],
    );
    return [
      for (final row in result.rows)
        QueuedJob(
          id: row.$id,
          agentId: '${row.data['agentId'] ?? ''}',
          title: '${row.data['title'] ?? ''}',
          payload: '${row.data['payload'] ?? ''}',
        ),
    ];
  }
}

JobWriter? jobWriterFromEnv() {
  final key = Platform.environment['APPWRITE_API_KEY'] ?? '';
  if (key.isEmpty) return null;
  return JobWriter(
    endpoint: Platform.environment['APPWRITE_ENDPOINT'] ?? 'https://sgp.cloud.appwrite.io/v1',
    projectId: Platform.environment['APPWRITE_PROJECT_ID'] ?? '6a8de2d2003a8c9f54fe',
    apiKey: key,
    databaseId: Platform.environment['APPWRITE_DATABASE_ID'] ?? 'biconcept',
  );
}

Future<T> withJob<T>({
  required String agentId,
  required String title,
  required Future<T> Function(JobWriter? writer, String? jobId) body,
}) async {
  final writer = jobWriterFromEnv();
  final existing = Platform.environment['AGENT_JOB_ID'];
  String? jobId;
  if (writer != null) {
    try {
      jobId = await writer.start(
        agentId: agentId,
        title: title,
        jobId: existing,
      );
    } catch (error) {
      stderr.writeln('Job start skipped: $error');
    }
  }
  try {
    return await body(writer, jobId);
  } catch (error) {
    if (writer != null && jobId != null) {
      try {
        await writer.fail(jobId, error);
      } catch (_) {}
    }
    rethrow;
  }
}

/// Files the SEO/copy agent may write. Anything else is rejected.
const seoAllowlistPrefixes = [
  'assets/seo/',
  'web/sitemap.xml',
  'web/index.html',
  'lib/content/copy.dart',
];

bool isSeoAllowlisted(String path) {
  final normalized = path.replaceAll('\\', '/');
  final relative = normalized.contains('/biconcept_in/')
      ? normalized.split('/biconcept_in/').last
      : normalized;
  for (final allowed in seoAllowlistPrefixes) {
    if (relative == allowed || relative.endsWith('/$allowed') || relative.startsWith(allowed)) {
      return true;
    }
    if (allowed.endsWith('/') && relative.startsWith(allowed)) return true;
  }
  return false;
}
