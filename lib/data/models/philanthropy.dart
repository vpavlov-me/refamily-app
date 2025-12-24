import 'package:flutter/material.dart';

enum CauseCategory {
  education,
  health,
  environment,
  arts,
  poverty,
  community,
  disaster,
  other,
}

enum DonationStatus {
  planned,
  pledged,
  completed,
  recurring,
}

class PhilanthropicCause {
  final String id;
  final String name;
  final String description;
  final CauseCategory category;
  final String? organizationName;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? imageUrl;
  final bool isFamilyPriority;
  final List<String> supporterIds;
  
  const PhilanthropicCause({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.organizationName,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.imageUrl,
    this.isFamilyPriority = false,
    this.supporterIds = const [],
  });
  
  double get progressPercent => 
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  
  IconData get categoryIcon {
    switch (category) {
      case CauseCategory.education:
        return Icons.school;
      case CauseCategory.health:
        return Icons.local_hospital;
      case CauseCategory.environment:
        return Icons.eco;
      case CauseCategory.arts:
        return Icons.palette;
      case CauseCategory.poverty:
        return Icons.people;
      case CauseCategory.community:
        return Icons.location_city;
      case CauseCategory.disaster:
        return Icons.warning;
      case CauseCategory.other:
        return Icons.volunteer_activism;
    }
  }
  
  String get categoryLabel {
    switch (category) {
      case CauseCategory.education:
        return 'Education';
      case CauseCategory.health:
        return 'Healthcare';
      case CauseCategory.environment:
        return 'Environment';
      case CauseCategory.arts:
        return 'Arts & Culture';
      case CauseCategory.poverty:
        return 'Poverty Relief';
      case CauseCategory.community:
        return 'Community';
      case CauseCategory.disaster:
        return 'Disaster Relief';
      case CauseCategory.other:
        return 'Other';
    }
  }
}

class Donation {
  final String id;
  final String causeId;
  final String causeName;
  final String donorId;
  final String donorName;
  final double amount;
  final DonationStatus status;
  final DateTime date;
  final String? notes;
  final bool isAnonymous;
  final bool isRecurring;
  final String? recurringFrequency;
  
  const Donation({
    required this.id,
    required this.causeId,
    required this.causeName,
    required this.donorId,
    required this.donorName,
    required this.amount,
    required this.status,
    required this.date,
    this.notes,
    this.isAnonymous = false,
    this.isRecurring = false,
    this.recurringFrequency,
  });
  
  Color get statusColor {
    switch (status) {
      case DonationStatus.planned:
        return Colors.blue;
      case DonationStatus.pledged:
        return Colors.orange;
      case DonationStatus.completed:
        return Colors.green;
      case DonationStatus.recurring:
        return Colors.purple;
    }
  }
}

class PhilanthropySummary {
  final double totalDonated;
  final double yearlyDonated;
  final int causesSupported;
  final int activeCampaigns;
  final Map<CauseCategory, double> allocationByCategory;
  
  const PhilanthropySummary({
    required this.totalDonated,
    required this.yearlyDonated,
    required this.causesSupported,
    required this.activeCampaigns,
    required this.allocationByCategory,
  });
}
