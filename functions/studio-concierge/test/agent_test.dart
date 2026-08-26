import 'package:studio_concierge/agent.dart';
import 'package:test/test.dart';

class FakeGemini implements GeminiLoop {
  FakeGemini(this.turns);

  final List<GeminiTurn> turns;
  int index = 0;
  List<Map<String, dynamic>>? lastContents;

  @override
  Future<GeminiTurn> next(List<Map<String, dynamic>> contents) async {
    lastContents = contents;
    if (index >= turns.length) return const GeminiTurn(text: 'Done.');
    return turns[index++];
  }
}

class FakeCms implements StudioCms {
  Map<String, dynamic>? lastOffer;
  Map<String, dynamic>? lastListing;
  Map<String, dynamic>? lastPublish;
  bool publishedAll = false;

  @override
  Future<Map<String, dynamic>> upsertListing(Map<String, dynamic> args) async {
    lastListing = args;
    return {'ok': true, 'id': 'listing-1', 'published': args['published'] != false, 'payload': args};
  }

  @override
  Future<Map<String, dynamic>> publishListing(Map<String, dynamic> args) async {
    lastPublish = args;
    return {'ok': true, 'id': args['id'] ?? 'listing-1', 'published': true};
  }

  @override
  Future<Map<String, dynamic>> publishAllListings() async {
    publishedAll = true;
    return {
      'ok': true,
      'publishedCount': 1,
      'alreadyLive': 1,
      'published': ['Godrej Jardinia'],
    };
  }

  @override
  Future<Map<String, dynamic>> listListings() async => {
        'listings': [
          {'id': 'listing-1', 'title': 'Godrej Jardinia', 'city': 'noida', 'published': false},
        ],
      };

  @override
  Future<Map<String, dynamic>> upsertOffer(Map<String, dynamic> args) async {
    lastOffer = args;
    return {'ok': true, 'id': 'offer-1', 'payload': args};
  }

  @override
  Future<Map<String, dynamic>> listLeads() async => {
        'leads': [
          {'id': 'lead-1', 'name': 'Asha', 'status': 'new'},
        ],
      };

  @override
  Future<Map<String, dynamic>> updateLeadStatus(String id, String status) async =>
      {'ok': true, 'id': id, 'status': status};

  @override
  Future<Map<String, dynamic>> listJobs() async => {'jobs': []};
}

void main() {
  test('tool call upserts an offer payload', () async {
    final cms = FakeCms();
    final gemini = FakeGemini([
      const GeminiTurn(
        call: FunctionCall(
          name: 'upsert_offer',
          args: {
            'title': 'Noida interiors hour',
            'summary': 'A first look at rooms.',
            'href': '/inquire?offer=interiors',
            'practice': 'interiors',
            'published': true,
          },
        ),
      ),
      const GeminiTurn(text: 'Published the interiors offer.'),
    ]);
    final agent = ConciergeAgent(gemini: gemini, cms: cms);
    final reply = await agent.handle('Add a quiet interiors offer for Noida.');
    expect(cms.lastOffer, isNotNull);
    expect(cms.lastOffer!['title'], 'Noida interiors hour');
    expect(cms.lastOffer!['practice'], 'interiors');
    expect(reply, contains('Published the interiors offer'));
  });

  test('parseGeminiTurn reads functionCall args', () {
    final turn = parseGeminiTurn({
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'functionCall': {
                  'name': 'upsert_listing',
                  'args': {'title': 'Godrej Jardinia', 'city': 'noida'},
                },
              },
            ],
          },
        },
      ],
    });
    expect(turn.call?.name, 'upsert_listing');
    expect(turn.call?.args['title'], 'Godrej Jardinia');
  });

  test('publish_listing tool call marks a listing live', () async {
    final cms = FakeCms();
    final gemini = FakeGemini([
      const GeminiTurn(
        call: FunctionCall(
          name: 'publish_listing',
          args: {'id': 'listing-1'},
        ),
      ),
      const GeminiTurn(text: 'The listing is live on the site.'),
    ]);
    final agent = ConciergeAgent(gemini: gemini, cms: cms);
    final reply = await agent.handle('Publish the Jardinia listing.');
    expect(cms.lastPublish, isNotNull);
    expect(cms.lastPublish!['id'], 'listing-1');
    expect(reply, contains('live'));
  });

  test('publish all listings shortcut skips Gemini', () async {
    final cms = FakeCms();
    final gemini = FakeGemini([]);
    final agent = ConciergeAgent(gemini: gemini, cms: cms);
    final reply = await agent.handle('publish all the listing');
    expect(cms.publishedAll, isTrue);
    expect(gemini.index, 0);
    expect(reply, contains('Published 1 listing'));
    expect(reply, contains('Godrej Jardinia'));
  });

  test('parseGeminiTurn stays empty when Gemini returns no candidates', () {
    final turn = parseGeminiTurn({'candidates': []});
    expect(turn.text, isNull);
    expect(turn.call, isNull);
  });

  test('wantsPublishAllListings matches studio phrasing', () {
    expect(wantsPublishAllListings('publish all the listing'), isTrue);
    expect(wantsPublishAllListings('make every listing live'), isTrue);
    expect(wantsPublishAllListings('list the leads'), isFalse);
  });
}
