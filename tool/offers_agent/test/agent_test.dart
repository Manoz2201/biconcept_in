import 'package:offers_agent/agent.dart';
import 'package:test/test.dart';

void main() {
  test('parses offers JSON and normalizes practice', () {
    const raw = '''
{"offers":[
  {"title":"Summer interiors consult","summary":"A calm first look at rooms in Noida.","ctaLabel":"Book a consultation","href":"/inquire?offer=interiors","practice":"Interiors"},
  {"title":"Land walk","summary":"Walk a plot before you buy.","href":"/real-estate","practice":"land"}
]}
''';
    final parsed = parseOffersJson(raw);
    expect(parsed, hasLength(2));
    expect(parsed.first.practice, 'interiors');
    expect(parsed.last.practice, 'real-estate');
    expect(parsed.first.toData()['published'], isTrue);
  });

  test('skips duplicate titles and respects the active cap', () {
    final drafts = [
      StudioOfferDraft(
        title: 'Existing offer',
        summary: 'Already live.',
        ctaLabel: 'Book a consultation',
        href: '/inquire',
        practice: '',
      ),
      StudioOfferDraft(
        title: 'New offer A',
        summary: 'A.',
        ctaLabel: 'Book a consultation',
        href: '/inquire?offer=a',
        practice: 'architecture',
      ),
      StudioOfferDraft(
        title: 'New offer B',
        summary: 'B.',
        ctaLabel: 'Book a consultation',
        href: '/inquire?offer=b',
        practice: 'interiors',
      ),
    ];
    final selection = selectOffers(
      drafts,
      existingTitles: {'existing offer'},
      activeCount: 1,
      capActive: 2,
    );
    expect(selection.accepted, hasLength(1));
    expect(selection.accepted.first.title, 'New offer A');
    expect(selection.skipped.any((s) => s.startsWith('duplicate:')), isTrue);
    expect(selection.skipped.any((s) => s.startsWith('cap:')), isTrue);
  });
}
