import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final membersSummary = ref.watch(membersSummaryProvider);
    final decisionsSummary = ref.watch(decisionsSummaryProvider);
    final meetingsSummary = ref.watch(meetingsSummaryProvider);

    return Scaffold(
      backgroundColor: RelunaTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(membersSummaryProvider);
              ref.invalidate(decisionsSummaryProvider);
              ref.invalidate(meetingsSummaryProvider);
            },
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header with gradient background
                _GradientHeader(
                  user: authState.currentUser,
                  onNotificationTap: () => context.router.push(const NotificationsRoute()),
                  onProfileTap: () => context.router.push(const ProfileRoute()),
                ),

                // Quick stats cards
                _QuickStatsRow(
                  membersSummary: membersSummary,
                  meetingsSummary: meetingsSummary,
                  decisionsSummary: decisionsSummary,
                ),

                const SizedBox(height: 16),

                // Progress card
                _ProgressCard(membersSummary: membersSummary),

                const SizedBox(height: 24),

                // Upcoming meetings section
                _UpcomingMeetingsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _GradientHeader({
    this.user,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB088),
            Color(0xFFFF8A5B),
            Color(0xFFFFAA7D),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Top row with profile and notification icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: LucideIcons.user,
                    onTap: onProfileTap,
                  ),
                  _CircleIconButton(
                    icon: LucideIcons.bell,
                    onTap: onNotificationTap,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Welcome text
              Text(
                'Welcome back, ${user?.name ?? 'User'}!',
                style: TextStyle(
                  fontFamily: RelunaTheme.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Here whats happening with your family governance today',
                style: TextStyle(
                  fontFamily: RelunaTheme.fontFamily,
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final AsyncValue<MembersSummary> membersSummary;
  final AsyncValue<MeetingsSummary> meetingsSummary;
  final AsyncValue<DecisionsSummary> decisionsSummary;

  const _QuickStatsRow({
    required this.membersSummary,
    required this.meetingsSummary,
    required this.decisionsSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      transform: Matrix4.translationValues(0, -20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: LucideIcons.circleCheck,
              title: 'Members',
              value: membersSummary.when(
                data: (s) => '${s.totalMembers} people',
                loading: () => '...',
                error: (_, __) => '-',
              ),
              onTap: () => context.router.push(const MembersRoute()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.circleCheck,
              title: 'Meetings',
              value: meetingsSummary.when(
                data: (s) => '${s.upcoming} upcoming',
                loading: () => '...',
                error: (_, __) => '-',
              ),
              onTap: () => context.router.push(const MeetingsRoute()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.circleCheck,
              title: 'Decisions',
              value: decisionsSummary.when(
                data: (s) => '${s.voting} opened',
                loading: () => '...',
                error: (_, __) => '-',
              ),
              onTap: () => context.router.push(const DecisionsRoute()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB088),
              Color(0xFFFF9966),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: RelunaTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontFamily: RelunaTheme.fontFamily,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final AsyncValue<MembersSummary> membersSummary;

  const _ProgressCard({required this.membersSummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RelunaTheme.textPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D0084).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock the full potential of your Family Governance',
                  style: TextStyle(
                    fontFamily: RelunaTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: RelunaTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                membersSummary.when(
                  data: (s) => Text(
                    '6/8 steps · Registered ${s.activeMembers} of ${s.totalMembers} member',
                    style: TextStyle(
                      fontFamily: RelunaTheme.fontFamily,
                      fontSize: 12,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                  loading: () => Text(
                    '...',
                    style: TextStyle(
                      fontFamily: RelunaTheme.fontFamily,
                      fontSize: 12,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _CircularProgress(progress: 0.70),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double progress;

  const _CircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(RelunaTheme.accentColor),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontFamily: RelunaTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: RelunaTheme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingMeetingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming meetings',
                style: TextStyle(
                  fontFamily: RelunaTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: RelunaTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.router.push(const MeetingsRoute()),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: RelunaTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: RelunaTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: RelunaTheme.accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meeting cards
          meetings.when(
            data: (meetingsList) {
              final upcoming = meetingsList
                  .where((m) => m.date.isAfter(DateTime.now()))
                  .take(4)
                  .toList();

              if (upcoming.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: RelunaTheme.textPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No upcoming meetings',
                      style: TextStyle(
                        fontFamily: RelunaTheme.fontFamily,
                        fontSize: 14,
                        color: RelunaTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: upcoming.map((meeting) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MeetingCard(meeting: meeting),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CupertinoActivityIndicator(),
              ),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(24),
              child: const Text('Failed to load meetings'),
            ),
          ),

          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;

  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: () => context.router.push(MeetingDetailRoute(meetingId: meeting.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: RelunaTheme.textPrimary.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D0084).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    style: TextStyle(
                      fontFamily: RelunaTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: RelunaTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(meeting.date)} · ${timeFormat.format(meeting.date)} — ${timeFormat.format(meeting.endTime)}',
                    style: TextStyle(
                      fontFamily: RelunaTheme.fontFamily,
                      fontSize: 13,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: RelunaTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
