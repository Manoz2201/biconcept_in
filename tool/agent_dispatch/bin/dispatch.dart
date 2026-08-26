import 'dart:io';

import 'package:agent_runtime/agent_runtime.dart';

const _agents = {
  'market': ['tool/market_agent', 'bin/market_agent.dart'],
  'offers': ['tool/offers_agent', 'bin/offers_agent.dart'],
  'seo': ['tool/seo_agent', 'bin/seo_agent.dart'],
};

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  if (dryRun && (Platform.environment['APPWRITE_API_KEY'] ?? '').isEmpty) {
    stdout.writeln('Dry-run: dispatcher would list queued jobs and run matching CLIs.');
    _writeGithubOutput(seoChanged: false);
    return;
  }
  final writer = jobWriterFromEnv();
  if (writer == null) {
    stderr.writeln('APPWRITE_API_KEY is required to dispatch queued jobs.');
    exitCode = 1;
    return;
  }

  final root = _repoRoot();
  final queued = await writer.listQueued();
  stdout.writeln('Queued jobs: ${queued.length}');
  var seoChanged = false;

  if (queued.isEmpty) {
    _writeGithubOutput(seoChanged: false);
    return;
  }

  for (final job in queued) {
    stdout.writeln('Dispatch ${job.agentId} ${job.id} ${job.title}');
    if (job.agentId == 'concierge') {
      await writer.fail(
        job.id,
        'Concierge runs from admin chat, not the dispatcher.',
      );
      continue;
    }
    final spec = _agents[job.agentId];
    if (spec == null) {
      await writer.fail(job.id, 'Unknown agent ${job.agentId}');
      continue;
    }
    if (dryRun) {
      stdout.writeln('Dry-run: would run ${spec[0]}/${spec[1]}');
      continue;
    }
    final workingDir = '${root.path}${Platform.pathSeparator}${spec[0].replaceAll('/', Platform.pathSeparator)}';
    final dartArgs = <String>['run', spec[1]];
    if (job.agentId == 'seo') {
      dartArgs.addAll(['--root', root.path]);
    }
    final env = Map<String, String>.from(Platform.environment);
    env['AGENT_JOB_ID'] = job.id;
    final result = await Process.run(
      'dart',
      dartArgs,
      workingDirectory: workingDir,
      environment: env,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      await writer.fail(job.id, 'CLI exit ${result.exitCode}\n${result.stderr}');
      continue;
    }
    if (job.agentId == 'seo') {
      seoChanged = seoChanged || await _seoTreeDirty(root);
    }
  }

  _writeGithubOutput(seoChanged: seoChanged);
}

Directory _repoRoot() {
  var dir = Directory.current.absolute;
  for (var i = 0; i < 8; i++) {
    final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspec.existsSync() && pubspec.readAsStringSync().contains('name: biconcept_in')) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError('Could not find biconcept_in repo root.');
}

Future<bool> _seoTreeDirty(Directory root) async {
  final result = await Process.run(
    'git',
    ['diff', '--name-only'],
    workingDirectory: root.path,
  );
  final names = result.stdout.toString().split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty);
  return names.any(isSeoAllowlisted);
}

void _writeGithubOutput({required bool seoChanged}) {
  final path = Platform.environment['GITHUB_OUTPUT'];
  if (path == null || path.isEmpty) return;
  File(path).writeAsStringSync('seo_changed=$seoChanged\n', mode: FileMode.append);
}
