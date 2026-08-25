import 'dart:io';

import 'package:seo_agent/agent.dart';

Future<void> main(List<String> args) async {
  String? root;
  String? fixture;
  var dryRun = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--root' && i + 1 < args.length) {
      root = args[++i];
    } else if (arg.startsWith('--root=')) {
      root = arg.substring('--root='.length);
    } else if (arg == '--fixture' && i + 1 < args.length) {
      fixture = args[++i];
    } else if (arg.startsWith('--fixture=')) {
      fixture = arg.substring('--fixture='.length);
    } else if (arg == '--dry-run') {
      dryRun = true;
    }
  }

  final result = await runAgent(
    AgentConfig(
      root: findRepoRoot(root),
      geminiApiKey: Platform.environment['GEMINI_API_KEY'],
      serperApiKey: Platform.environment['SERPER_API_KEY'],
      siteUrl: Platform.environment['SITE_URL'],
      fixturePath: fixture,
      dryRun: dryRun,
    ),
  );
  if (result.skipped && result.note != null) {
    stdout.writeln(result.note);
  }
  exitCode = 0;
}
