// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AssetsScreen]
class AssetsRoute extends PageRouteInfo<void> {
  const AssetsRoute({List<PageRouteInfo>? children})
    : super(AssetsRoute.name, initialChildren: children);

  static const String name = 'AssetsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AssetsScreen();
    },
  );
}

/// generated route for
/// [ChatDetailScreen]
class ChatDetailRoute extends PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    Key? key,
    required String chatId,
    required String chatName,
    required bool isGroup,
    List<PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(
           key: key,
           chatId: chatId,
           chatName: chatName,
           isGroup: isGroup,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatDetailRouteArgs>();
      return ChatDetailScreen(
        key: args.key,
        chatId: args.chatId,
        chatName: args.chatName,
        isGroup: args.isGroup,
      );
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({
    this.key,
    required this.chatId,
    required this.chatName,
    required this.isGroup,
  });

  final Key? key;

  final String chatId;

  final String chatName;

  final bool isGroup;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, chatId: $chatId, chatName: $chatName, isGroup: $isGroup}';
  }
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatScreen();
    },
  );
}

/// generated route for
/// [CommunicationScreen]
class CommunicationRoute extends PageRouteInfo<void> {
  const CommunicationRoute({List<PageRouteInfo>? children})
    : super(CommunicationRoute.name, initialChildren: children);

  static const String name = 'CommunicationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CommunicationScreen();
    },
  );
}

/// generated route for
/// [ConflictResolutionScreen]
class ConflictResolutionRoute extends PageRouteInfo<void> {
  const ConflictResolutionRoute({List<PageRouteInfo>? children})
    : super(ConflictResolutionRoute.name, initialChildren: children);

  static const String name = 'ConflictResolutionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConflictResolutionScreen();
    },
  );
}

/// generated route for
/// [ConstitutionEditScreen]
class ConstitutionEditRoute extends PageRouteInfo<ConstitutionEditRouteArgs> {
  ConstitutionEditRoute({
    Key? key,
    required String sectionId,
    List<PageRouteInfo>? children,
  }) : super(
         ConstitutionEditRoute.name,
         args: ConstitutionEditRouteArgs(key: key, sectionId: sectionId),
         initialChildren: children,
       );

  static const String name = 'ConstitutionEditRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConstitutionEditRouteArgs>();
      return ConstitutionEditScreen(key: args.key, sectionId: args.sectionId);
    },
  );
}

class ConstitutionEditRouteArgs {
  const ConstitutionEditRouteArgs({this.key, required this.sectionId});

  final Key? key;

  final String sectionId;

  @override
  String toString() {
    return 'ConstitutionEditRouteArgs{key: $key, sectionId: $sectionId}';
  }
}

/// generated route for
/// [ConstitutionScreen]
class ConstitutionRoute extends PageRouteInfo<void> {
  const ConstitutionRoute({List<PageRouteInfo>? children})
    : super(ConstitutionRoute.name, initialChildren: children);

  static const String name = 'ConstitutionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConstitutionScreen();
    },
  );
}

/// generated route for
/// [ConstitutionVersionsScreen]
class ConstitutionVersionsRoute extends PageRouteInfo<void> {
  const ConstitutionVersionsRoute({List<PageRouteInfo>? children})
    : super(ConstitutionVersionsRoute.name, initialChildren: children);

  static const String name = 'ConstitutionVersionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConstitutionVersionsScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [DecisionCreateScreen]
class DecisionCreateRoute extends PageRouteInfo<void> {
  const DecisionCreateRoute({List<PageRouteInfo>? children})
    : super(DecisionCreateRoute.name, initialChildren: children);

  static const String name = 'DecisionCreateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionCreateScreen();
    },
  );
}

/// generated route for
/// [DecisionDetailScreen]
class DecisionDetailRoute extends PageRouteInfo<DecisionDetailRouteArgs> {
  DecisionDetailRoute({
    Key? key,
    required String decisionId,
    List<PageRouteInfo>? children,
  }) : super(
         DecisionDetailRoute.name,
         args: DecisionDetailRouteArgs(key: key, decisionId: decisionId),
         initialChildren: children,
       );

  static const String name = 'DecisionDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DecisionDetailRouteArgs>();
      return DecisionDetailScreen(key: args.key, decisionId: args.decisionId);
    },
  );
}

class DecisionDetailRouteArgs {
  const DecisionDetailRouteArgs({this.key, required this.decisionId});

  final Key? key;

  final String decisionId;

  @override
  String toString() {
    return 'DecisionDetailRouteArgs{key: $key, decisionId: $decisionId}';
  }
}

/// generated route for
/// [DecisionsScreen]
class DecisionsRoute extends PageRouteInfo<void> {
  const DecisionsRoute({List<PageRouteInfo>? children})
    : super(DecisionsRoute.name, initialChildren: children);

  static const String name = 'DecisionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DecisionsScreen();
    },
  );
}

/// generated route for
/// [EducationScreen]
class EducationRoute extends PageRouteInfo<void> {
  const EducationRoute({List<PageRouteInfo>? children})
    : super(EducationRoute.name, initialChildren: children);

  static const String name = 'EducationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EducationScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainShellScreen]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellScreen();
    },
  );
}

/// generated route for
/// [MeetingDetailScreen]
class MeetingDetailRoute extends PageRouteInfo<MeetingDetailRouteArgs> {
  MeetingDetailRoute({
    Key? key,
    required String meetingId,
    List<PageRouteInfo>? children,
  }) : super(
         MeetingDetailRoute.name,
         args: MeetingDetailRouteArgs(key: key, meetingId: meetingId),
         initialChildren: children,
       );

  static const String name = 'MeetingDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MeetingDetailRouteArgs>();
      return MeetingDetailScreen(key: args.key, meetingId: args.meetingId);
    },
  );
}

class MeetingDetailRouteArgs {
  const MeetingDetailRouteArgs({this.key, required this.meetingId});

  final Key? key;

  final String meetingId;

  @override
  String toString() {
    return 'MeetingDetailRouteArgs{key: $key, meetingId: $meetingId}';
  }
}

/// generated route for
/// [MeetingsScreen]
class MeetingsRoute extends PageRouteInfo<void> {
  const MeetingsRoute({List<PageRouteInfo>? children})
    : super(MeetingsRoute.name, initialChildren: children);

  static const String name = 'MeetingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MeetingsScreen();
    },
  );
}

/// generated route for
/// [MemberProfileScreen]
class MemberProfileRoute extends PageRouteInfo<MemberProfileRouteArgs> {
  MemberProfileRoute({
    Key? key,
    required String memberId,
    List<PageRouteInfo>? children,
  }) : super(
         MemberProfileRoute.name,
         args: MemberProfileRouteArgs(key: key, memberId: memberId),
         initialChildren: children,
       );

  static const String name = 'MemberProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MemberProfileRouteArgs>();
      return MemberProfileScreen(key: args.key, memberId: args.memberId);
    },
  );
}

class MemberProfileRouteArgs {
  const MemberProfileRouteArgs({this.key, required this.memberId});

  final Key? key;

  final String memberId;

  @override
  String toString() {
    return 'MemberProfileRouteArgs{key: $key, memberId: $memberId}';
  }
}

/// generated route for
/// [MembersScreen]
class MembersRoute extends PageRouteInfo<void> {
  const MembersRoute({List<PageRouteInfo>? children})
    : super(MembersRoute.name, initialChildren: children);

  static const String name = 'MembersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MembersScreen();
    },
  );
}

/// generated route for
/// [NotificationsScreen]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [PhilanthropyScreen]
class PhilanthropyRoute extends PageRouteInfo<void> {
  const PhilanthropyRoute({List<PageRouteInfo>? children})
    : super(PhilanthropyRoute.name, initialChildren: children);

  static const String name = 'PhilanthropyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PhilanthropyScreen();
    },
  );
}

/// generated route for
/// [PinSetupScreen]
class PinSetupRoute extends PageRouteInfo<void> {
  const PinSetupRoute({List<PageRouteInfo>? children})
    : super(PinSetupRoute.name, initialChildren: children);

  static const String name = 'PinSetupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PinSetupScreen();
    },
  );
}

/// generated route for
/// [PinVerifyScreen]
class PinVerifyRoute extends PageRouteInfo<void> {
  const PinVerifyRoute({List<PageRouteInfo>? children})
    : super(PinVerifyRoute.name, initialChildren: children);

  static const String name = 'PinVerifyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PinVerifyScreen();
    },
  );
}

/// generated route for
/// [PlatformScreen]
class PlatformRoute extends PageRouteInfo<void> {
  const PlatformRoute({List<PageRouteInfo>? children})
    : super(PlatformRoute.name, initialChildren: children);

  static const String name = 'PlatformRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlatformScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SuccessionScreen]
class SuccessionRoute extends PageRouteInfo<void> {
  const SuccessionRoute({List<PageRouteInfo>? children})
    : super(SuccessionRoute.name, initialChildren: children);

  static const String name = 'SuccessionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SuccessionScreen();
    },
  );
}
