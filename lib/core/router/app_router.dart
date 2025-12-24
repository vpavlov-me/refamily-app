import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/pin_verify_screen.dart';

// Main screens
import '../../features/main/main_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/platform/screens/platform_screen.dart';
import '../../features/chat/screens/chat_screen.dart';

// Feature screens
import '../../features/constitution/screens/constitution_screen.dart';
import '../../features/constitution/screens/constitution_edit_screen.dart';
import '../../features/constitution/screens/constitution_versions_screen.dart';
import '../../features/members/screens/members_screen.dart';
import '../../features/members/screens/member_profile_screen.dart';
import '../../features/decisions/screens/decisions_screen.dart';
import '../../features/decisions/screens/decision_detail_screen.dart';
import '../../features/decisions/screens/decision_create_screen.dart';
import '../../features/meetings/screens/meetings_screen.dart';
import '../../features/meetings/screens/meeting_detail_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

// New feature screens
import '../../features/assets/screens/assets_screen.dart';
import '../../features/education/screens/education_screen.dart';
import '../../features/philanthropy/screens/philanthropy_screen.dart';
import '../../features/succession/screens/succession_screen.dart';
import '../../features/conflict_resolution/screens/conflict_resolution_screen.dart';
import '../../features/communication/screens/communication_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';

// Profile and Settings
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  List<AutoRoute> get routes => [
        // Splash
        AutoRoute(page: SplashRoute.page, initial: true, path: '/'),

        // Auth routes
        AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
        AutoRoute(page: PinSetupRoute.page, path: '/pin-setup'),
        AutoRoute(page: PinVerifyRoute.page, path: '/pin-verify'),

        // Main app with bottom navigation
        AutoRoute(
          page: MainShellRoute.page,
          path: '/main',
          children: [
            AutoRoute(page: DashboardRoute.page, path: 'dashboard', initial: true),
            AutoRoute(page: PlatformRoute.page, path: 'platform'),
            AutoRoute(page: ChatRoute.page, path: 'chat'),
            AutoRoute(page: ProfileRoute.page, path: 'profile'),
          ],
        ),

        // Constitution
        AutoRoute(page: ConstitutionRoute.page, path: '/constitution'),
        AutoRoute(page: ConstitutionEditRoute.page, path: '/constitution/edit/:sectionId'),
        AutoRoute(page: ConstitutionVersionsRoute.page, path: '/constitution/versions'),

        // Members
        AutoRoute(page: MembersRoute.page, path: '/members'),
        AutoRoute(page: MemberProfileRoute.page, path: '/members/:memberId'),

        // Decisions
        AutoRoute(page: DecisionsRoute.page, path: '/decisions'),
        AutoRoute(page: DecisionCreateRoute.page, path: '/decisions/create'),
        AutoRoute(page: DecisionDetailRoute.page, path: '/decisions/:decisionId'),

        // Meetings
        AutoRoute(page: MeetingsRoute.page, path: '/meetings'),
        AutoRoute(page: MeetingDetailRoute.page, path: '/meetings/:meetingId'),

        // Notifications
        AutoRoute(page: NotificationsRoute.page, path: '/notifications'),

        // Feature screens
        AutoRoute(page: ConflictResolutionRoute.page, path: '/conflict-resolution'),
        AutoRoute(page: AssetsRoute.page, path: '/assets'),
        AutoRoute(page: EducationRoute.page, path: '/education'),
        AutoRoute(page: PhilanthropyRoute.page, path: '/philanthropy'),
        AutoRoute(page: SuccessionRoute.page, path: '/succession'),
        AutoRoute(page: CommunicationRoute.page, path: '/communication'),

        // Chat detail (outside shell - no bottom nav)
        AutoRoute(page: ChatDetailRoute.page, path: '/chat-detail/:chatId'),

        // Settings (outside shell)
        AutoRoute(page: SettingsRoute.page, path: '/settings'),
      ];
}

// Provider for the router
final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});
