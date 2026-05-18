import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/soil_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class SoilCard extends StatelessWidget {
  final SoilModel soil;
  final VoidCallback? onTap;

  const SoilCard({super.key, required this.soil, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (soil.moistureLevel / 100).clamp(0.0, 1.0);
    final color = _healthColor(soil.healthStatus);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(kPaddingLarge),
            decoration: BoxDecoration(
              color: kSoilBrown.withOpacity(0.08),
              borderRadius: BorderRadius.circular(kRadius),
              border: Border.all(color: kSoilBrown.withOpacity(0.25), width: 1),
              boxShadow: [
                BoxShadow(
                  color: kSoilBrown.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circular moisture gauge
                CircularPercentIndicator(
                  radius: 52,
                  lineWidth: 7,
                  percent: pct,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.moisture(soil.moistureLevel),
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                      Text(
                        'moist',
                        style: GoogleFonts.dmSans(fontSize: 10, color: kTextMuted),
                      ),
                    ],
                  ),
                  progressColor: color,
                  backgroundColor: Colors.white12,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 900,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Soil Health',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _badge(soil.healthStatus, color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        soil.irrigationAdvice,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: kTextMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.opacity_rounded, size: 13, color: kSkyBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${Formatters.litres(soil.waterRequirementLitresPerAcre)}/acre',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: kSkyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _badge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _healthColor(String status) {
    switch (status) {
      case 'good': return kAccentGreen;
      case 'moderate': return kWarningOrange;
      default: return kDangerRed;
    }
  }
}
