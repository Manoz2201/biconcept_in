import 'dart:convert';
import 'dart:io';

import 'package:seo_agent/apply.dart';
import 'package:seo_agent/gemini.dart';
import 'package:seo_agent/live_audit.dart';
import 'package:seo_agent/models.dart';
import 'package:seo_agent/search_console.dart';
import 'package:seo_agent/serp.dart';

class AgentConfig {
  const AgentConfig({
    required this.root,
    this.geminiApiKey,
    this.serperApiKey,
    this.siteUrl,
    this.fixturePath,
    this.dryRun = false,
    this.geminiModel = 'gemini-3.6-flash',
  });

  final Directory root;
  final String? geminiApiKey;
  final String? serperApiKey;
  final String? siteUrl;
  final String? fixturePath;
  final bool dryRun;
  final String geminiModel;
}

class AgentResult {
  const AgentResult({
    required this.skipped,
    required this.changed,
    this.note,
    this.changes = const [],
  });

  final bool skipped;
  final bool changed;
  final String? note;
  final List<ChangeRecord> changes;
}

Future<AgentResult> runAgent(AgentConfig config) async {
  final files = RepoFiles(config.root);
  if (!files.pages.existsSync()) {
    return AgentResult(
      skipped: true,
      changed: false,
      note: 'Missing ${files.pages.path}',
    );
  }

  final pages = readPages(files.pages);
  final keywords = readKeywords(files.keywords);
  // Search Console: not connected until the domain is verified.
  await SearchConsoleClient().fetch();

  List<SerpSnippet> serp = const [];
  if (config.serperApiKey != null && config.serperApiKey!.isNotEmpty) {
    try {
      serp = await SerpClient(apiKey: config.serperApiKey!).search(keywords);
    } catch (error) {
      stderr.writeln('SERP skipped: $error');
    }
  }

  List<Map<String, dynamic>> audit = const [];
  final siteUrl = config.siteUrl;
  if (siteUrl != null && siteUrl.isNotEmpty) {
    try {
      final rows = await auditLiveSite(
        siteUrl: siteUrl,
        paths: [for (final page in pages) page.path],
      );
      audit = [for (final row in rows) row.toJson()];
    } catch (error) {
      stderr.writeln('Live audit skipped: $error');
    }
  }

  final hasGemini = config.geminiApiKey != null && config.geminiApiKey!.isNotEmpty;
  final hasFixture = config.fixturePath != null && config.fixturePath!.isNotEmpty;

  if (!hasGemini && !hasFixture) {
    final note = 'No GEMINI_API_KEY and no --fixture; skipping write.';
    stdout.writeln(note);
    return AgentResult(skipped: true, changed: false, note: note);
  }

  List<PageProposal> proposals;
  if (hasFixture) {
    proposals = GeminiClient.parseProposalJson(File(config.fixturePath!).readAsStringSync());
  } else {
    proposals = await GeminiClient(
      apiKey: config.geminiApiKey!,
      model: config.geminiModel,
    ).propose(
      pages: pages,
      keywords: keywords,
      serp: serp,
      selfAudit: audit,
    );
  }

  final changes = applyProposals(pages: pages, proposals: proposals);
  if (changes.isEmpty) {
    final note = 'Model proposed no material changes.';
    stdout.writeln(note);
    return AgentResult(skipped: true, changed: false, note: note);
  }

  if (config.dryRun) {
    stdout.writeln('Dry run: ${changes.length} page(s) would change.');
    stdout.writeln(const JsonEncoder.withIndent('  ').convert([
      for (final change in changes) change.toJson(),
    ]));
    return AgentResult(skipped: false, changed: false, note: 'dry-run', changes: changes);
  }

  writePages(files.pages, pages, files: files);
  bumpSitemap(files.sitemap, changes.map((c) => c.path), DateTime.now(), files: files);
  PageCopy? home;
  for (final page in pages) {
    if (page.path == '/') {
      home = page;
      break;
    }
  }
  if (home != null) {
    syncHomeIndexHtml(files.indexHtml, home, files: files);
    syncCopyMeta(files.copyDart, home, files: files);
  }
  writeRunLog(
    runs: files.runs,
    now: DateTime.now(),
    queries: keywords,
    changes: changes,
    skipped: false,
    note: 'applied ${changes.length} page(s)',
    files: files,
  );
  stdout.writeln('Applied ${changes.length} page(s).');
  return AgentResult(skipped: false, changed: true, changes: changes);
}

Directory findRepoRoot(String? override) {
  if (override != null && override.isNotEmpty) {
    return Directory(override);
  }
  var dir = Directory.current.absolute;
  for (var i = 0; i < 8; i++) {
    final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspec.existsSync()) {
      final text = pubspec.readAsStringSync();
      if (text.contains('name: biconcept_in')) {
        return dir;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('Could not find biconcept_in repo root. Pass --root.');
}
