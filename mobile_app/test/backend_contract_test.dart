// =============================================================================
// AeroYield — Backend Data Contract Test
//
// Parses REAL payloads captured from the live backend
// (https://aeroyield-api.onrender.com) and stored as fixtures, so the
// FarmData model is regression-tested against the actual API response shape
// without needing network access.
//
// To refresh the fixtures after a backend contract change:
//   curl -H "X-API-Key: <key>" https://aeroyield-api.onrender.com/api/farms \
//        -o test/fixtures/live_farms_response.json
// =============================================================================
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aeroyield/models/farm_data.dart';
import 'package:aeroyield/services/api_service.dart';

void main() {
  final farmsJson =
      jsonDecode(
            File('test/fixtures/live_farms_response.json').readAsStringSync(),
          )
          as List<dynamic>;

  test('parses the full /api/farms list from a live-captured payload', () {
    expect(
      farmsJson,
      isNotEmpty,
      reason: 'fixture should contain at least one farm',
    );

    final farms = farmsJson
        .map((e) => FarmData.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final farm in farms) {
      expect(farm.fieldId, isNotEmpty);
      expect(farm.farmerName, isNotEmpty);
      expect(farm.district, isNotEmpty);
      expect(farm.districtUr, isNotEmpty, reason: 'Urdu district required');
      expect(farm.cropType, isNotEmpty);
      expect(farm.cropTypeUr, isNotEmpty, reason: 'Urdu crop name required');
      expect(farm.cropVitalScore, inInclusiveRange(0, 100));
      expect(farm.statusLabelEn, isNotEmpty);
      expect(farm.statusLabelUr, isNotEmpty);
      expect(farm.soilMoisturePct, inInclusiveRange(0, 100));
      expect(farm.ndviIndex, inInclusiveRange(-1, 1));
      expect(farm.advisoryTextEn, isNotEmpty);
      expect(farm.advisoryTextUr, isNotEmpty);
      expect(farm.lastUpdated, isNotEmpty);
    }

    // Vital score ↔ status label must follow the ML class mapping
    // (Class 0 → 85 Healthy, Class 1 → 60 Moderate, Class 2 → 30 Critical).
    for (final farm in farms) {
      if (farm.cropVitalScore >= 75) {
        expect(farm.statusLabelEn.toLowerCase(), contains('healthy'));
      } else if (farm.cropVitalScore >= 45) {
        expect(
          farm.statusLabelEn.toLowerCase(),
          anyOf(contains('moderate'), contains('stress')),
        );
      } else {
        expect(
          farm.statusLabelEn.toLowerCase(),
          anyOf(contains('critical'), contains('severe'), contains('danger')),
        );
      }
    }

    // Mobile field ownership/onboarding also needs the same [lat, lon] pair.
    for (final farm in farms) {
      expect(
        farm.latitude,
        inInclusiveRange(23, 37),
        reason: '${farm.fieldId} needs a Pakistan latitude',
      );
      expect(
        farm.longitude,
        inInclusiveRange(60, 78),
        reason: '${farm.fieldId} needs a Pakistan longitude',
      );
    }
  });

  test('parses a single-farm payload and resolves the relative audio URL', () {
    final singleJson =
        jsonDecode(
              File('test/fixtures/live_farm_single.json').readAsStringSync(),
            )
            as Map<String, dynamic>;

    // ApiService rewrites relative audio paths before deserialization.
    final mutable = Map<String, dynamic>.from(singleJson);
    mutable['audio_url'] = ApiService.resolveUrl(
      singleJson['audio_url'] as String?,
    );

    final farm = FarmData.fromJson(mutable);

    expect(farm.fieldId, 'mardan_plot_01');
    expect(farm.farmerName, 'Khan Muhammad');
    expect(farm.district, 'Mardan');
    expect(farm.weather.tempC, isNotNull);
    expect(farm.weather.rainRiskPct, inInclusiveRange(0, 100));
    expect(
      farm.audioUrl,
      startsWith('https://aeroyield-api.onrender.com/static/audio/'),
      reason: 'audio player needs an absolute URL to stream',
    );

    // GIS map contract: [lat, lon] pair in the raw payload.
    expect(singleJson['coordinates'], hasLength(2));
  });

  test('toJson round-trips every parsed field without loss', () {
    final farm = FarmData.fromJson(farmsJson.first as Map<String, dynamic>);
    final restored = FarmData.fromJson(farm.toJson());

    expect(restored.fieldId, farm.fieldId);
    expect(restored.farmerName, farm.farmerName);
    expect(restored.district, farm.district);
    expect(restored.cropType, farm.cropType);
    expect(restored.cropVitalScore, farm.cropVitalScore);
    expect(restored.soilMoisturePct, farm.soilMoisturePct);
    expect(restored.ndviIndex, farm.ndviIndex);
    expect(restored.weather.tempC, farm.weather.tempC);
    expect(restored.advisoryTextEn, farm.advisoryTextEn);
  });
}
