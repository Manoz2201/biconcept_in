import 'package:biconcept_in/app.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/widgets/faq_section.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const BiConceptApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  setUpAll(() async {
    await SiteSeo.load();
    ShowcaseRepository.forceLocalProjects = true;
  });

  testWidgets('home renders BiConcept wordmark and primary CTA', (tester) async {
    await _pumpApp(tester, const Size(1440, 900));
    expect(find.text('BiConcept'), findsWidgets);
    expect(find.textContaining('START A CONCEPT'), findsWidgets);
  });

  testWidgets('FaqSection renders questions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FaqSection(
            items: [
              FaqItem(
                question: 'What does BiConcept do?',
                answer: 'A conceptual studio.',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('What does BiConcept do?'), findsOneWidget);
    expect(find.text('Asked before the brief.'), findsOneWidget);
  });

  testWidgets('desktop navigates practices, work, project, studio, inquire', (tester) async {
    await _pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('Architecture').first);
    await _settle(tester);
    expect(find.text('Architecture as a held idea.'), findsWidgets);

    await tester.tap(find.text('Interiors').first);
    await _settle(tester);
    expect(find.text('Interiors with architectural calm.'), findsWidgets);

    await tester.tap(find.text('Real estate').first);
    await _settle(tester);
    expect(find.text('Land, composed.'), findsWidgets);

    await tester.tap(find.text('Listings').first);
    await _settle(tester);
    expect(find.text('NCR, by pocket.'), findsWidgets);

    await tester.tap(find.text('Work').first);
    await _settle(tester);
    expect(find.text('Selected work.'), findsWidgets);

    await tester.tap(find.byKey(const Key('project-house-on-the-ridge')));
    await _settle(tester);
    expect(find.textContaining('steps with the land'), findsWidgets);

    await tester.tap(find.text('Studio').first);
    await _settle(tester);
    expect(find.text('A studio of one concept.'), findsWidgets);

    await tester.tap(find.textContaining('START A CONCEPT').first);
    await _settle(tester);
    expect(find.text('Start a concept.'), findsWidgets);
    expect(find.text('Which practice?'), findsOneWidget);
  });

  testWidgets('mobile menu opens practices', (tester) async {
    await _pumpApp(tester, const Size(390, 844));
    expect(find.byTooltip('Open menu'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await _settle(tester);
    expect(find.text('Architecture'), findsWidgets);

    await tester.tap(find.text('Architecture').last);
    await _settle(tester);
    expect(find.text('Architecture as a held idea.'), findsWidgets);
  });
}
