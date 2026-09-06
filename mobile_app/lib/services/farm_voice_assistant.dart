import '../models/farm_data.dart';

class VoiceReply {
  final String text;
  final bool offersHelp;

  const VoiceReply(this.text, {this.offersHelp = false});
}

/// Answers the small, predictable set of farmer questions using the selected
/// field's actual data. Speech recognition is handled separately by the UI.
class FarmVoiceAssistant {
  static VoiceReply answer({
    required FarmData farm,
    required String question,
    required bool isUrdu,
  }) {
    final normalized = question.toLowerCase();

    if (_matches(normalized, const [
      'help',
      'helpline',
      'call',
      'whatsapp',
      'madad',
      'مدد',
      'ہیلپ',
    ])) {
      return VoiceReply(
        isUrdu
            ? 'مدد کے لیے نیچے ہیلپ لائن بٹن دبائیں۔'
            : 'Tap the helpline button below for WhatsApp or a call.',
        offersHelp: true,
      );
    }

    if (_matches(normalized, const [
      'water',
      'irrig',
      'moisture',
      'pani',
      'آبپاشی',
      'پانی',
      'نمی',
    ])) {
      return VoiceReply(
        isUrdu
            ? 'زمین میں نمی ${farm.soilMoisturePct.toStringAsFixed(1)} فیصد ہے۔ ${farm.advisoryTextUr}'
            : 'Soil moisture is ${farm.soilMoisturePct.toStringAsFixed(1)}%. ${farm.advisoryTextEn}',
      );
    }

    if (_matches(normalized, const [
      'weather',
      'rain',
      'temperature',
      'mausam',
      'بارش',
      'موسم',
      'درجہ',
    ])) {
      return VoiceReply(
        isUrdu
            ? 'موجودہ درجہ حرارت ${farm.tempC} ڈگری سیلسیس اور بارش کا خطرہ ${farm.rainRiskPct} فیصد ہے۔'
            : 'The current temperature is ${farm.tempC}°C and rain risk is ${farm.rainRiskPct}%.',
      );
    }

    if (_matches(normalized, const [
      'advice',
      'advisory',
      'recommend',
      'mashwara',
      'مشورہ',
      'ہدایت',
    ])) {
      return VoiceReply(isUrdu ? farm.advisoryTextUr : farm.advisoryTextEn);
    }

    if (_matches(normalized, const [
      'health',
      'score',
      'status',
      'crop',
      'field',
      'fasal',
      'sehat',
      'فصل',
      'صحت',
      'کھیت',
      'سکور',
    ])) {
      return VoiceReply(
        isUrdu
            ? 'آپ کے ${farm.cropTypeUr} کے کھیت کا صحت سکور ${farm.cropVitalScore} ہے۔ حالت: ${farm.statusLabelUr}۔'
            : 'Your ${farm.cropType} field has a crop vital score of ${farm.cropVitalScore}. Status: ${farm.statusLabelEn}.',
      );
    }

    return VoiceReply(
      isUrdu
          ? 'میں فصل کی صحت، پانی، موسم، بارش یا مشورے کے بارے میں جواب دے سکتا ہوں۔'
          : 'I can answer about crop health, water, weather, rain risk, or today’s advisory.',
    );
  }

  static bool _matches(String text, List<String> terms) =>
      terms.any(text.contains);
}
