import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../data/models/conflict.dart';

// Mock data providers
final conflictsProvider = FutureProvider<List<Conflict>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Conflict(
      id: '1',
      title: 'Business Expansion Disagreement',
      description: 'Disagreement over proposed expansion into new market segment. Michael wants aggressive expansion while Sarah prefers conservative approach.',
      type: ConflictType.business,
      status: ConflictStatus.inMediation,
      priority: ConflictPriority.high,
      involvedPartyIds: ['user2', 'user3'],
      involvedPartyNames: ['Sarah Johnson', 'Michael Johnson'],
      mediatorId: 'user1',
      mediatorName: 'Robert Johnson',
      reportedDate: DateTime(2025, 11, 15),
      notes: [
        ConflictNote(
          id: 'n1',
          authorId: 'user1',
          authorName: 'Robert Johnson',
          content: 'Scheduled initial mediation session for next week.',
          createdAt: DateTime(2025, 11, 16),
        ),
        ConflictNote(
          id: 'n2',
          authorId: 'user1',
          authorName: 'Robert Johnson',
          content: 'Both parties have agreed to present their proposals in writing.',
          createdAt: DateTime(2025, 11, 20),
        ),
      ],
    ),
    Conflict(
      id: '2',
      title: 'Vacation Property Usage',
      description: 'Scheduling conflict for use of family vacation home during peak summer season.',
      type: ConflictType.property,
      status: ConflictStatus.resolved,
      priority: ConflictPriority.medium,
      involvedPartyIds: ['user2', 'user4'],
      involvedPartyNames: ['Sarah Johnson', 'Emily Johnson'],
      reportedDate: DateTime(2025, 10, 1),
      resolvedDate: DateTime(2025, 10, 15),
      resolution: 'Implemented rotating schedule with alternating priority years.',
    ),
    Conflict(
      id: '3',
      title: 'Trust Distribution Timing',
      description: 'Disagreement on timing of trust distributions to next generation members.',
      type: ConflictType.financial,
      status: ConflictStatus.underReview,
      priority: ConflictPriority.high,
      involvedPartyIds: ['user3', 'user4'],
      involvedPartyNames: ['Michael Johnson', 'Emily Johnson'],
      reportedDate: DateTime(2025, 12, 1),
    ),
    Conflict(
      id: '4',
      title: 'Board Seat Appointment',
      description: 'Dispute over nomination process for open board seat.',
      type: ConflictType.governance,
      status: ConflictStatus.reported,
      priority: ConflictPriority.urgent,
      involvedPartyIds: ['user2', 'user3'],
      involvedPartyNames: ['Sarah Johnson', 'Michael Johnson'],
      reportedDate: DateTime(2025, 12, 20),
    ),
  ];
});

final conflictsSummaryProvider = FutureProvider<ConflictsSummary>((ref) async {
  final conflicts = await ref.watch(conflictsProvider.future);
  
  return ConflictsSummary(
    total: conflicts.length,
    active: conflicts.where((c) => 
        c.status != ConflictStatus.resolved).length,
    resolved: conflicts.where((c) => c.status == ConflictStatus.resolved).length,
    urgent: conflicts.where((c) => c.priority == ConflictPriority.urgent).length,
  );
});

@RoutePage()
class ConflictResolutionScreen extends ConsumerStatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  ConsumerState<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends ConsumerState<ConflictResolutionScreen> {
  ConflictStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final conflicts = ref.watch(conflictsProvider);
    final summary = ref.watch(conflictsSummaryProvider);
    

    return AppScaffold(
      title: 'Conflict Resolution',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showReportConflictDialog(context),
        ),
      ],
      body: Column(
        children: [
          // Summary Card
          summary.when(
            data: (data) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    icon: Icons.format_list_bulleted,
                    value: '${data.total}',
                    label: 'Total',
                  ),
                  _SummaryStat(
                    icon: Icons.pending_actions,
                    value: '${data.active}',
                    label: 'Active',
                  ),
                  _SummaryStat(
                    icon: Icons.check_circle,
                    value: '${data.resolved}',
                    label: 'Resolved',
                  ),
                  _SummaryStat(
                    icon: Icons.priority_high,
                    value: '${data.urgent}',
                    label: 'Urgent',
                    isUrgent: data.urgent > 0,
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 100, child: Center(child: CupertinoActivityIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Status Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                for (final status in ConflictStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: _getStatusLabel(status),
                      isSelected: _selectedStatus == status,
                      onTap: () => setState(() => _selectedStatus = status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Conflicts List
          Expanded(
            child: conflicts.when(
              data: (data) {
                var filtered = data;
                if (_selectedStatus != null) {
                  filtered = filtered.where((c) => c.status == _selectedStatus).toList();
                }
                
                // Sort by priority (urgent first) then by date
                filtered.sort((a, b) {
                  if (a.priority == ConflictPriority.urgent && b.priority != ConflictPriority.urgent) return -1;
                  if (b.priority == ConflictPriority.urgent && a.priority != ConflictPriority.urgent) return 1;
                  return b.reportedDate.compareTo(a.reportedDate);
                });

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handshake_outlined, size: 64, color: RelunaTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('No conflicts found', style: TextStyle(color: RelunaTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Family harmony achieved! 🎉', 
                            style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _ConflictCard(
                    conflict: filtered[index],
                    onTap: () => _showConflictDetails(context, filtered[index]),
                  ),
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ConflictStatus status) {
    switch (status) {
      case ConflictStatus.reported: return 'Reported';
      case ConflictStatus.underReview: return 'Under Review';
      case ConflictStatus.inMediation: return 'In Mediation';
      case ConflictStatus.resolved: return 'Resolved';
      case ConflictStatus.escalated: return 'Escalated';
    }
  }

  void _showReportConflictDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Report a Conflict'),
        description: const Text('Describe the conflict that needs resolution. This will be reviewed by family mediators.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ShadButton(
            child: const Text('Report'),
            onPressed: () {
              Navigator.pop(context);
              // Report conflict logic would go here
            },
          ),
        ],
      ),
    );
  }

  void _showConflictDetails(BuildContext context, Conflict conflict) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: conflict.priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(conflict.typeIcon, color: conflict.priorityColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(conflict.title, style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: conflict.statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_getStatusLabel(conflict.status),
                                        style: TextStyle(color: conflict.statusColor,
                                            fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  if (conflict.priority == ConflictPriority.urgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: RelunaTheme.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('URGENT',
                                          style: TextStyle(color: RelunaTheme.error,
                                              fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(conflict.description, style: TextStyle(
                      color: RelunaTheme.textSecondary, height: 1.5, fontSize: 15)),
                    const SizedBox(height: 24),
                    
                    // Involved Parties
                    const Text('Involved Parties', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: conflict.involvedPartyNames.map((name) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: RelunaTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
                              child: Text(name[0], style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Text(name),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Details
                    _DetailRow('Type', conflict.typeLabel),
                    _DetailRow('Reported', dateFormat.format(conflict.reportedDate)),
                    if (conflict.mediatorName != null)
                      _DetailRow('Mediator', conflict.mediatorName!),
                    if (conflict.resolvedDate != null)
                      _DetailRow('Resolved', dateFormat.format(conflict.resolvedDate!)),
                    
                    // Resolution
                    if (conflict.resolution != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: RelunaTheme.success.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RelunaTheme.success.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: RelunaTheme.success, size: 20),
                                const SizedBox(width: 8),
                                const Text('Resolution', style: TextStyle(
                                  fontWeight: FontWeight.bold, color: RelunaTheme.success)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(conflict.resolution!, style: const TextStyle(height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                    
                    // Notes
                    if (conflict.notes.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Activity Log', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...conflict.notes.map((note) => _NoteItem(note: note)),
                    ],
                    
                    const SizedBox(height: 24),
                    if (conflict.status != ConflictStatus.resolved)
                      SizedBox(
                        width: double.infinity,
                        child: ShadButton.outline(
                          child: const Text('Add Note'),
                          onPressed: () {},
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isUrgent;

  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isUrgent ? Colors.redAccent : Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          color: isUrgent ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RelunaTheme.accentColor : RelunaTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : RelunaTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final Conflict conflict;
  final VoidCallback onTap;

  const _ConflictCard({required this.conflict, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: conflict.priority == ConflictPriority.urgent
                ? RelunaTheme.error.withValues(alpha: 0.5)
                : RelunaTheme.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: conflict.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(conflict.typeIcon, color: conflict.statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(conflict.title, style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                          if (conflict.priority == ConflictPriority.urgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: RelunaTheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('URGENT', style: TextStyle(
                                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(conflict.typeLabel, style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 13)),
                          const Text(' • ', style: TextStyle(color: RelunaTheme.textSecondary)),
                          Text(dateFormat.format(conflict.reportedDate), style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ...conflict.involvedPartyNames.take(3).map((name) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: RelunaTheme.surfaceDark,
                    child: Text(name[0], style: const TextStyle(fontSize: 11)),
                  ),
                )),
                if (conflict.involvedPartyNames.length > 3)
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: RelunaTheme.surfaceDark,
                    child: Text('+${conflict.involvedPartyNames.length - 3}',
                        style: const TextStyle(fontSize: 10)),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: conflict.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    conflict.status.name[0].toUpperCase() + conflict.status.name.substring(1),
                    style: TextStyle(color: conflict.statusColor,
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: RelunaTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final ConflictNote note;

  const _NoteItem({required this.note});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RelunaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
                child: Text(note.authorName[0], style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text(note.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(dateFormat.format(note.createdAt),
                  style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.content, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
