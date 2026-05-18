import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback? onTap;

  const WeatherCard({super.key, required this.weather, this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradient = _conditionGradient(weather.condition);
    final icon = _weatherIcon(weather.condition);
    final label = _weatherLabel(weather.condition);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: Stack(
          children: [
            // Cinematic gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Frosted overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(kRadius),
                ),
                padding: const EdgeInsets.all(kPaddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gradient temperature
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFB2FFD6)],
                                ).createShader(b),
                                child: Text(
                                  Formatters.temperature(weather.temperature),
                                  style: GoogleFonts.sora(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Feels like ${Formatters.temperature(weather.feelsLike)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(icon, size: 52, color: Colors.white)
                                .animate(onPlay: (c) => c.repeat())
                                .shimmer(duration: 2400.ms, color: Colors.white24),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Divider
                    Container(height: 1, color: Colors.white.withOpacity(0.10)),
                    const SizedBox(height: 16),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stat(Icons.water_drop_outlined, Formatters.humidity(weather.humidity), 'Humidity'),
                        _stat(Icons.air_rounded, Formatters.windSpeed(weather.windSpeed), 'Wind'),
                        _stat(Icons.umbrella_rounded, '${weather.rainProbability.toInt()}%', 'Rain'),
                        _stat(Icons.grain_rounded, Formatters.rainfall(weather.rainfall), 'Rainfall'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sora(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  List<Color> _conditionGradient(String c) {
    switch (c) {
      case 'sunny': return kSunnyGradient;
      case 'rainy': return kRainyGradient;
      case 'stormy': return kStormGradient;
      case 'cloudy': return kCloudyGradient;
      case 'heatwave': return kHeatwaveGradient;
      default: return kSunnyGradient;
    }
  }

  IconData _weatherIcon(String c) {
    switch (c) {
      case 'sunny': return Icons.wb_sunny_rounded;
      case 'rainy': return Icons.umbrella_rounded;
      case 'stormy': return Icons.thunderstorm_rounded;
      case 'cloudy': return Icons.cloud_rounded;
      case 'heatwave': return Icons.local_fire_department_rounded;
      default: return Icons.wb_sunny_rounded;
    }
  }

  String _weatherLabel(String c) {
    switch (c) {
      case 'sunny': return 'Sunny';
      case 'rainy': return 'Rainy';
      case 'stormy': return 'Stormy';
      case 'cloudy': return 'Cloudy';
      case 'heatwave': return 'Heatwave';
      default: return 'Clear';
    }
  }
}
