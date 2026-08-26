import 'dart:io';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:offers_agent/agent.dart';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final geminiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
  final appwriteKey = Platform.environment['APPWRITE_API_KEY'] ?? '';
  final endpoint =
      Platform.environment['APPWRITE_ENDPOINT'] ?? 'https://sgp.cloud.appwrite.io/v1';
  final projectId = Platform.environment['APPWRITE_PROJECT_ID'] ?? '6a8de2d2003a8c9f54fe';
  final databaseId = Platform.environment['APPWRITE_DATABASE_ID'] ?? 'biconcept';
  final model = Platform.environment['GEMINI_MODEL'] ?? 'gemini-3.6-flash';

  if (geminiKey.isEmpty) {
    stderr.writeln('GEMINI_API_KEY is required.');
    exitCode = 1;
    return;
  }
  if (!dryRun && appwriteKey.isEmpty) {
    stderr.writeln('APPWRITE_API_KEY is required unless --dry-run.');
    exitCode = 1;
    return;
  }

  try {
    await withJob(
      agentId: 'offers',
      title: dryRun ? 'Studio offers (dry run)' : 'Studio offers',
      body: (writer, jobId) async {
        if (writer != null && jobId != null) {
          await writer.progress(jobId, 40, summary: 'Proposing offers…');
        }
        final drafts = await GeminiOffers(apiKey: geminiKey, model: model).propose();
        stdout.writeln('Proposed offers=${drafts.length}');
        if (dryRun) {
          for (final draft in drafts) {
            stdout.writeln('- ${draft.title}');
          }
          if (jobId != null) {
            await writer?.succeed(jobId, summary: 'Dry run: ${drafts.length} offer(s)');
          }
          return;
        }
        final sync = OffersSync(
          endpoint: endpoint,
          projectId: projectId,
          apiKey: appwriteKey,
          databaseId: databaseId,
        );
        final result = await sync.upsertNewOffers(drafts, capActive: 2);
        stdout.writeln('Wrote published offers=${result.written}');
        if (jobId != null) {
          await writer?.succeed(
            jobId,
            summary: 'Published ${result.written} offer(s)',
            log: result.skipped.join('\n'),
          );
        }
      },
    );
    exitCode = 0;
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
