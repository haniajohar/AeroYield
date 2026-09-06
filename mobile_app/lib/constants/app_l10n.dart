// =============================================================================
// AeroYield — Bilingual Localization Delegate
// Provides English (en) and Urdu (ur) translations for all app-facing strings.
// =============================================================================

import 'package:flutter/material.dart';

/// Custom [LocalizationsDelegate] that resolves to [AppLocalizations].
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Holds all bilingual string pairs keyed by language code.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Convenience accessor from any [BuildContext].
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  // Supported language codes
  static const List<String> supportedLanguageCodes = ['en', 'ur'];
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ur'),
  ];

  // ---- Internal string tables ----
  static const Map<String, Map<String, String>> _strings = {
    // App identity
    'app_name':        {'en': 'AeroYield',  'ur': 'ایرو ییلڈ'},
    'tagline':         {'en': 'Satellite Intelligence for Every Field',
                        'ur': 'خلائی معلومات، کسان کی ترقی'},

    // Language selection
    'select_language': {'en': 'Select Your Language', 'ur': 'اپنی زبان منتخب کریں'},
    'english':         {'en': 'English',               'ur': 'English'},
    'urdu':            {'en': 'اردو (Urdu)',           'ur': 'اردو'},

    // Login
    'login_title':         {'en': 'Farmer Login',       'ur': 'کسان لاگ ان'},
    'mobile_number':       {'en': 'Mobile Number',      'ur': 'موبائل نمبر'},
    'enter_otp':           {'en': 'Enter 4-digit OTP',  'ur': 'چار ہندسوں کا او ٹی پی درج کریں'},
    'login_button':        {'en': 'Login',               'ur': 'لاگ ان'},
    'quick_demo_login':    {'en': 'Quick Demo Login',    'ur': 'فوری ٹیسٹ لاگ ان'},
    'otp_sent':            {'en': 'OTP sent to your number', 'ur': 'آپ کے نمبر پر او ٹی پی بھیج دیا گیا'},

    // Dashboard
    'select_field':        {'en': 'Select Field',        'ur': 'کھیت منتخب کریں'},
    'crop_vital_score':    {'en': 'Crop Vital Score',    'ur': 'فصل کی صحت سکور'},
    'status_healthy':      {'en': 'Healthy',              'ur': 'صحت مند'},
    'status_moderate':     {'en': 'Moderate Stress',      'ur': 'پانی کی ضرورت'},
    'status_critical':     {'en': 'Critical',             'ur': 'خطرہ'},

    // Advisory
    'ai_advisory':         {'en': 'AI Advisory',          'ur': 'اے آئی مشورہ'},

    // Metrics
    'soil_moisture':       {'en': 'Soil Moisture',        'ur': 'زمین میں نمی'},
    'vegetation_ndvi':     {'en': 'Vegetation (NDVI)',    'ur': 'نباتات (این ڈی وی آئی)'},
    'weather_rain':        {'en': 'Weather & Rain Risk',  'ur': 'موسم اور بارش کا خطرہ'},

    // Voice assistant
    'voice_prompt_en':     {'en': 'Tap to ask AeroYield...',
                            'ur': 'اردو میں بولنے کے لیے مائیک دبائیں...'},
    'voice_listening':     {'en': 'Listening...',         'ur': 'سن رہا ہے...'},
    'voice_close':         {'en': 'Close',                'ur': 'بند کریں'},

    // Helpline
    'helpline_title':      {'en': 'Agriculture Helpline', 'ur': 'زرعی ہیلپ لائن'},
    'whatsapp_chat':       {'en': 'WhatsApp Chat',        'ur': 'واٹس ایپ چیٹ'},
    'call_helpline':       {'en': 'Call Toll-Free 1100',  'ur': 'ٹول فری 1100 پر کال کریں'},

    // Status labels for metric badges
    'adequate':            {'en': 'Adequate',  'ur': 'مناسب'},
    'low':                 {'en': 'Low',        'ur': 'کم'},
    'very_low':            {'en': 'Very Low',   'ur': 'بہت کم'},
    'dense':               {'en': 'Dense',      'ur': 'گھنی'},
    'moderate':            {'en': 'Moderate',   'ur': 'درمیانی'},
    'sparse':              {'en': 'Sparse',     'ur': 'کمزور'},
    'rain_risk':           {'en': 'Rain Risk',  'ur': 'بارش کا خطرہ'},

    // Simulated voice response
    'voice_response_en':   {
      'en': 'Your crop in Mardan is healthy. Soil moisture is optimal — no irrigation needed today.',
      'ur': 'مردان میں آپ کی فصل صحت مند ہے۔ زمین میں نمی مناسب ہے — آج آبپاشی کی ضرورت نہیں۔',
    },
  };

  /// Generic lookup — falls back to English if the key or language is missing.
  String _t(String key) =>
      _strings[key]?[locale.languageCode] ?? _strings[key]?['en'] ?? key;

  // Public getters ----------------------------------------------------------
  String get appName        => _t('app_name');
  String get tagline        => _t('tagline');
  String get selectLanguage => _t('select_language');
  String get english        => _t('english');
  String get urdu           => _t('urdu');
  String get loginTitle     => _t('login_title');
  String get mobileNumber   => _t('mobile_number');
  String get enterOtp       => _t('enter_otp');
  String get loginButton    => _t('login_button');
  String get quickDemoLogin => _t('quick_demo_login');
  String get otpSent        => _t('otp_sent');
  String get selectField    => _t('select_field');
  String get cropVitalScore => _t('crop_vital_score');
  String get statusHealthy  => _t('status_healthy');
  String get statusModerate => _t('status_moderate');
  String get statusCritical => _t('status_critical');
  String get aiAdvisory     => _t('ai_advisory');
  String get soilMoisture   => _t('soil_moisture');
  String get vegetationNdvi => _t('vegetation_ndvi');
  String get weatherRain    => _t('weather_rain');
  String get voicePrompt    => _t('voice_prompt_en');
  String get voiceListening => _t('voice_listening');
  String get voiceClose     => _t('voice_close');
  String get helplineTitle  => _t('helpline_title');
  String get whatsappChat   => _t('whatsapp_chat');
  String get callHelpline   => _t('call_helpline');
  String get adequate       => _t('adequate');
  String get low            => _t('low');
  String get veryLow        => _t('very_low');
  String get dense          => _t('dense');
  String get moderate       => _t('moderate');
  String get sparse         => _t('sparse');
  String get rainRisk       => _t('rain_risk');
  String get voiceResponseEn => _t('voice_response_en');
}
