import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/field_registration.dart';

/// Small device-local queue used by the Plan B demo flow.
///
/// It is intentionally not authentication or server-side authorization. The
/// backend remains the source of truth after a successful sync.
class LocalFieldStore {
  static String _key(String phone) =>
      'owned_fields_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

  Future<List<FieldRegistration>> load(String phone) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(phone));
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => FieldRegistration.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> save(String phone, List<FieldRegistration> fields) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key(phone),
      jsonEncode(fields.map((field) => field.toJson()).toList()),
    );
  }
}
