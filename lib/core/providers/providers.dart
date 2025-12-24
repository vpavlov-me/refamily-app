import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/services/mock_data_service.dart';
import '../services/pin_manager.dart';
import '../services/memory_storage.dart';

// Memory Storage Provider (replaces SharedPreferences)
final memoryStorageProvider = Provider<MemoryStorage>((ref) {
  return MemoryStorage();
});

// PIN Manager Provider
final pinManagerProvider = Provider<PinManager>((ref) {
  final storage = ref.watch(memoryStorageProvider);
  return PinManager(storage);
});

// Mock Data Service Provider
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final pinManager = ref.watch(pinManagerProvider);
  final mockDataService = ref.watch(mockDataServiceProvider);
  return AuthNotifier(pinManager, mockDataService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final PinManager _pinManager;
  final MockDataService _mockDataService;

  AuthNotifier(this._pinManager, this._mockDataService) : super(const AuthState()) {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    state = state.copyWith(isLoading: true);
    
    final hasCompletedOnboarding = _pinManager.isOnboardingCompleted();
    final hasPinSetup = _pinManager.hasPin();
    final isLoggedIn = _pinManager.isLoggedIn();
    
    User? currentUser;
    if (isLoggedIn) {
      try {
        currentUser = await _mockDataService.getCurrentUser();
      } catch (_) {
        // User not found, clear token
        await _pinManager.clearAuthToken();
      }
    }
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: isLoggedIn && currentUser != null,
      hasCompletedOnboarding: hasCompletedOnboarding,
      hasPinSetup: hasPinSetup,
      isPinVerified: false,
      currentUser: currentUser,
    );
  }

  Future<void> completeOnboarding() async {
    await _pinManager.setOnboardingCompleted(true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final user = await _mockDataService.authenticateUser(email, password);
      
      if (user != null) {
        await _pinManager.setAuthToken('mock_token_${user.id}');
        await _pinManager.setUserId(user.id);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid email or password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String familyName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // Mock registration - in real app would create user
    await Future.delayed(const Duration(seconds: 1));
    
    final mockUser = User(
      id: 'user_new',
      email: email,
      name: name.split(' ').first,
      surname: name.split(' ').length > 1 ? name.split(' ').last : '',
      familyName: familyName,
      role: 'Member',
      isAdmin: false,
    );
    
    await _pinManager.setAuthToken('mock_token_new');
    await _pinManager.setUserId(mockUser.id);
    
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      currentUser: mockUser,
    );
    return true;
  }

  Future<void> setupPin(String pin) async {
    await _pinManager.setPin(pin);
    state = state.copyWith(hasPinSetup: true, isPinVerified: true);
  }

  Future<bool> verifyPin(String pin) async {
    final isValid = await _pinManager.verifyPin(pin);
    if (isValid) {
      state = state.copyWith(isPinVerified: true);
    }
    return isValid;
  }

  Future<void> enableBiometric(bool enabled) async {
    await _pinManager.setBiometricEnabled(enabled);
  }

  bool isBiometricEnabled() {
    return _pinManager.isBiometricEnabled();
  }

  Future<void> logout() async {
    await _pinManager.clearAll();
    state = const AuthState(hasCompletedOnboarding: true);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Constitution Provider
final constitutionProvider = FutureProvider<Constitution>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getConstitution();
});

final constitutionVersionsProvider = FutureProvider<List<ConstitutionVersion>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getConstitutionVersions();
});

// Members Provider
final membersProvider = FutureProvider<List<Member>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMembers();
});

final membersSummaryProvider = FutureProvider<MembersSummary>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMembersSummary();
});

final memberByIdProvider = FutureProvider.family<Member?, String>((ref, id) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMemberById(id);
});

// Decisions Provider
final decisionsProvider = FutureProvider<List<Decision>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getDecisions();
});

final decisionsSummaryProvider = FutureProvider<DecisionsSummary>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getDecisionsSummary();
});

final decisionByIdProvider = FutureProvider.family<Decision?, String>((ref, id) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getDecisionById(id);
});

// Meetings Provider
final meetingsProvider = FutureProvider<List<Meeting>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMeetings();
});

final meetingsSummaryProvider = FutureProvider<MeetingsSummary>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMeetingsSummary();
});

final meetingByIdProvider = FutureProvider.family<Meeting?, String>((ref, id) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getMeetingById(id);
});

// Notifications Provider
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getNotifications();
});

final notificationsSummaryProvider = FutureProvider<NotificationsSummary>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getNotificationsSummary();
});

// Activity Provider
final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return mockDataService.getActivities();
});
