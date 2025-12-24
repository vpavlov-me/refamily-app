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
  Widget build(BuildContext context, ) {
    final decisions = ref.watch(decisionsProvider);
    final decisionsSummary = ref.watch(decisionsSummaryProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Decisions',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.add : Icons.add,
          onPressed: () => context.router.push(const DecisionCreateRoute()),
        ),
      ],
      body: Column(
        children: [
          // Summary
          decisionsSummary.when(
            data: (summary) => Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      RelunaTheme.accentColor.withValues(alpha: 0.1),
                      RelunaTheme.info.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Voting',
                      value: '${summary.voting}',
                      color: RelunaTheme.accentColor,
                    ),
                    _SummaryItem(
                      label: 'Pending',
                      value: '${summary.pending}',
                      color: RelunaTheme.warning,
                    ),
                    _SummaryItem(
                      label: 'Approved',
                      value: '${summary.approved}',
                      color: RelunaTheme.success,
                    ),
                    _SummaryItem(
                      label: 'Rejected',
                      value: '${summary.rejected}',
                      color: RelunaTheme.error,
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AdaptiveSearchField(
              placeholder: 'Search decisions...',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: RelunaTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: RelunaTheme.textSecondary,
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
              loading: () => const Center(child: AdaptiveLoadingIndicator()),
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
          style: const TextStyle(
            fontSize: 12,
            color: RelunaTheme.textSecondary,
          ),
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
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    if (decisions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIOS ? CupertinoIcons.doc_text : Icons.how_to_vote_outlined,
              size: 64,
              color: RelunaTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No decisions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: RelunaTheme.textSecondary,
              ),
            ),
          ],
        ),
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
    final totalVotes = decision.votesFor + decision.votesAgainst + decision.votesAbstain;
    final hasVotes = totalVotes > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: decision.status == 'Voting'
                ? RelunaTheme.accentColor.withValues(alpha: 0.3)
                : RelunaTheme.divider,
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
                          : RelunaTheme.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title and description
            Text(
              decision.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: RelunaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              decision.description.length > 100
                  ? '${decision.description.substring(0, 100)}...'
                  : decision.description,
              style: const TextStyle(
                fontSize: 14,
                color: RelunaTheme.textSecondary,
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
                              style: const TextStyle(
                                fontSize: 12,
                                color: RelunaTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '${((totalVotes / decision.requiredVotes) * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: RelunaTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalVotes / decision.requiredVotes,
                            backgroundColor: RelunaTheme.surfaceDark,
                            valueColor: const AlwaysStoppedAnimation(RelunaTheme.accentColor),
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
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: RelunaTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  decision.createdBy,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RelunaTheme.textTertiary,
                  ),
                ),
                const Spacer(),
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
          style: const TextStyle(
            fontSize: 12,
            color: RelunaTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
