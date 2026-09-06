// =============================================================================
// AeroYield — Farmer-Owned Field Provider (Plan B)
//
// The app never falls back to the shared seed list. It displays only farms
// filtered by the signed-in phone, or local fields waiting to be synced.
// =============================================================================

import 'package:flutter/material.dart';

import '../models/farm_data.dart';
import '../models/field_registration.dart';
import '../services/api_service.dart';
import '../services/local_field_store.dart';

class FarmProvider extends ChangeNotifier {
  final ApiService _api;
  final LocalFieldStore _store;

  FarmProvider({ApiService? api, LocalFieldStore? store})
    : _api = api ?? ApiService(),
      _store = store ?? LocalFieldStore();

  List<FarmData> _farms = [];
  List<FieldRegistration> _localFields = [];
  int _activeFarmIndex = 0;
  bool _isLive = false;
  bool _isLoading = false;
  int _pendingSyncCount = 0;

  List<FarmData> get farms => List.unmodifiable(_farms);
  FarmData? get activeFarm => _farms.isEmpty ? null : _farms[_activeFarmIndex];
  int get activeFarmIndex => _activeFarmIndex;
  bool get isLive => _isLive;
  bool get isLoading => _isLoading;
  bool get hasFarms => _farms.isNotEmpty;
  int get pendingSyncCount => _pendingSyncCount;

  void setActiveFarm(int index) {
    if (index < 0 || index >= _farms.length) return;
    _activeFarmIndex = index;
    notifyListeners();
  }

  /// Saves fields locally first. Home then syncs them in the background.
  Future<void> saveLocalFields(
    String phone,
    List<FieldRegistration> fields,
    String farmerName,
  ) async {
    _localFields = fields;
    await _store.save(phone, _localFields);
    _showLocalFields(farmerName);
  }

  /// Loads only the current phone's farms. This is a UX privacy filter for the
  /// explicitly demo-only Plan B flow; it is not server-side authorization.
  Future<void> loadOwnedFarms({
    required String phone,
    required String farmerName,
    bool createDemoField = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    _localFields = await _store.load(phone);
    if (createDemoField && _localFields.isEmpty) {
      _localFields = [
        FieldRegistration.create(
          label: 'Demo Field',
          cropType: 'Wheat',
          cropTypeUr: 'گندم',
          district: 'Mardan',
          districtUr: 'مردان',
          latitude: 34.1989,
          longitude: 72.0421,
        ),
      ];
      await _store.save(phone, _localFields);
    }

    await _syncPendingFields(phone, farmerName);
    var result = await _api.fetchOwnedFarms(phone);

    // Render's filesystem/database may reset after a redeploy. If the owned
    // endpoint is alive but has lost this phone's fields, re-queue the local
    // registrations once and restore them instead of showing another farmer.
    if (result.isLive && result.farms.isEmpty && _localFields.isNotEmpty) {
      _localFields = _localFields
          .map((field) => field.copyWith(synced: false))
          .toList();
      await _syncPendingFields(phone, farmerName);
      result = await _api.fetchOwnedFarms(phone);
    }

    _isLive = result.isLive;
    if (result.isLive && result.farms.isNotEmpty) {
      _replaceFarms(result.farms);
    } else {
      _showLocalFields(farmerName, notify: false);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncPendingFields(String phone, String farmerName) async {
    for (var index = 0; index < _localFields.length; index++) {
      final field = _localFields[index];
      if (field.synced) continue;
      final created = await _api.createOwnedFarm(
        ownerPhone: phone,
        farmerName: farmerName,
        fieldLabel: field.label,
        cropType: field.cropType,
        cropTypeUr: field.cropTypeUr,
        district: field.district,
        districtUr: field.districtUr,
        latitude: field.latitude,
        longitude: field.longitude,
      );
      if (created != null) {
        _localFields[index] = field.copyWith(
          synced: true,
          serverFieldId: created.fieldId,
        );
      }
    }
    _pendingSyncCount = _localFields.where((field) => !field.synced).length;
    await _store.save(phone, _localFields);
  }

  void _showLocalFields(String farmerName, {bool notify = true}) {
    _replaceFarms(
      _localFields.map((field) => field.toPendingFarm(farmerName)).toList(),
      notify: notify,
    );
    _isLive = false;
  }

  void _replaceFarms(List<FarmData> farms, {bool notify = true}) {
    _farms = farms;
    if (_activeFarmIndex >= _farms.length) _activeFarmIndex = 0;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
