import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';

@RoutePage()
class DecisionCreateScreen extends ConsumerStatefulWidget {
  const DecisionCreateScreen({super.key});

  @override
  ConsumerState<DecisionCreateScreen> createState() => _DecisionCreateScreenState();
}

class _DecisionCreateScreenState extends ConsumerState<DecisionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;
  String _category = 'General';
  bool _isLoading = false;

  final _categories = [
    'General',
    'Financial',
    'Governance',
    'Investment',
    'Family Affairs',
    'Succession',
    'Philanthropy',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    return AppScaffold(
      title: 'New Decision',
      hasBackButton: true,
      actions: [
        ShadButton.link(
          child: const Text('Submit'),
          onPressed: _isLoading ? null : _submitDecision,
        ),
      ],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RelunaTheme.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RelunaTheme.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: RelunaTheme.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Decisions will be sent to all voting members for review and approval.',
                        style: TextStyle(
                          fontSize: 14,
                          color: RelunaTheme.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ShadInput(
                controller: _titleController,
                placeholder: const Text('Enter decision title'),
              ),
              const SizedBox(height: 20),

              // Category
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: RelunaTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RelunaTheme.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    style: const TextStyle(
                      fontSize: 16,
                      color: RelunaTheme.textPrimary,
                    ),
                    dropdownColor: RelunaTheme.surfaceLight,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Deadline
              const Text(
                'Deadline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDeadline(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RelunaTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RelunaTheme.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: RelunaTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _deadline != null
                            ? '${_deadline!.month}/${_deadline!.day}/${_deadline!.year}'
                            : 'Select deadline',
                        style: TextStyle(
                          fontSize: 16,
                          color: _deadline != null
                              ? RelunaTheme.textPrimary
                              : RelunaTheme.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (_deadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _deadline = null),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: RelunaTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
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
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Describe the decision in detail...',
                    hintStyle: TextStyle(color: RelunaTheme.textTertiary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: RelunaTheme.textPrimary,
                    height: 1.5,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  child: Text(_isLoading ? 'Submitting...' : 'Submit Decision'),
                  onPressed: _isLoading ? null : _submitDecision,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ShadButton.outline(
                  child: const Text('Save as Draft'),
                  onPressed: _isLoading ? null : _saveDraft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final isIOS = Platform.isIOS;
    
    if (isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: RelunaTheme.surfaceLight,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _deadline ?? DateTime.now().add(const Duration(days: 7)),
                  minimumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    setState(() => _deadline = date);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (date != null) {
        setState(() => _deadline = date);
      }
    }
  }

  void _submitDecision() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        
        showShadDialog(
          context: context,
          builder: (dialogContext) => ShadDialog.alert(
            title: const Text('Decision Submitted'),
            description: const Text('Your decision has been submitted for voting. You will be notified when votes are cast.'),
            actions: [
              ShadButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.router.maybePop();
                },
              ),
            ],
          ),
        );
      });
    }
  }

  void _saveDraft() {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Draft Saved'),
        description: const Text('Your decision has been saved as a draft. You can continue editing it later.'),
        actions: [
          ShadButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
