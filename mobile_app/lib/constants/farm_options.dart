import 'package:flutter/foundation.dart';

@immutable
class LocalizedFarmOption {
  final String en;
  final String ur;

  const LocalizedFarmOption(this.en, this.ur);

  String forLanguage(String languageCode) => languageCode == 'ur' ? ur : en;
}

const cropOptions = <LocalizedFarmOption>[
  LocalizedFarmOption('Wheat', 'گندم'),
  LocalizedFarmOption('Maize', 'مکئی'),
  LocalizedFarmOption('Rice', 'چاول'),
  LocalizedFarmOption('Sugarcane', 'گنا'),
  LocalizedFarmOption('Tobacco', 'تمباکو'),
  LocalizedFarmOption('Cotton', 'کپاس'),
  LocalizedFarmOption('Potato', 'آلو'),
  LocalizedFarmOption('Tomato', 'ٹماٹر'),
  LocalizedFarmOption('Onion', 'پیاز'),
  LocalizedFarmOption('Fodder', 'چارہ'),
];

const districtOptions = <LocalizedFarmOption>[
  LocalizedFarmOption('Mardan', 'مردان'),
  LocalizedFarmOption('Swabi', 'صوابی'),
  LocalizedFarmOption('Charsadda', 'چارسدہ'),
  LocalizedFarmOption('Peshawar', 'پشاور'),
  LocalizedFarmOption('Nowshera', 'نوشہرہ'),
  LocalizedFarmOption('Kohat', 'کوہاٹ'),
  LocalizedFarmOption('Lahore', 'لاہور'),
  LocalizedFarmOption('Faisalabad', 'فیصل آباد'),
  LocalizedFarmOption('Multan', 'ملتان'),
  LocalizedFarmOption('Sukkur', 'سکھر'),
  LocalizedFarmOption('Hyderabad', 'حیدرآباد'),
  LocalizedFarmOption('Quetta', 'کوئٹہ'),
];
