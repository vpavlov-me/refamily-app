import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = true;

  @override
  Widget build(BuildContext context) {
    final meetings = ref.watch(meetingsProvider);
    final meetingsSummary = ref.watch(meetingsSummaryProvider);
    

    return AppScaffold(
      title: 'Meetings',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: _showCalendar
              ? const Icon(Icons.list)
              : const Icon(Icons.calendar_month),
          onPressed: () => setState(() => _showCalendar = !_showCalendar),
        ),
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
          final meetingDays = <DateTime, List<Meeting>>{};
          for (final meeting in data) {
            final day = DateTime(meeting.date.year, meeting.date.month, meeting.date.day);
            meetingDays[day] ??= [];
            meetingDays[day]!.add(meeting);
          }

          final selectedMeetings = _selectedDay != null
              ? meetingDays[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []
              : data.where((m) => m.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();

          return Column(
            children: [
              // Summary
              meetingsSummary.when(
                data: (summary) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RelunaTheme.info.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: 'Upcoming',
                          value: '${summary.upcoming}',
                          icon: Icons.event,
                          color: RelunaTheme.accentColor,
                        ),
                        _SummaryItem(
                          label: 'This Month',
                          value: '${summary.thisMonth}',
                          icon: Icons.calendar_today,
                          color: RelunaTheme.info,
                        ),
                        _SummaryItem(
                          label: 'Total',
                          value: '${summary.total}',
                          icon: Icons.event_note,
                          color: RelunaTheme.success,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              if (_showCalendar) ...[
                // Calendar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: RelunaTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: RelunaTheme.divider),
                  ),
                  child: TableCalendar<Meeting>(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) {
                      final key = DateTime(day.year, day.month, day.day);
                      return meetingDays[key] ?? [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: RelunaTheme.textSecondary),
                      defaultTextStyle: const TextStyle(color: RelunaTheme.textPrimary),
                      todayDecoration: BoxDecoration(
                        color: RelunaTheme.accentColor.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: RelunaTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: RelunaTheme.info,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 6,
                      markersMaxCount: 3,
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: RelunaTheme.textPrimary,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: RelunaTheme.textSecondary),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: RelunaTheme.textSecondary),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: RelunaTheme.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: RelunaTheme.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Meetings list
              Expanded(
                child: selectedMeetings.isEmpty
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
                            Text(
                              _selectedDay != null
                                  ? 'No meetings on this day'
                                  : 'No upcoming meetings',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: RelunaTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedMeetings.length,
                        itemBuilder: (context, index) {
                          final meeting = selectedMeetings[index];
                          return _MeetingCard(
                            meeting: meeting,
                            onTap: () => context.router.push(MeetingDetailRoute(meetingId: meeting.id)),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load meetings')),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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
