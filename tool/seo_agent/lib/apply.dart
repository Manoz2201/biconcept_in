import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:seo_agent/models.dart';

class RepoFiles {
  RepoFiles(this.root);

  final Directory root;

  File get pages => File(p.join(root.path, 'assets', 'seo', 'pages.json'));
  File get keywords => File(p.join(root.path, 'assets', 'seo', 'keywords.json'));
  File get sitemap => File(p.join(root.path, 'web', 'sitemap.xml'));
  File get indexHtml => File(p.join(root.path, 'web', 'index.html'));
  Directory get runs => Directory(p.join(root.path, 'assets', 'seo', 'runs'));
}

List<PageCopy> readPages(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final list = decoded['pages'] as List? ?? const [];
  return [
    for (final item in list)
      if (item is Map<String, dynamic>) PageCopy.fromJson(item),
  ];
}

List<String> readKeywords(File file) {
  if (!file.existsSync()) return const [];
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final item in decoded['seeds'] as List? ?? const []) item.toString(),
  ];
}

void writePages(File file, List<PageCopy> pages) {
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert({'pages': [for (final page in pages) page.toJson()]})}\n');
}

List<ChangeRecord> applyProposals({
  required List<PageCopy> pages,
  required List<PageProposal> proposals,
  int cap = 3,
}) {
  final byPath = {for (final page in pages) page.path: page};
  final changes = <ChangeRecord>[];
  for (final proposal in proposals) {
    if (!proposal.change) continue;
    if (changes.length >= cap) break;
    final current = byPath[proposal.path];
    if (current == null) continue;
    final before = Map<String, dynamic>.from(current.toJson());
    if (proposal.title != null && proposal.title!.trim().isNotEmpty) {
      current.title = proposal.title!.trim();
    }
    if (proposal.description != null && proposal.description!.trim().isNotEmpty) {
      current.description = proposal.description!.trim();
    }
    if (proposal.h1 != null && proposal.h1!.trim().isNotEmpty) {
      current.h1 = proposal.h1!.trim();
    }
    if (proposal.keywords != null && proposal.keywords!.isNotEmpty) {
      current.keywords = proposal.keywords!;
    }
    if (proposal.faqs != null && proposal.faqs!.isNotEmpty) {
      current.faqs = proposal.faqs!;
    }
    final after = current.toJson();
    if (jsonEncode(before) == jsonEncode(after)) continue;
    changes.add(
      ChangeRecord(
        path: current.path,
        reason: proposal.reason,
        before: before,
        after: after,
      ),
    );
  }
  return changes;
}

void bumpSitemap(File sitemap, Iterable<String> paths, DateTime now) {
  if (!sitemap.existsSync()) return;
  var xml = sitemap.readAsStringSync();
  final day = now.toUtc().toIso8601String().split('T').first;
  for (final path in paths) {
    final loc = path == '/' ? 'https://biconcept.in/' : 'https://biconcept.in$path';
    final locEsc = RegExp.escape(loc);
    final block = RegExp(
      '<url>\\s*<loc>$locEsc</loc>[\\s\\S]*?</url>',
    );
    xml = xml.replaceFirstMapped(block, (match) {
      var inner = match.group(0)!;
      if (inner.contains('<lastmod>')) {
        inner = inner.replaceFirst(RegExp('<lastmod>[^<]*</lastmod>'), '<lastmod>$day</lastmod>');
      } else {
        inner = inner.replaceFirst('</loc>', '</loc><lastmod>$day</lastmod>');
      }
      return inner;
    });
  }
  sitemap.writeAsStringSync(xml.endsWith('\n') ? xml : '$xml\n');
}

void syncHomeIndexHtml(File indexHtml, PageCopy home) {
  if (!indexHtml.existsSync()) return;
  var html = indexHtml.readAsStringSync();
  html = html.replaceFirst(
    RegExp(r'<title>[^<]*</title>'),
    '<title>${_esc(home.title)}</title>',
  );
  html = _replaceMeta(html, 'name', 'description', home.description);
  html = _replaceMeta(html, 'property', 'og:title', home.title);
  html = _replaceMeta(html, 'property', 'og:description', home.description);
  html = _replaceMeta(html, 'name', 'twitter:title', home.title);
  html = _replaceMeta(html, 'name', 'twitter:description', home.description);
  indexHtml.writeAsStringSync(html);
}

String _replaceMeta(String html, String attr, String key, String value) {
  final pattern = RegExp(
    '<meta $attr="$key" content="[^"]*"',
  );
  return html.replaceFirst(pattern, '<meta $attr="$key" content="${_esc(value)}"');
}

String _esc(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll('<', '&lt;');

void writeRunLog({
  required Directory runs,
  required DateTime now,
  required List<String> queries,
  required List<ChangeRecord> changes,
  required bool skipped,
  String? note,
}) {
  if (!runs.existsSync()) {
    runs.createSync(recursive: true);
  }
  final stamp = now.toUtc().toIso8601String().replaceAll(':', '-');
  final file = File('${runs.path}${Platform.pathSeparator}$stamp.json');
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync(
    '${encoder.convert({
      'at': now.toUtc().toIso8601String(),
      'skipped': skipped,
      'note': note,
      'queries': queries,
      'changes': [for (final change in changes) change.toJson()],
    })}\n',
  );
}
