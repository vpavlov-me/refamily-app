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
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final constitution = ref.watch(constitutionProvider);
    final membersSummary = ref.watch(membersSummaryProvider);
    final decisionsSummary = ref.watch(decisionsSummaryProvider);
    final meetingsSummary = ref.watch(meetingsSummaryProvider);
    final activities = ref.watch(activitiesProvider);
    final notificationsSummary = ref.watch(notificationsSummaryProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Dashboard',
      actions: [
        Stack(
          children: [
            AdaptiveIconButton(
              icon: isIOS ? CupertinoIcons.bell : Icons.notifications_outlined,
              onPressed: () => context.router.push(const NotificationsRoute()),
            ),
            notificationsSummary.when(
              data: (summary) => summary.unread > 0
                  ? Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: RelunaTheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${summary.unread}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(constitutionProvider);
          ref.invalidate(membersSummaryProvider);
          ref.invalidate(decisionsSummaryProvider);
          ref.invalidate(meetingsSummaryProvider);
          ref.invalidate(activitiesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _WelcomeSection(user: authState.currentUser),
              
              // Quick stats
              _QuickStats(
                decisionsSummary: decisionsSummary,
                meetingsSummary: meetingsSummary,
              ),
              
              // Constitution status card
              _ConstitutionCard(constitution: constitution),
              
              // Members summary card
              _MembersCard(membersSummary: membersSummary),
              
              // Recent activity
              _RecentActivity(activities: activities),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final User? user;

  const _WelcomeSection({this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.1),
            child: user?.avatar != null
                ? ClipOval(
                    child: Image.network(
                      user!.avatar!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RelunaTheme.accentColor,
                        ),
                      ),
                    ),
                  )
                : Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: RelunaTheme.accentColor,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 14,
                    color: RelunaTheme.textSecondary,
                  ),
                ),
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
                if (user?.role != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: RelunaTheme.getRoleColor(user!.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user!.role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: RelunaTheme.getRoleColor(user!.role),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final AsyncValue<DecisionsSummary> decisionsSummary;
  final AsyncValue<MeetingsSummary> meetingsSummary;

  const _QuickStats({
    required this.decisionsSummary,
    required this.meetingsSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.how_to_vote_outlined,
              label: 'Active Decisions',
              value: decisionsSummary.when(
                data: (s) => '${s.voting}',
                loading: () => '-',
                error: (_, __) => '-',
              ),
              color: RelunaTheme.accentColor,
              onTap: () => context.router.push(const DecisionsRoute()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.event_outlined,
              label: 'Upcoming Meetings',
              value: meetingsSummary.when(
                data: (s) => '${s.upcoming}',
                loading: () => '-',
                error: (_, __) => '-',
              ),
              color: RelunaTheme.info,
              onTap: () => context.router.push(const MeetingsRoute()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RelunaTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: RelunaTheme.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _ConstitutionCard extends StatelessWidget {
  final AsyncValue<Constitution> constitution;

  const _ConstitutionCard({required this.constitution});

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      onTap: () => context.router.push(const ConstitutionRoute()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RelunaTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: RelunaTheme.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Family Constitution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
              ),
              constitution.when(
                data: (c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelunaTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'v${c.version}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RelunaTheme.success,
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          constitution.when(
            data: (c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last edited ${_formatDate(c.lastEditedAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: RelunaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${c.lastEditedBy}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: RelunaTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RelunaTheme.accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: AdaptiveLoadingIndicator(size: 24)),
            error: (_, __) => const Text('Failed to load constitution'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}

class _MembersCard extends StatelessWidget {
  final AsyncValue<MembersSummary> membersSummary;

  const _MembersCard({required this.membersSummary});

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      onTap: () => context.router.push(const MembersRoute()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RelunaTheme.roleColors['Founder']!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.people_outline,
                  color: RelunaTheme.roleColors['Founder'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Family Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: RelunaTheme.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          membersSummary.when(
            data: (summary) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MemberStat(
                      label: 'Total',
                      value: '${summary.totalMembers}',
                    ),
                    _MemberStat(
                      label: 'Active',
                      value: '${summary.activeMembers}',
                    ),
                    _MemberStat(
                      label: 'Generations',
                      value: '${summary.generations}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: summary.byRole.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: RelunaTheme.getRoleColor(entry.key).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.value} ${entry.key}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: RelunaTheme.getRoleColor(entry.key),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            loading: () => const Center(child: AdaptiveLoadingIndicator(size: 24)),
            error: (_, __) => const Text('Failed to load members'),
          ),
        ],
      ),
    );
  }
}

class _MemberStat extends StatelessWidget {
  final String label;
  final String value;

  const _MemberStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: RelunaTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: RelunaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final AsyncValue<List<Activity>> activities;

  const _RecentActivity({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RelunaTheme.textPrimary,
            ),
          ),
        ),
        activities.when(
          data: (items) => items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No recent activity'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length > 5 ? 5 : items.length,
                  itemBuilder: (context, index) {
                    final activity = items[index];
                    return _ActivityItem(activity: activity);
                  },
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: AdaptiveLoadingIndicator()),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Failed to load activity'),
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({required this.activity});

  IconData get _icon {
    switch (activity.type) {
      case 'vote':
        return Icons.how_to_vote_outlined;
      case 'constitution':
        return Icons.description_outlined;
      case 'meeting':
        return Icons.event_outlined;
      case 'decision':
        return Icons.gavel_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'member':
        return Icons.person_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (activity.type) {
      case 'vote':
        return RelunaTheme.accentColor;
      case 'constitution':
        return RelunaTheme.info;
      case 'meeting':
        return RelunaTheme.success;
      case 'decision':
        return RelunaTheme.warning;
      case 'comment':
        return RelunaTheme.roleColors['Advisor']!;
      case 'member':
        return RelunaTheme.roleColors['Founder']!;
      default:
        return RelunaTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, size: 20, color: _color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: RelunaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: RelunaTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
