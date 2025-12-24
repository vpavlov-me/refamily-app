import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../data/models/philanthropy.dart';

// Mock data providers
final causesProvider = FutureProvider<List<PhilanthropicCause>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    PhilanthropicCause(
      id: '1',
      name: 'Youth Education Fund',
      description: 'Supporting underprivileged students with scholarships and educational resources.',
      category: CauseCategory.education,
      organizationName: 'Future Leaders Foundation',
      targetAmount: 100000,
      currentAmount: 75000,
      deadline: DateTime(2025, 6, 30),
      isFamilyPriority: true,
      supporterIds: ['user1', 'user2', 'user3'],
    ),
    PhilanthropicCause(
      id: '2',
      name: 'Community Health Initiative',
      description: 'Building and equipping local health clinics in underserved areas.',
      category: CauseCategory.health,
      organizationName: 'Health For All',
      targetAmount: 250000,
      currentAmount: 180000,
      deadline: DateTime(2025, 12, 31),
      isFamilyPriority: true,
      supporterIds: ['user1', 'user2'],
    ),
    PhilanthropicCause(
      id: '3',
      name: 'Environmental Conservation',
      description: 'Protecting local wildlife habitats and promoting sustainable practices.',
      category: CauseCategory.environment,
      organizationName: 'Green Earth Society',
      targetAmount: 50000,
      currentAmount: 32000,
      supporterIds: ['user2', 'user4'],
    ),
    PhilanthropicCause(
      id: '4',
      name: 'Arts & Culture Program',
      description: 'Supporting local artists and cultural preservation initiatives.',
      category: CauseCategory.arts,
      organizationName: 'Cultural Heritage Foundation',
      targetAmount: 75000,
      currentAmount: 45000,
      supporterIds: ['user1'],
    ),
    PhilanthropicCause(
      id: '5',
      name: 'Food Security Project',
      description: 'Establishing community gardens and food banks for families in need.',
      category: CauseCategory.poverty,
      organizationName: 'Feed The Future',
      targetAmount: 80000,
      currentAmount: 60000,
      isFamilyPriority: true,
      supporterIds: ['user1', 'user2', 'user3', 'user4'],
    ),
  ];
});

final donationsProvider = FutureProvider<List<Donation>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Donation(
      id: '1',
      causeId: '1',
      causeName: 'Youth Education Fund',
      donorId: 'user1',
      donorName: 'Robert Johnson',
      amount: 25000,
      status: DonationStatus.completed,
      date: DateTime(2025, 1, 15),
    ),
    Donation(
      id: '2',
      causeId: '2',
      causeName: 'Community Health Initiative',
      donorId: 'user1',
      donorName: 'Robert Johnson',
      amount: 50000,
      status: DonationStatus.completed,
      date: DateTime(2025, 2, 20),
    ),
    Donation(
      id: '3',
      causeId: '5',
      causeName: 'Food Security Project',
      donorId: 'user2',
      donorName: 'Sarah Johnson',
      amount: 10000,
      status: DonationStatus.recurring,
      date: DateTime(2025, 1, 1),
      isRecurring: true,
      recurringFrequency: 'Monthly',
    ),
  ];
});

final philanthropySummaryProvider = FutureProvider<PhilanthropySummary>((ref) async {
  final donations = await ref.watch(donationsProvider.future);
  final causes = await ref.watch(causesProvider.future);
  
  final totalDonated = donations.fold<double>(0, (sum, d) => sum + d.amount);
  final yearlyDonated = donations
      .where((d) => d.date.year == DateTime.now().year)
      .fold<double>(0, (sum, d) => sum + d.amount);
  
  return PhilanthropySummary(
    totalDonated: totalDonated,
    yearlyDonated: yearlyDonated,
    causesSupported: causes.length,
    activeCampaigns: causes.where((c) => c.deadline?.isAfter(DateTime.now()) ?? true).length,
    allocationByCategory: {},
  );
});

@RoutePage()
class PhilanthropyScreen extends ConsumerStatefulWidget {
  const PhilanthropyScreen({super.key});

  @override
  ConsumerState<PhilanthropyScreen> createState() => _PhilanthropyScreenState();
}

class _PhilanthropyScreenState extends ConsumerState<PhilanthropyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CauseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final causes = ref.watch(causesProvider);
    final donations = ref.watch(donationsProvider);
    final summary = ref.watch(philanthropySummaryProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AdaptiveScaffold(
      title: 'Philanthropy',
      hasBackButton: true,
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.add : Icons.add,
          onPressed: () => _showAddCauseDialog(context),
        ),
      ],
      body: Column(
        children: [
          // Summary Card
          summary.when(
            data: (data) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple,
                    Colors.purple.withValues(alpha: 0.8),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Donated', style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(currencyFormat.format(data.totalDonated),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryStat(
                        value: currencyFormat.format(data.yearlyDonated),
                        label: 'This Year',
                      ),
                      _SummaryStat(
                        value: '${data.causesSupported}',
                        label: 'Causes',
                      ),
                      _SummaryStat(
                        value: '${data.activeCampaigns}',
                        label: 'Active',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: RelunaTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: RelunaTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: RelunaTheme.textSecondary,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Causes'),
                Tab(text: 'Donations'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Causes Tab
                causes.when(
                  data: (data) {
                    final priorityCauses = data.where((c) => c.isFamilyPriority).toList();
                    final otherCauses = data.where((c) => !c.isFamilyPriority).toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (priorityCauses.isNotEmpty) ...[
                          const _SectionHeader('Family Priorities'),
                          ...priorityCauses.map((c) => _CauseCard(
                            cause: c,
                            onTap: () => _showCauseDetails(context, c),
                            onDonate: () => _showDonateDialog(context, c),
                          )),
                          const SizedBox(height: 16),
                        ],
                        if (otherCauses.isNotEmpty) ...[
                          const _SectionHeader('Other Causes'),
                          ...otherCauses.map((c) => _CauseCard(
                            cause: c,
                            onTap: () => _showCauseDetails(context, c),
                            onDonate: () => _showDonateDialog(context, c),
                          )),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),

                // Donations Tab
                donations.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: RelunaTheme.textSecondary),
                            const SizedBox(height: 16),
                            Text('No donations yet', style: TextStyle(color: RelunaTheme.textSecondary)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.length,
                      itemBuilder: (context, index) => _DonationCard(donation: data[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCauseDialog(BuildContext context) {
    AdaptiveDialog.show(
      context: context,
      title: 'Add Cause',
      content: 'Create a new philanthropic cause for the family to support.',
      confirmText: 'Create',
      cancelText: 'Cancel',
      onConfirm: () {
        // Add cause logic would go here
      },
    );
  }

  void _showDonateDialog(BuildContext context, PhilanthropicCause cause) {
    AdaptiveDialog.show(
      context: context,
      title: 'Donate to ${cause.name}',
      content: 'Choose an amount to donate to this cause.',
      confirmText: 'Donate',
      cancelText: 'Cancel',
      onConfirm: () {
        // Donate logic would go here
      },
    );
  }

  void _showCauseDetails(BuildContext context, PhilanthropicCause cause) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
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
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cause.categoryIcon, color: Colors.purple, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cause.name, style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                              if (cause.organizationName != null)
                                Text(cause.organizationName!, style: TextStyle(
                                  color: RelunaTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${currencyFormat.format(cause.currentAmount)} raised',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Goal: ${currencyFormat.format(cause.targetAmount)}',
                            style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cause.progressPercent / 100,
                        backgroundColor: RelunaTheme.surfaceDark,
                        valueColor: const AlwaysStoppedAnimation(Colors.purple),
                        minHeight: 10,
                      ),
                    ),
                    Text('${cause.progressPercent.toStringAsFixed(0)}% funded',
                        style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 24),
                    Text(cause.description, style: TextStyle(
                      color: RelunaTheme.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 18, color: RelunaTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text('${cause.supporterIds.length} family supporters',
                            style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AdaptiveButton(
                        text: 'Make a Donation',
                        onPressed: () {
                          Navigator.pop(context);
                          _showDonateDialog(context, cause);
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

class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: RelunaTheme.textPrimary)),
    );
  }
}

class _CauseCard extends StatelessWidget {
  final PhilanthropicCause cause;
  final VoidCallback onTap;
  final VoidCallback onDonate;

  const _CauseCard({required this.cause, required this.onTap, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cause.isFamilyPriority 
              ? Colors.purple.withValues(alpha: 0.3) 
              : RelunaTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cause.categoryIcon, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(cause.name, style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                          if (cause.isFamilyPriority)
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                        ],
                      ),
                      Text(cause.categoryLabel, style: TextStyle(
                        color: RelunaTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: cause.progressPercent / 100,
                          backgroundColor: RelunaTheme.surfaceDark,
                          valueColor: const AlwaysStoppedAnimation(Colors.purple),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currencyFormat.format(cause.currentAmount)} / ${currencyFormat.format(cause.targetAmount)}',
                        style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onDonate,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    foregroundColor: Colors.purple,
                  ),
                  child: const Text('Donate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final Donation donation;

  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelunaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelunaTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: donation.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              donation.isRecurring ? Icons.repeat : Icons.volunteer_activism,
              color: donation.statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation.causeName, style: const TextStyle(
                  fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text(donation.donorName, style: TextStyle(
                      color: RelunaTheme.textSecondary, fontSize: 13)),
                    if (donation.isRecurring) ...[
                      const Text(' • ', style: TextStyle(color: RelunaTheme.textSecondary)),
                      Text(donation.recurringFrequency ?? 'Recurring',
                          style: TextStyle(color: donation.statusColor, fontSize: 13)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currencyFormat.format(donation.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(dateFormat.format(donation.date),
                  style: TextStyle(color: RelunaTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
