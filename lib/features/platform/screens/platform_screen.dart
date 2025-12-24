import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class PlatformScreen extends ConsumerWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    final features = [
      _Feature(
        icon: Icons.gavel_outlined,
        title: 'Decision Making',
        route: '/decisions',
        color: RelunaTheme.accentColor,
        isImplemented: true,
      ),
      _Feature(
        icon: Icons.event_outlined,
        title: 'Meetings',
        route: '/meetings',
        color: RelunaTheme.info,
        isImplemented: true,
      ),
      _Feature(
        icon: Icons.people_outlined,
        title: 'Members',
        route: '/members',
        color: RelunaTheme.roleColors['Founder']!,
        isImplemented: true,
      ),
      _Feature(
        icon: Icons.balance_outlined,
        title: 'Conflict Resolution',
        route: '/conflict-resolution',
        color: RelunaTheme.warning,
        isImplemented: false,
      ),
      _Feature(
        icon: Icons.description_outlined,
        title: 'Constitution',
        route: '/constitution',
        color: RelunaTheme.success,
        isImplemented: true,
      ),
      _Feature(
        icon: Icons.forum_outlined,
        title: 'Communication',
        route: '/communication',
        color: RelunaTheme.roleColors['Chair']!,
        isImplemented: false,
      ),
      _Feature(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Assets',
        route: '/assets',
        color: RelunaTheme.roleColors['CFO']!,
        isImplemented: false,
      ),
      _Feature(
        icon: Icons.school_outlined,
        title: 'Education',
        route: '/education',
        color: RelunaTheme.roleColors['Advisor']!,
        isImplemented: false,
      ),
      _Feature(
        icon: Icons.volunteer_activism_outlined,
        title: 'Philanthropy',
        route: '/philanthropy',
        color: RelunaTheme.roleColors['Next-Gen']!,
        isImplemented: false,
      ),
      _Feature(
        icon: Icons.family_restroom,
        title: 'Succession',
        route: '/succession',
        color: const Color(0xFF6366F1),
        isImplemented: false,
      ),
    ];

    return AdaptiveScaffold(
      title: 'Platform',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Governance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: RelunaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access all family governance tools and features',
              style: TextStyle(
                fontSize: 15,
                color: RelunaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _FeatureCard(feature: feature, isIOS: isIOS);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String route;
  final Color color;
  final bool isImplemented;

  const _Feature({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
    required this.isImplemented,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool isIOS;

  const _FeatureCard({
    required this.feature,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToFeature(context, feature.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
          border: isIOS
              ? Border.all(color: RelunaTheme.divider.withValues(alpha: 0.5))
              : null,
          boxShadow: isIOS
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    feature.icon,
                    size: 28,
                    color: feature.color,
                  ),
                ),
                if (!feature.isImplemented)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: RelunaTheme.textTertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: feature.isImplemented
                    ? RelunaTheme.textPrimary
                    : RelunaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, String route) {
    switch (route) {
      case '/decisions':
        context.router.push(const DecisionsRoute());
        break;
      case '/meetings':
        context.router.push(const MeetingsRoute());
        break;
      case '/members':
        context.router.push(const MembersRoute());
        break;
      case '/conflict-resolution':
        context.router.push(const ConflictResolutionRoute());
        break;
      case '/constitution':
        context.router.push(const ConstitutionRoute());
        break;
      case '/communication':
        context.router.push(const CommunicationRoute());
        break;
      case '/assets':
        context.router.push(const AssetsRoute());
        break;
      case '/education':
        context.router.push(const EducationRoute());
        break;
      case '/philanthropy':
        context.router.push(const PhilanthropyRoute());
        break;
      case '/succession':
        context.router.push(const SuccessionRoute());
        break;
    }
  }
}
