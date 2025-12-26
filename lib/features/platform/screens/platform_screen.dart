import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/shared.dart';

@RoutePage()
class PlatformScreen extends ConsumerWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    return AppScaffold(
      title: '{Family name}',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Governance Section
            _SectionHeader(title: 'Governance'),
            _PlatformCard(
              icon: LucideIcons.bookOpen,
              title: 'Constitution',
              subtitle: 'Shared family values & rules',
              onTap: () => context.router.push(const ConstitutionRoute()),
            ),
            _PlatformCard(
              icon: LucideIcons.vote,
              title: 'Decisions',
              subtitle: 'Family voting and decision making',
              onTap: () => context.router.push(const DecisionsRoute()),
            ),
            _PlatformCard(
              icon: LucideIcons.users,
              title: 'Conflicts',
              subtitle: 'Dispute resolution tools',
              onTap: () => context.router.push(const ConflictResolutionRoute()),
            ),
            _PlatformCard(
              icon: LucideIcons.calendar,
              title: 'Family Council',
              subtitle: 'Schedule, manage and track meetings',
              onTap: () => context.router.push(const MeetingsRoute()),
            ),
            
            // Development Section
            _SectionHeader(title: 'Development'),
            _PlatformCard(
              icon: LucideIcons.graduationCap,
              title: 'Education',
              subtitle: 'Family learning hub',
              onTap: () => context.router.push(const EducationRoute()),
            ),
            
            // Family affairs Section
            _SectionHeader(title: 'Family affairs'),
            _PlatformCard(
              icon: LucideIcons.gitBranch,
              title: 'Family',
              subtitle: 'Organize family records',
              onTap: () => context.router.push(const MembersRoute()),
            ),
            _PlatformCard(
              icon: LucideIcons.messageSquare,
              title: 'Communication',
              subtitle: 'Centralized family messaging',
              onTap: () => context.router.push(const CommunicationRoute()),
            ),
            _PlatformCard(
              icon: LucideIcons.trendingUp,
              title: 'Assets',
              subtitle: 'Track family wealth',
              onTap: () => context.router.push(const AssetsRoute()),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: RelunaTheme.textPrimary,
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PlatformCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: RelunaTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: RelunaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
