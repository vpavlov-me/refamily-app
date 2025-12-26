import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/shared.dart';

@RoutePage()
class ConstitutionScreen extends ConsumerWidget {
  const ConstitutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constitution = ref.watch(constitutionProvider);

    return AppScaffold(
      title: 'Constitution',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => context.router.push(const ConstitutionVersionsRoute()),
        ),
      ],
      body: constitution.when(
        data: (data) => _ConstitutionContent(constitution: data),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, _) => ErrorState(
          message: 'Failed to load constitution',
          onRetry: () => ref.invalidate(constitutionProvider),
        ),
      ),
    );
  }
}

class _ConstitutionContent extends StatelessWidget {
  final Constitution constitution;

  const _ConstitutionContent({required this.constitution});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                RelunaTheme.accentColor.withValues(alpha: 0.1),
                RelunaTheme.info.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: RelunaTheme.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          constitution.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShadBadge.secondary(
                          child: Text('Version ${constitution.version}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (constitution.preamble.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  constitution.preamble,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Last edited by ${constitution.lastEditedBy}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Sections Title
        Text(
          'Sections',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 12),
        
        // Sections List (no accordion to avoid scroll conflicts)
        ...constitution.sections.map((section) => _SectionCard(section: section)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ConstitutionSection section;
  
  const _SectionCard({required this.section});
  
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.router.push(ConstitutionEditRoute(sectionId: section.id)),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${section.order}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: RelunaTheme.info,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  section.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.mutedForeground,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
