import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/models.dart';

@RoutePage()
class ConstitutionEditScreen extends ConsumerStatefulWidget {
  @PathParam('sectionId')
  final String sectionId;

  const ConstitutionEditScreen({
    super.key,
    required this.sectionId,
  });

  @override
  ConsumerState<ConstitutionEditScreen> createState() => _ConstitutionEditScreenState();
}

class _ConstitutionEditScreenState extends ConsumerState<ConstitutionEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeControllers(ConstitutionSection section) {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      _titleController.text = section.title;
      _contentController.text = section.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final constitution = ref.watch(constitutionProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return constitution.when(
      data: (data) {
        final section = data.sections.firstWhere(
          (s) => s.id == widget.sectionId,
          orElse: () => data.sections.first,
        );
        _initializeControllers(section);

        return AdaptiveScaffold(
          title: 'Section ${section.order}',
          hasBackButton: true,
          actions: [
            if (_isEditing)
              AdaptiveTextButton(
                text: 'Save',
                onPressed: _hasChanges ? () => _saveChanges(section) : null,
              )
            else
              AdaptiveIconButton(
                icon: isIOS ? CupertinoIcons.pencil : Icons.edit_outlined,
                onPressed: () => setState(() => _isEditing = true),
              ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                if (!_isEditing) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: RelunaTheme.info.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RelunaTheme.info.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: RelunaTheme.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${section.order}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: RelunaTheme.info,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                section.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: RelunaTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          section.content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: RelunaTheme.textPrimary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Articles
                  if (section.articles.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: RelunaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.articles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final article = entry.value;
                      return _ArticleCard(
                        number: index + 1,
                        content: article,
                      );
                    }),
                  ],
                ] else ...[
                  // Edit mode
                  const Text(
                    'Section Title',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AdaptiveTextField(
                    controller: _titleController,
                    placeholder: 'Enter section title',
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Content',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: RelunaTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: RelunaTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RelunaTheme.divider),
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: 15,
                      onChanged: (_) => setState(() => _hasChanges = true),
                      decoration: const InputDecoration(
                        hintText: 'Enter section content...',
                        hintStyle: TextStyle(color: RelunaTheme.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: RelunaTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AdaptiveButton(
                          text: 'Cancel',
                          isOutlined: true,
                          onPressed: () {
                            _titleController.text = section.title;
                            _contentController.text = section.content;
                            setState(() {
                              _isEditing = false;
                              _hasChanges = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
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
        body: const Center(child: Text('Failed to load section')),
      ),
    );
  }

  void _saveChanges(ConstitutionSection section) {
    // In a real app, this would call an API
    AdaptiveDialog.show(
      context: context,
      title: 'Changes Saved',
      content: 'Your changes to "${_titleController.text}" have been saved and are pending review.',
      confirmText: 'OK',
      onConfirm: () {
        setState(() {
          _isEditing = false;
          _hasChanges = false;
        });
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final int number;
  final String content;

  const _ArticleCard({
    required this.number,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelunaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelunaTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RelunaTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: RelunaTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
