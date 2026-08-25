import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seo_agent/models.dart';

class GeminiClient {
  GeminiClient({required this.apiKey, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  Future<List<PageProposal>> propose({
    required List<PageCopy> pages,
    required List<String> keywords,
    required List<SerpSnippet> serp,
    required List<Map<String, dynamic>> selfAudit,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );
    final prompt = _prompt(
      pages: pages,
      keywords: keywords,
      serp: serp,
      selfAudit: selfAudit,
    );
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.4,
          'responseMimeType': 'application/json',
        },
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Gemini HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractText(decoded);
    return parseProposalJson(text);
  }

  static List<PageProposal> parseProposalJson(String raw) {
    var payload = raw.trim();
    if (payload.startsWith('```')) {
      payload = payload.replaceAll(RegExp(r'^```(?:json)?'), '').replaceAll(RegExp(r'```$'), '').trim();
    }
    final decoded = jsonDecode(payload);
    final list = decoded is Map<String, dynamic> ? decoded['pages'] : decoded;
    if (list is! List) {
      throw const FormatException('Proposal JSON must contain a pages array.');
    }
    return [
      for (final item in list)
        if (item is Map<String, dynamic>) PageProposal.fromJson(item),
    ];
  }

  String _extractText(Map<String, dynamic> body) {
    final candidates = body['candidates'] as List? ?? const [];
    if (candidates.isEmpty) {
      throw const FormatException('Gemini returned no candidates.');
    }
    final content = (candidates.first as Map)['content'] as Map?;
    final parts = content?['parts'] as List? ?? const [];
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    return buffer.toString();
  }

  String _prompt({
    required List<PageCopy> pages,
    required List<String> keywords,
    required List<SerpSnippet> serp,
    required List<Map<String, dynamic>> selfAudit,
  }) {
    return '''
You are the SEO editor for BiConcept, a luxury conceptual studio in India for architecture, interior design, and real estate.

Voice: short, confident, cinematic. Do not sound like a generic SEO mill.
Hard rules:
- Do not change paths.
- Do not invent awards, cities, clients, or facts.
- Title about 50–60 characters. Description about 140–160 characters.
- Keep H1 brand-true. FAQs must be answerable from the existing copy.
- Set change=true only if the rewrite is clearly better for search and brand. Otherwise change=false.
- Propose at most 3 pages with change=true.

Seed queries:
${jsonEncode(keywords)}

Public SERP snippets (titles/URLs/descriptions only — not a license to copy):
${jsonEncode([for (final s in serp) s.toJson()])}

Self-audit of our live HTML if present:
${jsonEncode(selfAudit)}

Current pages:
${jsonEncode([for (final p in pages) p.toJson()])}

Return JSON only:
{"pages":[{"path":"/","change":false,"reason":"...","title":"...","description":"...","h1":"...","keywords":["..."],"faqs":[{"question":"...","answer":"..."}]}]}
''';
  }
}
