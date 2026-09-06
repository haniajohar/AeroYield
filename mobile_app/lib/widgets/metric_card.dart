// =============================================================================
// AeroYield — Metric Card
// A compact badge showing one satellite-derived farming metric with an
// emoji icon, localized title, numeric value, and status sub-label.
// Fully theme-aware (card surface, text colours adapt to light/dark mode).
// =============================================================================

import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String icon; // Emoji character (💧, 🌿, ☀️)
  final String title;
  final String value;
  final String subLabel;
  final Color statusColor;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                  theme.brightness == Brightness.dark ? 40 : 18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: statusColor.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
