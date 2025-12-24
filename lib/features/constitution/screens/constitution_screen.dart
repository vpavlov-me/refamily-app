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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Last edited by ${constitution.lastEditedBy}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sections with Accordion
          Text(
            'Sections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ShadAccordion<int>.multiple(
            children: constitution.sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              return ShadAccordionItem(
                value: index,
                title: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: RelunaTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
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
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.mutedForeground,
                        height: 1.6,
                      ),
                    ),
                    if (section.articles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...section.articles.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Article ${entry.key + 1}: ${entry.value}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      )),
                    ],
                    const SizedBox(height: 12),
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () => context.router.push(ConstitutionEditRoute(sectionId: section.id)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Edit Section'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
