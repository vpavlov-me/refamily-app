import 'package:flutter/material.dart';

enum ConflictType {
  financial,
  governance,
  interpersonal,
  succession,
  business,
  property,
  other,
}

enum ConflictStatus {
  reported,
  underReview,
  inMediation,
  resolved,
  escalated,
}

enum ConflictPriority {
  low,
  medium,
  high,
  urgent,
}

class Conflict {
  final String id;
  final String title;
  final String description;
  final ConflictType type;
  final ConflictStatus status;
  final ConflictPriority priority;
  final List<String> involvedPartyIds;
  final List<String> involvedPartyNames;
  final String? mediatorId;
  final String? mediatorName;
  final DateTime reportedDate;
  final DateTime? resolvedDate;
  final String? resolution;
  final List<ConflictNote> notes;
  
  const Conflict({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    required this.involvedPartyIds,
    required this.involvedPartyNames,
    this.mediatorId,
    this.mediatorName,
    required this.reportedDate,
    this.resolvedDate,
    this.resolution,
    this.notes = const [],
  });
  
  IconData get typeIcon {
    switch (type) {
      case ConflictType.financial:
        return Icons.attach_money;
      case ConflictType.governance:
        return Icons.gavel;
      case ConflictType.interpersonal:
        return Icons.people;
      case ConflictType.succession:
        return Icons.swap_horiz;
      case ConflictType.business:
        return Icons.business;
      case ConflictType.property:
        return Icons.home;
      case ConflictType.other:
        return Icons.help_outline;
    }
  }
  
  String get typeLabel {
    switch (type) {
      case ConflictType.financial:
        return 'Financial';
      case ConflictType.governance:
        return 'Governance';
      case ConflictType.interpersonal:
        return 'Interpersonal';
      case ConflictType.succession:
        return 'Succession';
      case ConflictType.business:
        return 'Business';
      case ConflictType.property:
        return 'Property';
      case ConflictType.other:
        return 'Other';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case ConflictStatus.reported:
        return Colors.blue;
      case ConflictStatus.underReview:
        return Colors.orange;
      case ConflictStatus.inMediation:
        return Colors.purple;
      case ConflictStatus.resolved:
        return Colors.green;
      case ConflictStatus.escalated:
        return Colors.red;
    }
  }
  
  Color get priorityColor {
    switch (priority) {
      case ConflictPriority.low:
        return Colors.green;
      case ConflictPriority.medium:
        return Colors.orange;
      case ConflictPriority.high:
        return Colors.deepOrange;
      case ConflictPriority.urgent:
        return Colors.red;
    }
  }
}

class ConflictNote {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final bool isPrivate;
  
  const ConflictNote({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isPrivate = false,
  });
}

class ConflictsSummary {
  final int total;
  final int active;
  final int resolved;
  final int urgent;
  
  const ConflictsSummary({
    required this.total,
    required this.active,
    required this.resolved,
    required this.urgent,
  });
}
