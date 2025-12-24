import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';

@RoutePage()
class ConstitutionVersionsScreen extends ConsumerWidget {
  const ConstitutionVersionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versions = ref.watch(constitutionVersionsProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Version History',
      hasBackButton: true,
      body: versions.when(
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIOS ? CupertinoIcons.doc_text : Icons.history,
                      size: 64,
                      color: RelunaTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No version history',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: RelunaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final version = data[index];
                  final isLatest = index == 0;
                  return _VersionCard(
                    version: version,
                    isLatest: isLatest,
                  );
                },
              ),
        loading: () => const Center(child: AdaptiveLoadingIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load versions')),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final ConstitutionVersion version;
  final bool isLatest;

  const _VersionCard({
    required this.version,
    required this.isLatest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelunaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest
              ? RelunaTheme.success.withValues(alpha: 0.5)
              : RelunaTheme.divider,
          width: isLatest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLatest
                      ? RelunaTheme.success.withValues(alpha: 0.1)
                      : RelunaTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'v${version.version}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLatest ? RelunaTheme.success : RelunaTheme.textSecondary,
                  ),
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelunaTheme.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                DateFormat('MMM d, y').format(version.publishedAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: RelunaTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            version.changesSummary,
            style: const TextStyle(
              fontSize: 15,
              color: RelunaTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: RelunaTheme.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Published by ${version.publishedBy}',
                style: const TextStyle(
                  fontSize: 13,
                  color: RelunaTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (version.sectionsChanged.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: version.sectionsChanged.map((section) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelunaTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    section,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RelunaTheme.info,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
