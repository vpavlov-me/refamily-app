import 'package:flutter/material.dart';

enum CourseCategory {
  familyGovernance,
  financialLiteracy,
  leadership,
  communication,
  succession,
  philanthropy,
  legal,
  wellness,
}

enum CourseStatus {
  available,
  inProgress,
  completed,
  locked,
}

class Course {
  final String id;
  final String title;
  final String description;
  final CourseCategory category;
  final CourseStatus status;
  final int totalLessons;
  final int completedLessons;
  final int durationMinutes;
  final String? instructor;
  final String? thumbnailUrl;
  final DateTime? dueDate;
  final bool isRequired;
  final List<String> tags;
  
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.totalLessons,
    this.completedLessons = 0,
    required this.durationMinutes,
    this.instructor,
    this.thumbnailUrl,
    this.dueDate,
    this.isRequired = false,
    this.tags = const [],
  });
  
  double get progressPercent => 
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
  
  IconData get categoryIcon {
    switch (category) {
      case CourseCategory.familyGovernance:
        return Icons.account_balance;
      case CourseCategory.financialLiteracy:
        return Icons.attach_money;
      case CourseCategory.leadership:
        return Icons.emoji_people;
      case CourseCategory.communication:
        return Icons.forum;
      case CourseCategory.succession:
        return Icons.swap_horiz;
      case CourseCategory.philanthropy:
        return Icons.volunteer_activism;
      case CourseCategory.legal:
        return Icons.gavel;
      case CourseCategory.wellness:
        return Icons.favorite;
    }
  }
  
  String get categoryLabel {
    switch (category) {
      case CourseCategory.familyGovernance:
        return 'Family Governance';
      case CourseCategory.financialLiteracy:
        return 'Financial Literacy';
      case CourseCategory.leadership:
        return 'Leadership';
      case CourseCategory.communication:
        return 'Communication';
      case CourseCategory.succession:
        return 'Succession';
      case CourseCategory.philanthropy:
        return 'Philanthropy';
      case CourseCategory.legal:
        return 'Legal';
      case CourseCategory.wellness:
        return 'Wellness';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case CourseStatus.available:
        return Colors.blue;
      case CourseStatus.inProgress:
        return Colors.orange;
      case CourseStatus.completed:
        return Colors.green;
      case CourseStatus.locked:
        return Colors.grey;
    }
  }
}

class EducationProgress {
  final int totalCourses;
  final int completedCourses;
  final int inProgressCourses;
  final int totalMinutesLearned;
  final List<String> earnedBadges;
  
  const EducationProgress({
    required this.totalCourses,
    required this.completedCourses,
    required this.inProgressCourses,
    required this.totalMinutesLearned,
    this.earnedBadges = const [],
  });
  
  double get completionRate => 
      totalCourses > 0 ? (completedCourses / totalCourses) * 100 : 0;
}
