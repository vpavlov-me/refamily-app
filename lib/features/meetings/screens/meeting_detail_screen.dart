import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';

@RoutePage()
class MeetingDetailScreen extends ConsumerWidget {
  @PathParam('meetingId')
  final String meetingId;

  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingAsync = ref.watch(meetingByIdProvider(meetingId));
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return meetingAsync.when(
      data: (meeting) {
        if (meeting == null) {
          return AdaptiveScaffold(
            title: 'Meeting',
            hasBackButton: true,
            body: const Center(child: Text('Meeting not found')),
          );
        }

        final isPast = meeting.date.isBefore(DateTime.now());

        return AdaptiveScaffold(
          title: 'Meeting Details',
          hasBackButton: true,
          actions: [
            AdaptiveIconButton(
              icon: isIOS ? CupertinoIcons.share : Icons.share_outlined,
              onPressed: () {
                _showShareOptions(context, meeting);
              },
            ),
          ],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getTypeColor(meeting.type).withValues(alpha: 0.1),
                        RelunaTheme.background,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getTypeColor(meeting.type).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              meeting.type,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(meeting.type),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isPast)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: RelunaTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: RelunaTheme.textTertiary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        meeting.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RelunaTheme.textPrimary,
                        ),
                      ),
                      if (meeting.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          meeting.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: RelunaTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date, time, location
                      AdaptiveCard(
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: isIOS ? CupertinoIcons.calendar : Icons.calendar_today_outlined,
                              label: 'Date',
                              value: DateFormat('EEEE, MMMM d, y').format(meeting.date),
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: isIOS ? CupertinoIcons.clock : Icons.access_time,
                              label: 'Time',
                              value: meeting.time,
                            ),
                            if (meeting.location != null) ...[
                              const Divider(height: 24),
                              _InfoRow(
                                icon: isIOS ? CupertinoIcons.location : Icons.location_on_outlined,
                                label: 'Location',
                                value: meeting.location!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Attendees
                      const SizedBox(height: 24),
                      Text(
                        'Attendees (${meeting.attendees.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: RelunaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AdaptiveCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: meeting.attendees.asMap().entries.map((entry) {
                            final index = entry.key;
                            final attendee = entry.value;
                            final isLast = index == meeting.attendees.length - 1;
                            return Column(
                              children: [
                                _AttendeeRow(attendee: attendee),
                                if (!isLast) const Divider(height: 1, indent: 72),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      // Agenda
                      if (meeting.agenda.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Agenda (${meeting.agenda.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...meeting.agenda.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _AgendaItemCard(index: index + 1, item: item);
                        }),
                      ],

                      // Documents
                      if (meeting.documents.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Documents (${meeting.documents.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AdaptiveCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: meeting.documents.asMap().entries.map((entry) {
                              final index = entry.key;
                              final doc = entry.value;
                              final isLast = index == meeting.documents.length - 1;
                              return Column(
                                children: [
                                  _DocumentRow(document: doc),
                                  if (!isLast) const Divider(height: 1, indent: 56),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Action buttons
                      if (!isPast) ...[
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: AdaptiveButton(
                                text: 'RSVP',
                                onPressed: () {
                                  AdaptiveActionSheet.show(
                                    context: context,
                                    title: 'RSVP',
                                    message: 'Will you attend this meeting?',
                                    actions: [
                                      AdaptiveAction(
                                        title: 'Yes, I\'ll attend',
                                        icon: Icons.check_circle_outline,
                                        onPressed: () {
                                          AdaptiveDialog.show(
                                            context: context,
                                            title: 'RSVP Confirmed',
                                            content: 'You have confirmed attendance.',
                                            confirmText: 'OK',
                                          );
                                        },
                                      ),
                                      AdaptiveAction(
                                        title: 'No, I can\'t attend',
                                        icon: Icons.cancel_outlined,
                                        isDestructive: true,
                                        onPressed: () {},
                                      ),
                                      AdaptiveAction(
                                        title: 'Maybe',
                                        icon: Icons.help_outline,
                                        onPressed: () {},
                                      ),
                                    ],
                                    cancelAction: AdaptiveAction(
                                      title: 'Cancel',
                                      onPressed: () {},
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AdaptiveButton(
                                text: 'Add to Calendar',
                                isOutlined: true,
                                onPressed: () {
                                  AdaptiveDialog.show(
                                    context: context,
                                    title: 'Added to Calendar',
                                    content: 'Meeting has been added to your calendar.',
                                    confirmText: 'OK',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AdaptiveScaffold(
        title: 'Loading...',
        hasBackButton: true,
        body: Center(child: AdaptiveLoadingIndicator()),
      ),
      error: (_, __) => AdaptiveScaffold(
        title: 'Error',
        hasBackButton: true,
        body: const Center(child: Text('Failed to load meeting')),
      ),
    );
  }

  void _showShareOptions(BuildContext context, Meeting meeting) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    AdaptiveActionSheet.show(
      context: context,
      title: 'Share Meeting',
      actions: [
        AdaptiveAction(
          title: 'Copy Meeting Link',
          icon: isIOS ? CupertinoIcons.link : Icons.link,
          onPressed: () {
            AdaptiveDialog.show(
              context: context,
              title: 'Link Copied',
              content: 'Meeting link has been copied to clipboard.',
              confirmText: 'OK',
            );
          },
        ),
        AdaptiveAction(
          title: 'Share via Email',
          icon: isIOS ? CupertinoIcons.mail : Icons.email_outlined,
          onPressed: () {
            AdaptiveDialog.show(
              context: context,
              title: 'Email Prepared',
              content: 'Meeting details ready to share via email:\n\n${meeting.title}\n${dateFormat.format(meeting.date)} at ${timeFormat.format(meeting.date)}',
              confirmText: 'OK',
            );
          },
        ),
        AdaptiveAction(
          title: 'Send to Family Chat',
          icon: isIOS ? CupertinoIcons.chat_bubble : Icons.chat_outlined,
          onPressed: () {
            AdaptiveDialog.show(
              context: context,
              title: 'Shared',
              content: 'Meeting details have been shared to Family Chat.',
              confirmText: 'OK',
            );
          },
        ),
      ],
      cancelAction: AdaptiveAction(
        title: 'Cancel',
        onPressed: () {},
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: RelunaTheme.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: RelunaTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: RelunaTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final MeetingAttendee attendee;

  const _AttendeeRow({required this.attendee});

  @override
  Widget build(BuildContext context) {
    final roleColor = RelunaTheme.getRoleColor(attendee.role);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: roleColor.withValues(alpha: 0.1),
            child: Text(
              attendee.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attendee.role,
                  style: TextStyle(
                    fontSize: 13,
                    color: roleColor,
                  ),
                ),
              ],
            ),
          ),
          _RsvpBadge(status: attendee.rsvp),
        ],
      ),
    );
  }
}

class _RsvpBadge extends StatelessWidget {
  final String status;

  const _RsvpBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return RelunaTheme.success;
      case 'declined':
        return RelunaTheme.error;
      case 'pending':
        return RelunaTheme.warning;
      default:
        return RelunaTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _AgendaItemCard extends StatelessWidget {
  final int index;
  final AgendaItem item;

  const _AgendaItemCard({
    required this.index,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelunaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelunaTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: RelunaTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: RelunaTheme.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: RelunaTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: RelunaTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.duration} min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RelunaTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: RelunaTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.presenter,
                      style: const TextStyle(
                        fontSize: 12,
                        color: RelunaTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final MeetingDocument document;

  const _DocumentRow({required this.document});

  IconData get _icon {
    switch (document.type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RelunaTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 20, color: RelunaTheme.info),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: RelunaTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${document.type.toUpperCase()} • ${document.size}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: RelunaTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.download_outlined,
            size: 20,
            color: RelunaTheme.info,
          ),
        ],
      ),
    );
  }
}
