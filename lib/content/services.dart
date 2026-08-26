enum PracticeKind { architecture, interiors, realEstate }

extension PracticeKindX on PracticeKind {
  String get slug => switch (this) {
        PracticeKind.architecture => 'architecture',
        PracticeKind.interiors => 'interiors',
        PracticeKind.realEstate => 'real-estate',
      };

  String get route => '/$slug';

  String get label => switch (this) {
        PracticeKind.architecture => 'Architecture',
        PracticeKind.interiors => 'Interiors',
        PracticeKind.realEstate => 'Real estate',
      };

  String get ctaLabel => switch (this) {
        PracticeKind.architecture => 'Start an architecture brief',
        PracticeKind.interiors => 'Plan an interiors project',
        PracticeKind.realEstate => 'Request a site visit',
      };

  String inquirePath({String? listing, String? city, String? sector, String? offer}) {
    final params = <String, String>{
      'practice': slug,
      if (listing != null && listing.isNotEmpty) 'listing': listing,
      if (city != null && city.isNotEmpty) 'city': city,
      if (sector != null && sector.isNotEmpty) 'sector': sector,
      if (offer != null && offer.isNotEmpty) 'offer': offer,
    };
    return Uri(path: '/inquire', queryParameters: params).toString();
  }
}

class ProcessStep {
  const ProcessStep({required this.index, required this.title, required this.body});

  final String index;
  final String title;
  final String body;
}

class Practice {
  const Practice({
    required this.kind,
    required this.kicker,
    required this.headline,
    required this.lede,
    required this.imageUrl,
    required this.process,
    required this.deliverables,
  });

  final PracticeKind kind;
  final String kicker;
  final String headline;
  final String lede;
  final String imageUrl;
  final List<ProcessStep> process;
  final List<String> deliverables;

  String get route => kind.route;
  String get label => kind.label;
  String get ctaLabel => kind.ctaLabel;
  String get inquirePath => kind.inquirePath();
}

abstract final class Practices {
  static const architecture = Practice(
    kind: PracticeKind.architecture,
    kicker: 'Practice 01',
    headline: 'Architecture as a held idea.',
    lede:
        'From the first massing to the last threshold, we design buildings that feel inevitable — villas, residences, and developments with a single spatial argument.',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1800&q=80',
    process: [
      ProcessStep(
        index: '01',
        title: 'Brief & site',
        body: 'We read land, light, and the life you want to hold — not a programme of rooms.',
      ),
      ProcessStep(
        index: '02',
        title: 'Concept',
        body: 'One idea, drawn until it can carry structure, climate, and atmosphere.',
      ),
      ProcessStep(
        index: '03',
        title: 'Design development',
        body: 'Proportion, material, and engineering resolved as a single drawing set.',
      ),
      ProcessStep(
        index: '04',
        title: 'Realisation',
        body: 'Site presence through construction, so the built work matches the concept.',
      ),
    ],
    deliverables: [
      'Concept and massing studies',
      'Planning and authority drawings',
      'Detailed architectural set',
      'Material and façade direction',
      'Site coordination through build',
    ],
  );

  static const interiors = Practice(
    kind: PracticeKind.interiors,
    kicker: 'Practice 02',
    headline: 'Interiors with architectural calm.',
    lede:
        'We compose rooms the way we compose buildings — light, material, and furniture as one temperature. Homes and hospitality that feel finished, not decorated.',
    imageUrl:
        'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1800&q=80',
    process: [
      ProcessStep(
        index: '01',
        title: 'Atmosphere',
        body: 'A material and light brief before a furniture list.',
      ),
      ProcessStep(
        index: '02',
        title: 'Composition',
        body: 'Plans, millwork, and pieces arranged as a spatial sequence.',
      ),
      ProcessStep(
        index: '03',
        title: 'Craft',
        body: 'Joinery, stone, textile, and lighting specified to the millimetre.',
      ),
      ProcessStep(
        index: '04',
        title: 'Styling & handoff',
        body: 'The last objects placed so the room can be lived, not photographed only.',
      ),
    ],
    deliverables: [
      'Concept and mood direction',
      'Furniture and lighting layouts',
      'Custom millwork drawings',
      'FF&E specification',
      'Styling and installation',
    ],
  );

  static const realEstate = Practice(
    kind: PracticeKind.realEstate,
    kicker: 'Practice 03',
    headline: 'Land, composed.',
    lede:
        'We advise on residences, plots, and developments with a designer’s eye — selecting, shaping, and presenting property as a long idea, not a listing.',
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1800&q=80',
    process: [
      ProcessStep(
        index: '01',
        title: 'Intent',
        body: 'Hold, inhabit, or develop — we name the purpose before the search.',
      ),
      ProcessStep(
        index: '02',
        title: 'Selection',
        body: 'Sites and residences filtered for light, access, grain, and future value.',
      ),
      ProcessStep(
        index: '03',
        title: 'Concept overlay',
        body: 'What the land can become, drawn so you can decide with clarity.',
      ),
      ProcessStep(
        index: '04',
        title: 'Transaction & next',
        body: 'Advisory through close, then architecture or interiors if the brief continues.',
      ),
    ],
    deliverables: [
      'Search and shortlist',
      'Site and product due diligence',
      'Concept overlay for development',
      'Presentation for sale or hold',
      'Handoff into design, if commissioned',
    ],
  );

  static const all = [architecture, interiors, realEstate];

  static Practice byKind(PracticeKind kind) => switch (kind) {
        PracticeKind.architecture => architecture,
        PracticeKind.interiors => interiors,
        PracticeKind.realEstate => realEstate,
      };

  static Practice? bySlug(String slug) {
    for (final practice in all) {
      if (practice.kind.slug == slug) return practice;
    }
    return null;
  }
}
