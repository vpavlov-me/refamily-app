import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final notificationsSummary = ref.watch(notificationsSummaryProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Notifications',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.checkmark_circle : Icons.done_all,
          onPressed: () {
            AdaptiveDialog.show(
              context: context,
              title: 'Mark All as Read',
              content: 'Are you sure you want to mark all notifications as read?',
              confirmText: 'Mark All Read',
              cancelText: 'Cancel',
              onConfirm: () {
                // Mark all as read
              },
            );
          },
        ),
      ],
      body: Column(
        children: [
          // Summary
          notificationsSummary.when(
            data: (summary) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Unread',
                      value: '${summary.unread}',
                      color: RelunaTheme.accentColor,
                      isSelected: _filter == 'Unread',
                      onTap: () => setState(() => _filter = _filter == 'Unread' ? 'All' : 'Unread'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Today',
                      value: '${summary.today}',
                      color: RelunaTheme.info,
                      isSelected: false,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total',
                      value: '${summary.total}',
                      color: RelunaTheme.textSecondary,
                      isSelected: false,
                      onTap: null,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Notifications list
          Expanded(
            child: notifications.when(
              data: (data) {
                var filtered = _filter == 'Unread'
                    ? data.where((n) => !n.isRead).toList()
                    : data;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIOS ? CupertinoIcons.bell : Icons.notifications_none,
                          size: 64,
                          color: RelunaTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'Unread'
                              ? 'No unread notifications'
                              : 'No notifications',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: RelunaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group notifications by date
                final grouped = <String, List<AppNotification>>{};
                for (final notification in filtered) {
                  final key = _getDateKey(notification.createdAt);
                  grouped[key] ??= [];
                  grouped[key]!.add(notification);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final key = grouped.keys.elementAt(index);
                    final items = grouped[key]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RelunaTheme.textSecondary,
                            ),
                          ),
                        ),
                        ...items.map((notification) => _NotificationCard(
                          notification: notification,
                          onTap: () => _handleNotificationTap(context, notification),
                        )),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: AdaptiveLoadingIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load notifications')),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case 'decision':
        if (notification.actionUrl != null) {
          final parts = notification.actionUrl!.split('/');
          if (parts.length >= 3) {
            context.router.push(DecisionDetailRoute(decisionId: parts.last));
          }
        }
        break;
      case 'meeting':
        if (notification.actionUrl != null) {
          final parts = notification.actionUrl!.split('/');
          if (parts.length >= 3) {
            context.router.push(MeetingDetailRoute(meetingId: parts.last));
          }
        }
        break;
      case 'constitution':
        context.router.push(const ConstitutionRoute());
        break;
      case 'member':
        context.router.push(const MembersRoute());
        break;
      default:
        break;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : RelunaTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : RelunaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : RelunaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.notification,
    this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'decision':
        return Icons.how_to_vote_outlined;
      case 'meeting':
        return Icons.event_outlined;
      case 'constitution':
        return Icons.description_outlined;
      case 'member':
        return Icons.person_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'reminder':
        return Icons.alarm_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (notification.type) {
      case 'decision':
        return RelunaTheme.accentColor;
      case 'meeting':
        return RelunaTheme.info;
      case 'constitution':
        return RelunaTheme.success;
      case 'member':
        return RelunaTheme.roleColors['Founder']!;
      case 'comment':
        return RelunaTheme.roleColors['Advisor']!;
      case 'reminder':
        return RelunaTheme.warning;
      default:
        return RelunaTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? RelunaTheme.surfaceLight
              : _color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? RelunaTheme.divider
                : _color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, size: 20, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: RelunaTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: RelunaTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('h:mm a').format(time);
    }
  }
}
