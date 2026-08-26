import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

/// Idempotent schema bootstrap for offers + agent_jobs.
Future<void> main() async {
  final key = Platform.environment['APPWRITE_API_KEY'] ?? '';
  if (key.isEmpty) {
    stderr.writeln('APPWRITE_API_KEY is required to bootstrap tables.');
    exitCode = 1;
    return;
  }
  final endpoint =
      Platform.environment['APPWRITE_ENDPOINT'] ?? 'https://sgp.cloud.appwrite.io/v1';
  final projectId = Platform.environment['APPWRITE_PROJECT_ID'] ?? '6a8de2d2003a8c9f54fe';
  final databaseId = Platform.environment['APPWRITE_DATABASE_ID'] ?? 'biconcept';

  final tables = TablesDB(
    Client().setEndpoint(endpoint).setProject(projectId).setKey(key),
  );

  final usersWrite = [
    Permission.read(Role.users()),
    Permission.create(Role.users()),
    Permission.update(Role.users()),
    Permission.delete(Role.users()),
  ];
  final offersTablePerms = [
    Permission.read(Role.any()),
    Permission.create(Role.users()),
    Permission.update(Role.users()),
    Permission.delete(Role.users()),
  ];

  await _ensureTable(
    tables,
    databaseId: databaseId,
    tableId: 'offers',
    name: 'Offers',
    permissions: offersTablePerms,
    rowSecurity: true,
  );
  await _string(tables, databaseId, 'offers', 'title', 256, required: true);
  await _string(tables, databaseId, 'offers', 'summary', 1000);
  await _string(tables, databaseId, 'offers', 'ctaLabel', 64);
  await _string(tables, databaseId, 'offers', 'href', 512);
  await _string(tables, databaseId, 'offers', 'practice', 64);
  await _bool(tables, databaseId, 'offers', 'published', xdefault: false);

  await _ensureTable(
    tables,
    databaseId: databaseId,
    tableId: 'agent_jobs',
    name: 'Agent jobs',
    permissions: usersWrite,
    rowSecurity: true,
  );
  await _string(tables, databaseId, 'agent_jobs', 'agentId', 64, required: true);
  await _string(tables, databaseId, 'agent_jobs', 'title', 256, required: true);
  await _string(tables, databaseId, 'agent_jobs', 'status', 32, required: true);
  await _int(tables, databaseId, 'agent_jobs', 'progress', xdefault: 0);
  await _string(tables, databaseId, 'agent_jobs', 'summary', 1000);
  await _string(tables, databaseId, 'agent_jobs', 'log', 10000);
  await _string(tables, databaseId, 'agent_jobs', 'payload', 4000);
  await _string(tables, databaseId, 'agent_jobs', 'startedAt', 64);
  await _string(tables, databaseId, 'agent_jobs', 'finishedAt', 64);

  stdout.writeln('Bootstrap complete.');
}

Future<void> _ensureTable(
  TablesDB tables, {
  required String databaseId,
  required String tableId,
  required String name,
  required List<String> permissions,
  required bool rowSecurity,
}) async {
  try {
    await tables.getTable(databaseId: databaseId, tableId: tableId);
    stdout.writeln('Table $tableId exists.');
  } on AppwriteException catch (error) {
    if (error.code != 404) {
      stderr.writeln('getTable $tableId: ${error.message}');
      rethrow;
    }
    await tables.createTable(
      databaseId: databaseId,
      tableId: tableId,
      name: name,
      permissions: permissions,
      rowSecurity: rowSecurity,
      enabled: true,
    );
    stdout.writeln('Created table $tableId.');
  }
}

Future<void> _string(
  TablesDB tables,
  String databaseId,
  String tableId,
  String key,
  int size, {
  bool required = false,
}) async {
  try {
    await tables.createStringColumn(
      databaseId: databaseId,
      tableId: tableId,
      key: key,
      size: size,
      xrequired: required,
    );
    stdout.writeln('Column $tableId.$key');
  } on AppwriteException catch (error) {
    if ('${error.message}'.contains('already') || error.code == 409) {
      stdout.writeln('Column $tableId.$key exists.');
      return;
    }
    stderr.writeln('column $key: ${error.message}');
  }
}

Future<void> _bool(
  TablesDB tables,
  String databaseId,
  String tableId,
  String key, {
  bool? xdefault,
}) async {
  try {
    await tables.createBooleanColumn(
      databaseId: databaseId,
      tableId: tableId,
      key: key,
      xrequired: false,
      xdefault: xdefault,
    );
    stdout.writeln('Column $tableId.$key');
  } on AppwriteException catch (error) {
    if ('${error.message}'.contains('already') || error.code == 409) {
      stdout.writeln('Column $tableId.$key exists.');
      return;
    }
    stderr.writeln('column $key: ${error.message}');
  }
}

Future<void> _int(
  TablesDB tables,
  String databaseId,
  String tableId,
  String key, {
  int? xdefault,
}) async {
  try {
    await tables.createIntegerColumn(
      databaseId: databaseId,
      tableId: tableId,
      key: key,
      xrequired: false,
      min: 0,
      max: 100,
      xdefault: xdefault,
    );
    stdout.writeln('Column $tableId.$key');
  } on AppwriteException catch (error) {
    if ('${error.message}'.contains('already') || error.code == 409) {
      stdout.writeln('Column $tableId.$key exists.');
      return;
    }
    stderr.writeln('column $key: ${error.message}');
  }
}
