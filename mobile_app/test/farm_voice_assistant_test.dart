import 'package:flutter_test/flutter_test.dart';

import 'package:aeroyield/models/farm_data.dart';
import 'package:aeroyield/services/farm_voice_assistant.dart';

const _farm = FarmData(
  fieldId: 'field_1',
  farmerName: 'Amina',
  district: 'Mardan',
  districtUr: 'مردان',
  cropType: 'Wheat',
  cropTypeUr: 'گندم',
  cropVitalScore: 60,
  statusLabelEn: 'Moderate Stress',
  statusLabelUr: 'پانی کی ضرورت',
  soilMoisturePct: 42.5,
  ndviIndex: 0.51,
  weather: WeatherInfo(tempC: 31, rainRiskPct: 20),
  advisoryTextEn: 'Irrigate within 24 hours.',
  advisoryTextUr: '24 گھنٹے کے اندر آبپاشی کریں۔',
  audioUrl: '',
  latitude: 34.2,
  longitude: 72.0,
);

void main() {
  test('answers an English water question from the selected field', () {
    final reply = FarmVoiceAssistant.answer(
      farm: _farm,
      question: 'Do I need water today?',
      isUrdu: false,
    );

    expect(reply.text, contains('42.5%'));
    expect(reply.text, contains('Irrigate within 24 hours.'));
  });

  test('answers Urdu crop health questions with the current score', () {
    final reply = FarmVoiceAssistant.answer(
      farm: _farm,
      question: 'میری فصل کی صحت کیسی ہے؟',
      isUrdu: true,
    );

    expect(reply.text, contains('60'));
    expect(reply.text, contains('پانی کی ضرورت'));
  });

  test('offers helpline actions when a farmer asks for help', () {
    final reply = FarmVoiceAssistant.answer(
      farm: _farm,
      question: 'I need helpline help',
      isUrdu: false,
    );

    expect(reply.offersHelp, isTrue);
  });
}
