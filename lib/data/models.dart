import 'package:appwrite/models.dart' as models;
import 'package:biconcept_in/content/ncr_locations.dart';
import 'package:biconcept_in/content/projects.dart';
import 'package:biconcept_in/content/services.dart';
import 'package:biconcept_in/data/appwrite_config.dart';

Map<String, dynamic> rowFields(models.Row row) {
  final data = Map<String, dynamic>.from(row.data);
  data.removeWhere((key, _) => key.startsWith(r'$'));
  return data;
}

String rowString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) return '';
  return value.toString();
}

bool rowBool(Map<String, dynamic> data, String key) {
  final value = data[key];
  return value == true || value == 1 || value == 'true';
}

class MarketListing {
  const MarketListing({
    required this.id,
    required this.title,
    required this.developer,
    required this.city,
    required this.sector,
    required this.locality,
    required this.status,
    required this.typology,
    required this.priceBand,
    required this.summary,
    required this.sourceUrl,
    required this.sourceName,
    required this.published,
    required this.researchedAt,
  });

  final String id;
  final String title;
  final String developer;
  final String city;
  final String sector;
  final String locality;
  final String status;
  final String typology;
  final String priceBand;
  final String summary;
  final String sourceUrl;
  final String sourceName;
  final bool published;
  final String researchedAt;

  String get placeLabel => NcrLocations.labelFor(city: city, sector: sector);

  String get inquirePath {
    final params = <String, String>{
      'practice': 'real-estate',
      'listing': id,
      if (city.isNotEmpty) 'city': city,
      if (sector.isNotEmpty) 'sector': sector,
    };
    return Uri(path: '/inquire', queryParameters: params).toString();
  }

  factory MarketListing.fromRow(models.Row row) {
    final data = rowFields(row);
    return MarketListing(
      id: row.$id,
      title: rowString(data, 'title'),
      developer: rowString(data, 'developer'),
      city: rowString(data, 'city'),
      sector: rowString(data, 'sector'),
      locality: rowString(data, 'locality'),
      status: rowString(data, 'status'),
      typology: rowString(data, 'typology'),
      priceBand: rowString(data, 'priceBand'),
      summary: rowString(data, 'summary'),
      sourceUrl: rowString(data, 'sourceUrl'),
      sourceName: rowString(data, 'sourceName'),
      published: rowBool(data, 'published'),
      researchedAt: rowString(data, 'researchedAt'),
    );
  }

  Map<String, dynamic> toData() => {
        'title': title,
        'developer': developer,
        'city': city,
        'sector': sector,
        'locality': locality,
        'status': status,
        'typology': typology,
        'priceBand': priceBand,
        'summary': summary,
        'sourceUrl': sourceUrl,
        'sourceName': sourceName,
        'published': published,
        'researchedAt': researchedAt,
      };
}

class StudioLead {
  const StudioLead({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.sector,
    required this.practice,
    required this.projectType,
    required this.budgetBand,
    required this.message,
    required this.source,
    required this.status,
    required this.listingId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String sector;
  final String practice;
  final String projectType;
  final String budgetBand;
  final String message;
  final String source;
  final String status;
  final String listingId;
  final String createdAt;

  factory StudioLead.fromRow(models.Row row) {
    final data = rowFields(row);
    return StudioLead(
      id: row.$id,
      name: rowString(data, 'name'),
      phone: rowString(data, 'phone'),
      email: rowString(data, 'email'),
      city: rowString(data, 'city'),
      sector: rowString(data, 'sector'),
      practice: rowString(data, 'practice'),
      projectType: rowString(data, 'projectType'),
      budgetBand: rowString(data, 'budgetBand'),
      message: rowString(data, 'message'),
      source: rowString(data, 'source'),
      status: rowString(data, 'status'),
      listingId: rowString(data, 'listingId'),
      createdAt: row.$createdAt,
    );
  }
}

class ShowcaseRow {
  const ShowcaseRow({
    required this.id,
    required this.slug,
    required this.title,
    required this.location,
    required this.year,
    required this.kind,
    required this.lede,
    required this.story,
    required this.heroFileId,
    required this.published,
    required this.featured,
  });

  final String id;
  final String slug;
  final String title;
  final String location;
  final String year;
  final String kind;
  final String lede;
  final String story;
  final String heroFileId;
  final bool published;
  final bool featured;

  String get heroUrl => heroFileId.isEmpty
      ? 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1800&q=80'
      : AppwriteConfig.fileViewUrl(heroFileId);

  PracticeKind get practiceKind => switch (kind) {
        'interiors' => PracticeKind.interiors,
        'real-estate' => PracticeKind.realEstate,
        _ => PracticeKind.architecture,
      };

  Project toProject() {
    return Project(
      slug: slug,
      title: title,
      location: location,
      year: year,
      kind: practiceKind,
      heroUrl: heroUrl,
      gallery: const [],
      lede: lede,
      story: story,
      featured: featured,
    );
  }

  factory ShowcaseRow.fromRow(models.Row row) {
    final data = rowFields(row);
    return ShowcaseRow(
      id: row.$id,
      slug: rowString(data, 'slug'),
      title: rowString(data, 'title'),
      location: rowString(data, 'location'),
      year: rowString(data, 'year'),
      kind: rowString(data, 'kind'),
      lede: rowString(data, 'lede'),
      story: rowString(data, 'story'),
      heroFileId: rowString(data, 'heroFileId'),
      published: rowBool(data, 'published'),
      featured: rowBool(data, 'featured'),
    );
  }

  Map<String, dynamic> toData() => {
        'slug': slug,
        'title': title,
        'location': location,
        'year': year,
        'kind': kind,
        'lede': lede,
        'story': story,
        'heroFileId': heroFileId,
        'published': published,
        'featured': featured,
      };
}

class ServiceRow {
  const ServiceRow({
    required this.id,
    required this.slug,
    required this.label,
    required this.kicker,
    required this.headline,
    required this.lede,
    required this.published,
  });

  final String id;
  final String slug;
  final String label;
  final String kicker;
  final String headline;
  final String lede;
  final bool published;

  factory ServiceRow.fromRow(models.Row row) {
    final data = rowFields(row);
    return ServiceRow(
      id: row.$id,
      slug: rowString(data, 'slug'),
      label: rowString(data, 'label'),
      kicker: rowString(data, 'kicker'),
      headline: rowString(data, 'headline'),
      lede: rowString(data, 'lede'),
      published: rowBool(data, 'published'),
    );
  }

  Map<String, dynamic> toData() => {
        'slug': slug,
        'label': label,
        'kicker': kicker,
        'headline': headline,
        'lede': lede,
        'published': published,
      };
}

class StudioOffer {
  const StudioOffer({
    required this.id,
    required this.title,
    required this.summary,
    required this.ctaLabel,
    required this.href,
    required this.practice,
    required this.published,
  });

  final String id;
  final String title;
  final String summary;
  final String ctaLabel;
  final String href;
  final String practice;
  final bool published;

  factory StudioOffer.fromRow(models.Row row) {
    final data = rowFields(row);
    return StudioOffer(
      id: row.$id,
      title: rowString(data, 'title'),
      summary: rowString(data, 'summary'),
      ctaLabel: rowString(data, 'ctaLabel'),
      href: rowString(data, 'href'),
      practice: rowString(data, 'practice'),
      published: rowBool(data, 'published'),
    );
  }

  Map<String, dynamic> toData() => {
        'title': title,
        'summary': summary,
        'ctaLabel': ctaLabel,
        'href': href,
        'practice': practice,
        'published': published,
      };
}

class AgentJob {
  const AgentJob({
    required this.id,
    required this.agentId,
    required this.title,
    required this.status,
    required this.progress,
    required this.summary,
    required this.log,
    required this.payload,
    required this.startedAt,
    required this.finishedAt,
  });

  final String id;
  final String agentId;
  final String title;
  final String status;
  final int progress;
  final String summary;
  final String log;
  final String payload;
  final String startedAt;
  final String finishedAt;

  bool get isActive => status == 'queued' || status == 'running';

  factory AgentJob.fromRow(models.Row row) {
    final data = rowFields(row);
    return AgentJob(
      id: row.$id,
      agentId: rowString(data, 'agentId'),
      title: rowString(data, 'title'),
      status: rowString(data, 'status'),
      progress: int.tryParse(rowString(data, 'progress')) ??
          (data['progress'] is num ? (data['progress'] as num).toInt() : 0),
      summary: rowString(data, 'summary'),
      log: rowString(data, 'log'),
      payload: rowString(data, 'payload'),
      startedAt: rowString(data, 'startedAt'),
      finishedAt: rowString(data, 'finishedAt'),
    );
  }
}
