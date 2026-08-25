import 'dart:convert';

import 'package:flutter/services.dart';

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class PageSeo {
  const PageSeo({
    required this.path,
    required this.title,
    required this.description,
    required this.h1,
    this.keywords = const [],
    this.faqs = const [],
  });

  final String path;
  final String title;
  final String description;
  final String h1;
  final List<String> keywords;
  final List<FaqItem> faqs;

  factory PageSeo.fromJson(Map<String, dynamic> json) {
    return PageSeo(
      path: json['path'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      h1: json['h1'] as String? ?? '',
      keywords: [
        for (final item in json['keywords'] as List? ?? const []) item.toString(),
      ],
      faqs: [
        for (final item in json['faqs'] as List? ?? const [])
          if (item is Map<String, dynamic>) FaqItem.fromJson(item),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'description': description,
        'h1': h1,
        'keywords': keywords,
        'faqs': [for (final faq in faqs) faq.toJson()],
      };

  PageSeo copyWith({
    String? title,
    String? description,
    String? h1,
    List<String>? keywords,
    List<FaqItem>? faqs,
  }) {
    return PageSeo(
      path: path,
      title: title ?? this.title,
      description: description ?? this.description,
      h1: h1 ?? this.h1,
      keywords: keywords ?? this.keywords,
      faqs: faqs ?? this.faqs,
    );
  }
}

/// Ranking copy loaded from [assets/seo/pages.json] so the daily SEO agent
/// can rewrite titles, meta, H1s, and FAQs without a UI change.
///
/// Search Console is not wired yet (needs a live, verified domain).
abstract final class SiteSeo {
  static const assetPath = 'assets/seo/pages.json';

  static List<PageSeo> _pages = List<PageSeo>.unmodifiable(_fallback);

  static List<PageSeo> get pages => _pages;

  static PageSeo get home => forPath('/');
  static PageSeo get architecture => forPath('/architecture');
  static PageSeo get interiors => forPath('/interiors');
  static PageSeo get realEstate => forPath('/real-estate');
  static PageSeo get work => forPath('/work');
  static PageSeo get studio => forPath('/studio');
  static PageSeo get inquire => forPath('/inquire');

  static Future<void> load() async {
    final raw = await rootBundle.loadString(assetPath);
    loadFromString(raw);
  }

  static void loadFromString(String raw) {
    _pages = List<PageSeo>.unmodifiable(parsePagesJson(raw));
  }

  static List<PageSeo> parsePagesJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['pages'] as List? ?? const [];
    return [
      for (final item in list)
        if (item is Map<String, dynamic>) PageSeo.fromJson(item),
    ];
  }

  static PageSeo forPath(String path) {
    for (final page in _pages) {
      if (page.path == path) return page;
    }
    if (path.startsWith('/work/')) {
      return forPath('/work').copyWith(
        title: 'Project — BiConcept',
        description: 'A BiConcept case study in architecture, interiors, or real estate.',
        h1: 'Case study.',
        faqs: const [],
      );
    }
    return home;
  }
}

const _fallback = <PageSeo>[
  PageSeo(
    path: '/',
    title: 'BiConcept — Architecture, Interiors & Real Estate',
    description:
        'BiConcept conceives architecture, interior design, and real estate as one idea. A conceptual studio for homes, developments, and land across India.',
    h1: 'One concept. Every scale.',
  ),
];
