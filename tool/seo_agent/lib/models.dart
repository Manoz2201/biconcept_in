class PageCopy {
  PageCopy({
    required this.path,
    required this.title,
    required this.description,
    required this.h1,
    required this.keywords,
    required this.faqs,
  });

  final String path;
  String title;
  String description;
  String h1;
  List<String> keywords;
  List<FaqCopy> faqs;

  factory PageCopy.fromJson(Map<String, dynamic> json) {
    return PageCopy(
      path: json['path'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      h1: json['h1'] as String? ?? '',
      keywords: [
        for (final item in json['keywords'] as List? ?? const []) item.toString(),
      ],
      faqs: [
        for (final item in json['faqs'] as List? ?? const [])
          if (item is Map<String, dynamic>) FaqCopy.fromJson(item),
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
}

class FaqCopy {
  FaqCopy({required this.question, required this.answer});

  final String question;
  final String answer;

  factory FaqCopy.fromJson(Map<String, dynamic> json) {
    return FaqCopy(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class PageProposal {
  PageProposal({
    required this.path,
    required this.change,
    required this.reason,
    this.title,
    this.description,
    this.h1,
    this.keywords,
    this.faqs,
  });

  final String path;
  final bool change;
  final String reason;
  final String? title;
  final String? description;
  final String? h1;
  final List<String>? keywords;
  final List<FaqCopy>? faqs;

  factory PageProposal.fromJson(Map<String, dynamic> json) {
    return PageProposal(
      path: json['path'] as String,
      change: json['change'] == true,
      reason: json['reason'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      h1: json['h1'] as String?,
      keywords: json['keywords'] is List
          ? [for (final item in json['keywords'] as List) item.toString()]
          : null,
      faqs: json['faqs'] is List
          ? [
              for (final item in json['faqs'] as List)
                if (item is Map<String, dynamic>) FaqCopy.fromJson(item),
            ]
          : null,
    );
  }
}

class SerpSnippet {
  const SerpSnippet({
    required this.query,
    required this.title,
    required this.link,
    required this.snippet,
  });

  final String query;
  final String title;
  final String link;
  final String snippet;

  Map<String, dynamic> toJson() => {
        'query': query,
        'title': title,
        'link': link,
        'snippet': snippet,
      };
}

class ChangeRecord {
  const ChangeRecord({
    required this.path,
    required this.reason,
    required this.before,
    required this.after,
  });

  final String path;
  final String reason;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;

  Map<String, dynamic> toJson() => {
        'path': path,
        'reason': reason,
        'before': before,
        'after': after,
      };
}
