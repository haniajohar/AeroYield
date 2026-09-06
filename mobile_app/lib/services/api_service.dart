// =============================================================================
// AeroYield — API Service
//
// HTTP client that fetches farm data from the AeroYield FastAPI backend
// (deployed on Render).  Falls back to local mock data when the backend is
// unreachable (offline mode).
//
// Backend endpoints (all require the X-API-Key header):
//   GET  /api/farms               → List<FarmData>  (all plots)
//   GET  /api/farms/{field_id}    → FarmData        (single plot)
//   POST /api/predict/{field_id}  → FarmData        (fresh ML prediction)
//   GET  /api/admin/dashboard     → aggregated stats
//   GET  /health                  → health check (no auth)
//
// Notes:
//   • Render free tier "spins down" after inactivity — the first request
//     after a cold start can take 30–60 s.  Timeouts below account for this,
//     and the fetch helper retries once on failure.
//   • The backend returns RELATIVE audio URLs (e.g. "/static/audio/x.mp3").
//     This service resolves them to absolute URLs before parsing.
// =============================================================================

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/mock_data.dart';
import '../models/farm_data.dart';

/// Result of the owner-filtered farm request. A failed request intentionally
/// never falls back to shared demo plots, preventing accidental data mixing.
class OwnedFarmsResult {
  final List<FarmData> farms;
  final bool isLive;

  const OwnedFarmsResult({required this.farms, required this.isLive});
}

class ApiService {
  // ── Configuration ───────────────────────────────────────────────────────

  /// Production API key (configured in the Render dashboard → API_KEYS).
  /// Rotated 2026-09-04 after the original key leaked into the public repo.
  /// Override per build without touching source:
  ///   flutter run --dart-define=AEROYIELD_API_KEY=`<key>`
  static const String apiKey = String.fromEnvironment(
    'AEROYIELD_API_KEY',
    defaultValue: 'aeroyield-8iUXOUZIBl0YDT2uKh4WHAYoHXRPWsAhidkT',
  );

  /// Live backend on Render.
  static const String baseUrl = 'https://aeroyield-api.onrender.com';

  /// Default headers sent with every request.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
  };

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── URL helpers ─────────────────────────────────────────────────────────

  /// Resolves a possibly-relative backend URL (e.g. "/static/audio/x.mp3")
  /// into an absolute one the audio player can stream.
  static String resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$baseUrl$url';
  }

  FarmData _parseFarm(Map<String, dynamic> json) {
    // Rewrite relative audio path → absolute URL before deserialization.
    final mutable = Map<String, dynamic>.from(json);
    mutable['audio_url'] = resolveUrl(json['audio_url'] as String?);
    return FarmData.fromJson(mutable);
  }

  // ── Request helper with cold-start retry ────────────────────────────────

  /// GETs [path] and decodes a successful JSON response.
  /// Retries once after a short delay — this transparently absorbs Render
  /// free-tier cold starts (first hit after ~15 min of inactivity).
  Future<dynamic> _getJson(String path, {Duration? timeout}) async {
    final response = await _getWithRetry(
      Uri.parse('$baseUrl$path'),
      timeout: timeout,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('GET $path returned HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  Future<http.Response> _getWithRetry(Uri uri, {Duration? timeout}) async {
    try {
      return await _client
          .get(uri, headers: _headers)
          .timeout(timeout ?? const Duration(seconds: 15));
    } catch (_) {
      await Future<void>.delayed(const Duration(seconds: 5));
      return _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 60));
    }
  }

  Future<http.Response> _postWithRetry(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    try {
      return await _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      await Future<void>.delayed(const Duration(seconds: 5));
      return _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 90));
    }
  }

  // ── Fetch all farms ─────────────────────────────────────────────────────

  /// Tries the backend first; falls back to mock data on failure.
  Future<List<FarmData>> fetchAllFarms() async {
    try {
      final data = await _getJson('/api/farms');
      if (data is List) {
        return data.map((e) => _parseFarm(e as Map<String, dynamic>)).toList();
      }
      return MockData.farms;
    } catch (e) {
      debugPrint('ApiService: $e — falling back to mock data');
      return MockData.farms;
    }
  }

  // ── Phone-owned farms (Plan B) ──────────────────────────────────────────

  /// Fetch only fields registered under [ownerPhone]. Unlike the legacy
  /// endpoint helper, this returns an empty non-live result on failure rather
  /// than exposing unrelated fallback farms.
  Future<OwnedFarmsResult> fetchOwnedFarms(String ownerPhone) async {
    final uri = Uri.parse(
      '$baseUrl/api/farms',
    ).replace(queryParameters: {'owner_phone': ownerPhone});
    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode != 200 ||
          response.headers['x-aeroyield-owner-filter'] != 'v1') {
        debugPrint(
          'ApiService.fetchOwnedFarms: ownership endpoint unavailable '
          '(HTTP ${response.statusCode})',
        );
        return const OwnedFarmsResult(farms: [], isLive: false);
      }
      final data = jsonDecode(response.body);
      if (data is! List) {
        return const OwnedFarmsResult(farms: [], isLive: false);
      }
      return OwnedFarmsResult(
        farms: data
            .map((item) => _parseFarm(Map<String, dynamic>.from(item as Map)))
            .toList(),
        isLive: true,
      );
    } catch (error) {
      debugPrint('ApiService.fetchOwnedFarms: $error');
      return const OwnedFarmsResult(farms: [], isLive: false);
    }
  }

  /// Creates one field owned by [ownerPhone]. The backend runs its weather and
  /// ML pipeline immediately and returns a normal [FarmData] response.
  Future<FarmData?> createOwnedFarm({
    required String ownerPhone,
    required String farmerName,
    required String fieldLabel,
    required String cropType,
    required String cropTypeUr,
    required String district,
    required String districtUr,
    required double latitude,
    required double longitude,
  }) async {
    final payload = {
      'owner_phone': ownerPhone,
      'farmer_name': farmerName,
      'field_label': fieldLabel,
      'crop_type': cropType,
      'crop_type_ur': cropTypeUr,
      'district': district,
      'district_ur': districtUr,
      'latitude': latitude,
      'longitude': longitude,
    };
    try {
      final response = await _postWithRetry(
        Uri.parse('$baseUrl/api/farms'),
        payload,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('ApiService.createOwnedFarm: HTTP ${response.statusCode}');
        return null;
      }
      return _parseFarm(
        Map<String, dynamic>.from(jsonDecode(response.body) as Map),
      );
    } catch (error) {
      debugPrint('ApiService.createOwnedFarm: $error');
      return null;
    }
  }

  // ── Fetch single farm ───────────────────────────────────────────────────

  Future<FarmData?> fetchFarm(String fieldId) async {
    try {
      final data = await _getJson('/api/farms/$fieldId');
      if (data is Map<String, dynamic>) return _parseFarm(data);
      return null;
    } catch (e) {
      debugPrint('ApiService.fetchFarm: $e');
      return null;
    }
  }

  // ── Trigger ML prediction ──────────────────────────────────────────────

  /// Sends weather features to the backend, which runs the Gradient Boosting
  /// model and returns a fresh Crop Vital Score + status labels.
  Future<FarmData?> predictCropHealth(
    String fieldId,
    Map<String, dynamic> weatherFeatures,
  ) async {
    try {
      http.Response response;
      try {
        response = await _client
            .post(
              Uri.parse('$baseUrl/api/predict/$fieldId'),
              headers: _headers,
              body: jsonEncode(weatherFeatures),
            )
            .timeout(const Duration(seconds: 15));
      } catch (_) {
        // Cold-start retry (TTS generation can also be slow).
        await Future<void>.delayed(const Duration(seconds: 5));
        response = await _client
            .post(
              Uri.parse('$baseUrl/api/predict/$fieldId'),
              headers: _headers,
              body: jsonEncode(weatherFeatures),
            )
            .timeout(const Duration(seconds: 90));
      }

      if (response.statusCode == 200) {
        return _parseFarm(jsonDecode(response.body) as Map<String, dynamic>);
      }
      debugPrint('ApiService.predict: HTTP ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('ApiService.predictCropHealth: $e');
      return null;
    }
  }

  // ── Health check ────────────────────────────────────────────────────────

  /// Lightweight liveness probe. Returns true if the backend responds.
  /// Uses a generous timeout to absorb Render cold starts.
  Future<bool> isBackendAlive() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 60));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Utility ─────────────────────────────────────────────────────────────

  /// Jitter helper used by callers that back off before retrying.
  static Duration randomBackoff() =>
      Duration(milliseconds: 500 + math.Random().nextInt(1500));

  void dispose() => _client.close();
}
