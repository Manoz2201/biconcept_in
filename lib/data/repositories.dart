import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/data/appwrite_client.dart';
import 'package:biconcept_in/data/appwrite_config.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:flutter/widgets.dart';

bool get _inWidgetTest {
  try {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  } catch (_) {
    return false;
  }
}

List<String> _publicRowPermissions() => [
      Permission.read(Role.any()),
      Permission.update(Role.users()),
      Permission.delete(Role.users()),
    ];

List<String> _usersRowPermissions() => [
      Permission.read(Role.users()),
      Permission.update(Role.users()),
      Permission.delete(Role.users()),
    ];

class AuthRepository {
  AuthRepository({Account? account}) : _account = account ?? AppwriteServices.instance.account;

  final Account _account;

  Future<models.User?> currentUser() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    }
  }

  Future<models.User> login({required String username, required String password}) async {
    AppwriteException? last;
    for (final email in _loginEmails(username)) {
      try {
        await _account.createEmailPasswordSession(email: email, password: password);
        return await _account.get();
      } on AppwriteException catch (error) {
        last = error;
      }
    }
    throw last ?? AppwriteException('Sign-in failed.');
  }

  static List<String> _loginEmails(String username) {
    final trimmed = username.trim();
    if (trimmed.contains('@')) return [trimmed];
    if (trimmed.toLowerCase() == 'manozsingharya') {
      return const [
        'manozsingharya@biconcept.in',
        'manozsingharya@gmail.com',
      ];
    }
    return [AppwriteConfig.emailFromUsername(trimmed)];
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException {
      // Already signed out.
    }
  }
}

class ListingsRepository {
  ListingsRepository({TablesDB? tables}) : _tables = tables ?? AppwriteServices.instance.tables;

  final TablesDB _tables;

  Future<List<MarketListing>> listPublished({String? city, String? sector}) async {
    if (_inWidgetTest) return const [];
    final queries = <String>[
      Query.equal('published', true),
      Query.orderDesc('\$createdAt'),
      Query.limit(100),
    ];
    if (city != null && city.isNotEmpty) {
      queries.add(Query.equal('city', city));
    }
    if (sector != null && sector.isNotEmpty) {
      queries.add(Query.equal('sector', sector));
    }
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableListings,
      queries: queries,
    );
    return [for (final row in result.rows) MarketListing.fromRow(row)];
  }

  Future<List<MarketListing>> listAll() async {
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableListings,
      queries: [Query.orderDesc('\$createdAt'), Query.limit(100)],
    );
    return [for (final row in result.rows) MarketListing.fromRow(row)];
  }

  Future<MarketListing> upsert(MarketListing listing, {String? id}) async {
    final rowId = id ?? listing.id;
    final existing = rowId.isEmpty;
    if (existing) {
      final row = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableListings,
        rowId: ID.unique(),
        data: listing.toData(),
        permissions: listing.published ? _publicRowPermissions() : _usersRowPermissions(),
      );
      return MarketListing.fromRow(row);
    }
    try {
      final row = await _tables.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableListings,
        rowId: rowId,
        data: listing.toData(),
        permissions: listing.published ? _publicRowPermissions() : _usersRowPermissions(),
      );
      return MarketListing.fromRow(row);
    } on AppwriteException catch (error) {
      if (error.code != 404) rethrow;
      final row = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableListings,
        rowId: rowId,
        data: listing.toData(),
        permissions: listing.published ? _publicRowPermissions() : _usersRowPermissions(),
      );
      return MarketListing.fromRow(row);
    }
  }

  Future<void> setPublished(String id, bool published) {
    return _tables.updateRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableListings,
      rowId: id,
      data: {'published': published},
      permissions: published ? _publicRowPermissions() : _usersRowPermissions(),
    );
  }

  Future<void> delete(String id) {
    return _tables.deleteRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableListings,
      rowId: id,
    );
  }
}

class LeadsRepository {
  LeadsRepository({TablesDB? tables}) : _tables = tables ?? AppwriteServices.instance.tables;

  final TablesDB _tables;

  Future<void> submitInquiry({
    required String name,
    required String phone,
    required String email,
    required String city,
    required String sector,
    required String practice,
    required String projectType,
    required String budgetBand,
    required String message,
    required String listingId,
    String offer = '',
  }) async {
    final brief = offer.trim().isEmpty ? message : 'Offer: $offer\n$message';
    await _tables.createRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableLeads,
      rowId: ID.unique(),
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'city': city,
        'sector': sector,
        'practice': practice,
        'projectType': projectType,
        'budgetBand': budgetBand,
        'message': brief,
        'source': 'website',
        'status': 'new',
        'listingId': listingId,
      },
      permissions: _usersRowPermissions(),
    );
  }

  Future<List<StudioLead>> listAll() async {
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableLeads,
      queries: [Query.orderDesc('\$createdAt'), Query.limit(100)],
    );
    return [for (final row in result.rows) StudioLead.fromRow(row)];
  }

  Future<void> updateStatus(String id, String status) {
    return _tables.updateRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableLeads,
      rowId: id,
      data: {'status': status},
    );
  }

  Future<void> delete(String id) {
    return _tables.deleteRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableLeads,
      rowId: id,
    );
  }
}

class ShowcaseRepository {
  ShowcaseRepository({TablesDB? tables}) : _tables = tables ?? AppwriteServices.instance.tables;

  final TablesDB _tables;

  /// Widget tests skip the network and keep the static Dart portfolio.
  static bool forceLocalProjects = false;

  Future<List<Project>> publishedProjects() async {
    if (forceLocalProjects || _inWidgetTest) return Projects.all;
    try {
      final rows = await listAll(publishedOnly: true);
      if (rows.isEmpty) return Projects.all;
      return [for (final row in rows) row.toProject()];
    } catch (_) {
      return Projects.all;
    }
  }

  Future<List<Project>> featuredProjects() async {
    final all = await publishedProjects();
    final featured = [for (final project in all) if (project.featured) project];
    if (featured.isEmpty) return all.take(2).toList();
    return featured;
  }

  Future<Project?> bySlug(String slug) async {
    final all = await publishedProjects();
    for (final project in all) {
      if (project.slug == slug) return project;
    }
    return Projects.bySlug(slug);
  }

  Future<List<ShowcaseRow>> listAll({bool publishedOnly = false}) async {
    final queries = <String>[
      Query.orderDesc('\$createdAt'),
      Query.limit(100),
    ];
    if (publishedOnly) queries.insert(0, Query.equal('published', true));
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableShowcase,
      queries: queries,
    );
    return [for (final row in result.rows) ShowcaseRow.fromRow(row)];
  }

  Future<ShowcaseRow> upsert(ShowcaseRow row) async {
    if (row.id.isEmpty) {
      final created = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableShowcase,
        rowId: ID.unique(),
        data: row.toData(),
        permissions: row.published ? _publicRowPermissions() : _usersRowPermissions(),
      );
      return ShowcaseRow.fromRow(created);
    }
    final updated = await _tables.updateRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableShowcase,
      rowId: row.id,
      data: row.toData(),
      permissions: row.published ? _publicRowPermissions() : _usersRowPermissions(),
    );
    return ShowcaseRow.fromRow(updated);
  }

  Future<void> delete(String id) {
    return _tables.deleteRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableShowcase,
      rowId: id,
    );
  }
}

class CmsServicesRepository {
  CmsServicesRepository({TablesDB? tables}) : _tables = tables ?? AppwriteServices.instance.tables;

  final TablesDB _tables;

  Future<List<ServiceRow>> listAll() async {
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableServices,
      queries: [Query.limit(25)],
    );
    return [for (final row in result.rows) ServiceRow.fromRow(row)];
  }

  Future<ServiceRow> upsert(ServiceRow row) async {
    if (row.id.isEmpty) {
      final created = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableServices,
        rowId: row.slug.isEmpty ? ID.unique() : row.slug,
        data: row.toData(),
      );
      return ServiceRow.fromRow(created);
    }
    final updated = await _tables.updateRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableServices,
      rowId: row.id,
      data: row.toData(),
    );
    return ServiceRow.fromRow(updated);
  }

  Future<void> delete(String id) {
    return _tables.deleteRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableServices,
      rowId: id,
    );
  }
}

class MediaRepository {
  MediaRepository({Storage? storage}) : _storage = storage ?? AppwriteServices.instance.storage;

  final Storage _storage;

  Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
  }) async {
    final file = await _storage.createFile(
      bucketId: AppwriteConfig.bucketMedia,
      fileId: ID.unique(),
      file: InputFile.fromBytes(bytes: bytes, filename: filename),
      permissions: [Permission.read(Role.any())],
    );
    return file.$id;
  }
}

class OffersRepository {
  OffersRepository({TablesDB? tables}) : _tables = tables ?? AppwriteServices.instance.tables;

  final TablesDB _tables;

  Future<List<StudioOffer>> listPublished({String? practice}) async {
    if (_inWidgetTest) return const [];
    try {
      final result = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableOffers,
        queries: [
          Query.equal('published', true),
          Query.limit(12),
        ],
      );
      final rows = [for (final row in result.rows) StudioOffer.fromRow(row)];
      if (practice == null || practice.isEmpty) return rows;
      return [
        for (final offer in rows)
          if (offer.practice.isEmpty || offer.practice == practice) offer,
      ];
    } on AppwriteException {
      return const [];
    }
  }

  Future<List<StudioOffer>> listAll() async {
    final result = await _tables.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableOffers,
      queries: [Query.limit(50)],
    );
    return [for (final row in result.rows) StudioOffer.fromRow(row)];
  }

  Future<StudioOffer> upsert(StudioOffer row) async {
    if (row.id.isEmpty) {
      final created = await _tables.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableOffers,
        rowId: ID.unique(),
        data: row.toData(),
        permissions: row.published ? _publicRowPermissions() : _usersRowPermissions(),
      );
      return StudioOffer.fromRow(created);
    }
    final updated = await _tables.updateRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableOffers,
      rowId: row.id,
      data: row.toData(),
      permissions: row.published ? _publicRowPermissions() : _usersRowPermissions(),
    );
    return StudioOffer.fromRow(updated);
  }

  Future<void> delete(String id) {
    return _tables.deleteRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableOffers,
      rowId: id,
    );
  }
}

class AgentJobsRepository {
  AgentJobsRepository({TablesDB? tables, Realtime? realtime})
      : _tables = tables ?? AppwriteServices.instance.tables,
        _realtime = realtime ?? AppwriteServices.instance.realtime;

  final TablesDB _tables;
  final Realtime _realtime;

  static List<AgentJob>? debugJobs;

  Future<List<AgentJob>> listRecent({int limit = 40}) async {
    if (debugJobs != null) return debugJobs!;
    if (_inWidgetTest) return const [];
    try {
      final result = await _tables.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.tableAgentJobs,
        queries: [Query.orderDesc('\$createdAt'), Query.limit(limit)],
      );
      return [for (final row in result.rows) AgentJob.fromRow(row)];
    } on AppwriteException {
      return const [];
    }
  }

  Future<AgentJob> enqueue({
    required String agentId,
    required String title,
    String payload = '',
  }) async {
    if (debugJobs != null) {
      final job = AgentJob(
        id: 'debug-${DateTime.now().millisecondsSinceEpoch}',
        agentId: agentId,
        title: title,
        status: 'queued',
        progress: 0,
        summary: 'Queued',
        log: '',
        payload: payload,
        startedAt: '',
        finishedAt: '',
      );
      debugJobs = [job, ...debugJobs!];
      return job;
    }
    final row = await _tables.createRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.tableAgentJobs,
      rowId: ID.unique(),
      data: {
        'agentId': agentId,
        'title': title,
        'status': 'queued',
        'progress': 0,
        'summary': 'Waiting for GitHub dispatcher (every 15 min on main)',
        'log': '',
        'payload': payload,
        'startedAt': '',
        'finishedAt': '',
      },
      permissions: _usersRowPermissions(),
    );
    return AgentJob.fromRow(row);
  }

  RealtimeSubscription? subscribe(void Function() onChange) {
    if (_inWidgetTest || debugJobs != null) return null;
    try {
      final sub = _realtime.subscribe([
        'databases.${AppwriteConfig.databaseId}.tables.${AppwriteConfig.tableAgentJobs}.rows',
      ]);
      sub.stream.listen((_) => onChange());
      return sub;
    } catch (_) {
      return null;
    }
  }
}

class ConciergeRepository {
  ConciergeRepository({Functions? functions})
      : _functions = functions ?? AppwriteServices.instance.functions;

  final Functions _functions;

  static String? debugReply;

  Future<String> ask(String message) async {
    if (debugReply != null) return debugReply!;
    if (_inWidgetTest) return 'Concierge is offline in tests.';
    try {
      final execution = await _functions.createExecution(
        functionId: AppwriteConfig.functionConcierge,
        body: jsonEncode({'message': message}),
        xasync: false,
      );
      final body = execution.responseBody.trim();
      if (body.isEmpty) {
        return execution.responseStatusCode == 200
            ? 'Done.'
            : 'Concierge returned ${execution.responseStatusCode}.';
      }
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['reply'] != null) {
          return decoded['reply'].toString();
        }
      } on FormatException {
        // Plain-text Function response.
      }
      return body;
    } on AppwriteException catch (error) {
      return error.message ?? 'Concierge is not deployed yet.';
    } catch (error) {
      return error.toString();
    }
  }
}
