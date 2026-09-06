import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/farm_options.dart';
import '../models/field_registration.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/field_location_picker.dart';
import '../widgets/helpline_footer.dart';

/// Collects the farmer's actual profile and one or more owned fields before
/// the dashboard is reachable.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final List<FieldRegistration> _fields = [];

  LocalizedFarmOption _selectedCrop = cropOptions.first;
  LocalizedFarmOption _selectedDistrict = districtOptions.first;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (_nameController.text.isEmpty && auth.farmerName.isNotEmpty) {
      _nameController.text = auth.farmerName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  bool get _isUrdu => Localizations.localeOf(context).languageCode == 'ur';

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.scoreRed),
    );
  }

  void _addField() {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      _showError(
        _isUrdu
            ? 'براہ کرم درست عرض بلد اور طول بلد درج کریں۔'
            : 'Enter a valid latitude and longitude.',
      );
      return;
    }
    if (latitude < 23.5 ||
        latitude > 37.5 ||
        longitude < 60.5 ||
        longitude > 77.5) {
      _showError(
        _isUrdu
            ? 'کھیت کی جگہ پاکستان کے اندر ہونی چاہیے۔'
            : 'Field coordinates must be inside Pakistan.',
      );
      return;
    }

    setState(() {
      _fields.add(
        FieldRegistration.create(
          label: _labelController.text.trim().isEmpty
              ? '${_isUrdu ? 'کھیت' : 'Field'} ${_fields.length + 1}'
              : _labelController.text.trim(),
          cropType: _selectedCrop.en,
          cropTypeUr: _selectedCrop.ur,
          district: _selectedDistrict.en,
          districtUr: _selectedDistrict.ur,
          latitude: latitude,
          longitude: longitude,
        ),
      );
      _labelController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
    });
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(_isUrdu ? 'اپنا نام درج کریں۔' : 'Enter your name.');
      return;
    }
    if (_fields.isEmpty) {
      _showError(
        _isUrdu
            ? 'آگے بڑھنے کے لیے کم از کم ایک کھیت شامل کریں۔'
            : 'Add at least one field to continue.',
      );
      return;
    }

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    await context.read<FarmProvider>().saveLocalFields(
      auth.phoneNumber,
      _fields,
      name,
    );
    await auth.completeOnboarding(name);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = _isUrdu;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'اپنا کھیت شامل کریں' : 'Add your field'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isUrdu
                    ? 'آپ کو صرف اپنے کھیتوں کی معلومات نظر آئیں گی۔'
                    : 'You will see data for only your own field(s).',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isUrdu
                    ? 'مقام موسم پر مبنی مشورہ بنانے کے لیے استعمال ہوتا ہے۔'
                    : 'Your location is used to create weather-based advice.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUrdu
                      ? 'ڈیمو نوٹ: یہ یونیورسٹی ڈیمو ورژن ہے؛ معلومات مکمل طور پر محفوظ نہیں ہیں۔'
                      : 'Demo note: this university-demo build does not provide production-grade data protection.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: isUrdu ? 'کسان کا نام' : 'Farmer name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                isUrdu ? 'نیا کھیت' : 'New field',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: isUrdu
                      ? 'کھیت کا نام (اختیاری)'
                      : 'Field label (optional)',
                  prefixIcon: const Icon(Icons.agriculture_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LocalizedFarmOption>(
                initialValue: _selectedCrop,
                decoration: InputDecoration(
                  labelText: isUrdu ? 'فصل' : 'Crop',
                  border: const OutlineInputBorder(),
                ),
                items: cropOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.forLanguage(isUrdu ? 'ur' : 'en')),
                      ),
                    )
                    .toList(),
                onChanged: (option) {
                  if (option != null) setState(() => _selectedCrop = option);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LocalizedFarmOption>(
                initialValue: _selectedDistrict,
                decoration: InputDecoration(
                  labelText: isUrdu ? 'ضلع' : 'District',
                  border: const OutlineInputBorder(),
                ),
                items: districtOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.forLanguage(isUrdu ? 'ur' : 'en')),
                      ),
                    )
                    .toList(),
                onChanged: (option) {
                  if (option != null) {
                    setState(() => _selectedDistrict = option);
                  }
                },
              ),
              const SizedBox(height: 16),
              FieldLocationPicker(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                isUrdu: isUrdu,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _addField,
                icon: const Icon(Icons.add),
                label: Text(isUrdu ? 'یہ کھیت شامل کریں' : 'Add this field'),
              ),
              if (_fields.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  isUrdu ? 'شامل کیے گئے کھیت' : 'Added fields',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ..._fields.asMap().entries.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                      ),
                      title: Text(entry.value.label),
                      subtitle: Text(
                        '${entry.value.cropType} · ${entry.value.district}\n'
                        '${entry.value.latitude.toStringAsFixed(4)}, ${entry.value.longitude.toStringAsFixed(4)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: isUrdu ? 'حذف کریں' : 'Remove',
                        onPressed: () =>
                            setState(() => _fields.removeAt(entry.key)),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _continue,
                  icon: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    isUrdu ? 'اپنا ڈیش بورڈ دیکھیں' : 'View my dashboard',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const HelplineFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
