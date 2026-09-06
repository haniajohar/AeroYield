// =============================================================================
// AeroYield — Splash Screen
// Displays the brand with an animated pulse/glow on a deep green gradient,
// then automatically navigates to the Language Selection screen after 2 s.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Continuous pulse animation (1.2 s cycle, ping-pong)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseCtrl.repeat(reverse: true);

    _restoreSessionAndNavigate();
  }

  Future<void> _restoreSessionAndNavigate() async {
    await context.read<AuthProvider>().restoreSession();
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final destination = !auth.isLoggedIn
        ? '/language'
        : auth.isOnboardingComplete
        ? '/home'
        : '/onboarding';
    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.splashStart, AppColors.splashEnd],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnim.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing halo behind the icon
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(
                          (26 * _pulseAnim.value).round().clamp(0, 255),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha(
                              (51 * _pulseAnim.value).round().clamp(0, 255),
                            ),
                            blurRadius: 40 * _pulseAnim.value,
                            spreadRadius: 10 * _pulseAnim.value,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.terrain,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App name
                    const Text(
                      'AeroYield',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bilingual tagline
                    const Text(
                      'Satellite Intelligence for Every Field',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'خلائی معلومات، کسان کی ترقی',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
