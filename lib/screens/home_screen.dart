import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/air_quality_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/soil_provider.dart';
import '../providers/recommendations_provider.dart';
import '../theme/dynamic_theme.dart';
import '../utils/constants.dart';
import 'calculators/calc_water_requirement.dart';
import 'calculators/calc_fertilizer.dart';
import 'calculators/calc_profit_margin.dart';
import 'calculators/calc_loan_emi.dart';
import 'calculators/calc_land_area.dart';
import 'calculators/calc_seed_quantity.dart';
import '../utils/formatters.dart';
import '../widgets/buttons/icon_action_button.dart';
import '../widgets/cards/quick_action_card.dart';
import '../widgets/cards/photo_hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
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
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, -0.8),
                  radius: 0.9,
                  colors: [cs.primary.withAlpha(26), Theme.of(context).scaffoldBackgroundColor],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _TopBar(
                onNotificationTap: () =>
                    Navigator.pushNamed(context, '/notifications'),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _GreetingHeader()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            kPadding, 0, kPadding, 20),
                        child: _WeatherHeroCard(),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: _SectionTitle('Quick Actions'),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            kPadding, 0, kPadding, 4),
                        child: _QuickActionsSection(),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: _SectionTitle('Smart Tools'),
                    ),
                    SliverToBoxAdapter(
                      child: _SmartToolsSection(),
                    ),
                    const SliverToBoxAdapter(
                        child: _SectionTitle('Soil & Recommendations')),
                    SliverToBoxAdapter(child: _SoilCropCarousel()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            kPadding, 0, kPadding, kPaddingLarge),
                        child: _AiTeaserCard(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _FloatingNav(
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/chat');
      case 2:
        Navigator.pushNamed(context, '/soil');
      case 3:
        Navigator.pushNamed(context, '/calculators');
      case 4:
        Navigator.pushNamed(context, '/alerts');
      case 5:
        Navigator.pushNamed(context, '/profile');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    final soil = context.watch<SoilProvider>().soil;
    final themeData = context.watch<DynamicThemeProvider>().data;

    final weatherSub = weather != null
        ? '${weather.temperature.toInt()}° · ${_conditionLabel(weather.condition)}'
        : 'Fetching forecast…';
    final soilSub = soil != null
        ? '${soil.moistureLevel.toInt()}% moisture · ${_capitalize(soil.healthStatus)}'
        : 'Checking soil…';

    final cards = [
      (icon: PhosphorIcons.cloudSun(), title: 'Weather', subtitle: weatherSub, route: '/weather', color: themeData.weatherAccent),
      (icon: PhosphorIcons.plant(), title: 'Soil', subtitle: soilSub, route: '/soil', color: themeData.soilAccent),
      (icon: PhosphorIcons.chatCircle(), title: 'AI Chat', subtitle: 'Ask anything', route: '/chat', color: themeData.chatAccent),
      (icon: PhosphorIcons.chartLine(), title: 'Market', subtitle: 'Live mandi prices', route: '/market', color: themeData.marketAccent),
    ];

    return Column(
      children: List.generate(cards.length, (i) {
        final c = cards[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i < cards.length - 1 ? 10 : 0),
          child: QuickActionCard(
            icon: c.icon,
            title: c.title,
            subtitle: c.subtitle,
            iconColor: c.color,
            onTap: () => Navigator.pushNamed(context, c.route),
            index: i,
          ),
        );
      }),
    );
  }

  String _conditionLabel(String c) {
    switch (c) {
      case 'sunny': return 'Sunny';
      case 'rainy': return 'Rainy';
      case 'stormy': return 'Stormy';
      case 'cloudy': return 'Partly Cloudy';
      case 'heatwave': return 'Heatwave';
      default: return 'Clear';
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const _TopBar({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kPadding, 8, kPadding, 0),
        child: Row(
          children: [
            Builder(builder: (ctx) {
              final primary = Theme.of(ctx).colorScheme.primary;
              return Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withAlpha(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Center(
                  child: Text('CG',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
              );
            }),
            const Spacer(),
            IconActionButton(
              icon: PhosphorIcons.bell(),
              onPressed: onNotificationTap,
              badge: '3',
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name ?? 'Farmer';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(kPadding, 16, kPadding, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 4),
          Row(
            children: [
              PhosphorIcon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text('Padra, Gujarat',
                  style: GoogleFonts.dmSans(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _WeatherHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    final temp = weather != null ? '${weather.temperature.toInt()}°' : '--°';
    final condition = weather?.condition ?? 'sunny';

    return PhotoHeroCard(
      imageUrl: _conditionPhoto(condition),
      height: 210,
      onTap: () => Navigator.pushNamed(context, '/weather'),
      topRight: _ViewForecastPill(),
      bottomContent: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temp,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  '${_conditionLabel(condition)} · Padra',
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            if (weather != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Stat(PhosphorIcons.drop(PhosphorIconsStyle.fill),
                      Formatters.humidity(weather.humidity)),
                  const SizedBox(height: 4),
                  _Stat(PhosphorIcons.wind(),
                      Formatters.windSpeed(weather.windSpeed)),
                ],
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
            begin: const Offset(0.97, 0.97), curve: Curves.easeOutCubic);
  }

  String _conditionLabel(String c) {
    switch (c) {
      case 'sunny': return 'Sunny';
      case 'rainy': return 'Rainy';
      case 'stormy': return 'Stormy';
      case 'cloudy': return 'Partly Cloudy';
      case 'heatwave': return 'Heatwave';
      default: return 'Clear';
    }
  }

  String _conditionPhoto(String c) {
    switch (c) {
      case 'rainy': return kPhotoRainy;
      case 'stormy': return kPhotoStormy;
      case 'cloudy': return kPhotoCloudy;
      default: return kPhotoHomeHero;
    }
  }
}

class _ViewForecastPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Forecast',
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          PhosphorIcon(PhosphorIcons.arrowRight(), size: 12, color: Colors.white),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final PhosphorIconData icon;
  final String value;
  const _Stat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(icon, size: 13, color: Colors.white60),
        const SizedBox(width: 4),
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kPadding, 4, kPadding, 14),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _SoilCropCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final soil = context.watch<SoilProvider>().soil;
    return SizedBox(
      height: 168,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
        scrollDirection: Axis.horizontal,
        children: [
          _SoilMiniCard(
            moisture: soil?.moistureLevel ?? 62,
            status: soil?.healthStatus ?? 'moderate',
            onTap: () => Navigator.pushNamed(context, '/soil'),
          ),
          const SizedBox(width: 12),
          ...kCropPhotos.entries.take(3).map((e) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CropCard(
                  cropName: e.key[0].toUpperCase() + e.key.substring(1),
                  photoUrl: e.value,
                  onTap: () => Navigator.pushNamed(context, '/recommendations'),
                ),
              )),
        ],
      ),
    );
  }
}

class _SoilMiniCard extends StatelessWidget {
  final double moisture;
  final String status;
  final VoidCallback onTap;
  const _SoilMiniCard(
      {required this.moisture, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = status == 'good'
        ? kForestSage
        : status == 'moderate'
            ? kSunsetOrange
            : kCoral;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: PhosphorIcon(
                      PhosphorIcons.drop(PhosphorIconsStyle.fill),
                      size: 20,
                      color: color),
                ),
              ),
              const Spacer(),
              Text(
                '${moisture.toInt()}%',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              Text('Soil moisture',
                  style: GoogleFonts.dmSans(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final String cropName;
  final String photoUrl;
  final VoidCallback onTap;
  const _CropCard(
      {required this.cropName, required this.photoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 140,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(178)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    cropName,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiTeaserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/chat'),
        child: Container(
          padding: const EdgeInsets.all(kPaddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.secondary.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary.withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: PhosphorIcon(
                      PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                      size: 26,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask ClimaVOICE',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Text(
                      'AI answers for every farming question',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(PhosphorIcons.arrowRight(),
                  size: 22, color: Colors.white70),
            ],
          ),
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SmartToolsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tools = [
      (Icons.water_drop_rounded, 'Water\nCalc', const Color(0xFF4A90C2), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterRequirementCalc()));
      }),
      (Icons.eco_rounded, 'Fertilizer', const Color(0xFF6B8E5A), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FertilizerCalc()));
      }),
      (Icons.currency_rupee_rounded, 'Profit', const Color(0xFFD4A017), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitMarginCalc()));
      }),
      (Icons.account_balance_rounded, 'Loan\nEMI', const Color(0xFF8E5572), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanEMICalc()));
      }),
      (Icons.landscape_rounded, 'Land\nArea', const Color(0xFF92400E), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LandAreaCalc()));
      }),
      (Icons.grass_rounded, 'Seed\nQty', const Color(0xFF4A7C59), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SeedQuantityCalc()));
      }),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
        itemCount: tools.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          if (i == tools.length) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, '/calculators'),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grid_view_rounded, color: cs.primary, size: 28),
                      const SizedBox(height: 8),
                      Text('See All\nTools',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
                    ],
                  ),
                ),
              ),
            );
          }
          final t = tools[i];
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: t.$4,
              child: Container(
                width: 110,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.$3.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(t.$1, color: t.$3, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(t.$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.3)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FloatingNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _FloatingNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (PhosphorIcons.house(PhosphorIconsStyle.fill), 'Home'),
      (PhosphorIcons.chatCircle(PhosphorIconsStyle.fill), 'Chat'),
      (PhosphorIcons.plant(PhosphorIconsStyle.fill), 'Soil'),
      (PhosphorIcons.calculator(PhosphorIconsStyle.fill), 'Tools'),
      (PhosphorIcons.warning(PhosphorIconsStyle.fill), 'Alerts'),
      (PhosphorIcons.user(PhosphorIconsStyle.fill), 'Profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Builder(builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            return Container(
            height: 72,
            decoration: BoxDecoration(
              color: cs.surface.withAlpha(230),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((e) {
                final idx = e.key;
                final icon = e.value.$1;
                final label = e.value.$2;
                final selected = idx == currentIndex;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onTap(idx),
                    child: AnimatedContainer(
                      duration: kAnimFast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cs.primary.withAlpha(30) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(icon,
                              size: 22,
                              color: selected ? cs.primary : cs.onSurfaceVariant),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
          }),
        ),
      ),
    );
  }
}
