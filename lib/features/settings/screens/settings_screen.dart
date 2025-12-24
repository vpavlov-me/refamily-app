import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/shared.dart';
import '../providers/settings_provider.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'Settings',
      hasBackButton: true,
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Appearance section
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: settings.themeModeName,
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: settings.languageName,
                onTap: () => _showLanguagePicker(context, ref, settings),
              ),
            ],
          ),
          
          // Notifications section
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsToggleTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts about family activities',
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
              ),
              _SettingsToggleTile(
                icon: Icons.volume_up_outlined,
                title: 'Sound',
                subtitle: 'Play sounds for notifications',
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                },
              ),
              _SettingsToggleTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: settings.hapticEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setHapticEnabled(value);
                },
              ),
            ],
          ),
          
          // Security section
          _SettingsSection(
            title: 'Security',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change PIN',
                subtitle: 'Update your security PIN',
                onTap: () => context.router.push(const PinSetupRoute()),
              ),
              _SettingsToggleTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Use Face ID or fingerprint',
                value: settings.biometricEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setBiometricEnabled(value);
                },
              ),
            ],
          ),
          
          // About section
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0 (Build 1)',
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _showInfoDialog(context, 'Terms of Service', 'Terms will be available soon.'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _showInfoDialog(context, 'Privacy Policy', 'Privacy policy will be available soon.'),
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _showInfoDialog(context, 'Help & Support', 'Contact us at support@reluna.com'),
              ),
            ],
          ),
          
          // Danger zone
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.restore,
                title: 'Reset Settings',
                subtitle: 'Restore default settings',
                isDestructive: false,
                onTap: () => _confirmResetSettings(context, ref),
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                isDestructive: true,
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Theme'),
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setThemeMode(value!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    final languages = ref.read(availableLanguagesProvider);
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: languages.map((lang) => RadioListTile<String>(
          title: Text('${lang['flag']} ${lang['name']}'),
          value: lang['code']!,
          groupValue: settings.languageCode,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setLanguage(value!);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    final theme = ShadTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.card,
        title: Text(title),
        content: Text(content),
        actions: [
          ShadButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.card,
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(height: 1, indent: 56, color: theme.colorScheme.border),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = isDestructive ? theme.colorScheme.destructive : theme.colorScheme.foreground;
    
    return ListTile(
      leading: Icon(icon, color: isDestructive ? theme.colorScheme.destructive : theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.mutedForeground,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.mutedForeground,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      trailing: ShadSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
