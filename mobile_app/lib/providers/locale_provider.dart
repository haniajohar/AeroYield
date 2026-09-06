// =============================================================================
// AeroYield — Locale Provider
// Manages the active locale and notifies listeners so the entire widget tree
// (including RTL/LTR layout direction) updates instantly on language change.
// =============================================================================

import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  /// The currently active locale.
  Locale get locale => _locale;

  /// Convenience: ISO language code ('en' or 'ur').
  String get languageCode => _locale.languageCode;

  /// Whether the active layout direction is right-to-left.
  bool get isRtl => _locale.languageCode == 'ur';

  /// Set a new locale and trigger a rebuild across the app.
  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  /// Toggle between English and Urdu.
  void toggleLocale() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ur') : const Locale('en');
    notifyListeners();
  }
}
