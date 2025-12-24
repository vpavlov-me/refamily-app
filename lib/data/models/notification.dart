class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String body; // Alias for message
  final bool isRead;
  final String priority;
  final String? actionUrl;
  final DateTime createdAt;
  final String? relatedId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    String? body,
    required this.isRead,
    required this.priority,
    this.actionUrl,
    required this.createdAt,
    this.relatedId,
  }) : body = body ?? message;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as String;
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: message,
      body: json['body'] as String? ?? message,
      isRead: json['isRead'] as bool,
      priority: json['priority'] as String,
      actionUrl: json['actionUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedId: json['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'body': body,
      'isRead': isRead,
      'priority': priority,
      'actionUrl': actionUrl,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? body,
    bool? isRead,
    String? priority,
    String? actionUrl,
    DateTime? createdAt,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

class NotificationsSummary {
  final int total;
  final int unread;
  final int highPriority;
  final int today;

  const NotificationsSummary({
    required this.total,
    required this.unread,
    required this.highPriority,
    this.today = 0,
  });

  factory NotificationsSummary.fromJson(Map<String, dynamic> json) {
    return NotificationsSummary(
      total: json['total'] as int,
      unread: json['unread'] as int,
      highPriority: json['highPriority'] as int,
      today: json['today'] as int? ?? 0,
    );
  }
}
