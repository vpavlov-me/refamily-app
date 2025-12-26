import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../data/models/asset.dart';

// Mock data provider
final assetsProvider = FutureProvider<List<Asset>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Asset(
      id: '1',
      name: 'Family Estate',
      description: 'Main family residence with 10 acres',
      type: AssetType.realEstate,
      status: AssetStatus.active,
      currentValue: 2500000,
      purchasePrice: 1800000,
      purchaseDate: DateTime(2015, 6, 15),
      location: 'Greenwich, CT',
      ownerId: 'user1',
      ownerName: 'Robert Johnson',
      beneficiaryIds: ['user2', 'user3'],
      lastUpdated: DateTime.now(),
    ),
    Asset(
      id: '2',
      name: 'Investment Portfolio',
      description: 'Diversified stock and bond portfolio',
      type: AssetType.investment,
      status: AssetStatus.active,
      currentValue: 5200000,
      purchasePrice: 3500000,
      purchaseDate: DateTime(2010, 1, 10),
      ownerId: 'user1',
      ownerName: 'Robert Johnson',
      beneficiaryIds: ['user2', 'user3', 'user4'],
      lastUpdated: DateTime.now(),
    ),
    Asset(
      id: '3',
      name: 'Family Business',
      description: 'Johnson Manufacturing LLC',
      type: AssetType.business,
      status: AssetStatus.active,
      currentValue: 15000000,
      purchasePrice: 8000000,
      purchaseDate: DateTime(2005, 3, 20),
      location: 'Boston, MA',
      ownerId: 'user1',
      ownerName: 'Robert Johnson',
      beneficiaryIds: ['user2'],
      ownershipPercentage: 60,
      lastUpdated: DateTime.now(),
    ),
    Asset(
      id: '4',
      name: 'Vacation Home',
      description: 'Beach house in the Hamptons',
      type: AssetType.realEstate,
      status: AssetStatus.active,
      currentValue: 1800000,
      purchasePrice: 1200000,
      purchaseDate: DateTime(2018, 7, 1),
      location: 'East Hampton, NY',
      ownerId: 'user2',
      ownerName: 'Sarah Johnson',
      beneficiaryIds: ['user3', 'user4'],
      lastUpdated: DateTime.now(),
    ),
    Asset(
      id: '5',
      name: 'Art Collection',
      description: 'Contemporary art pieces',
      type: AssetType.collectible,
      status: AssetStatus.active,
      currentValue: 450000,
      purchasePrice: 280000,
      purchaseDate: DateTime(2012, 9, 5),
      ownerId: 'user1',
      ownerName: 'Robert Johnson',
      beneficiaryIds: ['user2'],
      lastUpdated: DateTime.now(),
    ),
    Asset(
      id: '6',
      name: 'Cryptocurrency Holdings',
      description: 'Bitcoin and Ethereum portfolio',
      type: AssetType.crypto,
      status: AssetStatus.active,
      currentValue: 320000,
      purchasePrice: 150000,
      purchaseDate: DateTime(2020, 12, 1),
      ownerId: 'user3',
      ownerName: 'Michael Johnson',
      beneficiaryIds: [],
      lastUpdated: DateTime.now(),
    ),
  ];
});

final assetsSummaryProvider = FutureProvider<AssetsSummary>((ref) async {
  final assets = await ref.watch(assetsProvider.future);
  final totalValue = assets.fold<double>(0, (sum, a) => sum + a.currentValue);
  final totalGain = assets.fold<double>(0, (sum, a) => sum + a.valueChange);
  
  final allocationByType = <AssetType, double>{};
  for (final asset in assets) {
    allocationByType[asset.type] = (allocationByType[asset.type] ?? 0) + asset.currentValue;
  }
  
  return AssetsSummary(
    totalValue: totalValue,
    totalGain: totalGain,
    totalAssets: assets.length,
    allocationByType: allocationByType,
  );
});

@RoutePage()
class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  AssetType? _selectedType;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final summary = ref.watch(assetsSummaryProvider);
    
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return AppScaffold(
      title: 'Assets',
      hasBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddAssetDialog(context),
        ),
      ],
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShadInput(
              placeholder: const Text('Search assets...'),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Type Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                for (final type in AssetType.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: _getTypeLabel(type),
                      isSelected: _selectedType == type,
                      onTap: () => setState(() => _selectedType = type),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Assets List
          Expanded(
            child: assets.when(
              data: (data) {
                var filtered = data;
                if (_selectedType != null) {
                  filtered = filtered.where((a) => a.type == _selectedType).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((a) =>
                    a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    a.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, 
                            size: 64, color: RelunaTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text('No assets found',
                            style: TextStyle(color: RelunaTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _AssetCard(
                    asset: filtered[index],
                    onTap: () => _showAssetDetails(context, filtered[index]),
                  ),
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(AssetType type) {
    switch (type) {
      case AssetType.realEstate: return 'Real Estate';
      case AssetType.investment: return 'Investment';
      case AssetType.business: return 'Business';
      case AssetType.vehicle: return 'Vehicle';
      case AssetType.collectible: return 'Collectible';
      case AssetType.crypto: return 'Crypto';
      case AssetType.cash: return 'Cash';
      case AssetType.other: return 'Other';
    }
  }

  void _showAddAssetDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Add Asset'),
        description: const Text('Create a new asset entry for your family portfolio.'),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ShadButton(
            child: const Text('Add'),
            onPressed: () {
              Navigator.pop(context);
              // Add asset logic would go here
            },
          ),
        ],
      ),
    );
  }

  void _showAssetDetails(BuildContext context, Asset asset) {
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
                            color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(asset.typeIcon, color: RelunaTheme.accentColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(asset.name, style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(asset.typeLabel, style: TextStyle(
                                color: RelunaTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _DetailRow('Current Value', currencyFormat.format(asset.currentValue)),
                    _DetailRow('Purchase Price', currencyFormat.format(asset.purchasePrice)),
                    _DetailRow('Total Gain', 
                      '${asset.valueChange >= 0 ? '+' : ''}${currencyFormat.format(asset.valueChange)} (${asset.valueChangePercent.toStringAsFixed(1)}%)',
                      valueColor: asset.valueChange >= 0 ? RelunaTheme.success : RelunaTheme.error,
                    ),
                    _DetailRow('Owner', asset.ownerName),
                    if (asset.location != null)
                      _DetailRow('Location', asset.location!),
                    _DetailRow('Ownership', '${asset.ownershipPercentage.toStringAsFixed(0)}%'),
                    _DetailRow('Purchase Date', DateFormat('MMM d, yyyy').format(asset.purchaseDate)),
                    const SizedBox(height: 16),
                    Text(asset.description, style: TextStyle(
                      color: RelunaTheme.textSecondary, height: 1.5)),
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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

class _AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const _AssetCard({required this.asset, required this.onTap});

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
          border: Border.all(color: RelunaTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(asset.typeIcon, color: RelunaTheme.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.name, style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(asset.typeLabel, style: TextStyle(
                    color: RelunaTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currencyFormat.format(asset.currentValue),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      asset.valueChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: asset.valueChange >= 0 ? RelunaTheme.success : RelunaTheme.error,
                    ),
                    Text(
                      '${asset.valueChangePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: asset.valueChange >= 0 ? RelunaTheme.success : RelunaTheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: RelunaTheme.textSecondary)),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor ?? RelunaTheme.textPrimary,
          )),
        ],
      ),
    );
  }
}
