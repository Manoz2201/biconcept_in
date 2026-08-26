import 'package:biconcept_in/app.dart';
import 'package:biconcept_in/content/seo.dart';
import 'package:biconcept_in/core/routing/app_router.dart';
import 'package:biconcept_in/data/models.dart';
import 'package:biconcept_in/data/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

Future<void> _pumpAt(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = createRouter();
  await tester.pumpWidget(BiConceptApp(router: router));
  await tester.pump();
  router.go(location);
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

  setUp(() {
    ListingsRepository.debugListings = const [
      MarketListing(
        id: 'listing-1',
        title: 'Godrej Jardinia',
        developer: 'Godrej',
        city: 'noida',
        sector: '146',
        locality: '',
        status: 'upcoming',
        typology: 'apartment',
        priceBand: '₹3Cr+',
        summary: 'A Noida super-luxury tower researched for studio clients.',
        sourceUrl: '',
        sourceName: '',
        published: true,
        researchedAt: '2026-08-26',
      ),
    ];
  });

  tearDown(() {
    ListingsRepository.debugListings = null;
  });

  testWidgets('studio shows three practice cards', (tester) async {
    await _pumpAt(tester, '/studio');
    expect(find.textContaining('A studio of one concept'), findsWidgets);
    await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -720));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('studio-card-architecture')), findsOneWidget);
    expect(find.byKey(const Key('studio-card-interiors')), findsOneWidget);
    expect(find.byKey(const Key('studio-card-real-estate')), findsOneWidget);
  });

  testWidgets('real estate card opens listing photos and inquiry popup', (tester) async {
    await _pumpAt(tester, '/studio/real-estate');
    expect(find.text('Godrej Jardinia'), findsWidgets);

    await tester.tap(find.byKey(const Key('studio-item-listing-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Leave your details.'), findsOneWidget);
    expect(find.textContaining('A Noida super-luxury tower'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'NAME'), 'Asha Rao');
    await tester.enterText(find.widgetWithText(TextFormField, 'PHONE'), '9810012345');
    await tester.ensureVisible(find.text('SEND TO STUDIO'));
    await tester.tap(find.text('SEND TO STUDIO'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Received.'), findsOneWidget);
  });

  testWidgets('architecture card opens studio work and inquiry popup', (tester) async {
    await _pumpAt(tester, '/studio/architecture');
    expect(find.text('House on the Ridge'), findsWidgets);

    await tester.tap(find.byKey(const Key('studio-item-house-on-the-ridge')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Leave your details.'), findsOneWidget);
    expect(find.textContaining('The ridge asked for a long'), findsOneWidget);
  });
}
