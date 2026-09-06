// =============================================================================
// AeroYield — Login Screen
// Farmer-friendly mobile-number login with a simulated 4-digit OTP and a
// one-tap "Quick Demo Login" button for instant hackathon access.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';
import '../providers/auth_provider.dart';
import '../widgets/helpline_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1A2E1A), theme.scaffoldBackgroundColor]
                : [const Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Brand header
                const Icon(Icons.terrain, size: 64, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  'AeroYield',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.loginTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(178),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ── Phone input (+92 prefix) ──────────────────────────────
                Row(
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: const Center(
                        child: Text(
                          '+92',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: '3XX XXXXXXX',
                          counterText: '',
                          filled: true,
                          fillColor:
                              theme.inputDecorationTheme.fillColor ??
                              theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── OTP input (4 digits) ──────────────────────────────────
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  decoration: InputDecoration(
                    hintText: '• • • •',
                    counterText: '',
                    labelText: l10n.enterOtp,
                    filled: true,
                    fillColor:
                        theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Login button ──────────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.loginButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Quick Demo Login ──────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: auth.isLoading
                        ? null
                        : () => _demoLogin(context),
                    icon: const Icon(Icons.bolt, size: 22),
                    label: Text(
                      l10n.quickDemoLogin,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const HelplineFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _login(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final phone = _phoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();

    if (phone.length < 10) {
      _showError(context, 'Please enter a valid 10-digit number');
      return;
    }

    // First-time: send OTP; second tap: verify
    if (otp.isEmpty) {
      await auth.sendOtp(phone);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).otpSent)),
        );
      }
      return;
    }

    final success = await auth.verifyOtp(otp);
    if (success && context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        auth.isOnboardingComplete ? '/home' : '/onboarding',
      );
    } else if (context.mounted) {
      _showError(context, 'Invalid OTP. Please try again.');
    }
  }

  Future<void> _demoLogin(BuildContext context) async {
    await context.read<AuthProvider>().demoLogin();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.scoreRed),
    );
  }
}
