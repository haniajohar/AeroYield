// =============================================================================
// AeroYield — Farm Home Screen (Main Dashboard)
//
// Enhanced with:
//   • BottomNavigationBar (Dashboard · Advisory · Helpline · Settings)
//   • Navigation Drawer (farmer profile, language, dark-mode toggle, logout)
//   • Full dark / light theme support via Theme.of(context)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/audio_advisory_card.dart';
import '../widgets/crop_vital_gauge.dart';
import '../widgets/helpline_modal.dart';
import '../widgets/metric_card.dart';
import '../widgets/voice_assistant_modal.dart';

class FarmHomeScreen extends StatefulWidget {
  const FarmHomeScreen({super.key});

  @override
  State<FarmHomeScreen> createState() => _FarmHomeScreenState();
}

class _FarmHomeScreenState extends State<FarmHomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<FarmProvider>().loadOwnedFarms(
        phone: auth.phoneNumber,
        farmerName: auth.farmerName,
        createDemoField: auth.isDemoUser,
      );
    });
  }

  /// Reloads only the signed-in farmer's fields (used by pull-to-refresh).
  Future<void> _refreshFarms() async {
    final auth = context.read<AuthProvider>();
    await context.read<FarmProvider>().loadOwnedFarms(
      phone: auth.phoneNumber,
      farmerName: auth.farmerName,
      createDemoField: auth.isDemoUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmProv = context.watch<FarmProvider>();
    final localeProv = context.watch<LocaleProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final farm = farmProv.activeFarm;
    final l10n = AppLocalizations.of(context);
    final lang = localeProv.languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      // ── Navigation Drawer ───────────────────────────────────────────────
      drawer: _buildDrawer(context, localeProv, themeProv, l10n, theme),

      // ── Top App Bar ─────────────────────────────────────────────────────
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Toggle EN / UR',
            onPressed: () => localeProv.toggleLocale(),
          ),
          // Dark mode quick toggle
          IconButton(
            icon: Icon(themeProv.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: themeProv.isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => themeProv.toggleTheme(),
          ),
        ],
      ),

      // ── Body switches on bottom-nav tab ─────────────────────────────────
      body: farm == null
          ? _buildNoFieldsState(context, farmProv, lang, theme)
          : _buildTabBody(
              context,
              farmProv,
              localeProv,
              farm,
              l10n,
              lang,
              theme,
            ),

      // ── Bottom Navigation Bar ───────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: lang == 'ur' ? 'ڈیش بورڈ' : 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: l10n.aiAdvisory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.phone_in_talk),
            label: l10n.helplineTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: lang == 'ur' ? 'ترتیبات' : 'Settings',
          ),
        ],
      ),

      // ── Floating Mic FAB (only on dashboard tab) ────────────────────────
      floatingActionButton: _currentTab == 0 && farm != null
          ? _PulsingMicFab(
              onPressed: () => showVoiceAssistantModal(context, farm: farm),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNoFieldsState(
    BuildContext context,
    FarmProvider farmProvider,
    String lang,
    ThemeData theme,
  ) {
    if (farmProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              lang == 'ur'
                  ? 'ابھی کوئی کھیت شامل نہیں ہے'
                  : 'No field added yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              lang == 'ur'
                  ? 'اپنا نام اور کھیت کی جگہ شامل کریں تاکہ صرف آپ کی معلومات دکھائی جائیں۔'
                  : 'Add your name and field location so the app shows only your farm data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
              icon: const Icon(Icons.add_location_alt),
              label: Text(lang == 'ur' ? 'کھیت شامل کریں' : 'Add a field'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _refreshFarms,
              icon: const Icon(Icons.refresh),
              label: Text(lang == 'ur' ? 'دوبارہ کوشش کریں' : 'Try sync again'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Tab body router
  // ===========================================================================
  Widget _buildTabBody(
    BuildContext context,
    FarmProvider farmProv,
    LocaleProvider localeProv,
    farm,
    AppLocalizations l10n,
    String lang,
    ThemeData theme,
  ) {
    switch (_currentTab) {
      case 0:
        return _buildDashboardTab(
          context,
          farmProv,
          localeProv,
          farm,
          l10n,
          lang,
          theme,
        );
      case 1:
        return _buildAdvisoryTab(context, farm, l10n, lang, theme);
      case 2:
        return _buildHelplineTab(context, l10n, theme);
      case 3:
        return _buildSettingsTab(context, l10n, theme);
      default:
        return _buildDashboardTab(
          context,
          farmProv,
          localeProv,
          farm,
          l10n,
          lang,
          theme,
        );
    }
  }

  // ===========================================================================
  // TAB 0 — Dashboard (gauge + metrics + advisory)
  // ===========================================================================
  Widget _buildDashboardTab(
    BuildContext context,
    FarmProvider farmProv,
    LocaleProvider localeProv,
    farm,
    AppLocalizations l10n,
    String lang,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshFarms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live / offline data-source indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  farmProv.isLive ? Icons.cloud_done : Icons.cloud_off,
                  size: 14,
                  color: farmProv.isLive
                      ? AppColors.scoreGreen
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  farmProv.isLive
                      ? (lang == 'ur' ? 'لائیو ڈیٹا' : 'Live data')
                      : (lang == 'ur' ? 'ڈیمو ڈیٹا' : 'Demo data'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: farmProv.isLive
                        ? AppColors.scoreGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (farmProv.pendingSyncCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  lang == 'ur'
                      ? '${farmProv.pendingSyncCount} کھیت ہم وقت سازی کے منتظر ہیں'
                      : '${farmProv.pendingSyncCount} field(s) waiting to sync',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.scoreAmber,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Field selector dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: farmProv.activeFarmIndex,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 28),
                    items: List.generate(farmProv.farms.length, (i) {
                      final f = farmProv.farms[i];
                      return DropdownMenuItem<int>(
                        value: i,
                        child: Text(
                          '${f.regionFor(lang)} — ${f.cropFor(lang)}',
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                    onChanged: (idx) {
                      if (idx != null) farmProv.setActiveFarm(idx);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Crop Vital Score hero gauge
            Text(
              l10n.cropVitalScore,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CropVitalGauge(
              score: farm.cropVitalScore,
              locale: localeProv.locale,
            ),
            const SizedBox(height: 4),
            Text(
              '${farm.farmerName} · ${farm.regionFor(lang)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
            ),
            // Last-updated timestamp from backend
            if (farm.lastUpdated.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${lang == 'ur' ? 'آخری اپ ڈیٹ' : 'Last updated'}: ${farm.lastUpdated}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(102),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 22),

            // AI Audio Advisory Card
            AudioAdvisoryCard(
              advisoryText: farm.advisoryFor(lang),
              audioUrl: farm.audioUrl,
              locale: localeProv.locale,
            ),
            const SizedBox(height: 20),

            // Three Metric Badges
            Row(
              children: [
                MetricCard(
                  icon: '\u{1F4A7}',
                  title: l10n.soilMoisture,
                  value: '${farm.soilMoisturePct.toStringAsFixed(0)}%',
                  subLabel: _moistureLabel(l10n, farm.soilMoisturePct),
                  statusColor: _moistureColor(farm.soilMoisturePct),
                ),
                MetricCard(
                  icon: '\u{1F33F}',
                  title: l10n.vegetationNdvi,
                  value: farm.ndviIndex.toStringAsFixed(2),
                  subLabel: _ndviLabel(l10n, farm.ndviIndex),
                  statusColor: _ndviColor(farm.ndviIndex),
                ),
                MetricCard(
                  icon: '\u{2600}\u{FE0F}',
                  title: l10n.weatherRain,
                  value: '${farm.tempC}\u00B0C',
                  subLabel: '${l10n.rainRisk} ${farm.rainRiskPct}%',
                  statusColor: _rainColor(farm.rainRiskPct),
                ),
              ],
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1 — Advisory detail
  // ===========================================================================
  Widget _buildAdvisoryTab(
    BuildContext context,
    farm,
    AppLocalizations l10n,
    String lang,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AudioAdvisoryCard(
            advisoryText: farm.advisoryFor(lang),
            audioUrl: farm.audioUrl,
            locale: Localizations.localeOf(context),
          ),
          const SizedBox(height: 20),
          // Additional advisory context card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.satellite_alt,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        lang == 'ur' ? 'سیٹلائٹ ڈیٹا' : 'Satellite Data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    theme,
                    '\u{1F4A7}',
                    l10n.soilMoisture,
                    '${farm.soilMoisturePct.toStringAsFixed(1)}%',
                  ),
                  _infoRow(
                    theme,
                    '\u{1F33F}',
                    l10n.vegetationNdvi,
                    farm.ndviIndex.toStringAsFixed(2),
                  ),
                  _infoRow(
                    theme,
                    '\u{1F321}\u{FE0F}',
                    lang == 'ur' ? 'درجہ حرارت' : 'Temperature',
                    '${farm.tempC}\u00B0C',
                  ),
                  _infoRow(
                    theme,
                    '\u{1F327}\u{FE0F}',
                    l10n.rainRisk,
                    '${farm.rainRiskPct}%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2 — Helpline
  // ===========================================================================
  Widget _buildHelplineTab(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headset_mic, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            l10n.helplineTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => showHelplineModal(context),
              icon: const Icon(Icons.chat, size: 24),
              label: Text(
                l10n.whatsappChat,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whatsapp,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => showHelplineModal(context),
              icon: const Icon(Icons.phone, size: 24),
              label: Text(
                l10n.callHelpline,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.helpline,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3 — Settings (placeholder)
  // ===========================================================================
  Widget _buildSettingsTab(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final localeProv = context.watch<LocaleProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final lang = localeProv.languageCode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Text(
          lang == 'ur' ? 'ترتیبات' : 'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          title: Text(lang == 'ur' ? 'ڈارک موڈ' : 'Dark Mode'),
          subtitle: Text(
            themeProv.isDark
                ? (lang == 'ur' ? 'فعال' : 'Enabled')
                : (lang == 'ur' ? 'غیر فعال' : 'Disabled'),
          ),
          secondary: Icon(
            themeProv.isDark ? Icons.dark_mode : Icons.light_mode,
            color: theme.colorScheme.primary,
          ),
          value: themeProv.isDark,
          activeThumbColor: theme.colorScheme.primary,
          onChanged: (_) => themeProv.toggleTheme(),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.language, color: theme.colorScheme.primary),
          title: Text(lang == 'ur' ? 'زبان تبدیل کریں' : 'Change Language'),
          subtitle: Text(localeProv.isRtl ? 'اردو (Urdu)' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => localeProv.toggleLocale(),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
          title: Text(lang == 'ur' ? 'ایپ کے بارے میں' : 'About AeroYield'),
          subtitle: const Text('v1.0.0'),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: AppColors.scoreRed),
          title: Text(
            lang == 'ur' ? 'لاگ آؤٹ' : 'Logout',
            style: const TextStyle(color: AppColors.scoreRed),
          ),
          onTap: () {
            context.read<AuthProvider>().logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // Navigation Drawer
  // ===========================================================================
  Widget _buildDrawer(
    BuildContext context,
    LocaleProvider localeProv,
    ThemeProvider themeProv,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final auth = context.watch<AuthProvider>();
    final lang = localeProv.languageCode;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Drawer Header ─────────────────────────────────────────────
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.farmerName.isNotEmpty
                      ? auth.farmerName
                      : 'Khan Muhammad',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  auth.phoneNumber.isNotEmpty
                      ? auth.phoneNumber
                      : '+92 300 1234567',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),

          // ── Drawer items ──────────────────────────────────────────────
          ListTile(
            leading: Icon(Icons.dashboard, color: theme.colorScheme.primary),
            title: Text(lang == 'ur' ? 'ڈیش بورڈ' : 'Dashboard'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTab = 0);
            },
          ),
          ListTile(
            leading: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            title: Text(l10n.aiAdvisory),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTab = 1);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phone_in_talk,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.helplineTitle),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTab = 2);
            },
          ),
          const Divider(),

          // Language toggle
          SwitchListTile(
            secondary: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text(lang == 'ur' ? 'اردو' : 'English'),
            value: localeProv.isRtl,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (_) {
              localeProv.toggleLocale();
            },
          ),

          // Dark mode toggle
          SwitchListTile(
            secondary: Icon(
              themeProv.isDark ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              themeProv.isDark
                  ? (lang == 'ur' ? 'ڈارک موڈ' : 'Dark Mode')
                  : (lang == 'ur' ? 'لائٹ موڈ' : 'Light Mode'),
            ),
            value: themeProv.isDark,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (_) => themeProv.toggleTheme(),
          ),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.scoreRed),
            title: Text(
              lang == 'ur' ? 'لاگ آؤٹ' : 'Logout',
              style: const TextStyle(color: AppColors.scoreRed),
            ),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Label / colour helpers (unchanged)
  // ===========================================================================
  String _moistureLabel(AppLocalizations l, double pct) {
    if (pct >= 50) return l.adequate;
    if (pct >= 30) return l.low;
    return l.veryLow;
  }

  Color _moistureColor(double pct) {
    if (pct >= 50) return AppColors.scoreGreen;
    if (pct >= 30) return AppColors.scoreAmber;
    return AppColors.scoreRed;
  }

  String _ndviLabel(AppLocalizations l, double ndvi) {
    if (ndvi >= 0.6) return l.dense;
    if (ndvi >= 0.4) return l.moderate;
    return l.sparse;
  }

  Color _ndviColor(double ndvi) {
    if (ndvi >= 0.6) return AppColors.scoreGreen;
    if (ndvi >= 0.4) return AppColors.scoreAmber;
    return AppColors.scoreRed;
  }

  Color _rainColor(int risk) {
    if (risk <= 20) return AppColors.scoreGreen;
    if (risk <= 50) return AppColors.scoreAmber;
    return AppColors.scoreRed;
  }
}

// =============================================================================
// Pulsing microphone FAB with ripple animation (theme-aware)
// =============================================================================

class _PulsingMicFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulsingMicFab({required this.onPressed});

  @override
  State<_PulsingMicFab> createState() => _PulsingMicFabState();
}

class _PulsingMicFabState extends State<_PulsingMicFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ripple;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ripple = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _ripple,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64 * _ripple.value,
              height: 64 * _ripple.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withAlpha(
                  (102 * (1 - (_ripple.value - 1) / 0.5)).round().clamp(0, 255),
                ),
              ),
            ),
            SizedBox(
              width: 64,
              height: 64,
              child: FloatingActionButton(
                onPressed: widget.onPressed,
                backgroundColor: primaryColor,
                elevation: 6,
                child: const Icon(Icons.mic, size: 30, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
