import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/soil_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class SoilScreen extends StatelessWidget {
  const SoilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SoilProvider>();
    final soil = sp.soil;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo background
          CachedNetworkImage(
            imageUrl: kPhotoSoil,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF1A2E1A)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF1A2E1A)),
          ),

          // Dark gradient overlay — 55% black at bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x8C000000)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kPadding, vertical: 8),
                  child: Row(
                    children: [
                      _circleBtn(
                        Icons.arrow_back_rounded,
                        () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Soil Health',
                          style: tt.headlineMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _circleBtn(
                        Icons.refresh_rounded,
                        () => context.read<SoilProvider>().fetch('guest'),
                      ),
                    ],
                  ),
                ),

                if (sp.loading)
                  const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                else if (soil == null)
                  const Expanded(
                    child: Center(
                      child: Text('No soil data available.',
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          kPadding, 0, kPadding, kPadding),
                      children: [
                        // Moisture gauge card
                        _glass(
                          child: Column(
                            children: [
                              const Text(
                                'Soil Moisture',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 20),
                              CircularPercentIndicator(
                                radius: 80,
                                lineWidth: 12,
                                percent: (soil.moistureLevel / 100).clamp(0, 1),
                                center: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Formatters.moisture(soil.moistureLevel),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text('moisture',
                                        style: TextStyle(
                                            color: Color(0xC7FFFFFF),
                                            fontSize: 12)),
                                  ],
                                ),
                                progressColor: _healthColor(soil.healthStatus),
                                backgroundColor: Colors.white.withAlpha(40),
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                animationDuration: 1200,
                              ).animate().scale(
                                  begin: const Offset(0.5, 0.5),
                                  duration: 700.ms,
                                  curve: Curves.elasticOut),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _healthColor(soil.healthStatus)
                                      .withAlpha(40),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _healthColor(soil.healthStatus)
                                          .withAlpha(120)),
                                ),
                                child: Text(
                                  'Status: ${soil.healthStatus.toUpperCase()}',
                                  style: TextStyle(
                                    color: _healthColor(soil.healthStatus),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Irrigation advice card
                        _glass(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.water_drop_outlined,
                                      color: Color(0xC7FFFFFF), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Irrigation Advice',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius:
                                      BorderRadius.circular(kRadiusSmall),
                                  border: Border.all(
                                      color: Colors.white.withAlpha(50)),
                                ),
                                child: Text(
                                  soil.irrigationAdvice,
                                  style: const TextStyle(
                                      color: Color(0xC7FFFFFF), fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _infoTile(
                                      'Water Required',
                                      Formatters.litres(
                                          soil.waterRequirementLitresPerAcre),
                                      Icons.opacity_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _infoTile(
                                      'Soil Type',
                                      soil.soilType,
                                      Icons.layers_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _infoTile(
                                'Irrigation Method',
                                soil.irrigationMethod,
                                Icons.shower_rounded,
                              ),
                            ],
                          ),
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // 7-day trend chart
                        _glass(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '7-Day Moisture Trend',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 150,
                                child: BarChart(
                                  BarChartData(
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: Colors.white.withOpacity(0.10),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, m) {
                                            const days = [
                                              'Mon',
                                              'Tue',
                                              'Wed',
                                              'Thu',
                                              'Fri',
                                              'Sat',
                                              'Sun'
                                            ];
                                            return Text(
                                              days[v.toInt() % 7],
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.70),
                                                  fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: soil.weeklyMoisture
                                        .asMap()
                                        .entries
                                        .map((e) {
                                      return BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value,
                                            color: kForestSage,
                                            width: 16,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(4)),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.3),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(kPaddingLarge),
          decoration: BoxDecoration(
            color: const Color(0x24FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.35),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(kRadiusSmall),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xC7FFFFFF)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xC7FFFFFF))),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _healthColor(String status) {
    switch (status) {
      case 'good':
        return kForestSage;
      case 'moderate':
        return kSunsetOrange;
      default:
        return kCoral;
    }
  }
}
