import 'package:biconcept_in/core/theme/theme.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:biconcept_in/features/admin/admin_agents_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    AgentJobsRepository.debugJobs = [
      const AgentJob(
        id: 'job-1',
        agentId: 'market',
        title: 'Market research',
        status: 'running',
        progress: 50,
        summary: 'Extracting listings…',
        log: 'halfway',
        payload: '',
        startedAt: '',
        finishedAt: '',
      ),
    ];
  });

  tearDown(() {
    AgentJobsRepository.debugJobs = null;
  });

  testWidgets('agents page renders job title and status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BcTheme.admin,
        home: const Scaffold(body: AdminAgentsPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Agents'), findsWidgets);
    expect(find.text('Market research'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);
    expect(find.text('Extracting listings…'), findsOneWidget);
  });
}
