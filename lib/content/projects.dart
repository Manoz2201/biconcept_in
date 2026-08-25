import 'package:biconcept_in/content/services.dart';

class Project {
  const Project({
    required this.slug,
    required this.title,
    required this.location,
    required this.year,
    required this.kind,
    required this.heroUrl,
    required this.gallery,
    required this.lede,
    required this.story,
    required this.featured,
  });

  final String slug;
  final String title;
  final String location;
  final String year;
  final PracticeKind kind;
  final String heroUrl;
  final List<String> gallery;
  final String lede;
  final String story;
  final bool featured;

  String get route => '/work/$slug';
  String get practiceLabel => kind.label;
  String get practiceRoute => kind.route;
}

abstract final class Projects {
  static const houseOnTheRidge = Project(
    slug: 'house-on-the-ridge',
    title: 'House on the Ridge',
    location: 'Lonavala',
    year: '2024',
    kind: PracticeKind.architecture,
    heroUrl:
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A weekend house that steps with the land rather than flattening it.',
    story:
        'The ridge asked for a long, low line. We split the programme into two pavilions — living to the view, sleeping to the grove — connected by a shaded court. Stone from the site, a thin roof, and openings that track the afternoon wind. Architecture as a pause in the hill, not a monument on it.',
    featured: true,
  );

  static const courtyardResidence = Project(
    slug: 'courtyard-residence',
    title: 'Courtyard Residence',
    location: 'Ahmedabad',
    year: '2023',
    kind: PracticeKind.architecture,
    heroUrl:
        'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600607687644-c7171b42498f?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A family house organised around light that moves through the day.',
    story:
        'Four wings hold a planted court. Rooms open in sequence — arrival, living, kitchen, night — so the house is always in conversation with shade. Lime plaster, teak, and a water channel that cools the inner rooms. A contemporary reading of a courtyard type, without pastiche.',
    featured: true,
  );

  static const northFacingApartment = Project(
    slug: 'north-facing-apartment',
    title: 'North-Facing Apartment',
    location: 'Mumbai',
    year: '2025',
    kind: PracticeKind.interiors,
    heroUrl:
        'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600210492493-94dad1a56321?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A sea-facing apartment calmed into a single material temperature.',
    story:
        'We stripped the plan to three rooms and a long gallery. Oak, linen, and a quiet stone hold the north light. Storage is built in, so objects can be few. The city stays at the glass; the interior stays still.',
    featured: true,
  );

  static const studioHouseInteriors = Project(
    slug: 'studio-house-interiors',
    title: 'Studio House',
    location: 'Bengaluru',
    year: '2024',
    kind: PracticeKind.interiors,
    heroUrl:
        'https://images.unsplash.com/photo-1600607687920-4e2a09cf67cd?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1600489000022-c2086d79f9d4?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'Live and work in one volume, without the house becoming an office.',
    story:
        'A sliding oak wall divides the studio from the living room only when needed. Daylight from two sides; a work table that disappears as dining. We specified a short palette so the dual use never reads as compromise.',
    featured: false,
  );

  static const groveVilla = Project(
    slug: 'grove-villa',
    title: 'Grove Villa',
    location: 'Alibaug',
    year: '2022',
    kind: PracticeKind.architecture,
    heroUrl:
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdbc?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A house among coconut palms, opened to the breeze and closed to the road.',
    story:
        'The street elevation is almost mute. Inside, the plan fans toward the grove and a thin pool. Deep eaves, laterite, and rooms that can be entirely opened. Architecture as climate, not as object.',
    featured: false,
  );

  static const quietPenthouse = Project(
    slug: 'quiet-penthouse',
    title: 'Quiet Penthouse',
    location: 'Delhi',
    year: '2023',
    kind: PracticeKind.interiors,
    heroUrl:
        'https://images.unsplash.com/photo-1600607687644-aac4c3eac7f4?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600585153490-76fb20a32601?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A penthouse edited until only proportion and a few objects remain.',
    story:
        'We removed partitions that were doing no work. A stone spine runs the length of the plan; furniture is low; art is given wall. Evening light is warm and dimmable. Luxury as quiet, not as display.',
    featured: false,
  );

  static const plotSeventeen = Project(
    slug: 'plot-seventeen',
    title: 'Plot Seventeen',
    location: 'Goa',
    year: '2025',
    kind: PracticeKind.realEstate,
    heroUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A coastal plot selected for orientation, not for a listing photograph.',
    story:
        'We shortlisted six sites and held this one: west light filtered by casuarina, a legal access that will still work in ten years, and a contour that invites a court house. The overlay drawing showed a villa of 420 square metres without cutting the best trees. The client acquired. Architecture followed.',
    featured: true,
  );

  static const residencesAtAshok = Project(
    slug: 'residences-at-ashok',
    title: 'Residences at Ashok',
    location: 'Jaipur',
    year: '2024',
    kind: PracticeKind.realEstate,
    heroUrl:
        'https://images.unsplash.com/photo-1600585154363-67eb9e2e2099?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1600047509782-20d39509f26d?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'Eight residences on a historic-adjacent plot, positioned for a quiet hold.',
    story:
        'The brief was investment with a liveable grain. We advised on unit mix, court orientation, and a material language that would age in Rajasthan light. Sale was not the first conversation; composition was. The development is now occupied by families who intend to stay.',
    featured: false,
  );

  static const lakeEdgeParcel = Project(
    slug: 'lake-edge-parcel',
    title: 'Lake-Edge Parcel',
    location: 'Udaipur',
    year: '2023',
    kind: PracticeKind.realEstate,
    heroUrl:
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1400&q=80',
    ],
    lede: 'A lakeside parcel held for a future house, not rushed to market.',
    story:
        'Due diligence found an easement that would have blocked the view if ignored. We restructured the acquisition, drew a setback that protects the water edge, and recommended a pause before build. Real estate as stewardship of a long idea.',
    featured: false,
  );

  static const all = [
    houseOnTheRidge,
    courtyardResidence,
    northFacingApartment,
    studioHouseInteriors,
    groveVilla,
    quietPenthouse,
    plotSeventeen,
    residencesAtAshok,
    lakeEdgeParcel,
  ];

  static List<Project> get featured =>
      all.where((project) => project.featured).toList();

  static Project? bySlug(String slug) {
    for (final project in all) {
      if (project.slug == slug) return project;
    }
    return null;
  }

  static List<Project> byKind(PracticeKind kind) =>
      all.where((project) => project.kind == kind).toList();
}
