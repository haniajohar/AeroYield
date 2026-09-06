// =============================================================================
// AeroYield — Main Application Entry Point
//
// Bootstraps the app with:
//   • MultiProvider for state management (Locale, Auth, Farm, Audio, Theme)
//   • MaterialApp with custom bilingual localisation (EN / UR)
//   • RTL/LTR layout mirroring driven by the active locale
//   • Light / Dark theme toggle driven by ThemeProvider
//   • Named route table for the four-screen flow
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/app_l10n.dart';
import 'providers/audio_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/farm_home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AeroYieldApp());
}

class AeroYieldApp extends StatelessWidget {
  const AeroYieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProv, themeProv, _) {
          return MaterialApp(
            title: 'AeroYield',
            debugShowCheckedModeBanner: false,

            // ── Locale ───────────────────────────────────────────────────
            locale: localeProv.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return localeProv.locale;
              for (final s in supported) {
                if (s.languageCode == locale.languageCode) return s;
              }
              return localeProv.locale;
            },

            // ── Theme (light + dark) ─────────────────────────────────────
            themeMode: themeProv.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,

            // ── Routes ───────────────────────────────────────────────────
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/language': (_) => const LanguageSelectionScreen(),
              '/login': (_) => const LoginScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/home': (_) => const FarmHomeScreen(),
            },
          );
        },
      ),
    );
  }
}
