import 'package:flutter/material.dart';

enum AnnouncementType {
  general,
  urgent,
  event,
  decision,
  celebration,
  reminder,
}

enum AnnouncementPriority {
  low,
  normal,
  high,
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final AnnouncementType type;
  final AnnouncementPriority priority;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isPinned;
  final List<String> readByIds;
  final List<String>? targetAudienceIds;
  final List<String> attachmentUrls;
  
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.priority = AnnouncementPriority.normal,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    this.expiresAt,
    this.isPinned = false,
    this.readByIds = const [],
    this.targetAudienceIds,
    this.attachmentUrls = const [],
  });
  
  IconData get typeIcon {
    switch (type) {
      case AnnouncementType.general:
        return Icons.campaign;
      case AnnouncementType.urgent:
        return Icons.priority_high;
      case AnnouncementType.event:
        return Icons.event;
      case AnnouncementType.decision:
        return Icons.how_to_vote;
      case AnnouncementType.celebration:
        return Icons.celebration;
      case AnnouncementType.reminder:
        return Icons.alarm;
    }
  }
  
  Color get typeColor {
    switch (type) {
      case AnnouncementType.general:
        return Colors.blue;
      case AnnouncementType.urgent:
        return Colors.red;
      case AnnouncementType.event:
        return Colors.purple;
      case AnnouncementType.decision:
        return Colors.orange;
      case AnnouncementType.celebration:
        return Colors.pink;
      case AnnouncementType.reminder:
        return Colors.teal;
    }
  }
  
  String get typeLabel {
    switch (type) {
      case AnnouncementType.general:
        return 'General';
      case AnnouncementType.urgent:
        return 'Urgent';
      case AnnouncementType.event:
        return 'Event';
      case AnnouncementType.decision:
        return 'Decision';
      case AnnouncementType.celebration:
        return 'Celebration';
      case AnnouncementType.reminder:
        return 'Reminder';
    }
  }
}

class FamilyMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String? replyToId;
  final List<String> attachmentUrls;
  
  const FamilyMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.replyToId,
    this.attachmentUrls = const [],
  });
}

class CommunicationSummary {
  final int unreadAnnouncements;
  final int unreadMessages;
  final int pinnedAnnouncements;
  final int urgentItems;
  
  const CommunicationSummary({
    required this.unreadAnnouncements,
    required this.unreadMessages,
    required this.pinnedAnnouncements,
    required this.urgentItems,
  });
}
