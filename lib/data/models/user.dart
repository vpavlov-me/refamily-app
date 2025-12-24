class User {
  final String id;
  final String email;
  final String name;
  final String surname;
  final String familyName;
  final String role;
  final String? avatar;
  final String? phone;
  final DateTime? joinedAt;
  final bool isAdmin;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.familyName,
    required this.role,
    this.avatar,
    this.phone,
    this.joinedAt,
    this.isAdmin = false,
  });

  String get fullName => '$name $surname';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      familyName: json['familyName'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      joinedAt: json['joinedAt'] != null 
          ? DateTime.tryParse(json['joinedAt'] as String) 
          : null,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'familyName': familyName,
      'role': role,
      'avatar': avatar,
      'phone': phone,
      'joinedAt': joinedAt?.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? surname,
    String? familyName,
    String? role,
    String? avatar,
    String? phone,
    DateTime? joinedAt,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      familyName: familyName ?? this.familyName,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      joinedAt: joinedAt ?? this.joinedAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool hasCompletedOnboarding;
  final bool hasPinSetup;
  final bool isPinVerified;
  final User? currentUser;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.hasCompletedOnboarding = false,
    this.hasPinSetup = false,
    this.isPinVerified = false,
    this.currentUser,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? hasCompletedOnboarding,
    bool? hasPinSetup,
    bool? isPinVerified,
    User? currentUser,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasPinSetup: hasPinSetup ?? this.hasPinSetup,
      isPinVerified: isPinVerified ?? this.isPinVerified,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }
}
