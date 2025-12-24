import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/shared.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final authState = ref.watch(authStateProvider);
    final constitution = ref.watch(constitutionProvider);
    final membersSummary = ref.watch(membersSummaryProvider);
    final decisionsSummary = ref.watch(decisionsSummaryProvider);
    final meetingsSummary = ref.watch(meetingsSummaryProvider);
    final activities = ref.watch(activitiesProvider);
    final notificationsSummary = ref.watch(notificationsSummaryProvider);

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.router.push(const NotificationsRoute()),
            ),
            notificationsSummary.when(
              data: (summary) => summary.unread > 0
                  ? Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.destructive,
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
    final theme = ShadTheme.of(context);
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
          ShadAvatar(
            user?.avatar ?? 'placeholder',
            size: const Size(56, 56),
            placeholder: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                if (user?.role != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: RoleBadge(role: user!.role),
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
            child: StatCard(
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
            child: StatCard(
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

class _ConstitutionCard extends StatelessWidget {
  final AsyncValue<Constitution> constitution;

  const _ConstitutionCard({required this.constitution});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return AppCard(
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
              Expanded(
                child: Text(
                  'Family Constitution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
              constitution.when(
                data: (c) => ShadBadge.secondary(
                  child: Text('v${c.version}'),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${c.lastEditedBy}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.mutedForeground.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () => context.router.push(const ConstitutionRoute()),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Open'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: AppLoadingIndicator(size: 24)),
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
    final theme = ShadTheme.of(context);
    
    return AppCard(
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
              Expanded(
                child: Text(
                  'Family Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.mutedForeground,
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
                    _MemberStat(label: 'Total', value: '${summary.totalMembers}'),
                    _MemberStat(label: 'Active', value: '${summary.activeMembers}'),
                    _MemberStat(label: 'Generations', value: '${summary.generations}'),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: summary.byRole.entries.map((entry) {
                    return RoleBadge(role: '${entry.value} ${entry.key}');
                  }).toList(),
                ),
              ],
            ),
            loading: () => const Center(child: AppLoadingIndicator(size: 24)),
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
    final theme = ShadTheme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.foreground,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.mutedForeground,
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
        const SectionHeader(title: 'Recent Activity'),
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
                    return ActivityItem(
                      title: activity.title,
                      description: activity.description,
                      type: activity.type,
                      timestamp: activity.timestamp,
                    );
                  },
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: AppLoadingIndicator()),
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
