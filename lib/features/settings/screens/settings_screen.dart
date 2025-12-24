import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../providers/settings_provider.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isIOS = AdaptivePlatform.isIOSByContext(context);

    return AdaptiveScaffold(
      title: 'Settings',
      leading: AdaptiveIconButton(
        icon: isIOS ? CupertinoIcons.back : Icons.arrow_back,
        onPressed: () => context.router.maybePop(),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Appearance section
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.moon : Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: settings.themeModeName,
                onTap: () => _showThemePicker(context, ref, settings),
              ),
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.globe : Icons.language_outlined,
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
                icon: isIOS ? CupertinoIcons.bell : Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive alerts about family activities',
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
              ),
              _SettingsToggleTile(
                icon: isIOS ? CupertinoIcons.speaker_2 : Icons.volume_up_outlined,
                title: 'Sound',
                subtitle: 'Play sounds for notifications',
                value: settings.soundEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setSoundEnabled(value);
                },
              ),
              _SettingsToggleTile(
                icon: isIOS ? CupertinoIcons.waveform : Icons.vibration,
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
                icon: isIOS ? CupertinoIcons.lock : Icons.lock_outline,
                title: 'Change PIN',
                subtitle: 'Update your security PIN',
                onTap: () => context.router.push(const PinSetupRoute()),
              ),
              _SettingsToggleTile(
                icon: isIOS ? CupertinoIcons.eye_slash : Icons.fingerprint,
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
                icon: isIOS ? CupertinoIcons.info : Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0 (Build 1)',
                onTap: null,
              ),
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.doc_text : Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _showInfoDialog(context, 'Terms of Service', 'Terms will be available soon.'),
              ),
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.shield : Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _showInfoDialog(context, 'Privacy Policy', 'Privacy policy will be available soon.'),
              ),
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.question_circle : Icons.help_outline,
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
                icon: isIOS ? CupertinoIcons.arrow_counterclockwise : Icons.restore,
                title: 'Reset Settings',
                subtitle: 'Restore default settings',
                isDestructive: false,
                onTap: () => _confirmResetSettings(context, ref),
              ),
              _SettingsTile(
                icon: isIOS ? CupertinoIcons.square_arrow_right : Icons.logout,
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
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Select Theme'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (settings.themeMode == ThemeMode.system)
                    const Icon(CupertinoIcons.checkmark, size: 18),
                  const SizedBox(width: 8),
                  const Text('System'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (settings.themeMode == ThemeMode.light)
                    const Icon(CupertinoIcons.checkmark, size: 18),
                  const SizedBox(width: 8),
                  const Text('Light'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (settings.themeMode == ThemeMode.dark)
                    const Icon(CupertinoIcons.checkmark, size: 18),
                  const SizedBox(width: 8),
                  const Text('Dark'),
                ],
              ),
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
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppSettings settings) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    final languages = ref.read(availableLanguagesProvider);
    
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Select Language'),
          actions: languages.map((lang) => CupertinoActionSheetAction(
            onPressed: () {
              ref.read(settingsProvider.notifier).setLanguage(lang['code']!);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (settings.languageCode == lang['code'])
                  const Icon(CupertinoIcons.checkmark, size: 18),
                const SizedBox(width: 8),
                Text('${lang['flag']} ${lang['name']}'),
              ],
            ),
          )).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      );
    } else {
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
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
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
          title: Text(title),
          content: Text(content),
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

  void _confirmResetSettings(BuildContext context, WidgetRef ref) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to reset all settings to default values?'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Reset'),
              onPressed: () {
                ref.read(settingsProvider.notifier).resetToDefaults();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to reset all settings to default values?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).resetToDefaults();
                Navigator.pop(context);
              },
              child: const Text('Reset', style: TextStyle(color: RelunaTheme.error)),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: RelunaTheme.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(height: 1, indent: 56),
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
    final color = isDestructive ? RelunaTheme.error : RelunaTheme.textPrimary;
    
    return ListTile(
      leading: Icon(icon, color: isDestructive ? RelunaTheme.error : RelunaTheme.accentColor),
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
              style: const TextStyle(
                fontSize: 12,
                color: RelunaTheme.textTertiary,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: RelunaTheme.textTertiary,
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
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    return ListTile(
      leading: Icon(icon, color: RelunaTheme.accentColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: RelunaTheme.textTertiary,
        ),
      ),
      trailing: isIOS
          ? CupertinoSwitch(
              value: value,
              activeColor: RelunaTheme.accentColor,
              onChanged: onChanged,
            )
          : Switch(
              value: value,
              activeColor: RelunaTheme.accentColor,
              onChanged: onChanged,
            ),
    );
  }
}
