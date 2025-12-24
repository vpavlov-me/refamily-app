import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  String _searchQuery = '';
  String _selectedGeneration = 'All';
  String _selectedRole = 'All';

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider);
    final membersSummary = ref.watch(membersSummaryProvider);
    

    return AppScaffold(
      title: 'Members',
      hasBackButton: true,
      body: Column(
        children: [
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ShadInput(
                  placeholder: const Text('Search members...'),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedGeneration == 'All',
                        onTap: () => setState(() => _selectedGeneration = 'All'),
                      ),
                      _FilterChip(
                        label: 'G1',
                        isSelected: _selectedGeneration == 'G1',
                        onTap: () => setState(() => _selectedGeneration = 'G1'),
                      ),
                      _FilterChip(
                        label: 'G2',
                        isSelected: _selectedGeneration == 'G2',
                        onTap: () => setState(() => _selectedGeneration = 'G2'),
                      ),
                      _FilterChip(
                        label: 'G3',
                        isSelected: _selectedGeneration == 'G3',
                        onTap: () => setState(() => _selectedGeneration = 'G3'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary
          membersSummary.when(
            data: (summary) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RelunaTheme.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Total',
                      value: '${summary.totalMembers}',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: RelunaTheme.divider,
                    ),
                    _SummaryItem(
                      label: 'Active',
                      value: '${summary.activeMembers}',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: RelunaTheme.divider,
                    ),
                    _SummaryItem(
                      label: 'Generations',
                      value: '${summary.generations}',
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Members list
          Expanded(
            child: members.when(
              data: (data) {
                var filtered = data.where((m) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      m.role.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesGeneration = _selectedGeneration == 'All' ||
                      m.generation == _selectedGeneration;
                  return matchesSearch && matchesGeneration;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Platform.isIOS ? CupertinoIcons.person_2 : Icons.people_outline,
                          size: 64,
                          color: RelunaTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No members found',
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return _MemberCard(
                      member: member,
                      onTap: () => context.router.push(MemberProfileRoute(memberId: member.id)),
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load members')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RelunaTheme.accentColor : RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? RelunaTheme.accentColor : RelunaTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : RelunaTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: RelunaTheme.textPrimary,
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

class _MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;

  const _MemberCard({
    required this.member,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = RelunaTheme.getRoleColor(member.role);

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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: roleColor.withValues(alpha: 0.1),
              child: member.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        member.avatar!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          member.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      member.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: RelunaTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: RelunaTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.generation,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: RelunaTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (member.email != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      member.email!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RelunaTheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Status and arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: member.status == 'active'
                        ? RelunaTheme.success
                        : RelunaTheme.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.chevron_right,
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
