// =============================================================================
// AeroYield — Farm Data Model
//
// Represents a single farm plot.  Fields align with:
//   1. The ML team's Universal Data Contract (crop_vital_model_metadata.json)
//   2. The backend API JSON response
//   3. Backward-compatible getters for existing UI code
//
// New fields vs. original model:
//   • district / districtUr  (replaces regionEn / regionUr)
//   • cropType / cropTypeUr  (replaces cropEn / cropUr)
//   • weather (nested WeatherInfo sub-model)
//   • lastUpdated (ISO-8601 timestamp from backend)
//   • fromJson() factory for live API deserialization
// =============================================================================

/// Nested weather object matching the backend contract:
///   "weather": { "temp_c": 28, "rain_risk_pct": 10 }
class WeatherInfo {
  final int tempC;
  final int rainRiskPct;

  const WeatherInfo({required this.tempC, required this.rainRiskPct});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) => WeatherInfo(
    tempC: (json['temp_c'] as num).toInt(),
    rainRiskPct: (json['rain_risk_pct'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'temp_c': tempC,
    'rain_risk_pct': rainRiskPct,
  };
}

/// Full farm-plot data model.
class FarmData {
  final String fieldId;
  final String farmerName;

  // ── New API-aligned fields ──────────────────────────────────────────────
  /// District name (English) — maps to backend "district"
  final String district;

  /// District name (Urdu)
  final String districtUr;

  /// Crop type (English) — maps to backend "crop_type"
  final String cropType;

  /// Crop type (Urdu)
  final String cropTypeUr;

  /// Composite crop health index 0–100 (from ML model or mock)
  final int cropVitalScore;

  /// Human-readable status labels (bilingual)
  final String statusLabelEn;
  final String statusLabelUr;

  /// Satellite-derived soil moisture percentage
  final double soilMoisturePct;

  /// Normalized Difference Vegetation Index (0.0 – 1.0)
  final double ndviIndex;

  /// Nested weather snapshot
  final WeatherInfo weather;

  /// Single-sentence AI advisory text (bilingual)
  final String advisoryTextEn;
  final String advisoryTextUr;

  /// URL to pre-recorded voice advisory MP3
  final String audioUrl;

  /// ISO-8601 timestamp of the last prediction / data refresh
  final String lastUpdated;

  /// Field position from the backend's [latitude, longitude] coordinates pair.
  /// A locally queued field also carries these while it awaits backend sync.
  final double? latitude;
  final double? longitude;

  const FarmData({
    required this.fieldId,
    required this.farmerName,
    required this.district,
    required this.districtUr,
    required this.cropType,
    required this.cropTypeUr,
    required this.cropVitalScore,
    required this.statusLabelEn,
    required this.statusLabelUr,
    required this.soilMoisturePct,
    required this.ndviIndex,
    required this.weather,
    required this.advisoryTextEn,
    required this.advisoryTextUr,
    required this.audioUrl,
    this.lastUpdated = '',
    this.latitude,
    this.longitude,
  });

  // ── Backward-compatible getters (existing UI code keeps working) ────────
  String regionFor(String lang) => lang == 'ur' ? districtUr : district;
  String cropFor(String lang) => lang == 'ur' ? cropTypeUr : cropType;
  String statusFor(String lang) => lang == 'ur' ? statusLabelUr : statusLabelEn;
  String advisoryFor(String lang) =>
      lang == 'ur' ? advisoryTextUr : advisoryTextEn;

  /// Shortcut for weather.tempC
  int get tempC => weather.tempC;

  /// Shortcut for weather.rainRiskPct
  int get rainRiskPct => weather.rainRiskPct;

  // ── JSON serialization (matches backend API contract) ───────────────────

  /// Deserialize from the backend JSON response.
  factory FarmData.fromJson(Map<String, dynamic> json) {
    final weatherJson = json['weather'] as Map<String, dynamic>?;
    final weather = weatherJson != null
        ? WeatherInfo.fromJson(weatherJson)
        : const WeatherInfo(tempC: 0, rainRiskPct: 0);

    final coordinates = json['coordinates'] as List<dynamic>?;

    return FarmData(
      fieldId: json['field_id'] as String? ?? '',
      farmerName: json['farmer_name'] as String? ?? '',
      district: json['district'] as String? ?? '',
      districtUr: json['district_ur'] as String? ?? '',
      cropType: json['crop_type'] as String? ?? '',
      cropTypeUr: json['crop_type_ur'] as String? ?? '',
      cropVitalScore: (json['crop_vital_score'] as num?)?.toInt() ?? 0,
      statusLabelEn: json['status_label_en'] as String? ?? '',
      statusLabelUr: json['status_label_ur'] as String? ?? '',
      soilMoisturePct: (json['soil_moisture_pct'] as num?)?.toDouble() ?? 0.0,
      ndviIndex: (json['ndvi_index'] as num?)?.toDouble() ?? 0.0,
      weather: weather,
      advisoryTextEn: json['advisory_text_en'] as String? ?? '',
      advisoryTextUr: json['advisory_text_ur'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
      latitude: coordinates != null && coordinates.length == 2
          ? (coordinates.first as num?)?.toDouble()
          : null,
      longitude: coordinates != null && coordinates.length == 2
          ? (coordinates.last as num?)?.toDouble()
          : null,
    );
  }

  /// Serialize back to the backend JSON format.
  Map<String, dynamic> toJson() => {
    'field_id': fieldId,
    'farmer_name': farmerName,
    'district': district,
    'district_ur': districtUr,
    'crop_type': cropType,
    'crop_type_ur': cropTypeUr,
    'crop_vital_score': cropVitalScore,
    'status_label_en': statusLabelEn,
    'status_label_ur': statusLabelUr,
    'soil_moisture_pct': soilMoisturePct,
    'ndvi_index': ndviIndex,
    'weather': weather.toJson(),
    'advisory_text_en': advisoryTextEn,
    'advisory_text_ur': advisoryTextUr,
    'audio_url': audioUrl,
    'last_updated': lastUpdated,
    if (latitude != null && longitude != null)
      'coordinates': [latitude, longitude],
  };
}
