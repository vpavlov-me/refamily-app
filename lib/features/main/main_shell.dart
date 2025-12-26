import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/providers/providers.dart';
import '../../core/router/app_router.dart';

@RoutePage()
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final notificationsSummary = ref.watch(notificationsSummaryProvider);

    return AutoTabsScaffold(
      routes: const [
        DashboardRoute(),
        PlatformRoute(),
        ChatRoute(),
      ],
      extendBody: true,
      bottomNavigationBuilder: (context, tabsRouter) {
        return Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    isActive: tabsRouter.activeIndex == 0,
                    onTap: () => tabsRouter.setActiveIndex(0),
                    theme: theme,
                  ),
                  _NavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view,
                    isActive: tabsRouter.activeIndex == 1,
                    onTap: () => tabsRouter.setActiveIndex(1),
                    theme: theme,
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    isActive: tabsRouter.activeIndex == 2,
                    onTap: () => tabsRouter.setActiveIndex(2),
                    theme: theme,
                    badge: notificationsSummary.when(
                      data: (summary) => summary.unread > 0 ? summary.unread : null,
                      loading: () => null,
                      error: (_, __) => null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final ShadThemeData theme;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.theme,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      isActive ? activeIcon : icon,
      color: isActive ? theme.colorScheme.primary : theme.colorScheme.mutedForeground,
      size: 26,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: badge != null
              ? Badge(
                  label: Text('$badge'),
                  child: iconWidget,
                )
              : iconWidget,
        ),
      ),
    );
  }
}
