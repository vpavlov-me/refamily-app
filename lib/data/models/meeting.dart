class Meeting {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final String time; // Formatted time string for display
  final DateTime endTime;
  final String location;
  final bool isVirtual;
  final String? virtualLink;
  final String status;
  final String organizer;
  final List<MeetingAttendee> attendees;
  final List<AgendaItem> agenda;
  final List<MeetingDocument> documents;
  final String? notes;
  final DateTime createdAt;

  const Meeting({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.date,
    this.time = '',
    required this.endTime,
    required this.location,
    required this.isVirtual,
    this.virtualLink,
    required this.status,
    required this.organizer,
    required this.attendees,
    required this.agenda,
    required this.documents,
    this.notes,
    required this.createdAt,
  });

  int get durationMinutes => endTime.difference(date).inMinutes;
  
  bool get isUpcoming => date.isAfter(DateTime.now());
  
  int get confirmedAttendees => attendees.where((a) => a.status == 'Confirmed').length;

  factory Meeting.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    return Meeting(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? json['notes'] as String? ?? '',
      type: json['type'] as String,
      date: date,
      time: json['time'] as String? ?? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      isVirtual: json['isVirtual'] as bool,
      virtualLink: json['virtualLink'] as String?,
      status: json['status'] as String,
      organizer: json['organizer'] as String,
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((e) => MeetingAttendee.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      agenda: (json['agenda'] as List<dynamic>?)
          ?.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => MeetingDocument.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'endTime': endTime.toIso8601String(),
      'location': location,
      'isVirtual': isVirtual,
      'virtualLink': virtualLink,
      'status': status,
      'organizer': organizer,
      'attendees': attendees.map((e) => e.toJson()).toList(),
      'agenda': agenda.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MeetingAttendee {
  final String id;
  final String name;
  final String role;
  final String status;
  final String rsvp; // Alias for status

  const MeetingAttendee({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    String? rsvp,
  }) : rsvp = rsvp ?? status;

  factory MeetingAttendee.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String;
    return MeetingAttendee(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      status: status,
      rsvp: json['rsvp'] as String? ?? status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'status': status,
      'rsvp': rsvp,
    };
  }
}

class AgendaItem {
  final String id;
  final int order;
  final String title;
  final String description;
  final int duration;
  final String presenter;

  const AgendaItem({
    required this.id,
    required this.order,
    required this.title,
    this.description = '',
    required this.duration,
    required this.presenter,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      duration: json['duration'] as int,
      presenter: json['presenter'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'description': description,
      'duration': duration,
      'presenter': presenter,
    };
  }
}

class MeetingDocument {
  final String id;
  final String title;
  final String name; // Alias for title
  final String type;
  final String size;

  const MeetingDocument({
    required this.id,
    required this.title,
    String? name,
    required this.type,
    this.size = '',
  }) : name = name ?? title;

  factory MeetingDocument.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    return MeetingDocument(
      id: json['id'] as String,
      title: title,
      name: json['name'] as String? ?? title,
      type: json['type'] as String,
      size: json['size'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'type': type,
      'size': size,
    };
  }
}

class MeetingsSummary {
  final int total;
  final int upcoming;
  final int thisWeek;
  final int thisMonth;
  final int virtual;

  const MeetingsSummary({
    required this.total,
    required this.upcoming,
    required this.thisWeek,
    this.thisMonth = 0,
    required this.virtual,
  });

  factory MeetingsSummary.fromJson(Map<String, dynamic> json) {
    return MeetingsSummary(
      total: json['total'] as int,
      upcoming: json['upcoming'] as int,
      thisWeek: json['thisWeek'] as int,
      thisMonth: json['thisMonth'] as int? ?? json['thisWeek'] as int,
      virtual: json['virtual'] as int,
    );
  }
}
