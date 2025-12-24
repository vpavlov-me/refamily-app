import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class MemberProfileScreen extends ConsumerWidget {
  @PathParam('memberId')
  final String memberId;

  const MemberProfileScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberByIdProvider(memberId));
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return memberAsync.when(
      data: (member) {
        if (member == null) {
          return AdaptiveScaffold(
            title: 'Member',
            hasBackButton: true,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isIOS ? CupertinoIcons.person : Icons.person_outline,
                    size: 64,
                    color: RelunaTheme.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Member not found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final roleColor = RelunaTheme.getRoleColor(member.role);

        return AdaptiveScaffold(
          title: member.name,
          hasBackButton: true,
          actions: [
            AdaptiveIconButton(
              icon: isIOS ? CupertinoIcons.ellipsis_vertical : Icons.more_vert,
              onPressed: () {
                AdaptiveActionSheet.show(
                  context: context,
                  title: 'Actions',
                  actions: [
                    AdaptiveAction(
                      title: 'Send Message',
                      icon: isIOS ? CupertinoIcons.chat_bubble : Icons.chat_outlined,
                      onPressed: () {
                        context.router.push(ChatDetailRoute(
                          chatId: 'member_${member.id}',
                          chatName: member.name,
                          isGroup: false,
                        ));
                      },
                    ),
                    AdaptiveAction(
                      title: 'Call',
                      icon: isIOS ? CupertinoIcons.phone : Icons.phone_outlined,
                      onPressed: () {},
                    ),
                    AdaptiveAction(
                      title: 'Email',
                      icon: isIOS ? CupertinoIcons.mail : Icons.email_outlined,
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
          ],
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        roleColor.withValues(alpha: 0.1),
                        RelunaTheme.background,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: roleColor.withValues(alpha: 0.2),
                            child: member.avatar != null
                                ? ClipOval(
                                    child: Image.network(
                                      member.avatar!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        member.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: roleColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    member.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: roleColor,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: member.status == 'active'
                                    ? RelunaTheme.success
                                    : RelunaTheme.textTertiary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: RelunaTheme.background,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RelunaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Role and generation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.role,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: RelunaTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Generation ${member.generation}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: RelunaTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contact info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: RelunaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AdaptiveCard(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            if (member.email != null)
                              _ContactRow(
                                icon: isIOS ? CupertinoIcons.mail : Icons.email_outlined,
                                label: 'Email',
                                value: member.email!,
                              ),
                            if (member.phone != null) ...[
                              const Divider(height: 1, indent: 56),
                              _ContactRow(
                                icon: isIOS ? CupertinoIcons.phone : Icons.phone_outlined,
                                label: 'Phone',
                                value: member.phone!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: RelunaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AdaptiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (member.bio != null) ...[
                              Text(
                                member.bio!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: RelunaTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: RelunaTheme.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  member.joinedAt != null
                                      ? 'Member since ${DateFormat('MMMM y').format(member.joinedAt!)}'
                                      : 'Member',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: RelunaTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Expertise
                      if (member.expertise != null && member.expertise!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Expertise',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: member.expertise!.map((exp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: RelunaTheme.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                exp,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: RelunaTheme.info,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Committees
                      if (member.committees != null && member.committees!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Committees',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: RelunaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AdaptiveCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: member.committees!.asMap().entries.map((entry) {
                              final isLast = entry.key == member.committees!.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.groups_outlined,
                                            size: 20,
                                            color: RelunaTheme.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: RelunaTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) const Divider(height: 1, indent: 56),
                                ],
                              );
                            }).toList(),
                          ),
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
        body: const Center(child: Text('Failed to load member')),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: RelunaTheme.textSecondary),
          ),
          const SizedBox(width: 12),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: RelunaTheme.textPrimary,
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
