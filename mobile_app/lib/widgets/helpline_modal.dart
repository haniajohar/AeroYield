// =============================================================================
// AeroYield — Helpline Modal
// Bottom sheet with one-tap WhatsApp chat and toll-free dialer (1100) buttons.
// Theme-aware surface and text colours.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';

/// Display the helpline bottom sheet.
Future<void> showHelplineModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HelplineSheet(),
  );
}

// ── Private sheet widget ──────────────────────────────────────────────────

class _HelplineSheet extends StatelessWidget {
  const _HelplineSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            l10n.helplineTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // WhatsApp chat button
          _HelplineButton(
            icon: Icons.chat,
            label: l10n.whatsappChat,
            color: AppColors.whatsapp,
            onTap: () => _launchUrl('https://wa.me/923001234567'),
          ),
          const SizedBox(height: 14),

          // Toll-free dialer button
          _HelplineButton(
            icon: Icons.phone,
            label: l10n.callHelpline,
            color: AppColors.helpline,
            onTap: () => _launchUrl('tel:1100'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Reusable large tap target button ──────────────────────────────────────

class _HelplineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HelplineButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
