import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/offline_banner.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  String _photoUrl(String condition) {
    switch (condition) {
      case 'sunny':
        return kPhotoSunny;
      case 'cloudy':
        return kPhotoCloudy;
      case 'rainy':
        return kPhotoRainy;
      case 'stormy':
        return kPhotoStormy;
      case 'foggy':
        return kPhotoFoggy;
      default:
        final hour = DateTime.now().hour;
        return (hour < 6 || hour > 20) ? kPhotoStormy : kPhotoSunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final loc = context.read<LocationProvider>();
    final tt = Theme.of(context).textTheme;
    final weather = wp.weather;
    final condition = weather?.condition ?? 'sunny';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen photo background
          CachedNetworkImage(
            imageUrl: _photoUrl(condition),
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF0B1426)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF0B1426)),
          ),

          // Dark gradient overlay — transparent at top, 55% black at bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x8C000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kPadding, vertical: 8),
                  child: Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.35),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${loc.village} Weather',
                          style: tt.headlineMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => context
                              .read<WeatherProvider>()
                              .fetch(loc.lat, loc.lon),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.35),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (wp.isOffline) const OfflineBanner(),

                if (wp.loading)
                  const Expanded(
                      child: Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)))
                else if (weather == null)
                  const Expanded(
                      child: Center(
                          child: Text('No weather data',
                              style: TextStyle(color: Colors.white))))
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                          kPadding, 0, kPadding, kPadding),
                      children: [
                        // Current weather hero
                        _currentWeather(
                            weather.temperature,
                            weather.feelsLike,
                            weather.condition,
                            weather.humidity,
                            weather.windSpeed,
                            weather.rainfall,
                            tt),

                        const SizedBox(height: 24),

                        // Rain probability
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rain Probability',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: weather.rainProbability / 100,
                                  backgroundColor: const Color(0x2EFFFFFF),
                                  color: Colors.white,
                                  minHeight: 8,
                                ).animate().custom(
                                      duration: 800.ms,
                                      builder: (ctx, v, child) =>
                                          LinearProgressIndicator(
                                        value:
                                            (weather.rainProbability / 100) * v,
                                        backgroundColor:
                                            const Color(0x2EFFFFFF),
                                        color: Colors.white,
                                        minHeight: 8,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${weather.rainProbability.toInt()}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                              const Text(
                                'chance of rain',
                                style: TextStyle(
                                    color: Color(0xC7FFFFFF), fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Temperature chart
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('24-Hour Temperature',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 160,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 5,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: Colors.white.withOpacity(0.10),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
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
                                          interval: 6,
                                          getTitlesWidget: (v, m) {
                                            final idx = v.toInt();
                                            if (idx < weather.hourly.length) {
                                              return Text(
                                                DateFormat('ha').format(
                                                    weather.hourly[idx].time),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.70),
                                                    fontSize: 12),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: weather.hourly
                                            .asMap()
                                            .entries
                                            .map((e) => FlSpot(e.key.toDouble(),
                                                e.value.temperature))
                                            .toList(),
                                        isCurved: true,
                                        color: Colors.white,
                                        barWidth: 2.5,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.30),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Hourly forecast
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hourly Forecast',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: weather.hourly.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (ctx, i) {
                                    final h = weather.hourly[i];
                                    final isNow = i == 0;
                                    return _hourlyCard(h, isNow);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 7-day forecast
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('7-Day Forecast',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              ...weather.daily
                                  .asMap()
                                  .entries
                                  .map((e) => _dailyRow(e.key, e.value)),
                            ],
                          ),
                        ),

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

  Widget _glassCard({required Widget child}) {
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

  Widget _hourlyCard(dynamic h, bool isNow) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 64,
          height: 100,
          decoration: BoxDecoration(
            gradient: isNow
                ? const LinearGradient(
                    colors: [Color(0xFFE55934), Color(0xFFC44424)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isNow ? null : const Color(0x24FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('ha').format(h.time),
                style: TextStyle(
                    color: Colors.white.withOpacity(isNow ? 1.0 : 0.78),
                    fontSize: 11),
              ),
              const SizedBox(height: 6),
              Icon(
                h.precipitationProbability > 50
                    ? Icons.umbrella_rounded
                    : Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.temperature(h.temperature),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dailyRow(int index, dynamic d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              index == 0 ? 'Today' : DateFormat('EEE, d MMM').format(d.date),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: index == 0 ? FontWeight.w500 : FontWeight.w500,
              ),
            ),
          ),
          Icon(
            d.precipitationProbability > 50
                ? Icons.umbrella_rounded
                : Icons.wb_sunny_rounded,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 36,
            child: Text(
              '${d.precipitationProbability}%',
              style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 13),
            ),
          ),
          const Spacer(),
          Text(
            Formatters.temperature(d.minTemp),
            style:
                TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 13),
          ),
          const SizedBox(width: 10),
          Text(
            Formatters.temperature(d.maxTemp),
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _currentWeather(
    double temp,
    double feels,
    String condition,
    double humidity,
    double wind,
    double rain,
    TextTheme tt,
  ) {
    return Column(
      children: [
        Icon(
          condition == 'sunny'
              ? Icons.wb_sunny_rounded
              : condition == 'rainy'
                  ? Icons.umbrella_rounded
                  : condition == 'stormy'
                      ? Icons.thunderstorm_rounded
                      : condition == 'foggy'
                          ? Icons.cloud_rounded
                          : Icons.cloud_rounded,
          size: 80,
          color: Colors.white,
        ).animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 700.ms,
            curve: Curves.elasticOut),
        const SizedBox(height: 8),
        Text(
          Formatters.temperature(temp),
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 12, color: Colors.black38)],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
        Text(
          'Feels like ${Formatters.temperature(feels)}',
          style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 16),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat(Icons.water_drop_outlined, Formatters.humidity(humidity),
                'Humidity'),
            _stat(Icons.air_rounded, Formatters.windSpeed(wind), 'Wind'),
            _stat(Icons.grain_rounded, Formatters.rainfall(rain), 'Rainfall'),
          ],
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xC7FFFFFF), size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 12)),
      ],
    );
  }
}
