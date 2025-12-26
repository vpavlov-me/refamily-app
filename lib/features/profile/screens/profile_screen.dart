import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;

    return AppScaffold(
      title: 'Profile',
      actions: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: RelunaTheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D0084).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.pencil, size: 20),
            color: RelunaTheme.textPrimary,
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ),
        const SizedBox(width: 16),
      ],
      body: Column(
        children: [
          // Profile Header Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RelunaTheme.border,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: user?.avatar != null
                        ? Image.network(user!.avatar!, fit: BoxFit.cover)
                        : Container(
                            color: RelunaTheme.background,
                            child: Center(
                              child: Text(
                                user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: RelunaTheme.accentColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  user != null ? '${user.name} ${user.surname}' : 'Logan Roy',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: RelunaTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  user?.email ?? 'v.pavlov@reluna.com',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: RelunaTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Log out button
                GestureDetector(
                  onTap: () => _confirmLogout(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: RelunaTheme.border,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFCC0505),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  _MenuCard(
                    icon: LucideIcons.user,
                    title: 'Profile',
                    subtitle: 'View and edit you profile',
                    onTap: () => _showEditProfileDialog(context, ref),
                  ),
                  const SizedBox(height: 8),
                  // App preferences Card
                  _MenuCard(
                    icon: LucideIcons.settings,
                    title: 'App preferences',
                    subtitle: 'Setting, Themes and other',
                    onTap: () => context.router.push(const SettingsRoute()),
                  ),

                  const Spacer(),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Reluna Logo
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: RelunaTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'R',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Version info
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Version 1.0.1',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: RelunaTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Build 13',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: RelunaTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Copyright
                        const Text(
                          '2025©️ Reluna Family',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: RelunaTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.card,
        title: const Text('Edit Profile'),
        content: const Text('Profile editing will be available in a future update.'),
        actions: [
          ShadButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.card,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.router.replaceAll([const LoginRoute()]);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RelunaTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: RelunaTheme.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: RelunaTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: RelunaTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: RelunaTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: RelunaTheme.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
