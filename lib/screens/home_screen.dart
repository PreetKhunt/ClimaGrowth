import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/air_quality_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/soil_provider.dart';
import '../providers/recommendations_provider.dart';
import '../utils/constants.dart';
import '../widgets/cinematic/ambient_background.dart';
import 'calculators/calc_water_requirement.dart';
import 'calculators/calc_fertilizer.dart';
import 'calculators/calc_profit_margin.dart';
import 'calculators/calc_loan_emi.dart';
import 'calculators/calc_land_area.dart';
import 'calculators/calc_seed_quantity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIndex = 0;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<WeatherProvider>().fetch(kDefaultLat, kDefaultLon);
      context.read<AirQualityProvider>().fetch(kDefaultLat, kDefaultLon);
      context.read<SoilProvider>().fetch(auth.user?.uid ?? 'guest');
      context.read<RecommendationsProvider>().loadCached();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCineBg,
      extendBody: true,
      body: AmbientBackground(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _TopBar(
                    onNotifTap: () =>
                        Navigator.pushNamed(context, '/notifications'),
                  ),
                ),
                SliverToBoxAdapter(
                    child: _GreetingSection(pulseCtrl: _pulseCtrl)),
                SliverToBoxAdapter(child: _WeatherHeroCard()),
                const SliverToBoxAdapter(child: _SectionLabel('Intelligence Grid')),
                const SliverToBoxAdapter(child: _IntelligenceGrid()),
                const SliverToBoxAdapter(child: _SectionLabel('Smart Tools')),
                const SliverToBoxAdapter(child: _SmartToolsRow()),
                const SliverToBoxAdapter(child: _AiTeaserCard()),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _CinematicNav(index: _navIndex, onTap: _onNavTap),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: Navigator.pushNamed(context, '/chat');
      case 2: Navigator.pushNamed(context, '/soil');
      case 3: Navigator.pushNamed(context, '/calculators');
      case 4: Navigator.pushNamed(context, '/alerts');
      case 5: Navigator.pushNamed(context, '/profile');
    }
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onNotifTap;
  const _TopBar({required this.onNotifTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(
          children: [
            // Logo mark with glow
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kCineGreen, kCineBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: kGlowGreen, blurRadius: 14, spreadRadius: 0),
                ],
              ),
              child: Center(
                child: Text(
                  'CG',
                  style: GoogleFonts.syne(
                    fontSize: 14, fontWeight: FontWeight.w800, color: kCineBg),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const Spacer(),

            // Notification icon
            GestureDetector(
              onTap: onNotifTap,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: kCineCard,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: kCineBorder),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: PhosphorIcon(
                              PhosphorIcons.bell(),
                              size: 19, color: kCineTextSub),
                          ),
                          Positioned(
                            top: 9, right: 9,
                            child: Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(
                                color: kCineGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: kGlowGreen, blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _GreetingSection({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final name  = auth.user?.name ?? 'Farmer';
    final hour  = DateTime.now().hour;
    final greet = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final dateStr = _fmtDate(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Row(
            children: [
              Container(
                width: 4, height: 14,
                decoration: BoxDecoration(
                  color: kCineGreen,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [BoxShadow(color: kGlowGreen, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateStr.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: kCineGreen, letterSpacing: 2.0),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 10),

          // Greeting line
          Text(
            '$greet,',
            style: GoogleFonts.syne(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: kCineTextSub, height: 1.1),
          ).animate(delay: 80.ms).fadeIn(duration: 450.ms).slideY(begin: -0.1, end: 0),

          // Name gradient
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [kCineGreen, kCineBlue],
            ).createShader(b),
            child: Text(
              name,
              style: GoogleFonts.syne(
                fontSize: 32, fontWeight: FontWeight.w800,
                color: Colors.white, height: 1.1, letterSpacing: -0.5),
            ),
          ).animate(delay: 160.ms).fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const w = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${w[d.weekday - 1]}, ${m[d.month - 1]} ${d.day}';
  }
}

// ── Weather hero card ─────────────────────────────────────────────────────────

class _WeatherHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather   = context.watch<WeatherProvider>().weather;
    final temp      = weather != null ? '${weather.temperature.toInt()}°' : '—°';
    final condition = weather?.condition ?? 'clear';
    final accent    = _conditionAccent(condition);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/weather'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: 600.ms,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.13), kCineCard],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withOpacity(0.28), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.10),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _LivePill(),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              size: 12, color: kCineTextSub),
                            const SizedBox(width: 5),
                            Text(
                              'Padra, Gujarat',
                              style: GoogleFonts.outfit(
                                fontSize: 12, color: kCineTextSub),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Temperature
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: [Colors.white, accent.withOpacity(0.80)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(b),
                      child: Text(
                        temp,
                        style: GoogleFonts.syne(
                          fontSize: 76, fontWeight: FontWeight.w800,
                          color: Colors.white, height: 1.0),
                      ),
                    ),

                    Text(
                      _conditionLabel(condition),
                      style: GoogleFonts.outfit(
                        fontSize: 15, color: kCineTextSub, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 22),

                    Container(height: 1, color: kCineBorder),

                    const SizedBox(height: 18),

                    // Stats row
                    if (weather != null)
                      Row(
                        children: [
                          _WStat(
                            PhosphorIcons.drop(PhosphorIconsStyle.fill),
                            kCineBlue,
                            '${weather.humidity.toInt()}%',
                            'Humidity',
                          ),
                          const SizedBox(width: 24),
                          _WStat(
                            PhosphorIcons.wind(),
                            kCineGreen,
                            '${weather.windSpeed.toStringAsFixed(0)} km/h',
                            'Wind',
                          ),
                          const SizedBox(width: 24),
                          _WStat(
                            PhosphorIcons.cloudRain(PhosphorIconsStyle.fill),
                            kCineOrange,
                            '${weather.rainProbability.toInt()}%',
                            'Rain',
                          ),
                          const Spacer(),
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: accent.withOpacity(0.25), width: 1),
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.arrowRight(),
                                size: 17, color: accent),
                            ),
                          ),
                        ],
                      )
                    else
                      _ShimmerRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.97, 0.97),
          curve: Curves.easeOutCubic);
  }

  Color _conditionAccent(String c) => switch (c) {
    'sunny'    => kCineOrange,
    'rainy'    => kCineBlue,
    'stormy'   => kCinePurple,
    'heatwave' => const Color(0xFFFF6B35),
    'cloudy'   => const Color(0xFF7BAACC),
    _          => kCineGreen,
  };

  String _conditionLabel(String c) => switch (c) {
    'sunny'    => 'Sunny',
    'rainy'    => 'Rainy',
    'stormy'   => 'Stormy',
    'cloudy'   => 'Partly Cloudy',
    'heatwave' => 'Heatwave',
    _          => 'Clear',
  };
}

class _WStat extends StatelessWidget {
  final PhosphorIconData icon;
  final Color color;
  final String value;
  final String label;
  const _WStat(this.icon, this.color, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(value,
              style: GoogleFonts.syne(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
          style: GoogleFonts.outfit(
            fontSize: 10, color: kCineTextDim, letterSpacing: 0.5)),
      ],
    );
  }
}

// Pulsing "LIVE" pill
class _LivePill extends StatefulWidget {
  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: 1800.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kCineGreen.withOpacity(0.10),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: kCineGreen.withOpacity(0.30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCineGreen.withOpacity(0.5 + _c.value * 0.5),
                boxShadow: [
                  BoxShadow(
                    color: kGlowGreen.withOpacity(_c.value),
                    blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: GoogleFonts.outfit(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: kCineGreen, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple shimmer placeholder while data loads
class _ShimmerRow extends StatefulWidget {
  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: 1500.ms)..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _bar(double w) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      width: w, height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04 + _c.value * 0.04),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _bar(64), const SizedBox(width: 20),
        _bar(56), const SizedBox(width: 20),
        _bar(48),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
      child: Row(
        children: [
          Container(
            width: 3, height: 15,
            decoration: BoxDecoration(
              color: kCineGreen,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [BoxShadow(color: kGlowGreen, blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: kCineTextSub, letterSpacing: 2.2),
          ),
        ],
      ),
    );
  }
}

// ── Intelligence grid — horizontal premium analytics panels ──────────────────

class _IntelligenceGrid extends StatelessWidget {
  const _IntelligenceGrid();

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    final soil    = context.watch<SoilProvider>().soil;

    final cards = [
      _IntelData(
        icon:        PhosphorIcons.cloudSun(PhosphorIconsStyle.fill),
        color:       kCineBlue,
        module:      'WEATHER',
        value:       weather != null ? '${weather.temperature.toInt()}°' : '—',
        condition:   weather != null ? _condLabel(weather.condition) : 'Fetching…',
        detail:      'Padra, Gujarat',
        rightValue:  weather != null ? '${weather.humidity.toInt()}%' : '—',
        rightLabel:  'HUMIDITY',
        live:        weather != null,
        route:       '/weather',
      ),
      _IntelData(
        icon:        PhosphorIcons.plant(PhosphorIconsStyle.fill),
        color:       kCineGreen,
        module:      'SOIL',
        value:       soil != null ? '${soil.moistureLevel.toInt()}%' : '—',
        condition:   soil != null ? _capitalize(soil.healthStatus) : 'Checking…',
        detail:      soil?.soilType ?? 'Soil analysis',
        rightValue:  soil != null ? soil.healthStatus.toUpperCase() : '—',
        rightLabel:  'STATUS',
        live:        soil != null,
        route:       '/soil',
      ),
      _IntelData(
        icon:        PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
        color:       kCinePurple,
        module:      'AI CHAT',
        value:       'Ask',
        condition:   'ClimaVOICE',
        detail:      'Gemini AI assistant',
        rightValue:  '∞',
        rightLabel:  'QUERIES',
        live:        true,
        route:       '/chat',
      ),
      _IntelData(
        icon:        PhosphorIcons.chartLine(PhosphorIconsStyle.fill),
        color:       kCineOrange,
        module:      'MARKET',
        value:       '₹',
        condition:   'Live Mandi',
        detail:      'Cotton · Wheat · Tomato',
        rightValue:  'LIVE',
        rightLabel:  'PRICES',
        live:        true,
        route:       '/market',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          // ≥ 640px → two-column side-by-side
          if (constraints.maxWidth >= 640) {
            return _TwoColumnGrid(cards: cards);
          }
          // Narrow → single full-width column
          return Column(
            children: List.generate(cards.length, (i) => Padding(
              padding: EdgeInsets.only(bottom: i < cards.length - 1 ? 12 : 0),
              child: _IntelCard(data: cards[i], index: i),
            )),
          );
        },
      ),
    );
  }

  String _condLabel(String c) => switch (c) {
    'sunny'    => 'Sunny',
    'rainy'    => 'Rainy',
    'stormy'   => 'Stormy',
    'cloudy'   => 'Partly Cloudy',
    'heatwave' => 'Heatwave',
    _          => 'Clear',
  };

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _TwoColumnGrid extends StatelessWidget {
  final List<_IntelData> cards;
  const _TwoColumnGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < (cards.length / 2).ceil(); row++) ...[
          if (row > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _IntelCard(data: cards[row * 2], index: row * 2)),
              const SizedBox(width: 12),
              if (row * 2 + 1 < cards.length)
                Expanded(child: _IntelCard(data: cards[row * 2 + 1], index: row * 2 + 1))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _IntelData {
  final PhosphorIconData icon;
  final Color color;
  final String module;
  final String value;       // Primary large metric (e.g. "32°")
  final String condition;   // Secondary label next to value (e.g. "Partly Cloudy")
  final String detail;      // Small dim sub-line
  final String rightValue;  // Right-side metric
  final String rightLabel;  // Right-side label
  final bool live;
  final String route;
  const _IntelData({
    required this.icon, required this.color, required this.module,
    required this.value,   required this.condition, required this.detail,
    required this.rightValue, required this.rightLabel,
    required this.live,    required this.route,
  });
}

// ── Horizontal card ───────────────────────────────────────────────────────────

class _IntelCard extends StatefulWidget {
  final _IntelData data;
  final int index;
  const _IntelCard({required this.data, required this.index});

  @override
  State<_IntelCard> createState() => _IntelCardState();
}

class _IntelCardState extends State<_IntelCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, d.route),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    d.color.withOpacity(_hovered ? 0.13 : 0.06),
                    kCineSurface.withOpacity(0.80),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: d.color.withOpacity(_hovered ? 0.38 : 0.16),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: d.color.withOpacity(_hovered ? 0.14 : 0.04),
                    blurRadius: _hovered ? 28 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Left: Icon ──────────────────────────────────────────────
                  _IconOrb(icon: d.icon, color: d.color, pulse: _pulseCtrl, live: d.live),

                  const SizedBox(width: 16),

                  // ── Centre: Content ─────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Module badge row
                        Row(
                          children: [
                            Text(
                              d.module,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: d.color,
                                letterSpacing: 1.8,
                              ),
                            ),
                            if (d.live) ...[
                              const SizedBox(width: 6),
                              _LiveDot(color: d.color, pulse: _pulseCtrl),
                            ],
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Primary metric + condition on one line
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              d.value,
                              style: GoogleFonts.syne(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                d.condition,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kCineTextSub,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Detail line
                        Text(
                          d.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 11,
                            color: kCineTextDim,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Right: Secondary metric ─────────────────────────────────
                  _RightMetric(
                    value: d.rightValue,
                    label: d.rightLabel,
                    color: d.color,
                  ),

                  const SizedBox(width: 10),

                  // ── Arrow button ────────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: d.color.withOpacity(_hovered ? 0.18 : 0.09),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: d.color.withOpacity(_hovered ? 0.30 : 0.14),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIcons.arrowRight(),
                        size: 15,
                        color: d.color.withOpacity(_hovered ? 1.0 : 0.60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (80 * widget.index).ms)
        .fadeIn(duration: 520.ms)
        .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.98, 0.98),
          curve: Curves.easeOutCubic);
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Glowing icon orb for the left column
class _IconOrb extends StatelessWidget {
  final PhosphorIconData icon;
  final Color color;
  final AnimationController pulse;
  final bool live;
  const _IconOrb({
    required this.icon, required this.color,
    required this.pulse, required this.live,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(live ? 0.18 + pulse.value * 0.14 : 0.10),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

/// Tiny pulsing live dot
class _LiveDot extends StatelessWidget {
  final Color color;
  final AnimationController pulse;
  const _LiveDot({required this.color, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width: 5, height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.5 + pulse.value * 0.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(pulse.value * 0.7),
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Right-side secondary metric block
class _RightMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _RightMetric({
    required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.16), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Smart tools row ───────────────────────────────────────────────────────────

class _SmartToolsRow extends StatelessWidget {
  const _SmartToolsRow();

  @override
  Widget build(BuildContext context) {
    final tools = <(IconData, String, Color, VoidCallback)>[
      (Icons.water_drop_rounded, 'Water', kCineBlue, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WaterRequirementCalc()));
      }),
      (Icons.eco_rounded, 'Fertilizer', kCineGreen, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FertilizerCalc()));
      }),
      (Icons.currency_rupee_rounded, 'Profit', kCineOrange, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfitMarginCalc()));
      }),
      (Icons.account_balance_rounded, 'Loan EMI', kCinePurple, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LoanEMICalc()));
      }),
      (Icons.landscape_rounded, 'Land Area', const Color(0xFFFF6B6B), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LandAreaCalc()));
      }),
      (Icons.grass_rounded, 'Seed Qty', kCineGreen, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SeedQuantityCalc()));
      }),
    ];

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        children: [
          ...tools.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _ToolChip(
                icon: t.$1, label: t.$2, color: t.$3, onTap: t.$4, index: i),
            );
          }),
          _AllToolsChip(),
        ],
      ),
    );
  }
}

class _ToolChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int index;
  const _ToolChip({
    required this.icon, required this.label, required this.color,
    required this.onTap, required this.index,
  });

  @override
  State<_ToolChip> createState() => _ToolChipState();
}

class _ToolChipState extends State<_ToolChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: 150.ms,
              width: 78,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_hovered ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.color.withOpacity(_hovered ? 0.35 : 0.18), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 17),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      fontSize: 10, color: kCineTextSub,
                      fontWeight: FontWeight.w500, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (45 * widget.index).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _AllToolsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/calculators'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCineBorder, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view_rounded, color: kCineTextSub, size: 22),
              const SizedBox(height: 7),
              Text(
                'All Tools',
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                  fontSize: 10, color: kCineTextSub, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Teaser card ────────────────────────────────────────────────────────────

class _AiTeaserCard extends StatefulWidget {
  const _AiTeaserCard();

  @override
  State<_AiTeaserCard> createState() => _AiTeaserCardState();
}

class _AiTeaserCardState extends State<_AiTeaserCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: 2200.ms)
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/chat'),
          child: AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kCinePurple.withOpacity(_hovered ? 0.18 : 0.12),
                        kCineBlue.withOpacity(_hovered ? 0.10 : 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: kCinePurple.withOpacity(0.18 + _glow.value * 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kCinePurple.withOpacity(0.08 + _glow.value * 0.07),
                        blurRadius: 32, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // AI icon orb
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kCinePurple, kCineBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kGlowPurple
                                  .withOpacity(0.6 + _glow.value * 0.4),
                              blurRadius: 18),
                          ],
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                            size: 26, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask ClimaVOICE',
                              style: GoogleFonts.syne(
                                fontSize: 17, fontWeight: FontWeight.w700,
                                color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gemini AI answers every farming question',
                              style: GoogleFonts.figtree(
                                fontSize: 12, color: kCineTextSub),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kCinePurple.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kCinePurple.withOpacity(0.30), width: 1),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.arrowRight(),
                            size: 17, color: kCinePurple),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Cinematic floating nav ────────────────────────────────────────────────────

class _CinematicNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _CinematicNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icons = [
      PhosphorIcons.house(PhosphorIconsStyle.fill),
      PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
      PhosphorIcons.plant(PhosphorIconsStyle.fill),
      PhosphorIcons.calculator(PhosphorIconsStyle.fill),
      PhosphorIcons.warning(PhosphorIconsStyle.fill),
      PhosphorIcons.user(PhosphorIconsStyle.fill),
    ];

    final labels = ['Home', 'Chat', 'Soil', 'Tools', 'Alerts', 'Profile'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xD00F1115),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kCineBorder, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 32, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (i) {
                final selected = i == index;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 14 : 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? kCineGreen.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: selected
                            ? Border.all(
                                color: kCineGreen.withOpacity(0.22), width: 1)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: kGlowGreen.withOpacity(0.25),
                                  blurRadius: 12),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            icons[i],
                            size: 20,
                            color: selected ? kCineGreen : kCineTextDim,
                          ),
                          if (selected) ...[
                            const SizedBox(width: 7),
                            Text(
                              labels[i],
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kCineGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
