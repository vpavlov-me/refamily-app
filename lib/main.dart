import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: RelunaTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: RelunaFamilyApp(),
    ),
  );
}

class RelunaFamilyApp extends ConsumerWidget {
  const RelunaFamilyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    return ShadApp.router(
      title: 'Reluna Family',
      debugShowCheckedModeBanner: false,
      theme: RelunaTheme.lightTheme(),
      darkTheme: RelunaTheme.darkTheme(),
      themeMode: settings.themeMode,
      routerConfig: appRouter.config(),
      builder: (context, child) {
        // Apply iOS-compliant text scale for better readability
        // iOS minimum recommended: 17pt for body text
        return ShadToaster(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                (MediaQuery.of(context).textScaler.scale(1.0) * 1.15).clamp(1.0, 1.5),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}