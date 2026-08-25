import 'dart:convert';

import 'package:web/web.dart' as web;

void applyRouteSeo({
  required String title,
  required String description,
  String? canonical,
  String? imageUrl,
  List<({String question, String answer})> faqs = const [],
}) {
  web.document.title = title;
  _setMeta(name: 'description', content: description);
  _setMeta(property: 'og:title', content: title);
  _setMeta(property: 'og:description', content: description);
  _setMeta(property: 'og:type', content: 'website');
  _setMeta(name: 'twitter:card', content: 'summary_large_image');
  _setMeta(name: 'twitter:title', content: title);
  _setMeta(name: 'twitter:description', content: description);
  if (canonical != null) {
    _setMeta(property: 'og:url', content: canonical);
    _setCanonical(canonical);
  }
  if (imageUrl != null) {
    _setMeta(property: 'og:image', content: imageUrl);
    _setMeta(name: 'twitter:image', content: imageUrl);
  }
  _setFaqJsonLd(faqs);
}

void _setFaqJsonLd(List<({String question, String answer})> faqs) {
  const id = 'biconcept-faq-jsonld';
  web.document.getElementById(id)?.remove();
  if (faqs.isEmpty) return;

  final payload = {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    'mainEntity': [
      for (final faq in faqs)
        {
          '@type': 'Question',
          'name': faq.question,
          'acceptedAnswer': {
            '@type': 'Answer',
            'text': faq.answer,
          },
        },
    ],
  };
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.id = id;
  script.type = 'application/ld+json';
  script.text = const JsonEncoder().convert(payload);
  web.document.head?.append(script);
}

void _setMeta({String? name, String? property, required String content}) {
  final selector = name != null ? 'meta[name="$name"]' : 'meta[property="$property"]';
  var el = web.document.querySelector(selector);
  if (el == null) {
    el = web.document.createElement('meta');
    if (name != null) {
      el.setAttribute('name', name);
    } else if (property != null) {
      el.setAttribute('property', property);
    }
    web.document.head?.append(el);
  }
  el.setAttribute('content', content);
}

void _setCanonical(String href) {
  var el = web.document.querySelector('link[rel="canonical"]');
  if (el == null) {
    el = web.document.createElement('link');
    el.setAttribute('rel', 'canonical');
    web.document.head?.append(el);
  }
  el.setAttribute('href', href);
}
