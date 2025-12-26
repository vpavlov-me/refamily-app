import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import 'create_meeting_screen.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends ConsumerState<MeetingsScreen> {
  @override
  Widget build(BuildContext context) {
    final meetings = ref.watch(meetingsProvider);

    return AppScaffold(
      title: 'Meetings',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              Platform.isIOS
                  ? CupertinoPageRoute(
                      builder: (context) => const CreateMeetingScreen(),
                    )
                  : MaterialPageRoute(
                      builder: (context) => const CreateMeetingScreen(),
                    ),
            );
          },
        ),
      ],
      body: meetings.when(
        data: (data) {
          final upcomingMeetings = data
              .where((m) => m.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          return upcomingMeetings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: RelunaTheme.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No upcoming meetings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: RelunaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: upcomingMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = upcomingMeetings[index];
                    return _MeetingCard(
                      meeting: meeting,
                      onTap: () => context.router.push(MeetingDetailRoute(meetingId: meeting.id)),
                    );
                  },
                );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load meetings')),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;

  const _MeetingCard({
    required this.meeting,
    this.onTap,
  });

  Color get _typeColor {
    switch (meeting.type) {
      case 'Family Council':
        return RelunaTheme.accentColor;
      case 'Committee':
        return RelunaTheme.info;
      case 'Emergency':
        return RelunaTheme.error;
      default:
        return RelunaTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPast = meeting.date.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPast ? RelunaTheme.divider : _typeColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    meeting.type,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _typeColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: RelunaTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Past',
                      style: TextStyle(
                        fontSize: 11,
                        color: RelunaTheme.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meeting.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPast ? RelunaTheme.textSecondary : RelunaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isPast ? RelunaTheme.textTertiary : RelunaTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('EEE, MMM d').format(meeting.date)} at ${meeting.time}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isPast ? RelunaTheme.textTertiary : RelunaTheme.textSecondary,
                  ),
                ),
              ],
            ),
            if (meeting.location != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: isPast ? RelunaTheme.textTertiary : RelunaTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      meeting.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? RelunaTheme.textTertiary : RelunaTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                // Attendees
                SizedBox(
                  width: 80,
                  height: 28,
                  child: Stack(
                    children: List.generate(
                      meeting.attendees.length > 3 ? 3 : meeting.attendees.length,
                      (index) => Positioned(
                        left: index * 20.0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: RelunaTheme.getRoleColor(
                            meeting.attendees[index].role,
                          ).withValues(alpha: 0.2),
                          child: Text(
                            meeting.attendees[index].name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: RelunaTheme.getRoleColor(meeting.attendees[index].role),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${meeting.attendees.length} attendees',
                  style: const TextStyle(
                    fontSize: 12,
                    color: RelunaTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                if (meeting.agenda.isNotEmpty)
                  Text(
                    '${meeting.agenda.length} agenda items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: RelunaTheme.textTertiary,
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: RelunaTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
