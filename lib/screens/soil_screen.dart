import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../models/soil_model.dart';
import '../providers/soil_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'calculators/calc_fertilizer.dart';
import 'farm_map_screen.dart';
import 'soil_doctor_screen.dart';

class SoilScreen extends StatefulWidget {
  const SoilScreen({super.key});

  @override
  State<SoilScreen> createState() => _SoilScreenState();
}

class _SoilScreenState extends State<SoilScreen> {
  final Map<int, bool> _planChecked = {};
  FlutterTts? _tts;
  bool _isSpeaking = false;

  // Farm location state
  Map<String, dynamic>? _savedFarm;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _tts = FlutterTts();
      _tts!.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    }
    _loadFarm();
  }

  Future<void> _loadFarm() async {
    final farm = await FarmLocationStore.load();
    if (mounted) setState(() => _savedFarm = farm);
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  // ── Derived soil stats ────────────────────────────────────────────────────
  double _ph(soilType) {
    switch (soilType.toLowerCase()) {
      case 'black cotton':
        return 7.6;
      case 'loamy':
        return 6.5;
      case 'sandy':
        return 6.2;
      case 'red':
        return 5.8;
      case 'alluvial':
        return 7.0;
      default:
        return 6.8;
    }
  }

  double _nitrogen(String h, double m) => switch (h) {
        'good' => (220 + m * 0.3).clamp(150, 300).toDouble(),
        'moderate' => (180 + m * 0.2).clamp(100, 240).toDouble(),
        _ => (130 + m * 0.15).clamp(80, 180).toDouble(),
      };

  double _phosphorus(String h, double m) => switch (h) {
        'good' => (45 + m * 0.1).clamp(30, 60).toDouble(),
        'moderate' => (35 + m * 0.08).clamp(18, 50).toDouble(),
        _ => (22 + m * 0.05).clamp(10, 35).toDouble(),
      };

  double _potassium(String h, double m) => switch (h) {
        'good' => (230 + m * 0.4).clamp(160, 300).toDouble(),
        'moderate' => (190 + m * 0.3).clamp(120, 250).toDouble(),
        _ => (150 + m * 0.2).clamp(80, 200).toDouble(),
      };

  double _soilTemp(double m) => 28.5 + (m - 50) * 0.04;

  int _overallScore(String h, double m) => switch (h) {
        'good' => (70 + m * 0.26).toInt().clamp(70, 100),
        'moderate' => (48 + m * 0.2).toInt().clamp(45, 75),
        _ => (28 + m * 0.14).toInt().clamp(20, 55),
      };

  double _microbeHealth(String h, double m) => switch (h) {
        'good' => (75.0 + m * 0.15).clamp(65.0, 100.0),
        'moderate' => (55.0 + m * 0.1).clamp(40.0, 72.0),
        _ => (35.0 + m * 0.08).clamp(20.0, 52.0),
      };

  // ── Voice ─────────────────────────────────────────────────────────────────
  Future<void> _toggleVoice(SoilModel soil) async {
    if (_tts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice is not supported on this platform.')),
      );
      return;
    }
    if (_isSpeaking) {
      await _tts!.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    final n = _nitrogen(soil.healthStatus, soil.moistureLevel).toInt();
    final p = _phosphorus(soil.healthStatus, soil.moistureLevel).toInt();
    final k = _potassium(soil.healthStatus, soil.moistureLevel).toInt();
    final ph = _ph(soil.soilType).toStringAsFixed(1);
    final m = soil.moistureLevel.toInt();

    final nStatus = n > 200 ? 'adequate' : n > 160 ? 'moderate' : 'low';
    final pStatus = p > 40 ? 'adequate' : p > 28 ? 'moderate' : 'low';
    final kStatus = k > 200 ? 'adequate' : k > 150 ? 'moderate' : 'low';

    final text =
        'Your soil moisture is at $m percent, which is ${m > 60 ? "optimal" : m > 40 ? "slightly below optimal" : "low and needs irrigation"}. '
        'The pH is $ph which is ${double.parse(ph) >= 6.0 && double.parse(ph) <= 7.5 ? "perfect for most crops" : "outside optimal range"}. '
        'Nitrogen is ${nStatus == "low" ? "low at $n parts per million — consider applying urea 25 kilograms per acre next week" : "at $n parts per million which is $nStatus"}. '
        'Phosphorus is ${pStatus == "low" ? "low — apply DAP 15 kilograms per acre at next irrigation" : "$pStatus at $p parts per million"}. '
        'Potassium is $kStatus at $k parts per million. '
        '${soil.irrigationAdvice}';

    setState(() => _isSpeaking = true);
    await _tts!.setLanguage('en-IN');
    await _tts!.setSpeechRate(0.5);
    await _tts!.speak(text);
  }

  // ── Shared card decorator ─────────────────────────────────────────────────
  Widget _card(BuildContext context, Widget child, {EdgeInsetsGeometry? padding}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
          color: cs.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SoilProvider>();
    final soil = sp.soil;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  _circleBtn(context, Icons.arrow_back_rounded,
                      () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Soil Health',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  _circleBtn(context, Icons.refresh_rounded,
                      () => context.read<SoilProvider>().fetch('guest')),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FertilizerCalc())),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: kForestSage,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Fertilizer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (sp.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (soil == null)
              Expanded(
                child: Center(
                    child: Text('No soil data available.',
                        style: TextStyle(color: cs.onSurface))),
              )
            else
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    // 0 — Farm location card
                    _buildFarmLocationCard(context),
                    const SizedBox(height: 12),

                    // 1 — Hero score card
                    _buildHeroCard(context, soil)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.2),
                    const SizedBox(height: 12),

                    // 2 — AI Soil Doctor
                    _buildDoctorCard(context)
                        .animate(delay: 50.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.2),
                    const SizedBox(height: 12),

                    // 3 — Live Vitals
                    _buildVitals(context, soil)
                        .animate(delay: 80.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 4 — Irrigation Schedule
                    _buildIrrigationSchedule(context, soil)
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 5 — Crop Match
                    _buildCropMatch(context, soil)
                        .animate(delay: 120.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 6 — Improvement Plan
                    _buildImprovementPlan(context, soil)
                        .animate(delay: 140.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 7 — Microbe Health
                    _buildMicrobeHealth(context, soil)
                        .animate(delay: 160.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 8 — Soil Layer Visualizer
                    _buildLayerVisualizer(context, soil)
                        .animate(delay: 180.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 9 — Voice card
                    _buildVoiceCard(context, soil)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 10 — Compare with farms
                    _buildCompareFarms(context, soil)
                        .animate(delay: 220.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 12),

                    // 11 — Soil timeline
                    _buildTimeline(context, soil)
                        .animate(delay: 240.ms)
                        .fadeIn(duration: 350.ms),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 0. Farm Location Card ─────────────────────────────────────────────────
  Widget _buildFarmLocationCard(BuildContext context) {
    final hasFarm = _savedFarm != null;
    final name = _savedFarm?['name'] as String? ?? 'My Farm';
    final area = _savedFarm?['areaAcres'] as double?;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FarmMapScreen()),
        );
        _loadFarm();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFarm ? kCineGreen.withOpacity(0.06) : kCineCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasFarm ? kCineGreen.withOpacity(0.28) : kCineBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kCineGreen.withOpacity(0.12),
                    border: Border.all(color: kCineGreen.withOpacity(0.3)),
                    boxShadow: hasFarm
                        ? [BoxShadow(color: kGlowGreen, blurRadius: 16)]
                        : null,
                  ),
                  child: Icon(
                    hasFarm ? Icons.agriculture_rounded : Icons.map_outlined,
                    color: kCineGreen, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasFarm ? name : 'My Farm Location',
                        style: GoogleFonts.syne(
                          color: Colors.white, fontSize: 15,
                          fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasFarm
                            ? (area != null
                                ? '${area.toStringAsFixed(2)} acres · Tap to update'
                                : 'Saved · Tap to update')
                            : 'Tap to mark your farm on map',
                        style: GoogleFonts.outfit(
                          color: kCineTextSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: kCineTextDim, size: 20),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.1);
  }

  // ── 1. Hero Card ──────────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final score = _overallScore(soil.healthStatus, soil.moistureLevel);
    final scoreColor = score >= 70
        ? kForestSage
        : score >= 50
            ? kSunsetOrange
            : kCoral;
    final scoreLabel =
        score >= 70 ? 'Healthy' : score >= 50 ? 'Fair' : 'Needs Attention';

    return _card(
      context,
      Row(
        children: [
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 9,
            percent: score / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$score',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface)),
                Text('/100',
                    style:
                        TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
            progressColor: scoreColor,
            backgroundColor: cs.outlineVariant.withAlpha(60),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Soil Health Score',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(scoreLabel,
                      style: TextStyle(
                          color: scoreColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(
                  soil.soilType,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '${Formatters.moisture(soil.moistureLevel)} moisture',
                  style:
                      TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. AI Soil Doctor Card ────────────────────────────────────────────────
  Widget _buildDoctorCard(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SoilDoctorScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kForestSage.withAlpha(200), kForestSage.withAlpha(150)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.biotech_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Soil Doctor',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('Analyze soil from photo',
                        style: TextStyle(
                            color: Colors.white.withAlpha(180), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. Live Soil Vitals ───────────────────────────────────────────────────
  Widget _buildVitals(BuildContext context, SoilModel soil) {
    final h = soil.healthStatus;
    final m = soil.moistureLevel;

    final vitals = [
      _VitalData('Moisture', '${m.toInt()}%', kOceanTeal,
          m > 60 ? 'Optimal' : m > 40 ? 'Low' : 'Very Low',
          soil.weeklyMoisture.map((v) => v / 100).toList()),
      _VitalData('pH Level', _ph(soil.soilType).toStringAsFixed(1),
          kSunsetOrange,
          _ph(soil.soilType) >= 6.0 && _ph(soil.soilType) <= 7.5
              ? 'Ideal'
              : 'Adjust',
          List.generate(7, (i) => (_ph(soil.soilType) + (i.isEven ? 0.05 : -0.05)) / 9.0)),
      _VitalData('Nitrogen', '${_nitrogen(h, m).toInt()} ppm', kForestSage,
          _nitrogen(h, m) > 200 ? 'Good' : _nitrogen(h, m) > 150 ? 'Moderate' : 'Low',
          List.generate(7, (i) => (_nitrogen(h, m) - 30 + i * 10) / 300)),
      _VitalData('Phosphorus', '${_phosphorus(h, m).toInt()} ppm', kPlum,
          _phosphorus(h, m) > 38 ? 'Good' : 'Low',
          List.generate(7, (i) => (_phosphorus(h, m) - 5 + i * 2) / 60)),
      _VitalData('Potassium', '${_potassium(h, m).toInt()} ppm', kCoral,
          _potassium(h, m) > 180 ? 'Good' : 'Low',
          List.generate(7, (i) => (_potassium(h, m) - 20 + i * 8) / 300)),
      _VitalData('Soil Temp', '${_soilTemp(m).toStringAsFixed(1)}°C', kAmber,
          _soilTemp(m) < 32 ? 'Normal' : 'High',
          List.generate(7, (i) => (_soilTemp(m) + i * 0.3 - 1) / 40)),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: kCineCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kCineBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3, height: 18,
                    decoration: BoxDecoration(
                      color: kCineGreen,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: kGlowGreen, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('LIVE SOIL VITALS',
                      style: GoogleFonts.outfit(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: kCineTextSub, letterSpacing: 2.2,
                      )),
                  const Spacer(),
                  _VitalLiveDot(),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth >= 600) {
                    return _TwoColVitalGrid(vitals: vitals);
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < vitals.length; i++) ...[
                        _SoilVitalCard(vital: vitals[i], index: i),
                        if (i < vitals.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. Smart Irrigation Schedule ─────────────────────────────────────────
  Widget _buildIrrigationSchedule(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rng = math.Random(soil.moistureLevel.toInt());

    final schedule = days.map((d) {
      final isRain = rng.nextInt(7) < 2;
      final highMoisture = soil.moistureLevel > 70;
      final skip = isRain || (highMoisture && rng.nextInt(3) == 0);
      final liters = skip ? 0 : (soil.waterRequirementLitresPerAcre / 7).round();
      return _IrrigationDay(
        label: dayNames[d.weekday - 1],
        date: '${d.day}/${d.month}',
        litres: liters,
        type: isRain ? 'rain' : skip ? 'skip' : 'irrigate',
      );
    }).toList();

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, "This Week's Watering Plan"),
          const SizedBox(height: 4),
          Text(soil.irrigationAdvice,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) =>
                  _IrrigationDayTile(day: schedule[i], cs: cs),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Crop–Soil Match ────────────────────────────────────────────────────
  Widget _buildCropMatch(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final ph = _ph(soil.soilType);
    final moisture = soil.moistureLevel;

    double score(double idealPh, double phRange, double idealMoisture,
        double moistureRange) {
      final phDiff = (ph - idealPh).abs() / phRange;
      final mDiff = (moisture - idealMoisture).abs() / moistureRange;
      return ((1 - phDiff.clamp(0, 1)) * 50 +
              (1 - mDiff.clamp(0, 1)) * 50)
          .clamp(30, 100)
          .toDouble();
    }

    final crops = [
      _CropMatch('Tomato', '🍅', score(6.5, 1.0, 65, 30).toInt()),
      _CropMatch('Onion', '🧅', score(6.5, 1.2, 55, 35).toInt()),
      _CropMatch('Cotton', '🌿', score(7.0, 1.0, 50, 30).toInt()),
      _CropMatch('Wheat', '🌾', score(6.8, 1.2, 55, 30).toInt()),
      _CropMatch('Cabbage', '🥬', score(6.5, 0.8, 70, 25).toInt()),
    ]..sort((a, b) => b.score.compareTo(a.score));

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, "Your Soil's Best Crops"),
          const SizedBox(height: 12),
          ...crops.map((c) {
            final color = c.score >= 85
                ? kForestSage
                : c.score >= 70
                    ? kOceanTeal
                    : c.score >= 55
                        ? kSunsetOrange
                        : kCoral;
            final label = c.score >= 85
                ? 'Excellent'
                : c.score >= 70
                    ? 'Good'
                    : c.score >= 55
                        ? 'Fair'
                        : 'Poor';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(c.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.name,
                                style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(label,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: c.score / 100,
                            backgroundColor: cs.outlineVariant.withAlpha(60),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${c.score}',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 6. 30-Day Improvement Plan ────────────────────────────────────────────
  Widget _buildImprovementPlan(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final actions = _improvementActions(soil.healthStatus, soil.soilType);
    final completed = _planChecked.values.where((v) => v).length;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _sectionLabel(context, '30-Day Improvement Plan')),
              Text('$completed/${actions.length}',
                  style: const TextStyle(
                      color: kForestSage,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: actions.isEmpty ? 0 : completed / actions.length,
              backgroundColor: cs.outlineVariant.withAlpha(60),
              valueColor: const AlwaysStoppedAnimation<Color>(kForestSage),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          ...actions.asMap().entries.map((e) {
            final checked = _planChecked[e.key] ?? false;
            return GestureDetector(
              onTap: () => setState(
                  () => _planChecked[e.key] = !(_planChecked[e.key] ?? false)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: checked
                            ? kForestSage
                            : cs.outlineVariant.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: checked ? kForestSage : cs.outlineVariant),
                      ),
                      child: checked
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.title,
                              style: TextStyle(
                                  color: checked
                                      ? cs.onSurfaceVariant
                                      : cs.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: checked
                                      ? TextDecoration.lineThrough
                                      : null)),
                          Text('Day ${e.value.day}',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_PlanAction> _improvementActions(String health, String soilType) {
    final base = [
      const _PlanAction(1, 'Apply 5 tons farmyard manure per acre'),
      const _PlanAction(5, 'Spray neem oil 3ml/L for pest prevention'),
      const _PlanAction(10, 'Apply vermicompost 1 ton per acre'),
      const _PlanAction(15, 'Take soil sample for lab test'),
      const _PlanAction(20, 'Foliar spray micronutrients (Fe, Zn, B)'),
      const _PlanAction(25, 'Start cover crop sowing (sunhemp)'),
      const _PlanAction(30, 'Re-test soil and compare improvement'),
    ];
    if (health == 'moderate' || health == 'low') {
      base.insert(
          3, const _PlanAction(12, 'Apply gypsum 200 kg/acre for structure'));
    }
    if (soilType.toLowerCase().contains('sandy')) {
      base.insert(1, const _PlanAction(3, 'Mix 2 tons clay soil to improve retention'));
    }
    return base;
  }

  // ── 7. Microbe Health ─────────────────────────────────────────────────────
  Widget _buildMicrobeHealth(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final health = _microbeHealth(soil.healthStatus, soil.moistureLevel);
    final color = health >= 75
        ? kForestSage
        : health >= 55
            ? kSunsetOrange
            : kCoral;
    final label = health >= 75
        ? 'Thriving'
        : health >= 55
            ? 'Healthy'
            : health >= 40
                ? 'Average'
                : 'Poor';
    final tips = health < 75
        ? ['Add compost 500 kg/acre', 'Reduce chemical pesticides', 'Plant cover crops', 'Avoid deep tillage']
        : ['Maintain organic matter', 'Use bio-fertilizers', 'Keep soil moist'];

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'Microbe Health'),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _MicrobePainter(
                      health: health / 100, color: color),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    Text('${health.toInt()}% microbial activity',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 8),
                    ...tips.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right_rounded,
                                  size: 16, color: color),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(t,
                                      style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 12))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 8. Soil Layer Visualizer ──────────────────────────────────────────────
  Widget _buildLayerVisualizer(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'Soil Layer Profile'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                        painter: _SoilLayerPainter(
                            soilType: soil.soilType,
                            moisture: soil.moistureLevel)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _layerLegend(cs, const Color(0xFF3D2B1F), 'Topsoil (0–20 cm)',
                        'Humus, microbes,\nroots'),
                    _layerLegend(cs, const Color(0xFF8B6748), 'Subsoil (20–60 cm)',
                        'Minerals, clay\npockets'),
                    _layerLegend(cs, const Color(0xFFBEA589), 'Parent rock (60+ cm)',
                        'Bedrock &\nweathered rock'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layerLegend(cs, Color color, String title, String desc) {
    return Row(
      children: [
        Container(width: 12, height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            Text(desc,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  // ── 9. Voice Card ─────────────────────────────────────────────────────────
  Widget _buildVoiceCard(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _toggleVoice(soil),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kOceanTeal.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isSpeaking
                      ? Icons.stop_circle_rounded
                      : Icons.mic_rounded,
                  color: kOceanTeal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSpeaking
                          ? 'Tap to stop...'
                          : 'Listen to Your Soil',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _isSpeaking
                          ? 'Reading soil health report...'
                          : 'Tap for spoken soil health summary',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (_isSpeaking)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: kOceanTeal),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 10. Compare with Farms ────────────────────────────────────────────────
  Widget _buildCompareFarms(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final myScore = _overallScore(soil.healthStatus, soil.moistureLevel);
    const districtAvg = 58;
    const topFarm = 88;

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'Your Soil vs Padra Farms'),
          const SizedBox(height: 4),
          Text('Anonymous comparison — other farms are anonymized',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: cs.outlineVariant.withAlpha(60), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const labels = ['You', 'District\nAvg', 'Top Farm'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(labels[v.toInt()],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: myScore.toDouble(),
                        color: myScore >= districtAvg ? kForestSage : kCoral,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: districtAvg.toDouble(),
                        color: kOceanTeal,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)))
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: topFarm.toDouble(),
                        color: kSunsetOrange,
                        width: 32,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)))
                  ]),
                ],
                maxY: 100,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            myScore >= districtAvg
                ? 'Your soil is above the district average. Keep it up!'
                : 'Your soil is below the district average. Follow the 30-day plan to improve.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── 11. Soil Memory Timeline ──────────────────────────────────────────────
  Widget _buildTimeline(BuildContext context, SoilModel soil) {
    final cs = Theme.of(context).colorScheme;
    final score = _overallScore(soil.healthStatus, soil.moistureLevel);

    final events = [
      const _TimelineEvent('6 months ago', 'pH was 7.8 — applied gypsum 200kg/acre',
          Icons.science_rounded, kSunsetOrange),
      const _TimelineEvent('4 months ago',
          'Planted tomato crop — organic matter improved',
          Icons.eco_rounded, kForestSage),
      const _TimelineEvent('2 months ago',
          'Drought reduced moisture to 30% — stress period',
          Icons.wb_sunny_rounded, kCoral),
      const _TimelineEvent('1 month ago',
          'Started drip irrigation — moisture stabilised',
          Icons.water_drop_rounded, kOceanTeal),
      _TimelineEvent(
          'Today',
          'Soil score $score/100 — ${score > 62 ? "improved from 62 last season!" : "work in progress"}',
          Icons.star_rounded,
          kAmber),
    ];

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, "Your Soil's Story"),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((e) {
            final isLast = e.key == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: e.value.color.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(e.value.icon,
                              size: 16, color: e.value.color),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                                width: 2,
                                color: cs.outlineVariant.withAlpha(80)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.date,
                              style: TextStyle(
                                  color: e.value.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(e.value.description,
                              style: TextStyle(
                                  color: cs.onSurface, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Shared: circle button ─────────────────────────────────────────────────
  Widget _circleBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant)),
          child: Icon(icon, color: cs.onSurface, size: 18),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _VitalData {
  final String label;
  final String value;
  final Color color;
  final String status;
  final List<double> sparkline;
  const _VitalData(
      this.label, this.value, this.color, this.status, this.sparkline);
}

class _IrrigationDay {
  final String label, date, type;
  final int litres;
  const _IrrigationDay(
      {required this.label,
      required this.date,
      required this.litres,
      required this.type});
}

class _CropMatch {
  final String name, emoji;
  final int score;
  const _CropMatch(this.name, this.emoji, this.score);
}

class _PlanAction {
  final int day;
  final String title;
  const _PlanAction(this.day, this.title);
}

class _TimelineEvent {
  final String date, description;
  final IconData icon;
  final Color color;
  const _TimelineEvent(this.date, this.description, this.icon, this.color);
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

// ── Soil Vital Card (horizontal premium) ─────────────────────────────────────

class _TwoColVitalGrid extends StatelessWidget {
  final List<_VitalData> vitals;
  const _TwoColVitalGrid({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final rows = (vitals.length / 2).ceil();
    return Column(
      children: [
        for (int row = 0; row < rows; row++) ...[
          Row(
            children: [
              Expanded(child: _SoilVitalCard(vital: vitals[row * 2], index: row * 2)),
              const SizedBox(width: 10),
              Expanded(
                child: row * 2 + 1 < vitals.length
                    ? _SoilVitalCard(vital: vitals[row * 2 + 1], index: row * 2 + 1)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          if (row < rows - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SoilVitalCard extends StatefulWidget {
  final _VitalData vital;
  final int index;
  const _SoilVitalCard({required this.vital, required this.index});

  @override
  State<_SoilVitalCard> createState() => _SoilVitalCardState();
}

class _SoilVitalCardState extends State<_SoilVitalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _hovered = false;

  static IconData _iconFor(String label) => switch (label) {
        'Moisture'   => Icons.water_drop_outlined,
        'pH Level'   => Icons.science_outlined,
        'Nitrogen'   => Icons.eco_outlined,
        'Phosphorus' => Icons.bubble_chart_outlined,
        'Potassium'  => Icons.bolt_outlined,
        'Soil Temp'  => Icons.thermostat_outlined,
        _            => Icons.circle_outlined,
      };

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: 2200.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vital;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: _hovered ? v.color.withOpacity(0.08) : kCineCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? v.color.withOpacity(0.38)
                : v.color.withOpacity(0.16),
          ),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: v.color.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 6))]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  _SoilIconOrb(
                    pulse: _pulse,
                    color: v.color,
                    icon: _iconFor(v.label),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(v.label.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: kCineTextDim, letterSpacing: 1.5,
                            )),
                        const SizedBox(height: 3),
                        Text(v.value,
                            style: GoogleFonts.syne(
                              fontSize: 20, fontWeight: FontWeight.w800,
                              color: v.color, height: 1.0,
                            )),
                        const SizedBox(height: 6),
                        _VitalStatusBadge(status: v.status, color: v.color),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SoilSparklinePanel(data: v.sparkline, color: v.color),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SoilIconOrb extends StatelessWidget {
  final AnimationController pulse;
  final Color color;
  final IconData icon;
  const _SoilIconOrb(
      {required this.pulse, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final glow = 0.18 + pulse.value * 0.32;
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.28), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(glow), blurRadius: 18, spreadRadius: 2),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        );
      },
    );
  }
}

class _VitalStatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _VitalStatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(status,
          style: GoogleFonts.outfit(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: color, letterSpacing: 0.8,
          )),
    );
  }
}

class _SoilSparklinePanel extends StatelessWidget {
  final List<double> data;
  final Color color;
  const _SoilSparklinePanel({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final trend = data.length >= 2
        ? (data.last > data.first ? '+' : data.last < data.first ? '−' : '~')
        : '~';
    final trendColor = trend == '+'
        ? kCineGreen
        : trend == '−'
            ? kCineOrange
            : kCineTextSub;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 68,
          height: 34,
          child: CustomPaint(
            painter: _EnhancedSparklinePainter(data, color),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: trendColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
              trend == '~' ? 'STABLE' : trend == '+' ? 'RISING' : 'FALLING',
              style: GoogleFonts.outfit(
                fontSize: 8, fontWeight: FontWeight.w800,
                color: trendColor, letterSpacing: 0.6,
              )),
        ),
      ],
    );
  }
}

class _VitalLiveDot extends StatefulWidget {
  @override
  State<_VitalLiveDot> createState() => _VitalLiveDotState();
}

class _VitalLiveDotState extends State<_VitalLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 1600.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kCineGreen.withOpacity(0.5 + _ctrl.value * 0.5),
              boxShadow: [
                BoxShadow(
                  color: kCineGreen.withOpacity(_ctrl.value * 0.8),
                  blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text('LIVE',
              style: GoogleFonts.outfit(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: kCineGreen, letterSpacing: 1.2,
              )),
        ],
      ),
    );
  }
}

class _IrrigationDayTile extends StatelessWidget {
  final _IrrigationDay day;
  final ColorScheme cs;
  const _IrrigationDayTile({required this.day, required this.cs});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (day.type) {
      'rain' => (kOceanTeal, Icons.cloud_outlined),
      'skip' => (kSunsetOrange, Icons.wb_sunny_outlined),
      _ => (kAmber, Icons.water_drop_outlined),
    };

    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day.label,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          Icon(icon, color: color, size: 22),
          Text(day.type == 'irrigate' ? '${day.litres}L' : day.type,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          Text(day.date,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

// ── Custom painters ───────────────────────────────────────────────────────────

class _EnhancedSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _EnhancedSparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final w = size.width / (data.length - 1);
    final linePath = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * w;
      final y = size.height - (data[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final px = (i - 1) * w;
        final py = size.height - (data[i - 1].clamp(0.0, 1.0) * size.height);
        final cpx = (px + x) / 2;
        linePath.cubicTo(cpx, py, cpx, y, x, y);
        fillPath.cubicTo(cpx, py, cpx, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color.withOpacity(0.9)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final lastX = (data.length - 1) * w;
    final lastY = size.height - (data.last.clamp(0.0, 1.0) * size.height);
    canvas.drawCircle(Offset(lastX, lastY), 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_EnhancedSparklinePainter old) => old.data != data;
}


class _MicrobePainter extends CustomPainter {
  final double health;
  final Color color;
  const _MicrobePainter({required this.health, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(center, radius,
        Paint()..color = color.withAlpha(20));

    // Progress arc
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 2,
        2 * math.pi * health,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Draw "microbe" dots based on health level
    final rng = math.Random(42);
    final count = (health * 16).toInt().clamp(2, 16);
    final dotPaint = Paint()..color = color.withAlpha(200);
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final r = rng.nextDouble() * (radius - 14) + 4;
      final dotCenter = Offset(
          center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      canvas.drawCircle(dotCenter, rng.nextDouble() * 3 + 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_MicrobePainter old) => old.health != health;
}

class _SoilLayerPainter extends CustomPainter {
  final String soilType;
  final double moisture;
  const _SoilLayerPainter({required this.soilType, required this.moisture});

  @override
  void paint(Canvas canvas, Size size) {
    final darkFactor = moisture / 100;
    final topColor = Color.lerp(
        const Color(0xFF3D2B1F), const Color(0xFF1A0E06), darkFactor)!;
    final midColor = Color.lerp(
        const Color(0xFF8B6748), const Color(0xFF5C3D1E), darkFactor * 0.6)!;
    const botColor = Color(0xFFBEA589);

    // Top layer (30%)
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
        Paint()..color = topColor);

    // Mid layer (40%)
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.4),
        Paint()..color = midColor);

    // Bottom layer (30%)
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.7, size.width, size.height * 0.3),
        Paint()..color = botColor);

    // Draw texture dots
    final rng = math.Random(10);
    final dotPaint = Paint()..color = Colors.black.withAlpha(18);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * size.width,
              rng.nextDouble() * size.height),
          rng.nextDouble() * 2 + 0.5,
          dotPaint);
    }

    // Layer dividers
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.3), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.7), linePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
