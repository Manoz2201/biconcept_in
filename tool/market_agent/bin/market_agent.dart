import 'dart:io';

import 'package:market_agent/agent.dart';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final geminiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
  final serperKey = Platform.environment['SERPER_API_KEY'] ?? '';
  final appwriteKey = Platform.environment['APPWRITE_API_KEY'] ?? '';
  final endpoint =
      Platform.environment['APPWRITE_ENDPOINT'] ?? 'https://sgp.cloud.appwrite.io/v1';
  final projectId = Platform.environment['APPWRITE_PROJECT_ID'] ?? '6a86a3d4001d87aa9809';
  final databaseId =
      Platform.environment['APPWRITE_DATABASE_ID'] ?? '6a86ad9300190bcdd0df';
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
    final serp = SerpClient(apiKey: serperKey);
    final snippets = await serp.search(defaultQueries);
    stdout.writeln('Serper snippets: ${snippets.length}');
    final gemini = GeminiResearch(apiKey: geminiKey, model: model);
    final listings = await gemini.extract(snippets);
    stdout.writeln('Extracted listings=${listings.length}');
    if (dryRun) {
      for (final listing in listings) {
        stdout.writeln('- ${listing.city}/${listing.sector} ${listing.title}');
      }
      exitCode = 0;
      return;
    }
    final sync = AppwriteSync(
      endpoint: endpoint,
      projectId: projectId,
      apiKey: appwriteKey,
      databaseId: databaseId,
    );
    final written = await sync.upsertNewListings(listings, cap: 15);
    stdout.writeln('Wrote unpublished listings=$written');
    exitCode = 0;
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
