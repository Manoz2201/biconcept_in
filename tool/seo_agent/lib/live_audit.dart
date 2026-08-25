import 'dart:io';

import 'package:http/http.dart' as http;

class SelfAudit {
  const SelfAudit({required this.path, required this.title, required this.description});

  final String path;
  final String title;
  final String description;

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'description': description,
      };
}

Future<List<SelfAudit>> auditLiveSite({
  required String siteUrl,
  required List<String> paths,
  http.Client? httpClient,
}) async {
  final client = httpClient ?? http.Client();
  final base = siteUrl.endsWith('/') ? siteUrl.substring(0, siteUrl.length - 1) : siteUrl;
  final results = <SelfAudit>[];
  try {
    for (final path in paths) {
      final url = path == '/' ? '$base/' : '$base$path';
      try {
        final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) continue;
        final html = response.body;
        final title = _tag(html, r'<title>([^<]+)</title>') ?? '';
        final description =
            _attr(html, r'<meta[^>]*name="description"[^>]*content="([^"]*)"') ??
                _attr(html, r'<meta[^>]*content="([^"]*)"[^>]*name="description"') ??
                '';
        results.add(SelfAudit(path: path, title: title, description: description));
      } catch (_) {
        // Live site not reachable yet — skip this path.
      }
    }
  } on SocketException {
    return const [];
  }
  return results;
}

String? _tag(String html, String pattern) {
  final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
  return match?.group(1)?.trim();
}

String? _attr(String html, String pattern) {
  final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
  return match?.group(1)?.trim();
}
