import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../data/models/succession.dart';

// Mock data providers
final successionPlansProvider = FutureProvider<List<SuccessionPlan>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    SuccessionPlan(
      id: '1',
      title: 'CEO Succession',
      description: 'Transition plan for CEO role of Johnson Manufacturing LLC',
      role: SuccessionRole.ceo,
      status: PlanStatus.active,
      currentHolderId: 'user1',
      currentHolderName: 'Robert Johnson',
      successorId: 'user2',
      successorName: 'Sarah Johnson',
      targetDate: DateTime(2027, 1, 1),
      milestones: [
        SuccessionMilestone(
          id: 'm1',
          title: 'Complete leadership training',
          description: 'Finish executive development program',
          targetDate: DateTime(2025, 6, 30),
          isCompleted: true,
          completedDate: DateTime(2025, 5, 15),
        ),
        SuccessionMilestone(
          id: 'm2',
          title: 'Shadow current CEO',
          description: '6-month shadowing period',
          targetDate: DateTime(2025, 12, 31),
          isCompleted: false,
        ),
        SuccessionMilestone(
          id: 'm3',
          title: 'Lead major project',
          description: 'Successfully lead a major company initiative',
          targetDate: DateTime(2026, 6, 30),
          isCompleted: false,
        ),
        SuccessionMilestone(
          id: 'm4',
          title: 'Board approval',
          description: 'Receive formal board approval for transition',
          targetDate: DateTime(2026, 12, 1),
          isCompleted: false,
        ),
      ],
      createdAt: DateTime(2024, 1, 1),
      lastUpdated: DateTime.now(),
    ),
    SuccessionPlan(
      id: '2',
      title: 'Family Council Chair',
      description: 'Transition for Family Council leadership',
      role: SuccessionRole.familyCouncil,
      status: PlanStatus.underReview,
      currentHolderId: 'user1',
      currentHolderName: 'Robert Johnson',
      successorId: 'user3',
      successorName: 'Michael Johnson',
      targetDate: DateTime(2026, 6, 1),
      milestones: [
        SuccessionMilestone(
          id: 'm5',
          title: 'Governance training',
          description: 'Complete family governance certification',
          targetDate: DateTime(2025, 9, 30),
          isCompleted: true,
          completedDate: DateTime(2025, 8, 20),
        ),
        SuccessionMilestone(
          id: 'm6',
          title: 'Lead subcommittee',
          description: 'Chair at least one council subcommittee',
          targetDate: DateTime(2026, 3, 31),
          isCompleted: false,
        ),
      ],
      createdAt: DateTime(2024, 6, 1),
      lastUpdated: DateTime.now(),
    ),
    SuccessionPlan(
      id: '3',
      title: 'Trust Oversight',
      description: 'Succession plan for family trust trustee role',
      role: SuccessionRole.trustee,
      status: PlanStatus.draft,
      currentHolderId: 'user1',
      currentHolderName: 'Robert Johnson',
      targetDate: DateTime(2028, 1, 1),
      milestones: [],
      createdAt: DateTime(2025, 1, 1),
      lastUpdated: DateTime.now(),
    ),
  ];
});

final successionSummaryProvider = FutureProvider<SuccessionSummary>((ref) async {
  final plans = await ref.watch(successionPlansProvider.future);
  
  return SuccessionSummary(
    totalPlans: plans.length,
    activePlans: plans.where((p) => p.status == PlanStatus.active).length,
    pendingTransitions: plans.where((p) => 
        p.status == PlanStatus.active || p.status == PlanStatus.underReview).length,
    completedTransitions: plans.where((p) => p.status == PlanStatus.completed).length,
  );
});

@RoutePage()
class SuccessionScreen extends ConsumerStatefulWidget {
  const SuccessionScreen({super.key});

  @override
  ConsumerState<SuccessionScreen> createState() => _SuccessionScreenState();
}

class _SuccessionScreenState extends ConsumerState<SuccessionScreen> {
  PlanStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(successionPlansProvider);
    final summary = ref.watch(successionSummaryProvider);
    

    return AppScaffold(
      title: 'Succession Planning',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showCreatePlanDialog(context),
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
                    RelunaTheme.info,
                    Colors.indigo,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    icon: Icons.assignment,
                    value: '${data.totalPlans}',
                    label: 'Total Plans',
                  ),
                  _SummaryStat(
                    icon: Icons.play_circle,
                    value: '${data.activePlans}',
                    label: 'Active',
                  ),
                  _SummaryStat(
                    icon: Icons.pending,
                    value: '${data.pendingTransitions}',
                    label: 'Pending',
                  ),
                  _SummaryStat(
                    icon: Icons.check_circle,
                    value: '${data.completedTransitions}',
                    label: 'Completed',
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
                for (final status in PlanStatus.values)
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

          // Plans List
          Expanded(
            child: plans.when(
              data: (data) {
                var filtered = data;
                if (_selectedStatus != null) {
                  filtered = filtered.where((p) => p.status == _selectedStatus).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.family_restroom_outlined, size: 64, color: RelunaTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('No succession plans found', style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _SuccessionPlanCard(
                    plan: filtered[index],
                    onTap: () => _showPlanDetails(context, filtered[index]),
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

  String _getStatusLabel(PlanStatus status) {
    switch (status) {
      case PlanStatus.draft: return 'Draft';
      case PlanStatus.active: return 'Active';
      case PlanStatus.underReview: return 'Under Review';
      case PlanStatus.completed: return 'Completed';
      case PlanStatus.archived: return 'Archived';
    }
  }

  void _showCreatePlanDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Create Succession Plan'),
        description: const Text('Define a new succession plan for a family role or position.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ShadButton(
            child: const Text('Create'),
            onPressed: () {
              Navigator.pop(context);
              // Create plan logic would go here
            },
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(BuildContext context, SuccessionPlan plan) {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: plan.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(plan.roleIcon, color: plan.statusColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan.title, style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: plan.statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_getStatusLabel(plan.status), style: TextStyle(
                                  color: plan.statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(plan.description, style: TextStyle(
                      color: RelunaTheme.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                    
                    // Transition Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RelunaTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _TransitionRow(
                            label: 'Current',
                            name: plan.currentHolderName,
                            isFrom: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Icon(Icons.arrow_downward, color: RelunaTheme.textSecondary),
                          ),
                          _TransitionRow(
                            label: 'Successor',
                            name: plan.successorName ?? 'To be determined',
                            isFrom: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _DetailRow('Role', plan.roleLabel),
                    _DetailRow('Target Date', dateFormat.format(plan.targetDate)),
                    _DetailRow('Progress', '${plan.progressPercent.toStringAsFixed(0)}%'),
                    
                    const SizedBox(height: 24),
                    
                    // Milestones
                    if (plan.milestones.isNotEmpty) ...[
                      const Text('Milestones', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...plan.milestones.map((m) => _MilestoneItem(milestone: m)),
                    ] else
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.flag_outlined, size: 48, color: RelunaTheme.textSecondary),
                            const SizedBox(height: 8),
                            Text('No milestones defined yet',
                                style: TextStyle(color: RelunaTheme.textSecondary)),
                          ],
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

  const _SummaryStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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

class _SuccessionPlanCard extends StatelessWidget {
  final SuccessionPlan plan;
  final VoidCallback onTap;

  const _SuccessionPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RelunaTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: plan.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(plan.roleIcon, color: plan.statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.title, style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('${plan.roleLabel} • Target: ${dateFormat.format(plan.targetDate)}',
                          style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    plan.status.name[0].toUpperCase() + plan.status.name.substring(1),
                    style: TextStyle(color: plan.statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: RelunaTheme.surfaceDark,
                  child: Text(plan.currentHolderName[0],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16, color: RelunaTheme.textSecondary),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: plan.successorName != null 
                      ? RelunaTheme.accentColor.withValues(alpha: 0.2)
                      : RelunaTheme.surfaceDark,
                  child: plan.successorName != null
                      ? Text(plan.successorName![0],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                      : const Icon(Icons.help_outline, size: 14),
                ),
                const Spacer(),
                if (plan.milestones.isNotEmpty) ...[
                  Text(
                    '${plan.milestones.where((m) => m.isCompleted).length}/${plan.milestones.length} milestones',
                    style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (plan.milestones.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.progressPercent / 100,
                  backgroundColor: RelunaTheme.surfaceDark,
                  valueColor: AlwaysStoppedAnimation(plan.statusColor),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransitionRow extends StatelessWidget {
  final String label;
  final String name;
  final bool isFrom;

  const _TransitionRow({required this.label, required this.name, required this.isFrom});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: RelunaTheme.textSecondary)),
        const Spacer(),
        CircleAvatar(
          radius: 16,
          backgroundColor: isFrom 
              ? RelunaTheme.textSecondary.withValues(alpha: 0.2)
              : RelunaTheme.accentColor.withValues(alpha: 0.2),
          child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
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

class _MilestoneItem extends StatelessWidget {
  final SuccessionMilestone milestone;

  const _MilestoneItem({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: milestone.isCompleted 
            ? RelunaTheme.success.withValues(alpha: 0.05)
            : RelunaTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: milestone.isCompleted 
              ? RelunaTheme.success.withValues(alpha: 0.3)
              : RelunaTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            milestone.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: milestone.isCompleted ? RelunaTheme.success : RelunaTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                )),
                Text(
                  milestone.isCompleted && milestone.completedDate != null
                      ? 'Completed ${dateFormat.format(milestone.completedDate!)}'
                      : 'Due ${dateFormat.format(milestone.targetDate)}',
                  style: TextStyle(
                    color: milestone.isCompleted ? RelunaTheme.success : RelunaTheme.textSecondary,
                    fontSize: 12,
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
