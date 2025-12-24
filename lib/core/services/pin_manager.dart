import 'memory_storage.dart';

class PinManager {
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  final MemoryStorage _prefs;

  PinManager(this._prefs);

  // PIN Management
  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
  }

  String? getPin() {
    return _prefs.getString(_pinKey);
  }

  bool hasPin() {
    return _prefs.containsKey(_pinKey) && _prefs.getString(_pinKey)?.isNotEmpty == true;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = getPin();
    return storedPin == pin;
  }

  Future<void> clearPin() async {
    await _prefs.remove(_pinKey);
  }

  // Biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  bool isBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Auth Token (mock)
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_authTokenKey);
  }

  bool isLoggedIn() {
    return _prefs.containsKey(_authTokenKey) && _prefs.getString(_authTokenKey)?.isNotEmpty == true;
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_authTokenKey);
  }

  // User ID
  Future<void> setUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> clearUserId() async {
    await _prefs.remove(_userIdKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _prefs.remove(_pinKey);
    await _prefs.remove(_biometricEnabledKey);
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userIdKey);
    // Note: Don't clear onboarding flag
  }
}
