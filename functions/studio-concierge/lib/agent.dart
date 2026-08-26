import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:http/http.dart' as http;

class FunctionCall {
  const FunctionCall({required this.name, required this.args});

  final String name;
  final Map<String, dynamic> args;
}

class GeminiTurn {
  const GeminiTurn({this.text, this.call});

  final String? text;
  final FunctionCall? call;
}

abstract class GeminiLoop {
  Future<GeminiTurn> next(List<Map<String, dynamic>> contents);
}

abstract class StudioCms {
  Future<Map<String, dynamic>> upsertListing(Map<String, dynamic> args);
  Future<Map<String, dynamic>> publishListing(Map<String, dynamic> args);
  Future<Map<String, dynamic>> publishAllListings();
  Future<Map<String, dynamic>> listListings();
  Future<Map<String, dynamic>> upsertOffer(Map<String, dynamic> args);
  Future<Map<String, dynamic>> listLeads();
  Future<Map<String, dynamic>> updateLeadStatus(String id, String status);
  Future<Map<String, dynamic>> listJobs();
}

const toolDeclarations = [
  {
    'name': 'upsert_listing',
    'description':
        'Create or update an NCR market listing and publish it on the public site. city must be delhi, noida, or greater-noida. Pass published=false only if the user asks to keep a draft.',
    'parameters': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'developer': {'type': 'string'},
        'city': {'type': 'string'},
        'sector': {'type': 'string'},
        'status': {'type': 'string'},
        'typology': {'type': 'string'},
        'priceBand': {'type': 'string'},
        'summary': {'type': 'string'},
        'sourceUrl': {'type': 'string'},
        'sourceName': {'type': 'string'},
        'published': {'type': 'boolean'},
      },
      'required': ['title', 'city'],
    },
  },
  {
    'name': 'publish_listing',
    'description':
        'Publish an existing listing to the public site. Pass id, or title and city.',
    'parameters': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'city': {'type': 'string'},
      },
    },
  },
  {
    'name': 'publish_all_listings',
    'description':
        'Publish every unpublished listing to the public site. Use this when the user says publish all listings.',
    'parameters': {'type': 'object', 'properties': {}},
  },
  {
    'name': 'list_listings',
    'description': 'List recent listings with published vs draft status.',
    'parameters': {'type': 'object', 'properties': {}},
  },
  {
    'name': 'upsert_offer',
    'description': 'Create or update a studio offer shown on the public site.',
    'parameters': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'title': {'type': 'string'},
        'summary': {'type': 'string'},
        'ctaLabel': {'type': 'string'},
        'href': {'type': 'string'},
        'practice': {'type': 'string'},
        'published': {'type': 'boolean'},
      },
      'required': ['title', 'summary'],
    },
  },
  {
    'name': 'list_leads',
    'description': 'List recent inquiry leads with status.',
    'parameters': {'type': 'object', 'properties': {}},
  },
  {
    'name': 'update_lead_status',
    'description': 'Set a lead status: new, in-progress, won, or closed.',
    'parameters': {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'status': {'type': 'string'},
      },
      'required': ['id', 'status'],
    },
  },
  {
    'name': 'list_jobs',
    'description': 'List recent agent_jobs rows.',
    'parameters': {'type': 'object', 'properties': {}},
  },
];

bool wantsPublishAllListings(String message) {
  final t = message.toLowerCase();
  final listings = t.contains('listing');
  final publish = t.contains('publish') || t.contains('go live') || t.contains('make live') || t.contains('live');
  final all = t.contains('all') || t.contains('every') || t.contains('drafts');
  return listings && publish && all;
}

String friendlyConciergeError(Object error) {
  final text = error.toString();
  if (text.contains('503') || text.contains('UNAVAILABLE') || text.contains('high demand')) {
    return 'Gemini is busy right now. Wait a minute and try again, or send “publish all listings”.';
  }
  if (text.contains('429')) {
    return 'Gemini rate-limited the studio. Try again in a minute.';
  }
  if (text.contains('No element') || text.contains('no candidates')) {
    return 'The concierge got an empty Gemini reply. Send “publish all listings” to take drafts live without Gemini.';
  }
  return 'Concierge failed. Try again in a minute.';
}

String summarizePublishAll(Map<String, dynamic> result) {
  final error = '${result['error'] ?? ''}'.trim();
  if (error.isNotEmpty) return error;
  final names = [
    for (final item in result['published'] as List? ?? const []) '$item',
  ];
  final count = result['publishedCount'] is int ? result['publishedCount'] as int : names.length;
  if (count == 0) {
    return 'All listings are already live on the public site.';
  }
  final shown = names.take(12).join(', ');
  return 'Published $count listing${count == 1 ? '' : 's'}: $shown.';
}

class ConciergeAgent {
  ConciergeAgent({required this.gemini, required this.cms});

  final GeminiLoop gemini;
  final StudioCms cms;

  Future<String> handle(String message) async {
    if (wantsPublishAllListings(message)) {
      return summarizePublishAll(await cms.publishAllListings());
    }
    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [
          {
            'text':
                'You are BiConcept studio concierge. Use tools to write listings, offers, and lead status. Listings you create or update must be published on the public site unless the user asks to keep a draft. Use publish_all_listings when the user wants every draft live. Use publish_listing for one listing. Never ask for passwords or API keys. Never mention secrets.\n\nUser: $message',
          },
        ],
      },
    ];
    final notes = <String>[];
    for (var i = 0; i < 4; i++) {
      final turn = await gemini.next(contents);
      if (turn.call == null) {
        final text = (turn.text ?? '').trim();
        if (text.isNotEmpty) return text;
        if (notes.isNotEmpty) return notes.join('\n');
        return 'Done.';
      }
      contents.add({
        'role': 'model',
        'parts': [
          {
            'functionCall': {
              'name': turn.call!.name,
              'args': turn.call!.args,
            },
          },
        ],
      });
      final result = await _execute(turn.call!);
      notes.add('${turn.call!.name}: ${jsonEncode(result)}');
      contents.add({
        'role': 'user',
        'parts': [
          {
            'functionResponse': {
              'name': turn.call!.name,
              'response': result,
            },
          },
        ],
      });
    }
    return notes.isEmpty ? 'Done.' : notes.join('\n');
  }

  Future<Map<String, dynamic>> _execute(FunctionCall call) {
    switch (call.name) {
      case 'upsert_listing':
        return cms.upsertListing(call.args);
      case 'publish_listing':
        return cms.publishListing(call.args);
      case 'publish_all_listings':
        return cms.publishAllListings();
      case 'list_listings':
        return cms.listListings();
      case 'upsert_offer':
        return cms.upsertOffer(call.args);
      case 'list_leads':
        return cms.listLeads();
      case 'update_lead_status':
        return cms.updateLeadStatus(
          '${call.args['id'] ?? ''}',
          '${call.args['status'] ?? ''}',
        );
      case 'list_jobs':
        return cms.listJobs();
      default:
        return Future.value({'error': 'Unknown tool ${call.name}'});
    }
  }
}

class HttpGemini implements GeminiLoop {
  HttpGemini({
    required this.apiKey,
    this.model = 'gemini-3.6-flash',
    this.fallbackModels = const ['gemini-2.5-flash'],
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final List<String> fallbackModels;
  final http.Client _http;

  @override
  Future<GeminiTurn> next(List<Map<String, dynamic>> contents) async {
    final payload = {
      'contents': contents,
      'tools': [
        {'functionDeclarations': toolDeclarations},
      ],
    };
    final models = [model, ...fallbackModels.where((name) => name != model)];
    http.Response? last;
    for (final name in models) {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$name:generateContent?key=$apiKey',
      );
      for (var attempt = 0; attempt < 3; attempt++) {
        last = await _http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        if (last.statusCode >= 200 && last.statusCode < 300) {
          final decoded = jsonDecode(last.body);
          if (decoded is! Map) {
            return const GeminiTurn();
          }
          return parseGeminiTurn(Map<String, dynamic>.from(decoded));
        }
        final retryable = last.statusCode == 429 || last.statusCode == 503;
        if (!retryable) break;
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1) * (attempt + 1)));
      }
      if (last != null && last.statusCode != 404 && last.statusCode != 429 && last.statusCode != 503) {
        throw StateError('Gemini HTTP ${last.statusCode}: ${last.body}');
      }
    }
    throw StateError('Gemini HTTP ${last?.statusCode ?? 0}: ${last?.body ?? 'empty response'}');
  }
}

GeminiTurn parseGeminiTurn(Map<String, dynamic> body) {
  final candidates = body['candidates'] as List? ?? const [];
  Map<Object?, Object?>? candidate;
  for (final item in candidates) {
    if (item is Map) {
      candidate = item;
      break;
    }
  }
  if (candidate == null) return const GeminiTurn();
  final content = candidate['content'] as Map?;
  final parts = content?['parts'] as List? ?? const [];
  String? text;
  FunctionCall? call;
  for (final part in parts) {
    if (part is! Map) continue;
    if (part['text'] is String) {
      text = '${text ?? ''}${part['text']}';
    }
    final fn = part['functionCall'] ?? part['function_call'];
    if (fn is Map) {
      final args = fn['args'];
      call = FunctionCall(
        name: '${fn['name'] ?? ''}',
        args: args is Map<String, dynamic>
            ? args
            : args is Map
                ? Map<String, dynamic>.from(args)
                : const {},
      );
    }
  }
  return GeminiTurn(text: text, call: call);
}

class AppwriteCms implements StudioCms {
  AppwriteCms({required TablesDB tables, required this.databaseId}) : _tables = tables;

  final TablesDB _tables;
  final String databaseId;

  List<String> _perms(bool published) => published
      ? [
          Permission.read(Role.any()),
          Permission.update(Role.users()),
          Permission.delete(Role.users()),
        ]
      : [
          Permission.read(Role.users()),
          Permission.update(Role.users()),
          Permission.delete(Role.users()),
        ];

  @override
  Future<Map<String, dynamic>> upsertListing(Map<String, dynamic> args) async {
    var city = '${args['city'] ?? ''}'.trim().toLowerCase();
    if (city.contains('greater')) {
      city = 'greater-noida';
    } else if (city.contains('noida')) {
      city = 'noida';
    } else if (city.contains('delhi')) {
      city = 'delhi';
    }
    if (city != 'delhi' && city != 'noida' && city != 'greater-noida') {
      return {'error': 'city must be delhi, noida, or greater-noida'};
    }
    final published = args['published'] != false;
    final data = {
      'title': '${args['title'] ?? ''}'.trim(),
      'developer': '${args['developer'] ?? ''}'.trim(),
      'city': city,
      'sector': '${args['sector'] ?? ''}'.trim(),
      'locality': '${args['locality'] ?? ''}'.trim(),
      'status': '${args['status'] ?? 'upcoming'}'.trim(),
      'typology': '${args['typology'] ?? 'apartment'}'.trim(),
      'priceBand': '${args['priceBand'] ?? ''}'.trim(),
      'summary': '${args['summary'] ?? ''}'.trim(),
      'sourceUrl': '${args['sourceUrl'] ?? ''}'.trim(),
      'sourceName': '${args['sourceName'] ?? 'concierge'}'.trim(),
      'published': published,
      'researchedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (data['title'].toString().length < 3) {
      return {'error': 'title required'};
    }
    final id = '${args['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      final row = await _tables.createRow(
        databaseId: databaseId,
        tableId: 'listings',
        rowId: ID.unique(),
        data: data,
        permissions: _perms(published),
      );
      return {'ok': true, 'id': row.$id, 'published': published};
    }
    try {
      final row = await _tables.updateRow(
        databaseId: databaseId,
        tableId: 'listings',
        rowId: id,
        data: data,
        permissions: _perms(published),
      );
      return {'ok': true, 'id': row.$id, 'published': published};
    } on AppwriteException catch (error) {
      if (error.code != 404) rethrow;
      final row = await _tables.createRow(
        databaseId: databaseId,
        tableId: 'listings',
        rowId: id,
        data: data,
        permissions: _perms(published),
      );
      return {'ok': true, 'id': row.$id, 'published': published};
    }
  }

  @override
  Future<Map<String, dynamic>> publishListing(Map<String, dynamic> args) async {
    var id = '${args['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      final title = '${args['title'] ?? ''}'.trim().toLowerCase();
      var city = '${args['city'] ?? ''}'.trim().toLowerCase();
      if (city.contains('greater')) {
        city = 'greater-noida';
      } else if (city.contains('noida')) {
        city = 'noida';
      } else if (city.contains('delhi')) {
        city = 'delhi';
      }
      if (title.isEmpty) {
        return {'error': 'id or title required'};
      }
      final result = await _tables.listRows(
        databaseId: databaseId,
        tableId: 'listings',
        queries: [Query.limit(100)],
      );
      for (final row in result.rows) {
        final rowTitle = '${row.data['title'] ?? ''}'.trim().toLowerCase();
        final rowCity = '${row.data['city'] ?? ''}'.trim().toLowerCase();
        if (rowTitle == title && (city.isEmpty || rowCity == city)) {
          id = row.$id;
          break;
        }
      }
    }
    if (id.isEmpty) {
      return {'error': 'listing not found'};
    }
    await _tables.updateRow(
      databaseId: databaseId,
      tableId: 'listings',
      rowId: id,
      data: {'published': true},
      permissions: _perms(true),
    );
    return {'ok': true, 'id': id, 'published': true};
  }

  @override
  Future<Map<String, dynamic>> publishAllListings() async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'listings',
      queries: [Query.limit(100)],
    );
    final published = <String>[];
    var alreadyLive = 0;
    for (final row in result.rows) {
      final title = '${row.data['title'] ?? ''}'.trim();
      if (row.data['published'] == true) {
        alreadyLive += 1;
        continue;
      }
      await _tables.updateRow(
        databaseId: databaseId,
        tableId: 'listings',
        rowId: row.$id,
        data: {'published': true},
        permissions: _perms(true),
      );
      published.add(title.isEmpty ? row.$id : title);
    }
    return {
      'ok': true,
      'publishedCount': published.length,
      'alreadyLive': alreadyLive,
      'published': published,
    };
  }

  @override
  Future<Map<String, dynamic>> listListings() async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'listings',
      queries: [Query.limit(30)],
    );
    return {
      'listings': [
        for (final row in result.rows)
          {
            'id': row.$id,
            'title': row.data['title'],
            'city': row.data['city'],
            'published': row.data['published'] == true,
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> upsertOffer(Map<String, dynamic> args) async {
    final published = args['published'] != false;
    var href = '${args['href'] ?? '/inquire'}'.trim();
    if (!href.startsWith('/')) href = '/inquire';
    var practice = '${args['practice'] ?? ''}'.trim().toLowerCase();
    if (practice == 'land' || practice == 'real estate') practice = 'real-estate';
    if (practice != 'architecture' && practice != 'interiors' && practice != 'real-estate') {
      practice = '';
    }
    final data = {
      'title': '${args['title'] ?? ''}'.trim(),
      'summary': '${args['summary'] ?? ''}'.trim(),
      'ctaLabel': '${args['ctaLabel'] ?? 'Book a consultation'}'.trim(),
      'href': href,
      'practice': practice,
      'published': published,
    };
    if (data['title'].toString().length < 4) {
      return {'error': 'title required'};
    }
    final id = '${args['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      final row = await _tables.createRow(
        databaseId: databaseId,
        tableId: 'offers',
        rowId: ID.unique(),
        data: data,
        permissions: _perms(published),
      );
      return {'ok': true, 'id': row.$id, 'payload': data};
    }
    final row = await _tables.updateRow(
      databaseId: databaseId,
      tableId: 'offers',
      rowId: id,
      data: data,
      permissions: _perms(published),
    );
    return {'ok': true, 'id': row.$id, 'payload': data};
  }

  @override
  Future<Map<String, dynamic>> listLeads() async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'leads',
      queries: [Query.orderDesc('\$createdAt'), Query.limit(20)],
    );
    return {
      'leads': [
        for (final row in result.rows)
          {
            'id': row.$id,
            'name': row.data['name'],
            'status': row.data['status'],
            'practice': row.data['practice'],
            'city': row.data['city'],
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> updateLeadStatus(String id, String status) async {
    final allowed = {'new', 'in-progress', 'won', 'closed'};
    final next = status.trim().toLowerCase();
    if (!allowed.contains(next) || id.isEmpty) {
      return {'error': 'id and status (new|in-progress|won|closed) required'};
    }
    await _tables.updateRow(
      databaseId: databaseId,
      tableId: 'leads',
      rowId: id,
      data: {'status': next},
    );
    return {'ok': true, 'id': id, 'status': next};
  }

  @override
  Future<Map<String, dynamic>> listJobs() async {
    final result = await _tables.listRows(
      databaseId: databaseId,
      tableId: 'agent_jobs',
      queries: [Query.orderDesc('\$createdAt'), Query.limit(10)],
    );
    return {
      'jobs': [
        for (final row in result.rows)
          {
            'id': row.$id,
            'agentId': row.data['agentId'],
            'title': row.data['title'],
            'status': row.data['status'],
            'progress': row.data['progress'],
            'summary': row.data['summary'],
          },
      ],
    };
  }
}

class JobTracker {
  JobTracker({required TablesDB tables, required this.databaseId}) : _tables = tables;

  final TablesDB _tables;
  final String databaseId;

  Future<String> start({String? jobId}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    if (jobId != null && jobId.isNotEmpty) {
      await _tables.updateRow(
        databaseId: databaseId,
        tableId: 'agent_jobs',
        rowId: jobId,
        data: {
          'status': 'running',
          'progress': 20,
          'startedAt': now,
          'summary': 'Concierge running…',
        },
      );
      return jobId;
    }
    final row = await _tables.createRow(
      databaseId: databaseId,
      tableId: 'agent_jobs',
      rowId: ID.unique(),
      data: {
        'agentId': 'concierge',
        'title': 'Concierge',
        'status': 'running',
        'progress': 20,
        'summary': 'Concierge running…',
        'log': '',
        'payload': '',
        'startedAt': now,
        'finishedAt': '',
      },
      permissions: [
        Permission.read(Role.users()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
    return row.$id;
  }

  Future<void> finish(String jobId, {required bool ok, required String summary}) {
    return _tables.updateRow(
      databaseId: databaseId,
      tableId: 'agent_jobs',
      rowId: jobId,
      data: {
        'status': ok ? 'succeeded' : 'failed',
        'progress': 100,
        'summary': summary,
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }
}
