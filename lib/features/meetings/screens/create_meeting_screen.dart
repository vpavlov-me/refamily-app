import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';

// Meeting types as strings (matching Meeting model)
const List<String> _meetingTypes = [
  'General',
  'Family Council',
  'Investment Review',
  'Succession Planning',
  'Emergency',
];

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedType = 'General';
  int _durationMinutes = 60;
  
  final List<String> _selectedAttendees = [];
  
  // Mock family members
  final List<Map<String, String>> _familyMembers = [
    {'id': '1', 'name': 'Victoria Reluna', 'role': 'Family Head'},
    {'id': '2', 'name': 'Michael Reluna', 'role': 'Investment Lead'},
    {'id': '3', 'name': 'Sophia Reluna', 'role': 'Next-Gen Representative'},
    {'id': '4', 'name': 'James Reluna', 'role': 'Council Member'},
    {'id': '5', 'name': 'Emma Reluna', 'role': 'Council Member'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'New Meeting',
      hasBackButton: true,
      actions: [
        AdaptiveTextButton(
          text: 'Create',
          onPressed: _createMeeting,
        ),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Meeting Type
            _SectionTitle(title: 'Meeting Type'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: RelunaTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _meetingTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getTypeIcon(type), color: RelunaTheme.accentColor, size: 20),
                          const SizedBox(width: 12),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedType = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _SectionTitle(title: 'Title'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter meeting title',
                filled: true,
                fillColor: RelunaTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description
            _SectionTitle(title: 'Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter meeting description',
                filled: true,
                fillColor: RelunaTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time
            _SectionTitle(title: 'Date & Time'),
            Row(
              children: [
                Expanded(
                  child: _SelectionTile(
                    icon: isIOS ? CupertinoIcons.calendar : Icons.calendar_today,
                    label: DateFormat('MMM d, yyyy').format(_selectedDate),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectionTile(
                    icon: isIOS ? CupertinoIcons.clock : Icons.access_time,
                    label: _selectedTime.format(context),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Duration
            _SectionTitle(title: 'Duration'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: RelunaTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isIOS ? CupertinoIcons.timer : Icons.timelapse,
                    color: RelunaTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [30, 60, 90, 120].map((minutes) {
                        final isSelected = _durationMinutes == minutes;
                        return ChoiceChip(
                          label: Text(minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}'),
                          selected: isSelected,
                          selectedColor: RelunaTheme.accentColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : RelunaTheme.textPrimary,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _durationMinutes = minutes);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Location
            _SectionTitle(title: 'Location'),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter location or video link',
                prefixIcon: Icon(
                  isIOS ? CupertinoIcons.location : Icons.location_on_outlined,
                  color: RelunaTheme.textSecondary,
                ),
                filled: true,
                fillColor: RelunaTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Attendees
            _SectionTitle(title: 'Attendees'),
            Container(
              decoration: BoxDecoration(
                color: RelunaTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _familyMembers.map((member) {
                  final isSelected = _selectedAttendees.contains(member['id']);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedAttendees.add(member['id']!);
                        } else {
                          _selectedAttendees.remove(member['id']);
                        }
                      });
                    },
                    title: Text(member['name']!),
                    subtitle: Text(
                      member['role']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: RelunaTheme.textSecondary,
                      ),
                    ),
                    secondary: CircleAvatar(
                      backgroundColor: RelunaTheme.accentColor.withValues(alpha: 0.2),
                      child: Text(
                        member['name']![0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: RelunaTheme.accentColor,
                        ),
                      ),
                    ),
                    activeColor: RelunaTheme.accentColor,
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Create Button
            ElevatedButton(
              onPressed: _createMeeting,
              style: ElevatedButton.styleFrom(
                backgroundColor: RelunaTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Meeting',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _createMeeting() {
    if (_formKey.currentState!.validate()) {
      // Create meeting logic would go here
      // For now, show success and go back
      AdaptiveDialog.show(
        context: context,
        title: 'Meeting Created',
        content: 'Your meeting "${_titleController.text}" has been scheduled for ${DateFormat('MMM d, yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}.',
        confirmText: 'OK',
        onConfirm: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Family Council':
        return Icons.groups;
      case 'Investment Review':
        return Icons.trending_up;
      case 'Succession Planning':
        return Icons.swap_horiz;
      case 'Emergency':
        return Icons.warning;
      case 'General':
      default:
        return Icons.event;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: RelunaTheme.textSecondary,
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: RelunaTheme.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdaptiveTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AdaptiveTextButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: RelunaTheme.accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: RelunaTheme.accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
