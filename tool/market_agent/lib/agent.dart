import 'dart:convert';
import 'dart:io';

import 'package:agent_runtime/agent_runtime.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:http/http.dart' as http;

class SerpSnippet {
  const SerpSnippet({
    required this.query,
    required this.title,
    required this.link,
    required this.snippet,
  });

  final String query;
  final String title;
  final String link;
  final String snippet;

  Map<String, dynamic> toJson() => {
        'query': query,
        'title': title,
        'link': link,
        'snippet': snippet,
      };
}

class SerpClient {
  SerpClient({required this.apiKey, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String apiKey;
  final http.Client _http;

  Future<List<SerpSnippet>> search(List<String> queries, {int perQuery = 5}) async {
    final snippets = <SerpSnippet>[];
    for (final query in queries.take(8)) {
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
        stderr.writeln('Serper HTTP ${response.statusCode} for "$query"');
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

class ResearchListing {
  const ResearchListing({
    required this.title,
    required this.developer,
    required this.city,
    required this.sector,
    required this.status,
    required this.typology,
    required this.priceBand,
    required this.summary,
    required this.sourceUrl,
    required this.sourceName,
  });

  final String title;
  final String developer;
  final String city;
  final String sector;
  final String status;
  final String typology;
  final String priceBand;
  final String summary;
  final String sourceUrl;
  final String sourceName;

  String get duplicateKey => '${title.trim().toLowerCase()}|$city';

  String get rowId {
    return sha1.convert(utf8.encode(duplicateKey)).toString().substring(0, 32);
  }

  Map<String, dynamic> toData() => {
        'title': title,
        'developer': developer,
        'city': city,
        'sector': sector,
        'locality': '',
        'status': status,
        'typology': typology,
        'priceBand': priceBand,
        'summary': summary,
        'sourceUrl': sourceUrl,
        'sourceName': sourceName,
        'published': true,
        'researchedAt': DateTime.now().toUtc().toIso8601String(),
      };

  factory ResearchListing.fromJson(Map<String, dynamic> json) {
    var city = (json['city'] ?? '').toString().trim().toLowerCase();
    if (city.contains('greater')) {
      city = 'greater-noida';
    } else if (city.contains('noida')) {
      city = 'noida';
    } else if (city.contains('delhi')) {
      city = 'delhi';
    }
    var sector = (json['sector'] ?? '').toString().trim().toLowerCase();
    sector = sector.replaceFirst(RegExp(r'^sector\s+'), '');
    return ResearchListing(
      title: (json['title'] ?? '').toString().trim(),
      developer: (json['developer'] ?? '').toString().trim(),
      city: city,
      sector: sector,
      status: (json['status'] ?? 'upcoming').toString().trim(),
      typology: (json['typology'] ?? 'apartment').toString().trim(),
      priceBand: (json['priceBand'] ?? '').toString().trim(),
      summary: (json['summary'] ?? '').toString().trim(),
      sourceUrl: (json['sourceUrl'] ?? '').toString().trim(),
      sourceName: (json['sourceName'] ?? '').toString().trim(),
    );
  }
}

class GeminiResearch {
  GeminiResearch({
    required this.apiKey,
    this.model = 'gemini-3.6-flash',
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _http;

  Future<List<ResearchListing>> extract(List<SerpSnippet> serp) async {
    final response = await postGeminiGenerate(
      httpClient: _http,
      apiKey: apiKey,
      model: model,
      body: {
        'contents': [
          {
            'parts': [
              {'text': _prompt(serp)},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'responseMimeType': 'application/json',
        },
      },
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return parseResearchJson(_extractText(decoded));
  }

  static List<ResearchListing> parseResearchJson(String raw) {
    var payload = raw.trim();
    if (payload.startsWith('```')) {
      payload = payload
          .replaceAll(RegExp(r'^```(?:json)?'), '')
          .replaceAll(RegExp(r'```$'), '')
          .trim();
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Research JSON must be an object.');
    }
    final listings = <ResearchListing>[];
    final seen = <String>{};
    for (final item in decoded['listings'] as List? ?? const []) {
      if (item is! Map<String, dynamic>) continue;
      final listing = ResearchListing.fromJson(item);
      if (listing.title.length < 3) continue;
      if (listing.city != 'delhi' &&
          listing.city != 'noida' &&
          listing.city != 'greater-noida') {
        continue;
      }
      if (listing.sourceUrl.isEmpty && listing.sourceName.isEmpty) continue;
      if (!seen.add(listing.duplicateKey)) continue;
      listings.add(listing);
    }
    return listings;
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

  String _prompt(List<SerpSnippet> serp) {
    return '''
You are BiConcept's NCR real-estate research desk. BiConcept is a luxury architecture, interiors, and land studio — not a listing mill.

From public search snippets only, extract NEW or UPCOMING residential / plotted / mixed-use projects in:
- Delhi (city "delhi", sector slug such as south-delhi, dwarka, vasant-kunj)
- Noida (city "noida", sector as a number string such as "150", "137", "62")
- Greater Noida including West (city "greater-noida", sector slug such as west, chi, knowledge-park-5, techzone-4)

Hard rules:
- Do not invent projects, prices, developers, or phone numbers.
- Only include a project if the snippet clearly names it.
- Keep sourceUrl and sourceName from the snippet. Never invent a URL.
- city MUST be one of: delhi, noida, greater-noida.
- Skip Gurugram / Gurgaon / Ghaziabad.
- summary: 1–2 calm sentences, no hype, no copied marketing slogans.

Public SERP snippets:
${jsonEncode([for (final s in serp) s.toJson()])}

Return JSON only:
{"listings":[{"title":"","developer":"","city":"noida","sector":"150","status":"upcoming|pre-launch|launched|under-construction","typology":"apartment|villa|plot|mixed","priceBand":"","summary":"","sourceUrl":"","sourceName":""}]}
''';
  }
}

enum ListingWriteAction { create, publish, skip }

ListingWriteAction listingWriteAction({required bool exists, required bool published}) {
  if (!exists) return ListingWriteAction.create;
  if (!published) return ListingWriteAction.publish;
  return ListingWriteAction.skip;
}

class AppwriteSync {
  AppwriteSync({
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

  Future<int> upsertNewListings(List<ResearchListing> listings, {int cap = 15}) async {
    final existing = await _existing();
    var written = 0;
    for (final listing in listings) {
      if (written >= cap) break;
      final found = existing[listing.duplicateKey];
      final action = listingWriteAction(
        exists: found != null,
        published: found?.published ?? false,
      );
      if (action == ListingWriteAction.skip) {
        stdout.writeln('Skip duplicate ${listing.title} (${listing.city})');
        continue;
      }
      if (action == ListingWriteAction.publish) {
        try {
          await _publish(found!.id);
          existing[listing.duplicateKey] = (id: found.id, published: true);
          written += 1;
          stdout.writeln('Published existing ${listing.title}');
        } on AppwriteException catch (error) {
          stderr.writeln('Appwrite PUBLISH ${found?.id}: ${error.message}');
        }
        continue;
      }
      try {
        await _tables.getRow(
          databaseId: databaseId,
          tableId: 'listings',
          rowId: listing.rowId,
        );
        await _publish(listing.rowId);
        existing[listing.duplicateKey] = (id: listing.rowId, published: true);
        written += 1;
        stdout.writeln('Published existing row ${listing.title}');
        continue;
      } on AppwriteException catch (error) {
        if (error.code != 404) {
          stderr.writeln('Appwrite GET ${listing.rowId}: ${error.message}');
          continue;
        }
      }
      try {
        await _tables.createRow(
          databaseId: databaseId,
          tableId: 'listings',
          rowId: listing.rowId,
          data: listing.toData(),
          permissions: _publishedPerms,
        );
        existing[listing.duplicateKey] = (id: listing.rowId, published: true);
        written += 1;
        stdout.writeln('Created published ${listing.title}');
      } on AppwriteException catch (error) {
        stderr.writeln('Appwrite POST ${listing.rowId}: ${error.message}');
      }
    }
    if (written < cap) {
      written += await publishUnpublished(cap: cap - written);
    }
    return written;
  }

  Future<int> publishUnpublished({int cap = 15}) async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'listings',
      queries: [Query.equal('published', false), Query.limit(100)],
    );
    var published = 0;
    for (final row in result.rows) {
      if (published >= cap) break;
      try {
        await _publish(row.$id);
        published += 1;
        stdout.writeln('Published draft ${row.data['title'] ?? row.$id}');
      } on AppwriteException catch (error) {
        stderr.writeln('Appwrite PUBLISH ${row.$id}: ${error.message}');
      }
    }
    return published;
  }

  Future<void> _publish(String id) {
    return _tables.updateRow(
      databaseId: databaseId,
      tableId: 'listings',
      rowId: id,
      data: {'published': true},
      permissions: _publishedPerms,
    );
  }

  Future<Map<String, ({String id, bool published})>> _existing() async {
    final keys = <String, ({String id, bool published})>{};
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'listings',
      queries: [Query.limit(100)],
    );
    for (final row in result.rows) {
      final data = Map<String, dynamic>.from(row.data);
      final title = (data['title'] ?? '').toString().trim().toLowerCase();
      final city = (data['city'] ?? '').toString().trim().toLowerCase();
      if (title.isEmpty || city.isEmpty) continue;
      keys['$title|$city'] = (
        id: row.$id,
        published: data['published'] == true,
      );
    }
    return keys;
  }
}

const defaultQueries = [
  'upcoming residential projects Delhi 2026 new launch',
  'new upcoming projects Noida sector 150 137 144 2026',
  'Noida sector 62 73 78 128 new residential launch',
  'Greater Noida West upcoming projects 2026',
  'Greater Noida Knowledge Park Techzone new launch residential',
  'Delhi Dwarka Vasant Kunj South Delhi upcoming housing project',
];
