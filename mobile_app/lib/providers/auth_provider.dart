// =============================================================================
// AeroYield — Device-Linked Demo Auth Provider
//
// Plan B keeps the simulated OTP, but persists the selected phone/profile so
// each phone sees only the fields registered under that phone number.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const _sessionPhoneKey = 'session_phone';
  static const _sessionDemoKey = 'session_is_demo';

  bool _isLoggedIn = false;
  String _farmerName = '';
  String _phoneNumber = '';
  bool _isLoading = false;
  bool _onboardingComplete = false;
  bool _isDemoUser = false;

  bool get isLoggedIn => _isLoggedIn;
  String get farmerName => _farmerName;
  String get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  bool get isOnboardingComplete => _onboardingComplete;
  bool get isDemoUser => _isDemoUser;

  String get _profileSuffix => _phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  String get _nameKey => 'farmer_name_$_profileSuffix';
  String get _onboardingKey => 'onboarding_complete_$_profileSuffix';

  /// Restores the last device-local demo session during splash.
  Future<void> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final phone = preferences.getString(_sessionPhoneKey);
    if (phone == null || phone.isEmpty) return;

    _phoneNumber = phone;
    _isDemoUser = preferences.getBool(_sessionDemoKey) ?? false;
    _farmerName = preferences.getString(_nameKey) ?? '';
    _onboardingComplete = preferences.getBool(_onboardingKey) ?? _isDemoUser;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Simulate sending a 4-digit OTP and normalise the phone as an E.164 value.
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _phoneNumber = _normalisePakistanPhone(phone);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Any four digits work in the explicitly demo-only Plan B flow.
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final success = otp.length == 4 && _phoneNumber.isNotEmpty;
    if (success) {
      final preferences = await SharedPreferences.getInstance();
      _farmerName = preferences.getString(_nameKey) ?? '';
      _onboardingComplete = preferences.getBool(_onboardingKey) ?? false;
      _isDemoUser = false;
      _isLoggedIn = true;
      await _saveSession(preferences);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// One-tap access for demonstrations. It creates/uses only a demo-owned field.
  Future<void> demoLogin() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _phoneNumber = '+923001234567';
    _farmerName = 'Demo Farmer';
    _onboardingComplete = true;
    _isDemoUser = true;
    _isLoggedIn = true;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, _farmerName);
    await preferences.setBool(_onboardingKey, true);
    await _saveSession(preferences);
    _isLoading = false;
    notifyListeners();
  }

  /// Persist the real farmer's name after a successful field-registration step.
  Future<void> completeOnboarding(String name) async {
    _farmerName = name.trim();
    _onboardingComplete = true;
    _isDemoUser = false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, _farmerName);
    await preferences.setBool(_onboardingKey, true);
    await _saveSession(preferences);
    notifyListeners();
  }

  /// Clears only the active session. The per-phone field queue remains so the
  /// same farmer can return after logging back in on this device.
  void logout() {
    _isLoggedIn = false;
    _farmerName = '';
    _phoneNumber = '';
    _onboardingComplete = false;
    _isDemoUser = false;
    SharedPreferences.getInstance().then((preferences) {
      preferences.remove(_sessionPhoneKey);
      preferences.remove(_sessionDemoKey);
    });
    notifyListeners();
  }

  Future<void> _saveSession(SharedPreferences preferences) async {
    await preferences.setString(_sessionPhoneKey, _phoneNumber);
    await preferences.setBool(_sessionDemoKey, _isDemoUser);
  }

  static String _normalisePakistanPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('92')) return '+$digits';
    if (digits.startsWith('0')) return '+92${digits.substring(1)}';
    return '+92$digits';
  }
}
