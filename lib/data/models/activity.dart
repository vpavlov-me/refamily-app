class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final String actor;
  final String? actorAvatar;
  final DateTime timestamp;
  final String? relatedId;
  final String? relatedType;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actor,
    this.actorAvatar,
    required this.timestamp,
    this.relatedId,
    this.relatedType,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      actor: json['actor'] as String,
      actorAvatar: json['actorAvatar'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'actor': actor,
      'actorAvatar': actorAvatar,
      'timestamp': timestamp.toIso8601String(),
      'relatedId': relatedId,
      'relatedType': relatedType,
    };
  }
}
