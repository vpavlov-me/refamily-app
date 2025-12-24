class Constitution {
  final String id;
  final String version;
  final String title;
  final String preamble;
  final DateTime lastEditedAt;
  final String lastEditedBy;
  final String status;
  final List<ConstitutionSection> sections;

  const Constitution({
    required this.id,
    required this.version,
    required this.title,
    required this.preamble,
    required this.lastEditedAt,
    required this.lastEditedBy,
    required this.status,
    required this.sections,
  });

  factory Constitution.fromJson(Map<String, dynamic> json) {
    return Constitution(
      id: json['id'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      preamble: json['preamble'] as String? ?? '',
      lastEditedAt: DateTime.parse(json['lastEditedAt'] as String),
      lastEditedBy: json['lastEditedBy'] as String,
      status: json['status'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ConstitutionSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'title': title,
      'preamble': preamble,
      'lastEditedAt': lastEditedAt.toIso8601String(),
      'lastEditedBy': lastEditedBy,
      'status': status,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }

  Constitution copyWith({
    String? id,
    String? version,
    String? title,
    String? preamble,
    DateTime? lastEditedAt,
    String? lastEditedBy,
    String? status,
    List<ConstitutionSection>? sections,
  }) {
    return Constitution(
      id: id ?? this.id,
      version: version ?? this.version,
      title: title ?? this.title,
      preamble: preamble ?? this.preamble,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      status: status ?? this.status,
      sections: sections ?? this.sections,
    );
  }
}

class ConstitutionSection {
  final String id;
  final int order;
  final String title;
  final String content;
  final DateTime lastEditedAt;
  final List<String> articles;

  const ConstitutionSection({
    required this.id,
    required this.order,
    required this.title,
    required this.content,
    required this.lastEditedAt,
    this.articles = const [],
  });

  factory ConstitutionSection.fromJson(Map<String, dynamic> json) {
    return ConstitutionSection(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      lastEditedAt: DateTime.parse(json['lastEditedAt'] as String),
      articles: (json['articles'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'content': content,
      'lastEditedAt': lastEditedAt.toIso8601String(),
      'articles': articles,
    };
  }

  ConstitutionSection copyWith({
    String? id,
    int? order,
    String? title,
    String? content,
    DateTime? lastEditedAt,
    List<String>? articles,
  }) {
    return ConstitutionSection(
      id: id ?? this.id,
      order: order ?? this.order,
      title: title ?? this.title,
      content: content ?? this.content,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      articles: articles ?? this.articles,
    );
  }
}

class ConstitutionVersion {
  final String id;
  final String version;
  final String status;
  final DateTime publishedAt;
  final String publishedBy;
  final String changesSummary;
  final List<String> sectionsChanged;

  const ConstitutionVersion({
    required this.id,
    required this.version,
    required this.status,
    required this.publishedAt,
    required this.publishedBy,
    required this.changesSummary,
    required this.sectionsChanged,
  });

  factory ConstitutionVersion.fromJson(Map<String, dynamic> json) {
    return ConstitutionVersion(
      id: json['id'] as String,
      version: json['version'] as String,
      status: json['status'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String? ?? json['createdAt'] as String),
      publishedBy: json['publishedBy'] as String? ?? json['createdBy'] as String,
      changesSummary: json['changesSummary'] as String? ?? json['summary'] as String? ?? '',
      sectionsChanged: (json['sectionsChanged'] as List<dynamic>?)?.cast<String>() ?? 
          (json['changes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
