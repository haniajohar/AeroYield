// =============================================================================
// AeroYield — Mock Data
//
// Three regional Pakistan farming zones with realistic data aligned to the
// ML team's Crop Vital Score mapping:
//   Class 0 (Healthy)         → score 85  (range 75–100)
//   Class 1 (Moderate_Stress) → score 60  (range 45–74)
//   Class 2 (Severe_Stress)   → score 30  (range 0–44)
//
// Fields match the backend Universal Data Contract.
// =============================================================================

import '../models/farm_data.dart';

class MockData {
  MockData._();

  static final List<FarmData> farms = [
    // ── 1. Mardan Maize Plot ─ ML: Healthy (Class 0) ──────────────────────
    FarmData(
      fieldId: 'mardan_plot_01',
      farmerName: 'Khan Muhammad',
      district: 'Mardan',
      districtUr: 'مردان',
      cropType: 'Maize & Sugarcane',
      cropTypeUr: 'مکئی اور گنا',
      cropVitalScore: 85, // ML Class 0 → 85
      statusLabelEn: 'Healthy',
      statusLabelUr: 'صحت مند',
      soilMoisturePct: 68.5,
      ndviIndex: 0.72,
      weather: const WeatherInfo(tempC: 28, rainRiskPct: 10),
      advisoryTextEn:
          'Soil moisture is optimal. No irrigation required today.',
      advisoryTextUr: 'زمین میں نمی مناسب ہے۔ آج آبپاشی کی ضرورت نہیں ہے۔',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      lastUpdated: '2026-09-03',
    ),

    // ── 2. Swat Peach Orchard ─ ML: Moderate Stress (Class 1) ─────────────
    FarmData(
      fieldId: 'swat_orchard_02',
      farmerName: 'Said Rahman',
      district: 'Swat',
      districtUr: 'سوات',
      cropType: 'Peach Orchard',
      cropTypeUr: 'آڑو کا باغ',
      cropVitalScore: 60, // ML Class 1 → 60
      statusLabelEn: 'Moderate Stress',
      statusLabelUr: 'پانی کی ضرورت',
      soilMoisturePct: 41.2,
      ndviIndex: 0.48,
      weather: const WeatherInfo(tempC: 31, rainRiskPct: 25),
      advisoryTextEn:
          'Soil moisture is dropping. Light irrigation recommended within 48 hours.',
      advisoryTextUr:
          'زمین میں نمی کم ہو رہی ہے۔ 48 گھنٹوں کے اندر ہلکی آبپاشی کی سفارش ہے۔',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      lastUpdated: '2026-09-03',
    ),

    // ── 3. Multan Cotton Field ─ ML: Severe Stress (Class 2) ──────────────
    FarmData(
      fieldId: 'multan_cotton_03',
      farmerName: 'Allah Bakhsh',
      district: 'Multan',
      districtUr: 'ملتان',
      cropType: 'Cotton Field',
      cropTypeUr: 'کپاس کا کھیت',
      cropVitalScore: 30, // ML Class 2 → 30
      statusLabelEn: 'Critical',
      statusLabelUr: 'خطرہ',
      soilMoisturePct: 18.0,
      ndviIndex: 0.25,
      weather: const WeatherInfo(tempC: 42, rainRiskPct: 5),
      advisoryTextEn:
          'Critical moisture deficit detected. Immediate flood irrigation required.',
      advisoryTextUr: 'زمین میں نمی کی شدید کمی۔ فوری آبپاشی ضروری ہے۔',
      audioUrl:
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      lastUpdated: '2026-09-03',
    ),
  ];
}
