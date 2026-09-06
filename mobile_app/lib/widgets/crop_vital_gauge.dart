// =============================================================================
// AeroYield — Crop Vital Gauge Widget
// A custom-painted semi-circular speedometer that visualises the 0–100 Crop
// Vital Score with dynamic colour thresholds and an animated needle.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_l10n.dart';

/// Public-facing widget — drop it into any screen with a [score] and [locale].
class CropVitalGauge extends StatelessWidget {
  final int score;
  final Locale locale;

  const CropVitalGauge({
    super.key,
    required this.score,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware track and tick colours
    final trackColor = isDark
        ? const Color(0xFF424242)
        : const Color(0xFFE0E0E0);
    final tickColor = isDark
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF757575);

    return SizedBox(
      height: 230,
      child: Column(
        children: [
          // Gauge arc + needle (custom painter)
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _GaugePainter(
                score: score,
                color: color,
                trackColor: trackColor,
                tickColor: tickColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Numeric score
          Text(
            '$score',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          // Status label (localized)
          Text(
            _statusLabel(l10n),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    if (score >= 75) return l10n.statusHealthy;
    if (score >= 45) return l10n.statusModerate;
    return l10n.statusCritical;
  }
}

// =============================================================================
// CustomPainter — draws the arc, ticks, and needle
// =============================================================================

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;
  final Color trackColor;
  final Color tickColor;

  _GaugePainter({
    required this.score,
    required this.color,
    this.trackColor = const Color(0xFFE0E0E0),
    this.tickColor = const Color(0xFF757575),
  });

  // Arc geometry constants
  static const double _startAngleDeg = 135;
  static const double _sweepAngleDeg = 270;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.82);
    final radius = math.min(size.width / 2, size.height * 0.78);

    final startAngle = _startAngleDeg * math.pi / 180;
    final sweepAngle = _sweepAngleDeg * math.pi / 180;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // ── 1. Background arc (full sweep, light grey) ──────────────────────
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, bgPaint);

    // ── 2. Value arc (coloured, proportional to score) ───────────────────
    final valueFraction = score.clamp(0, 100) / 100;
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // Optional glow for emphasis
    final glowPaint = Paint()
      ..color = color.withAlpha(77) // ~0.3 opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawArc(
        arcRect, startAngle, sweepAngle * valueFraction, false, glowPaint);
    canvas.drawArc(
        arcRect, startAngle, sweepAngle * valueFraction, false, valuePaint);

    // ── 3. Tick marks at every 10 % ──────────────────────────────────────
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.8;

    for (int i = 0; i <= 10; i++) {
      final tickAngle =
          startAngle + sweepAngle * (i / 10);
      final outer = Offset(
        center.dx + radius * math.cos(tickAngle),
        center.dy + radius * math.sin(tickAngle),
      );
      final inner = Offset(
        center.dx + (radius - 14) * math.cos(tickAngle),
        center.dy + (radius - 14) * math.sin(tickAngle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // ── 4. Needle ────────────────────────────────────────────────────────
    final needleAngle = startAngle + sweepAngle * valueFraction;
    final needleLen = radius - 28;
    final needleTip = Offset(
      center.dx + needleLen * math.cos(needleAngle),
      center.dy + needleLen * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // ── 5. Center hub ────────────────────────────────────────────────────
    canvas.drawCircle(center, 9, Paint()..color = color);
    canvas.drawCircle(center, 5, Paint()..color = trackColor);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.score != score || old.color != color ||
      old.trackColor != trackColor || old.tickColor != tickColor;
}
