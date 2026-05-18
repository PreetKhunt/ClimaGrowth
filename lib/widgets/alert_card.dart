import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alert_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final int index;

  const AlertCard({super.key, required this.alert, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);
    final isHigh = alert.severity == AlertSeverity.high;

    return Container(
      margin: const EdgeInsets.only(bottom: kPaddingSmall),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Stack(
            children: [
              // Glow border for high severity
              if (isHigh)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
                        duration: 900.ms,
                        builder: (_, v, child) =>
                            Opacity(opacity: 0.4 + v * 0.6, child: child),
                      ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(kRadius),
                  border: Border.all(
                    color: color.withOpacity(isHigh ? 0.45 : 0.25),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(kPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon circle
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(_typeIcon(alert.type), color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.message,
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _severityBadge(alert.severity, color),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alert.advice,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: kTextMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${alert.region} • ${Formatters.dateTime(alert.timestamp)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: color.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.25, end: 0);
  }

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.high: return kDangerRed;
      case AlertSeverity.medium: return kWarningOrange;
      case AlertSeverity.low: return kGold;
    }
  }

  IconData _typeIcon(AlertType t) {
    switch (t) {
      case AlertType.flood: return Icons.water_rounded;
      case AlertType.rain: return Icons.umbrella_rounded;
      case AlertType.storm: return Icons.thunderstorm_rounded;
      case AlertType.heatwave: return Icons.local_fire_department_rounded;
    }
  }

  Widget _severityBadge(AlertSeverity s, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        s.name.toUpperCase(),
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
