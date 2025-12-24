import 'package:flutter/material.dart';

enum SuccessionRole {
  ceo,
  chairman,
  trustee,
  boardMember,
  familyCouncil,
  mentor,
  advisor,
}

enum PlanStatus {
  draft,
  active,
  underReview,
  completed,
  archived,
}

class SuccessionPlan {
  final String id;
  final String title;
  final String description;
  final SuccessionRole role;
  final PlanStatus status;
  final String currentHolderId;
  final String currentHolderName;
  final String? successorId;
  final String? successorName;
  final DateTime targetDate;
  final List<SuccessionMilestone> milestones;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  const SuccessionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.role,
    required this.status,
    required this.currentHolderId,
    required this.currentHolderName,
    this.successorId,
    this.successorName,
    required this.targetDate,
    this.milestones = const [],
    required this.createdAt,
    required this.lastUpdated,
  });
  
  double get progressPercent {
    if (milestones.isEmpty) return 0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return (completed / milestones.length) * 100;
  }
  
  IconData get roleIcon {
    switch (role) {
      case SuccessionRole.ceo:
        return Icons.business_center;
      case SuccessionRole.chairman:
        return Icons.chair;
      case SuccessionRole.trustee:
        return Icons.account_balance;
      case SuccessionRole.boardMember:
        return Icons.groups;
      case SuccessionRole.familyCouncil:
        return Icons.family_restroom;
      case SuccessionRole.mentor:
        return Icons.school;
      case SuccessionRole.advisor:
        return Icons.psychology;
    }
  }
  
  String get roleLabel {
    switch (role) {
      case SuccessionRole.ceo:
        return 'CEO';
      case SuccessionRole.chairman:
        return 'Chairman';
      case SuccessionRole.trustee:
        return 'Trustee';
      case SuccessionRole.boardMember:
        return 'Board Member';
      case SuccessionRole.familyCouncil:
        return 'Family Council';
      case SuccessionRole.mentor:
        return 'Mentor';
      case SuccessionRole.advisor:
        return 'Advisor';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case PlanStatus.draft:
        return Colors.grey;
      case PlanStatus.active:
        return Colors.blue;
      case PlanStatus.underReview:
        return Colors.orange;
      case PlanStatus.completed:
        return Colors.green;
      case PlanStatus.archived:
        return Colors.blueGrey;
    }
  }
}

class SuccessionMilestone {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedDate;
  
  const SuccessionMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.isCompleted = false,
    this.completedDate,
  });
}

class SuccessionSummary {
  final int totalPlans;
  final int activePlans;
  final int pendingTransitions;
  final int completedTransitions;
  
  const SuccessionSummary({
    required this.totalPlans,
    required this.activePlans,
    required this.pendingTransitions,
    required this.completedTransitions,
  });
}
