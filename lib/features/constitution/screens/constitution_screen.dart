import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class ConstitutionScreen extends ConsumerWidget {
  const ConstitutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constitution = ref.watch(constitutionProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Constitution',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.clock : Icons.history,
          onPressed: () => context.router.push(const ConstitutionVersionsRoute()),
        ),
      ],
      body: constitution.when(
        data: (data) => _ConstitutionContent(constitution: data),
        loading: () => const Center(child: AdaptiveLoadingIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isIOS ? CupertinoIcons.exclamationmark_triangle : Icons.error_outline,
                size: 48,
                color: RelunaTheme.error,
              ),
              const SizedBox(height: 16),
              const Text('Failed to load constitution'),
              const SizedBox(height: 8),
              AdaptiveButton(
                text: 'Retry',
                onPressed: () => ref.invalidate(constitutionProvider),
              ),
            ],
          ),
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
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: RelunaTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: RelunaTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Version ${constitution.version}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: RelunaTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  constitution.preamble,
                  style: const TextStyle(
                    fontSize: 14,
                    color: RelunaTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: RelunaTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Last edited by ${constitution.lastEditedBy}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RelunaTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sections
          const Text(
            'Sections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RelunaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...constitution.sections.map((section) => _SectionCard(
            section: section,
            onTap: () => context.router.push(ConstitutionEditRoute(sectionId: section.id)),
          )),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ConstitutionSection section;
  final VoidCallback? onTap;

  const _SectionCard({
    required this.section,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RelunaTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${section.order}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: RelunaTheme.info,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: RelunaTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: RelunaTheme.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.content.length > 150
                ? '${section.content.substring(0, 150)}...'
                : section.content,
            style: const TextStyle(
              fontSize: 14,
              color: RelunaTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (section.articles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelunaTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${section.articles.length} articles',
                    style: const TextStyle(
                      fontSize: 11,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
