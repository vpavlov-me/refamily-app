import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/memory_storage.dart';
import '../../../core/providers/providers.dart';

// App Settings Model
class AppSettings {
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool soundEnabled;
  final bool hapticEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  String get languageName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  String get themeModeName {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final MemoryStorage _storage;

  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    // Load from storage (in real app)
    final themeModeIndex = _storage.getInt('themeMode') ?? 0;
    final languageCode = _storage.getString('languageCode') ?? 'en';
    final notificationsEnabled = _storage.getBool('notificationsEnabled') ?? true;
    final biometricEnabled = _storage.getBool('biometricEnabled') ?? false;
    final soundEnabled = _storage.getBool('soundEnabled') ?? true;
    final hapticEnabled = _storage.getBool('hapticEnabled') ?? true;

    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex],
      languageCode: languageCode,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
      soundEnabled: soundEnabled,
      hapticEnabled: hapticEnabled,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _storage.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLanguage(String languageCode) {
    _storage.setString('languageCode', languageCode);
    state = state.copyWith(languageCode: languageCode);
  }

  void setNotificationsEnabled(bool enabled) {
    _storage.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setBiometricEnabled(bool enabled) {
    _storage.setBool('biometricEnabled', enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  void setSoundEnabled(bool enabled) {
    _storage.setBool('soundEnabled', enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  void setHapticEnabled(bool enabled) {
    _storage.setBool('hapticEnabled', enabled);
    state = state.copyWith(hapticEnabled: enabled);
  }

  void resetToDefaults() {
    state = const AppSettings();
    _storage.setInt('themeMode', 0);
    _storage.setString('languageCode', 'en');
    _storage.setBool('notificationsEnabled', true);
    _storage.setBool('biometricEnabled', false);
    _storage.setBool('soundEnabled', true);
    _storage.setBool('hapticEnabled', true);
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(memoryStorageProvider);
  return SettingsNotifier(storage);
});

// Available languages
final availableLanguagesProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];
});
