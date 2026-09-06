import 'package:flutter/foundation.dart';

import 'farm_data.dart';

/// A farmer-owned field saved locally before it is synced to the demo backend.
@immutable
class FieldRegistration {
  final String localId;
  final String label;
  final String cropType;
  final String cropTypeUr;
  final String district;
  final String districtUr;
  final double latitude;
  final double longitude;
  final bool synced;
  final String? serverFieldId;

  const FieldRegistration({
    required this.localId,
    required this.label,
    required this.cropType,
    required this.cropTypeUr,
    required this.district,
    required this.districtUr,
    required this.latitude,
    required this.longitude,
    this.synced = false,
    this.serverFieldId,
  });

  factory FieldRegistration.create({
    required String label,
    required String cropType,
    required String cropTypeUr,
    required String district,
    required String districtUr,
    required double latitude,
    required double longitude,
  }) {
    return FieldRegistration(
      localId: 'local_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      cropType: cropType,
      cropTypeUr: cropTypeUr,
      district: district,
      districtUr: districtUr,
      latitude: latitude,
      longitude: longitude,
    );
  }

  FieldRegistration copyWith({bool? synced, String? serverFieldId}) {
    return FieldRegistration(
      localId: localId,
      label: label,
      cropType: cropType,
      cropTypeUr: cropTypeUr,
      district: district,
      districtUr: districtUr,
      latitude: latitude,
      longitude: longitude,
      synced: synced ?? this.synced,
      serverFieldId: serverFieldId ?? this.serverFieldId,
    );
  }

  factory FieldRegistration.fromJson(Map<String, dynamic> json) {
    return FieldRegistration(
      localId: json['local_id'] as String,
      label: json['label'] as String? ?? 'My Field',
      cropType: json['crop_type'] as String,
      cropTypeUr: json['crop_type_ur'] as String? ?? '',
      district: json['district'] as String,
      districtUr: json['district_ur'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      synced: json['synced'] as bool? ?? false,
      serverFieldId: json['server_field_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'local_id': localId,
    'label': label,
    'crop_type': cropType,
    'crop_type_ur': cropTypeUr,
    'district': district,
    'district_ur': districtUr,
    'latitude': latitude,
    'longitude': longitude,
    'synced': synced,
    'server_field_id': serverFieldId,
  };

  /// A clearly-labelled local placeholder while offline sync is pending.
  FarmData toPendingFarm(String farmerName) {
    return FarmData(
      fieldId: serverFieldId ?? localId,
      farmerName: farmerName,
      district: district,
      districtUr: districtUr,
      cropType: cropType,
      cropTypeUr: cropTypeUr,
      cropVitalScore: 0,
      statusLabelEn: 'Awaiting sync',
      statusLabelUr: 'ہم وقت سازی کا انتظار',
      soilMoisturePct: 0,
      ndviIndex: 0,
      weather: const WeatherInfo(tempC: 0, rainRiskPct: 0),
      advisoryTextEn:
          'Your field is saved on this phone and will sync when the connection returns.',
      advisoryTextUr:
          'آپ کا کھیت اس فون میں محفوظ ہے اور کنکشن بحال ہونے پر ہم وقت ہو جائے گا۔',
      audioUrl: '',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
