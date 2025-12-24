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
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.mutedForeground,
          backgroundColor: theme.colorScheme.card,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Platform',
            ),
            BottomNavigationBarItem(
              icon: notificationsSummary.when(
                data: (summary) => summary.unread > 0
                    ? Badge(
                        label: Text('${summary.unread}'),
                        child: const Icon(Icons.chat_bubble_outline),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                loading: () => const Icon(Icons.chat_bubble_outline),
                error: (_, __) => const Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: const Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
