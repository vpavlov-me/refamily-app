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
    final theme = ShadTheme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;

    return AppScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditProfileDialog(context, ref),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            _ProfileHeader(user: user),
            
            const SizedBox(height: 24),
            
            // Profile info cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ProfileInfoCard(
                    title: 'Personal Information',
                    items: [
                      _ProfileInfoItem(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: user != null ? '${user.name} ${user.surname}' : 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user?.phone ?? 'Not set',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ProfileInfoCard(
                    title: 'Family Information',
                    items: [
                      _ProfileInfoItem(
                        icon: Icons.family_restroom,
                        label: 'Family',
                        value: user?.familyName ?? 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: Icons.badge_outlined,
                        label: 'Role',
                        value: user?.role ?? 'Member',
                        valueColor: RelunaTheme.getRoleColor(user?.role ?? 'Member'),
                      ),
                      _ProfileInfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: user?.joinedAt != null 
                            ? '${user!.joinedAt!.day}/${user.joinedAt!.month}/${user.joinedAt!.year}'
                            : 'N/A',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick actions
                  _QuickActionsCard(
                    actions: [
                      _QuickAction(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => context.router.push(const SettingsRoute()),
                      ),
                      _QuickAction(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => context.router.push(const NotificationsRoute()),
                      ),
                      _QuickAction(
                        icon: Icons.security_outlined,
                        label: 'Security',
                        onTap: () => _showSecurityOptions(context, ref),
                      ),
                      _QuickAction(
                        icon: Icons.help_outline,
                        label: 'Help',
                        onTap: () => _showHelpDialog(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: () => _confirmLogout(context, ref),
                      child: const Text('Sign Out'),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App version
                  Text(
                    'Reluna Family v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
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

  void _showSecurityOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('Change PIN'),
            onTap: () {
              Navigator.pop(context);
              context.router.push(const PinSetupRoute());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Enable Biometric'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = ShadTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.card,
        title: const Text('Help & Support'),
        content: const Text('For assistance, please contact support@reluna.com'),
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

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          ShadAvatar(
            user?.avatar ?? 'placeholder',
            size: const Size(100, 100),
            placeholder: Text(
              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user != null ? '${user.name} ${user.surname}' : 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 4),
          if (user?.role != null)
            RoleBadge(role: user!.role),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<_ProfileInfoItem> items;

  const _ProfileInfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.border),
          ...items,
        ],
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.mutedForeground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? theme.colorScheme.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final List<_QuickAction> actions;

  const _QuickActionsCard({required this.actions});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
