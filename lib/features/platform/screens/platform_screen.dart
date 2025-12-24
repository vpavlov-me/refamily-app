import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/shared.dart';

@RoutePage()
class PlatformScreen extends ConsumerWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

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

    return AppScaffold(
      title: 'Platform',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Governance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access all family governance tools and features',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.mutedForeground,
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
                return FeatureCard(
                  icon: feature.icon,
                  title: feature.title,
                  color: feature.color,
                  isImplemented: feature.isImplemented,
                  onTap: () => _navigateToFeature(context, feature.route),
                );
              },
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
