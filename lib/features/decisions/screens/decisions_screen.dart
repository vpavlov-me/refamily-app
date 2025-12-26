import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class DecisionsScreen extends ConsumerStatefulWidget {
  const DecisionsScreen({super.key});

  @override
  ConsumerState<DecisionsScreen> createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends ConsumerState<DecisionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decisions = ref.watch(decisionsProvider);
    final decisionsSummary = ref.watch(decisionsSummaryProvider);
    final theme = ShadTheme.of(context);

    return AppScaffold(
      title: 'Decisions',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => context.router.push(const DecisionCreateRoute()),
        ),
      ],
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShadInput(
              placeholder: const Text('Search decisions...'),
              prefix: const Icon(Icons.search, size: 20),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.primaryForeground,
              unselectedLabelColor: theme.colorScheme.mutedForeground,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Voting'),
                Tab(text: 'Pending'),
                Tab(text: 'Closed'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: decisions.when(
              data: (data) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _DecisionsList(
                      decisions: _filterDecisions(data, null),
                      searchQuery: _searchQuery,
                    ),
                    _DecisionsList(
                      decisions: _filterDecisions(data, 'Voting'),
                      searchQuery: _searchQuery,
                    ),
                    _DecisionsList(
                      decisions: _filterDecisions(data, 'Pending'),
                      searchQuery: _searchQuery,
                    ),
                    _DecisionsList(
                      decisions: data.where((d) => d.status == 'Approved' || d.status == 'Rejected').toList(),
                      searchQuery: _searchQuery,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load decisions')),
            ),
          ),
        ],
      ),
    );
  }

  List<Decision> _filterDecisions(List<Decision> decisions, String? status) {
    return decisions.where((d) {
      if (status != null && d.status != status) return false;
      if (_searchQuery.isEmpty) return true;
      return d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.small,
        ),
      ],
    );
  }
}

class _DecisionsList extends StatelessWidget {
  final List<Decision> decisions;
  final String searchQuery;

  const _DecisionsList({
    required this.decisions,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (decisions.isEmpty) {
      return const EmptyState(
        icon: Icons.how_to_vote_outlined,
        title: 'No decisions found',
        subtitle: 'Create a new decision to get started',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: decisions.length,
      itemBuilder: (context, index) {
        final decision = decisions[index];
        return _DecisionCard(
          decision: decision,
          onTap: () => context.router.push(DecisionDetailRoute(decisionId: decision.id)),
        );
      },
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final Decision decision;
  final VoidCallback? onTap;

  const _DecisionCard({
    required this.decision,
    this.onTap,
  });

  Color get _statusColor {
    switch (decision.status) {
      case 'Voting':
        return RelunaTheme.accentColor;
      case 'Pending':
        return RelunaTheme.warning;
      case 'Approved':
        return RelunaTheme.success;
      case 'Rejected':
        return RelunaTheme.error;
      default:
        return RelunaTheme.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (decision.status) {
      case 'Voting':
        return Icons.how_to_vote_outlined;
      case 'Pending':
        return Icons.pending_outlined;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final totalVotes = decision.votesFor + decision.votesAgainst + decision.votesAbstain;
    final hasVotes = totalVotes > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: decision.status == 'Voting'
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        decision.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (decision.deadline != null)
                  Text(
                    'Due ${DateFormat('MMM d').format(decision.deadline!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: decision.deadline!.isBefore(DateTime.now())
                          ? RelunaTheme.error
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title and description
            Text(
              decision.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              decision.description.length > 100
                  ? '${decision.description.substring(0, 100)}...'
                  : decision.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.mutedForeground,
                height: 1.4,
              ),
            ),

            // Voting progress
            if (hasVotes && decision.status == 'Voting') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$totalVotes of ${decision.requiredVotes} votes',
                              style: theme.textTheme.small,
                            ),
                            Text(
                              '${((totalVotes / decision.requiredVotes) * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.foreground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalVotes / decision.requiredVotes,
                            backgroundColor: theme.colorScheme.muted,
                            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _VoteIndicator(
                    label: 'For',
                    count: decision.votesFor,
                    color: RelunaTheme.success,
                  ),
                  const SizedBox(width: 16),
                  _VoteIndicator(
                    label: 'Against',
                    count: decision.votesAgainst,
                    color: RelunaTheme.error,
                  ),
                  const SizedBox(width: 16),
                  _VoteIndicator(
                    label: 'Abstain',
                    count: decision.votesAbstain,
                    color: RelunaTheme.textTertiary,
                  ),
                ],
              ),
            ],

            // Footer
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  decision.createdBy,
                  style: theme.textTheme.small,
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.mutedForeground,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _VoteIndicator({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: theme.textTheme.small,
        ),
      ],
    );
  }
}
