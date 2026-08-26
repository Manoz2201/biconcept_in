import 'dart:io';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:market_agent/agent.dart';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final geminiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
  final serperKey = Platform.environment['SERPER_API_KEY'] ?? '';
  final appwriteKey = Platform.environment['APPWRITE_API_KEY'] ?? '';
  final endpoint =
      Platform.environment['APPWRITE_ENDPOINT'] ?? 'https://sgp.cloud.appwrite.io/v1';
  final projectId = Platform.environment['APPWRITE_PROJECT_ID'] ?? '6a8de2d2003a8c9f54fe';
  final databaseId = Platform.environment['APPWRITE_DATABASE_ID'] ?? 'biconcept';
  final model = Platform.environment['GEMINI_MODEL'] ?? 'gemini-3.6-flash';

  if (geminiKey.isEmpty || serperKey.isEmpty) {
    stderr.writeln('GEMINI_API_KEY and SERPER_API_KEY are required.');
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
      agentId: 'market',
      title: dryRun ? 'Market research (dry run)' : 'Market research',
      body: (writer, jobId) async {
        if (writer != null && jobId != null) {
          await writer.progress(jobId, 20, summary: 'Searching NCR launches…');
        }
        final serp = SerpClient(apiKey: serperKey);
        final snippets = await serp.search(defaultQueries);
        stdout.writeln('Serper snippets: ${snippets.length}');
        if (writer != null && jobId != null) {
          await writer.progress(jobId, 50, summary: 'Extracting listings…');
        }
        final gemini = GeminiResearch(apiKey: geminiKey, model: model);
        final listings = await gemini.extract(snippets);
        stdout.writeln('Extracted listings=${listings.length}');
        if (dryRun) {
          for (final listing in listings) {
            stdout.writeln('- ${listing.city}/${listing.sector} ${listing.title}');
          }
          if (jobId != null) {
            await writer?.succeed(jobId, summary: 'Dry run: ${listings.length} listing(s)');
          }
          return;
        }
        final sync = AppwriteSync(
          endpoint: endpoint,
          projectId: projectId,
          apiKey: appwriteKey,
          databaseId: databaseId,
        );
        final written = await sync.upsertNewListings(listings, cap: 15);
        stdout.writeln('Wrote published listings=$written');
        if (jobId != null) {
          await writer?.succeed(
            jobId,
            summary: 'Published $written listing(s)',
            log: 'extracted=${listings.length} published=$written',
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
