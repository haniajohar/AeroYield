// =============================================================================
// AeroYield — Language Selection Screen
// Two large tappable cards let the farmer choose English or Urdu.
// Selecting a card sets the global Locale (including RTL/LTR) and advances
// to the Login screen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/helpline_footer.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1A2E1A), const Color(0xFF121212)]
                : [const Color(0xFFF1F8E9), const Color(0xFFDCEDC8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Page title
                Text(
                  l10n.selectLanguage,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'اپنی زبان منتخب کریں',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
                const Spacer(),

                // ── English card ──────────────────────────────────────────
                _LanguageCard(
                  title: 'English',
                  subtitle: 'Continue in English',
                  icon: Icons.language,
                  color: AppColors.primary,
                  onTap: () => _selectLocale(
                    context,
                    localeProvider,
                    const Locale('en'),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Urdu card ─────────────────────────────────────────────
                _LanguageCard(
                  title: 'اردو',
                  subtitle: 'اردو میں جاری رکھیں',
                  icon: Icons.translate,
                  color: AppColors.primaryDark,
                  onTap: () => _selectLocale(
                    context,
                    localeProvider,
                    const Locale('ur'),
                  ),
                ),
                const Spacer(),
                const HelplineFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectLocale(
    BuildContext context,
    LocaleProvider provider,
    Locale locale,
  ) {
    provider.setLocale(locale);
    final auth = context.read<AuthProvider>();
    final destination = !auth.isLoggedIn
        ? '/login'
        : auth.isOnboardingComplete
        ? '/home'
        : '/onboarding';
    Navigator.of(context).pushReplacementNamed(destination);
  }
}

// ── Reusable large language card (≥ 120 px height) ───────────────────────

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 130,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
        child: Row(
          children: [
            Icon(icon, size: 44, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 28, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
