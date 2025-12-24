import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  Map<String, dynamic>? _authData;
  Map<String, dynamic>? _constitutionData;
  Map<String, dynamic>? _constitutionVersionsData;
  Map<String, dynamic>? _membersData;
  Map<String, dynamic>? _decisionsData;
  Map<String, dynamic>? _meetingsData;
  Map<String, dynamic>? _notificationsData;
  Map<String, dynamic>? _activityData;

  Future<void> initialize() async {
    _authData = await _loadJson('assets/mock/auth.json');
    _constitutionData = await _loadJson('assets/mock/constitution_current.json');
    _constitutionVersionsData = await _loadJson('assets/mock/constitution_versions.json');
    _membersData = await _loadJson('assets/mock/members.json');
    _decisionsData = await _loadJson('assets/mock/decisions.json');
    _meetingsData = await _loadJson('assets/mock/meetings.json');
    _notificationsData = await _loadJson('assets/mock/notifications.json');
    _activityData = await _loadJson('assets/mock/activity.json');
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final String response = await rootBundle.loadString(path);
    return json.decode(response) as Map<String, dynamic>;
  }

  // Auth
  Future<User?> authenticateUser(String email, String password) async {
    if (_authData == null) await initialize();
    
    final users = _authData!['users'] as List<dynamic>;
    for (final userData in users) {
      final user = userData as Map<String, dynamic>;
      if (user['email'] == email && user['password'] == password) {
        return User.fromJson(user);
      }
    }
    return null;
  }

  Future<User> getCurrentUser() async {
    if (_authData == null) await initialize();
    return User.fromJson(_authData!['currentUser'] as Map<String, dynamic>);
  }

  Future<List<User>> getAllUsers() async {
    if (_authData == null) await initialize();
    final users = _authData!['users'] as List<dynamic>;
    return users.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Constitution
  Future<Constitution> getConstitution() async {
    if (_constitutionData == null) await initialize();
    return Constitution.fromJson(_constitutionData!);
  }

  Future<List<ConstitutionVersion>> getConstitutionVersions() async {
    if (_constitutionVersionsData == null) await initialize();
    final versions = _constitutionVersionsData!['versions'] as List<dynamic>;
    return versions.map((e) => ConstitutionVersion.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Members
  Future<List<Member>> getMembers() async {
    if (_membersData == null) await initialize();
    final members = _membersData!['members'] as List<dynamic>;
    return members.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Member?> getMemberById(String id) async {
    final members = await getMembers();
    return members.where((m) => m.id == id).firstOrNull;
  }

  Future<MembersSummary> getMembersSummary() async {
    if (_membersData == null) await initialize();
    return MembersSummary.fromJson(_membersData!['summary'] as Map<String, dynamic>);
  }

  // Decisions
  Future<List<Decision>> getDecisions() async {
    if (_decisionsData == null) await initialize();
    final decisions = _decisionsData!['decisions'] as List<dynamic>;
    return decisions.map((e) => Decision.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Decision?> getDecisionById(String id) async {
    final decisions = await getDecisions();
    return decisions.where((d) => d.id == id).firstOrNull;
  }

  Future<DecisionsSummary> getDecisionsSummary() async {
    if (_decisionsData == null) await initialize();
    return DecisionsSummary.fromJson(_decisionsData!['summary'] as Map<String, dynamic>);
  }

  // Meetings
  Future<List<Meeting>> getMeetings() async {
    if (_meetingsData == null) await initialize();
    final meetings = _meetingsData!['meetings'] as List<dynamic>;
    return meetings.map((e) => Meeting.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Meeting?> getMeetingById(String id) async {
    final meetings = await getMeetings();
    return meetings.where((m) => m.id == id).firstOrNull;
  }

  Future<MeetingsSummary> getMeetingsSummary() async {
    if (_meetingsData == null) await initialize();
    return MeetingsSummary.fromJson(_meetingsData!['summary'] as Map<String, dynamic>);
  }

  // Notifications
  Future<List<AppNotification>> getNotifications() async {
    if (_notificationsData == null) await initialize();
    final notifications = _notificationsData!['notifications'] as List<dynamic>;
    return notifications.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<NotificationsSummary> getNotificationsSummary() async {
    if (_notificationsData == null) await initialize();
    return NotificationsSummary.fromJson(_notificationsData!['summary'] as Map<String, dynamic>);
  }

  // Activity
  Future<List<Activity>> getActivities() async {
    if (_activityData == null) await initialize();
    final activities = _activityData!['activities'] as List<dynamic>;
    return activities.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList();
  }
}
