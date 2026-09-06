import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// GPS action plus readable manual coordinate inputs for field registration.
class FieldLocationPicker extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final bool isUrdu;

  const FieldLocationPicker({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.isUrdu,
  });

  @override
  State<FieldLocationPicker> createState() => _FieldLocationPickerState();
}

class _FieldLocationPickerState extends State<FieldLocationPicker> {
  bool _findingLocation = false;
  String? _message;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _findingLocation = true;
      _message = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          widget.isUrdu
              ? 'فون کی لوکیشن سروس آن کریں یا نیچے نقاط درج کریں۔'
              : 'Turn on phone location services or enter coordinates below.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          widget.isUrdu
              ? 'لوکیشن کی اجازت نہیں ملی۔ براہ کرم نقاط دستی طور پر درج کریں۔'
              : 'Location permission was not granted. Enter coordinates manually.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      widget.latitudeController.text = position.latitude.toStringAsFixed(6);
      widget.longitudeController.text = position.longitude.toStringAsFixed(6);
      if (mounted) {
        setState(() {
          _message = widget.isUrdu
              ? 'آپ کی موجودہ جگہ شامل ہو گئی ہے۔'
              : 'Your current location was added.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = error.toString().replaceFirst('Bad state: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _findingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _findingLocation ? null : _useCurrentLocation,
          icon: _findingLocation
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            widget.isUrdu
                ? 'میری موجودہ جگہ استعمال کریں'
                : 'Use my current location',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.isUrdu
              ? 'یا دستی طور پر عرض بلد اور طول بلد درج کریں'
              : 'Or enter latitude and longitude manually',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.isUrdu ? 'عرض بلد (Latitude)' : 'Latitude',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.isUrdu
                      ? 'طول بلد (Longitude)'
                      : 'Longitude',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(
            _message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _message!.contains('added') || _message!.contains('شامل')
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
