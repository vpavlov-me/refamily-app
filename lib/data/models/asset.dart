import 'package:flutter/material.dart';

enum AssetType {
  realEstate,
  investment,
  business,
  vehicle,
  collectible,
  crypto,
  cash,
  other,
}

enum AssetStatus {
  active,
  pending,
  sold,
  transferred,
}

class Asset {
  final String id;
  final String name;
  final String description;
  final AssetType type;
  final AssetStatus status;
  final double currentValue;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String? location;
  final String ownerId;
  final String ownerName;
  final List<String> beneficiaryIds;
  final double ownershipPercentage;
  final String? imageUrl;
  final DateTime lastUpdated;
  
  const Asset({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.currentValue,
    required this.purchasePrice,
    required this.purchaseDate,
    this.location,
    required this.ownerId,
    required this.ownerName,
    required this.beneficiaryIds,
    this.ownershipPercentage = 100.0,
    this.imageUrl,
    required this.lastUpdated,
  });
  
  double get valueChange => currentValue - purchasePrice;
  double get valueChangePercent => purchasePrice > 0 ? (valueChange / purchasePrice) * 100 : 0;
  
  IconData get typeIcon {
    switch (type) {
      case AssetType.realEstate:
        return Icons.home;
      case AssetType.investment:
        return Icons.trending_up;
      case AssetType.business:
        return Icons.business;
      case AssetType.vehicle:
        return Icons.directions_car;
      case AssetType.collectible:
        return Icons.diamond;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.cash:
        return Icons.account_balance;
      case AssetType.other:
        return Icons.category;
    }
  }
  
  String get typeLabel {
    switch (type) {
      case AssetType.realEstate:
        return 'Real Estate';
      case AssetType.investment:
        return 'Investment';
      case AssetType.business:
        return 'Business';
      case AssetType.vehicle:
        return 'Vehicle';
      case AssetType.collectible:
        return 'Collectible';
      case AssetType.crypto:
        return 'Cryptocurrency';
      case AssetType.cash:
        return 'Cash';
      case AssetType.other:
        return 'Other';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case AssetStatus.active:
        return Colors.green;
      case AssetStatus.pending:
        return Colors.orange;
      case AssetStatus.sold:
        return Colors.grey;
      case AssetStatus.transferred:
        return Colors.blue;
    }
  }
}

class AssetsSummary {
  final double totalValue;
  final double totalGain;
  final int totalAssets;
  final Map<AssetType, double> allocationByType;
  
  const AssetsSummary({
    required this.totalValue,
    required this.totalGain,
    required this.totalAssets,
    required this.allocationByType,
  });
}
