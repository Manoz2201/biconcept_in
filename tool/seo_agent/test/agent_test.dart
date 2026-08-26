import 'dart:io';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:seo_agent/agent.dart';
import 'package:seo_agent/apply.dart';
import 'package:seo_agent/gemini.dart';
import 'package:test/test.dart';

void main() {
  final repo = findRepoRoot(null);
  final fixture = File('${repo.path}/tool/seo_agent/test/fixtures/proposal.json');

  test('parseProposalJson reads fixture pages', () {
    final proposals = GeminiClient.parseProposalJson(fixture.readAsStringSync());
    expect(proposals, hasLength(3));
    expect(proposals.where((p) => p.change).length, 2);
  });

  test('without Gemini key, agent skips and does not rewrite pages.json', () async {
    final original = File('${repo.path}/assets/seo/pages.json').readAsStringSync();
    final result = await runAgent(
      AgentConfig(
        root: repo,
        dryRun: true,
      ),
    );
    expect(result.skipped, isTrue);
    expect(File('${repo.path}/assets/seo/pages.json').readAsStringSync(), original);
  });

  test('fixture apply writes pages, sitemap lastmod, index title, and a run log', () async {
    final pagesFile = File('${repo.path}/assets/seo/pages.json');
    final sitemapFile = File('${repo.path}/web/sitemap.xml');
    final indexFile = File('${repo.path}/web/index.html');
    final copyFile = File('${repo.path}/lib/content/copy.dart');
    final originalPages = pagesFile.readAsStringSync();
    final originalSitemap = sitemapFile.readAsStringSync();
    final originalIndex = indexFile.readAsStringSync();
    final originalCopy = copyFile.readAsStringSync();
    final runs = Directory('${repo.path}/assets/seo/runs');
    final beforeLogs = runs.existsSync()
        ? runs.listSync().whereType<File>().map((f) => f.path).toSet()
        : <String>{};

    addTearDown(() {
      pagesFile.writeAsStringSync(originalPages);
      sitemapFile.writeAsStringSync(originalSitemap);
      indexFile.writeAsStringSync(originalIndex);
      copyFile.writeAsStringSync(originalCopy);
      if (runs.existsSync()) {
        for (final file in runs.listSync().whereType<File>()) {
          if (!beforeLogs.contains(file.path) && file.path.endsWith('.json')) {
            file.deleteSync();
          }
        }
      }
    });

    final result = await runAgent(
      AgentConfig(
        root: repo,
        fixturePath: fixture.path,
      ),
    );
    expect(result.skipped, isFalse);
    expect(result.changed, isTrue);
    expect(result.changes.length, lessThanOrEqualTo(3));

    final pages = readPages(pagesFile);
    final home = pages.firstWhere((page) => page.path == '/');
    expect(home.title, contains('Architecture, Interiors, Real Estate India'));

    final sitemap = sitemapFile.readAsStringSync();
    expect(sitemap.contains('<lastmod>'), isTrue);

    final index = indexFile.readAsStringSync();
    expect(index, contains(home.title.replaceAll('&', '&amp;')));
    expect(index, contains('<meta name="description" content="${home.description}"'));
    expect(copyFile.readAsStringSync(), contains(home.title));

    final newLogs = runs
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json') && !beforeLogs.contains(file.path));
    expect(newLogs, isNotEmpty);
  });

  test('allowlist rejects auth and config files', () {
    expect(isSeoAllowlisted('assets/seo/pages.json'), isTrue);
    expect(isSeoAllowlisted('lib/content/copy.dart'), isTrue);
    expect(isSeoAllowlisted('lib/data/appwrite_config.dart'), isFalse);
    expect(isSeoAllowlisted('lib/features/admin/admin_login_page.dart'), isFalse);
    final files = RepoFiles(repo);
    expect(
      () => files.assertAllowed(File('${repo.path}/lib/data/appwrite_config.dart')),
      throwsStateError,
    );
  });
}
