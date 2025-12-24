import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Profile',
      actions: [
        AdaptiveIconButton(
          icon: isIOS ? CupertinoIcons.pencil : Icons.edit_outlined,
          onPressed: () {
            _showEditProfileDialog(context, ref);
          },
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
                        icon: isIOS ? CupertinoIcons.person : Icons.person_outline,
                        label: 'Full Name',
                        value: user != null ? '${user.name} ${user.surname}' : 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: isIOS ? CupertinoIcons.mail : Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: isIOS ? CupertinoIcons.phone : Icons.phone_outlined,
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
                        icon: isIOS ? CupertinoIcons.house : Icons.family_restroom,
                        label: 'Family',
                        value: user?.familyName ?? 'Not set',
                      ),
                      _ProfileInfoItem(
                        icon: isIOS ? CupertinoIcons.person_badge_plus : Icons.badge_outlined,
                        label: 'Role',
                        value: user?.role ?? 'Member',
                        valueColor: RelunaTheme.getRoleColor(user?.role ?? 'Member'),
                      ),
                      _ProfileInfoItem(
                        icon: isIOS ? CupertinoIcons.calendar : Icons.calendar_today_outlined,
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
                        icon: isIOS ? CupertinoIcons.settings : Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => context.router.push(const SettingsRoute()),
                      ),
                      _QuickAction(
                        icon: isIOS ? CupertinoIcons.bell : Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => context.router.push(const NotificationsRoute()),
                      ),
                      _QuickAction(
                        icon: isIOS ? CupertinoIcons.shield : Icons.security_outlined,
                        label: 'Security',
                        onTap: () => _showSecurityOptions(context, ref),
                      ),
                      _QuickAction(
                        icon: isIOS ? CupertinoIcons.question_circle : Icons.help_outline,
                        label: 'Help',
                        onTap: () => _showHelpDialog(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: AdaptiveButton(
                      text: 'Sign Out',
                      isOutlined: true,
                      onPressed: () => _confirmLogout(context, ref),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App version
                  Text(
                    'Reluna Family v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: RelunaTheme.textTertiary,
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
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Edit Profile'),
          content: const Text('Profile editing will be available in a future update.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Profile'),
          content: const Text('Profile editing will be available in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showSecurityOptions(BuildContext context, WidgetRef ref) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Security Options'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                context.router.push(const PinSetupRoute());
              },
              child: const Text('Change PIN'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Enable Face ID'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      );
    } else {
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
  }

  void _showHelpDialog(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Help & Support'),
          content: const Text('For assistance, please contact support@reluna.com'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Help & Support'),
          content: const Text('For assistance, please contact support@reluna.com'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Sign Out'),
              onPressed: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
                context.router.replaceAll([const LoginRoute()]);
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
                context.router.replaceAll([const LoginRoute()]);
              },
              child: const Text('Sign Out', style: TextStyle(color: RelunaTheme.error)),
            ),
          ],
        ),
      );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RelunaTheme.accentColor,
            RelunaTheme.accentColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              user != null ? '${user.name[0]}${user.surname[0]}' : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user != null ? '${user.name} ${user.surname}' : 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.role ?? 'Member',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (user?.familyName != null) ...[
            const SizedBox(height: 4),
            Text(
              user.familyName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<_ProfileInfoItem> items;

  const _ProfileInfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RelunaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: item,
          )),
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
    return Row(
      children: [
        Icon(icon, size: 20, color: RelunaTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: RelunaTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? RelunaTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final List<_QuickAction> actions;

  const _QuickActionsCard({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RelunaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions,
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RelunaTheme.accentColorLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: RelunaTheme.accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: RelunaTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
