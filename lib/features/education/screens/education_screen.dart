import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../data/models/education.dart';

// Mock data provider
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Course(
      id: '1',
      title: 'Family Governance Fundamentals',
      description: 'Learn the basics of family governance structures and best practices.',
      category: CourseCategory.familyGovernance,
      status: CourseStatus.inProgress,
      totalLessons: 12,
      completedLessons: 8,
      durationMinutes: 180,
      instructor: 'Dr. James Mitchell',
      isRequired: true,
    ),
    Course(
      id: '2',
      title: 'Wealth Management 101',
      description: 'Understanding investments, portfolio management, and wealth preservation.',
      category: CourseCategory.financialLiteracy,
      status: CourseStatus.available,
      totalLessons: 15,
      completedLessons: 0,
      durationMinutes: 240,
      instructor: 'Sarah Chen, CFA',
    ),
    Course(
      id: '3',
      title: 'Leadership Development',
      description: 'Develop essential leadership skills for family business.',
      category: CourseCategory.leadership,
      status: CourseStatus.completed,
      totalLessons: 10,
      completedLessons: 10,
      durationMinutes: 150,
      instructor: 'Michael Brown',
    ),
    Course(
      id: '4',
      title: 'Effective Communication',
      description: 'Master communication skills for family meetings and discussions.',
      category: CourseCategory.communication,
      status: CourseStatus.available,
      totalLessons: 8,
      completedLessons: 0,
      durationMinutes: 120,
      instructor: 'Dr. Lisa Park',
    ),
    Course(
      id: '5',
      title: 'Succession Planning Guide',
      description: 'Comprehensive guide to planning leadership transitions.',
      category: CourseCategory.succession,
      status: CourseStatus.available,
      totalLessons: 14,
      completedLessons: 0,
      durationMinutes: 200,
      instructor: 'Robert Williams',
      isRequired: true,
    ),
    Course(
      id: '6',
      title: 'Philanthropic Strategy',
      description: 'Design and implement effective charitable giving programs.',
      category: CourseCategory.philanthropy,
      status: CourseStatus.inProgress,
      totalLessons: 6,
      completedLessons: 2,
      durationMinutes: 90,
      instructor: 'Amanda Foster',
    ),
    Course(
      id: '7',
      title: 'Legal Essentials for Families',
      description: 'Understanding trusts, estates, and family legal structures.',
      category: CourseCategory.legal,
      status: CourseStatus.locked,
      totalLessons: 12,
      completedLessons: 0,
      durationMinutes: 180,
      instructor: 'Thomas Anderson, Esq.',
    ),
    Course(
      id: '8',
      title: 'Family Wellness & Balance',
      description: 'Maintaining healthy relationships and work-life balance.',
      category: CourseCategory.wellness,
      status: CourseStatus.available,
      totalLessons: 8,
      completedLessons: 0,
      durationMinutes: 100,
      instructor: 'Dr. Emily White',
    ),
  ];
});

final educationProgressProvider = FutureProvider<EducationProgress>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  final completed = courses.where((c) => c.status == CourseStatus.completed).length;
  final inProgress = courses.where((c) => c.status == CourseStatus.inProgress).length;
  final totalMinutes = courses
      .where((c) => c.status == CourseStatus.completed)
      .fold<int>(0, (sum, c) => sum + c.durationMinutes);
  
  return EducationProgress(
    totalCourses: courses.length,
    completedCourses: completed,
    inProgressCourses: inProgress,
    totalMinutesLearned: totalMinutes,
    earnedBadges: ['Quick Learner', 'Governance Expert'],
  );
});

@RoutePage()
class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  CourseCategory? _selectedCategory;
  CourseStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);
    final progress = ref.watch(educationProgressProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Education',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.bookmark : Icons.bookmark_border,
          onPressed: () {},
        ),
      ],
      body: Column(
        children: [
          // Progress Card
          progress.when(
            data: (data) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    RelunaTheme.info,
                    RelunaTheme.info.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${data.completionRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: data.completionRate / 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ProgressStat(
                        icon: Icons.check_circle,
                        value: '${data.completedCourses}',
                        label: 'Completed',
                      ),
                      _ProgressStat(
                        icon: Icons.play_circle,
                        value: '${data.inProgressCourses}',
                        label: 'In Progress',
                      ),
                      _ProgressStat(
                        icon: Icons.access_time,
                        value: '${(data.totalMinutesLearned / 60).toStringAsFixed(1)}h',
                        label: 'Learned',
                      ),
                    ],
                  ),
                  if (data.earnedBadges.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: data.earnedBadges.map((badge) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(badge, style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                for (final cat in CourseCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: _getCategoryLabel(cat),
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Courses List
          Expanded(
            child: courses.when(
              data: (data) {
                var filtered = data;
                if (_selectedCategory != null) {
                  filtered = filtered.where((c) => c.category == _selectedCategory).toList();
                }
                if (_selectedStatus != null) {
                  filtered = filtered.where((c) => c.status == _selectedStatus).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 64, color: RelunaTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('No courses found', style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _CourseCard(
                    course: filtered[index],
                    onTap: () => _showCourseDetails(context, filtered[index]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(CourseCategory cat) {
    switch (cat) {
      case CourseCategory.familyGovernance: return 'Governance';
      case CourseCategory.financialLiteracy: return 'Finance';
      case CourseCategory.leadership: return 'Leadership';
      case CourseCategory.communication: return 'Communication';
      case CourseCategory.succession: return 'Succession';
      case CourseCategory.philanthropy: return 'Philanthropy';
      case CourseCategory.legal: return 'Legal';
      case CourseCategory.wellness: return 'Wellness';
    }
  }

  void _showCourseDetails(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: course.statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(course.categoryIcon, color: course.statusColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title, style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Text(course.categoryLabel, style: TextStyle(
                                    color: RelunaTheme.textSecondary)),
                                  if (course.isRequired) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: RelunaTheme.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Required', style: TextStyle(
                                        color: RelunaTheme.error, fontSize: 10)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (course.status == CourseStatus.inProgress) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: TextStyle(color: RelunaTheme.textSecondary)),
                          Text('${course.completedLessons}/${course.totalLessons} lessons'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progressPercent / 100,
                          backgroundColor: RelunaTheme.surfaceDark,
                          valueColor: AlwaysStoppedAnimation(course.statusColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _DetailRow('Duration', '${course.durationMinutes} minutes'),
                    _DetailRow('Lessons', '${course.totalLessons}'),
                    if (course.instructor != null)
                      _DetailRow('Instructor', course.instructor!),
                    const SizedBox(height: 16),
                    Text(course.description, style: TextStyle(
                      color: RelunaTheme.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AdaptiveButton(
                        text: course.status == CourseStatus.inProgress 
                            ? 'Continue Learning'
                            : course.status == CourseStatus.completed
                                ? 'Review Course'
                                : course.status == CourseStatus.locked
                                    ? 'Locked'
                                    : 'Start Course',
                        onPressed: course.status == CourseStatus.locked ? null : () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? RelunaTheme.accentColor : RelunaTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : RelunaTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: course.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(course.categoryIcon, color: course.statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(course.title, style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                          if (course.isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: RelunaTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Required', style: TextStyle(
                                color: RelunaTheme.error, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(course.categoryLabel, style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 13)),
                          const Text(' • ', style: TextStyle(color: RelunaTheme.textSecondary)),
                          Text('${course.durationMinutes} min', style: TextStyle(
                            color: RelunaTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (course.status == CourseStatus.inProgress) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course.progressPercent / 100,
                        backgroundColor: RelunaTheme.surfaceDark,
                        valueColor: AlwaysStoppedAnimation(course.statusColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${course.progressPercent.toStringAsFixed(0)}%',
                      style: TextStyle(color: course.statusColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: RelunaTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
