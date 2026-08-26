import 'package:market_agent/agent.dart';
import 'package:test/test.dart';

void main() {
  test('parses research JSON, normalizes NCR cities, and skips invented rows', () {
    const raw = '''
{"listings":[
  {"title":"Godrej Jardinia","developer":"Godrej Properties","city":"Noida","sector":"Sector 146","status":"under-construction","typology":"apartment","priceBand":"","summary":"A high-rise residential in Noida.","sourceUrl":"https://example.com","sourceName":"Example"},
  {"title":"Invented Towers","developer":"","city":"gurgaon","sector":"","status":"upcoming","typology":"apartment","summary":"Skip me.","sourceUrl":"","sourceName":""}
]}
''';
    final parsed = GeminiResearch.parseResearchJson(raw);
    expect(parsed, hasLength(1));
    expect(parsed.first.city, 'noida');
    expect(parsed.first.sector, '146');
    expect(parsed.first.rowId.length, 32);
    expect(parsed.first.toData()['published'], isTrue);
  });

  test('existing drafts are published; live rows are skipped', () {
    expect(
      listingWriteAction(exists: false, published: false),
      ListingWriteAction.create,
    );
    expect(
      listingWriteAction(exists: true, published: false),
      ListingWriteAction.publish,
    );
    expect(
      listingWriteAction(exists: true, published: true),
      ListingWriteAction.skip,
    );
  });
}
