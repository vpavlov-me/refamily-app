import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';

@RoutePage()
class DecisionDetailScreen extends ConsumerStatefulWidget {
  @PathParam('decisionId')
  final String decisionId;

  const DecisionDetailScreen({
    super.key,
    required this.decisionId,
  });

  @override
  ConsumerState<DecisionDetailScreen> createState() => _DecisionDetailScreenState();
}

class _DecisionDetailScreenState extends ConsumerState<DecisionDetailScreen> {
  String? _selectedVote;

  @override
  Widget build(BuildContext context) {
    final decisionAsync = ref.watch(decisionByIdProvider(widget.decisionId));
    final theme = ShadTheme.of(context);

    return decisionAsync.when(
      data: (decision) {
        if (decision == null) {
          return AppScaffold(
            title: 'Decision',
            hasBackButton: true,
            body: const Center(child: Text('Decision not found')),
          );
        }

        return AppScaffold(
          title: 'Decision',
          hasBackButton: true,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getStatusColor(decision.status).withValues(alpha: 0.1),
                        theme.colorScheme.background,
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
                              color: _getStatusColor(decision.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(decision.status),
                                  size: 16,
                                  color: _getStatusColor(decision.status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  decision.status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(decision.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (decision.deadline != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Deadline',
                                  style: theme.textTheme.small,
                                ),
                                Text(
                                  DateFormat('MMM d, y').format(decision.deadline!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: decision.deadline!.isBefore(DateTime.now())
                                        ? RelunaTheme.error
                                        : theme.colorScheme.foreground,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        decision.title,
                        style: theme.textTheme.h3,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Proposed by ${decision.createdBy}',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text('Description', style: theme.textTheme.h4),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Text(
                          decision.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.foreground,
                            height: 1.6,
                          ),
                        ),
                      ),

                      // Voting results
                      if (decision.status == 'Voting' || decision.status == 'Approved' || decision.status == 'Rejected') ...[
                        const SizedBox(height: 24),
                        Text('Voting Results', style: theme.textTheme.h4),
                        const SizedBox(height: 12),
                        _VotingResults(decision: decision),
                      ],

                      // Cast vote section (only for voting decisions)
                      if (decision.status == 'Voting') ...[
                        const SizedBox(height: 24),
                        Text('Cast Your Vote', style: theme.textTheme.h4),
                        const SizedBox(height: 12),
                        _VoteSection(
                          selectedVote: _selectedVote,
                          onVoteSelected: (vote) => setState(() => _selectedVote = vote),
                          onSubmit: _selectedVote != null
                              ? () => _submitVote(decision)
                              : null,
                        ),
                      ],

                      // Proposals
                      if (decision.proposals.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Proposals', style: theme.textTheme.h4),
                        const SizedBox(height: 12),
                        ...decision.proposals.map((proposal) => _ProposalCard(proposal: proposal)),
                      ],

                      // Comments
                      if (decision.comments.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Discussion (${decision.comments.length})', style: theme.textTheme.h4),
                        const SizedBox(height: 12),
                        ...decision.comments.map((comment) => _CommentCard(comment: comment)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Loading...',
        hasBackButton: true,
        body: Center(child: AppLoadingIndicator()),
      ),
      error: (_, __) => const AppScaffold(
        title: 'Error',
        hasBackButton: true,
        body: Center(child: Text('Failed to load decision')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
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

  void _submitVote(Decision decision) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Confirm Vote'),
        description: Text('You are voting "$_selectedVote" on "${decision.title}". This action cannot be undone.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ShadButton(
            child: const Text('Submit Vote'),
            onPressed: () {
              Navigator.pop(context);
              ShadToaster.of(context).show(
                ShadToast(
                  title: const Text('Vote Submitted'),
                  description: const Text('Your vote has been recorded successfully.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VotingResults extends StatelessWidget {
  final Decision decision;

  const _VotingResults({required this.decision});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final total = decision.votesFor + decision.votesAgainst + decision.votesAbstain;
    final forPercent = total > 0 ? (decision.votesFor / total * 100) : 0.0;
    final againstPercent = total > 0 ? (decision.votesAgainst / total * 100) : 0.0;
    final abstainPercent = total > 0 ? (decision.votesAbstain / total * 100) : 0.0;

    return AppCard(
      child: Column(
        children: [
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$total of ${decision.requiredVotes} votes',
                style: theme.textTheme.muted,
              ),
              Text(
                '${((total / decision.requiredVotes) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total / decision.requiredVotes,
              backgroundColor: theme.colorScheme.muted,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Vote breakdown
          Row(
            children: [
              Expanded(
                child: _VoteBar(
                  label: 'For',
                  count: decision.votesFor,
                  percent: forPercent,
                  color: RelunaTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteBar(
                  label: 'Against',
                  count: decision.votesAgainst,
                  percent: againstPercent,
                  color: RelunaTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteBar(
                  label: 'Abstain',
                  count: decision.votesAbstain,
                  percent: abstainPercent,
                  color: RelunaTheme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const _VoteBar({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Column(
      children: [
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count $label',
          style: theme.textTheme.small,
        ),
      ],
    );
  }
}

class _VoteSection extends StatelessWidget {
  final String? selectedVote;
  final Function(String) onVoteSelected;
  final VoidCallback? onSubmit;

  const _VoteSection({
    required this.selectedVote,
    required this.onVoteSelected,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _VoteOption(
                  label: 'For',
                  icon: Icons.thumb_up_outlined,
                  color: RelunaTheme.success,
                  isSelected: selectedVote == 'For',
                  onTap: () => onVoteSelected('For'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteOption(
                  label: 'Against',
                  icon: Icons.thumb_down_outlined,
                  color: RelunaTheme.error,
                  isSelected: selectedVote == 'Against',
                  onTap: () => onVoteSelected('Against'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteOption(
                  label: 'Abstain',
                  icon: Icons.remove_circle_outline,
                  color: RelunaTheme.textTertiary,
                  isSelected: selectedVote == 'Abstain',
                  onTap: () => onVoteSelected('Abstain'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              child: const Text('Submit Vote'),
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _VoteOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : theme.colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? color : theme.colorScheme.mutedForeground),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;

  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  proposal.author[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                proposal.author,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d').format(proposal.createdAt),
                style: theme.textTheme.small,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            proposal.content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.foreground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: RelunaTheme.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  comment.author[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: RelunaTheme.info,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                comment.author,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d').format(comment.createdAt),
                style: theme.textTheme.small,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.foreground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
