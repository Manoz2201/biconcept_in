import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seo_agent/models.dart';

class SerpClient {
  SerpClient({required this.apiKey, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  Future<List<SerpSnippet>> search(List<String> queries, {int perQuery = 5}) async {
    final snippets = <SerpSnippet>[];
    for (final query in queries.take(6)) {
      final response = await _http.post(
        Uri.parse('https://google.serper.dev/search'),
        headers: {
          'X-API-KEY': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': query,
          'gl': 'in',
          'num': perQuery,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        continue;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) continue;
      final organic = decoded['organic'] as List? ?? const [];
      for (final row in organic.take(perQuery)) {
        if (row is! Map<String, dynamic>) continue;
        snippets.add(
          SerpSnippet(
            query: query,
            title: row['title']?.toString() ?? '',
            link: row['link']?.toString() ?? '',
            snippet: row['snippet']?.toString() ?? '',
          ),
        );
      }
    }
    return snippets;
  }
}
