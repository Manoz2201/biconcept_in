import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:http/http.dart' as http;

class StudioOfferDraft {
  const StudioOfferDraft({
    required this.title,
    required this.summary,
    required this.ctaLabel,
    required this.href,
    required this.practice,
  });

  final String title;
  final String summary;
  final String ctaLabel;
  final String href;
  final String practice;

  String get duplicateKey => title.trim().toLowerCase();

  Map<String, dynamic> toData() => {
        'title': title,
        'summary': summary,
        'ctaLabel': ctaLabel,
        'href': href,
        'practice': practice,
        'published': true,
      };

  factory StudioOfferDraft.fromJson(Map<String, dynamic> json) {
    var practice = (json['practice'] ?? '').toString().trim().toLowerCase();
    if (practice == 'land' || practice == 'real estate') {
      practice = 'real-estate';
    }
    if (practice != 'architecture' &&
        practice != 'interiors' &&
        practice != 'real-estate') {
      practice = '';
    }
    var href = (json['href'] ?? '').toString().trim();
    if (href.isEmpty) href = '/inquire';
    if (!href.startsWith('/')) href = '/inquire';
    return StudioOfferDraft(
      title: (json['title'] ?? '').toString().trim(),
      summary: (json['summary'] ?? '').toString().trim(),
      ctaLabel: ((json['ctaLabel'] ?? 'Book a consultation').toString().trim()).isEmpty
          ? 'Book a consultation'
          : (json['ctaLabel'] ?? 'Book a consultation').toString().trim(),
      href: href,
      practice: practice,
    );
  }
}

class OfferSelection {
  const OfferSelection({required this.accepted, required this.skipped});

  final List<StudioOfferDraft> accepted;
  final List<String> skipped;
}

OfferSelection selectOffers(
  List<StudioOfferDraft> drafts, {
  required Set<String> existingTitles,
  required int activeCount,
  int capActive = 2,
}) {
  final accepted = <StudioOfferDraft>[];
  final skipped = <String>[];
  var active = activeCount;
  final seen = {...existingTitles};
  for (final draft in drafts) {
    if (draft.title.length < 4) {
      skipped.add('short-title');
      continue;
    }
    if (!seen.add(draft.duplicateKey)) {
      skipped.add('duplicate:${draft.title}');
      continue;
    }
    if (active >= capActive) {
      skipped.add('cap:${draft.title}');
      continue;
    }
    accepted.add(draft);
    active += 1;
  }
  return OfferSelection(accepted: accepted, skipped: skipped);
}

List<StudioOfferDraft> parseOffersJson(String raw) {
  var payload = raw.trim();
  if (payload.startsWith('```')) {
    payload = payload
        .replaceAll(RegExp(r'^```(?:json)?'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();
  }
  final decoded = jsonDecode(payload);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Offers JSON must be an object.');
  }
  final offers = <StudioOfferDraft>[];
  for (final item in decoded['offers'] as List? ?? const []) {
    if (item is! Map<String, dynamic>) continue;
    final offer = StudioOfferDraft.fromJson(item);
    if (offer.title.length < 4) continue;
    offers.add(offer);
  }
  return offers.take(2).toList();
}

class GeminiOffers {
  GeminiOffers({
    required this.apiKey,
    this.model = 'gemini-3.6-flash',
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _http;

  Future<List<StudioOfferDraft>> propose() async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _prompt},
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
    return parseOffersJson(_extractText(decoded));
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

  static const _prompt = '''
You are BiConcept's studio concierge. BiConcept is a luxury architecture, interiors, and land studio in Delhi NCR — not a discount mill.

Propose 1 or 2 calm, current studio offers a visitor might take this month.
Rules:
- No invented prices, percentages, or phone numbers.
- Tone: quiet, specific, no hype.
- practice MUST be one of: architecture, interiors, real-estate, or empty for site-wide.
- href MUST be a site path starting with / (usually /inquire?offer=slug or /architecture).
- ctaLabel default: Book a consultation.

Return JSON only:
{"offers":[{"title":"","summary":"","ctaLabel":"Book a consultation","href":"/inquire?offer=","practice":"architecture"}]}
''';
}

class OffersSync {
  OffersSync({
    required String endpoint,
    required String projectId,
    required String apiKey,
    required this.databaseId,
  }) : _tables = TablesDB(
          Client()
              .setEndpoint(endpoint)
              .setProject(projectId)
              .setKey(apiKey),
        );

  final String databaseId;
  final TablesDB _tables;

  static final _publishedPerms = [
    Permission.read(Role.any()),
    Permission.update(Role.users()),
    Permission.delete(Role.users()),
  ];

  Future<({int written, List<String> skipped})> upsertNewOffers(
    List<StudioOfferDraft> drafts, {
    int capActive = 2,
  }) async {
    final listed = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'offers',
      queries: [Query.limit(50)],
    );
    final existing = listed.rows;
    final titles = {
      for (final row in existing)
        (row.data['title'] ?? '').toString().trim().toLowerCase(),
    };
    final activeCount = existing.where((row) => row.data['published'] == true).length;
    final selection = selectOffers(
      drafts,
      existingTitles: titles,
      activeCount: activeCount,
      capActive: capActive,
    );
    var written = 0;
    for (final draft in selection.accepted) {
      try {
        await _tables.createRow(
          databaseId: databaseId,
          tableId: 'offers',
          rowId: ID.unique(),
          data: draft.toData(),
          permissions: _publishedPerms,
        );
        written += 1;
        stdout.writeln('Created published offer ${draft.title}');
      } on AppwriteException catch (error) {
        stderr.writeln('Appwrite POST offer: ${error.message}');
      }
    }
    for (final skip in selection.skipped) {
      stdout.writeln('Skip $skip');
    }
    return (written: written, skipped: selection.skipped);
  }
}
