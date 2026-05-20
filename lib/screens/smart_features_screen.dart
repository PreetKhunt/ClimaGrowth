import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

// ── Feature model ──────────────────────────────────────────────────────────
class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext) builder;
  const _Feature({required this.title, required this.subtitle,
      required this.icon, required this.color, required this.builder});
}

// ── Screen ──────────────────────────────────────────────────────────────────
class SmartFeaturesScreen extends StatelessWidget {
  const SmartFeaturesScreen({super.key});

  static final _features = <_Feature>[
    _Feature(
      title: 'Irrigation Scheduler',
      subtitle: 'Plan watering based on crop & weather',
      icon: Icons.water_drop_rounded,
      color: kOceanTeal,
      builder: (_) => const _IrrigationScheduler(),
    ),
    _Feature(
      title: 'Pest Network',
      subtitle: 'Community pest & disease reports',
      icon: Icons.bug_report_outlined,
      color: kCoral,
      builder: (_) => const _PestNetwork(),
    ),
    _Feature(
      title: 'Insurance Advisor',
      subtitle: 'PM-FASAL Bima & crop insurance',
      icon: Icons.shield_outlined,
      color: kForestSage,
      builder: (_) => const _InsuranceAdvisor(),
    ),
    _Feature(
      title: 'Profit Calculator',
      subtitle: 'Estimate crop profit before sowing',
      icon: Icons.calculate_outlined,
      color: kSunsetOrange,
      builder: (_) => const _ProfitCalculator(),
    ),
    _Feature(
      title: 'Soil Test Booking',
      subtitle: 'Book GSAU / ICAR soil testing',
      icon: Icons.science_outlined,
      color: kForestSage,
      builder: (_) => const _SoilTestBooking(),
    ),
    _Feature(
      title: 'Smart Weather Alerts',
      subtitle: 'Set custom threshold notifications',
      icon: Icons.notifications_active_outlined,
      color: kAmber,
      builder: (_) => const _WeatherAlerts(),
    ),
    _Feature(
      title: 'Equipment Rental',
      subtitle: 'Rent tractors, harvesters nearby',
      icon: Icons.agriculture_rounded,
      color: kIndigo,
      builder: (_) => const _EquipmentRental(),
    ),
    _Feature(
      title: 'Mandi Live Auction',
      subtitle: 'Real-time prices from APMC mandis',
      icon: Icons.gavel_rounded,
      color: kSunsetOrange,
      builder: (_) => const _MandiAuction(),
    ),
    _Feature(
      title: 'Knowledge Reels',
      subtitle: 'Short video farming tips',
      icon: Icons.play_circle_outline_rounded,
      color: kPlum,
      builder: (_) => const _KnowledgeReels(),
    ),
    _Feature(
      title: 'Crop Comparison',
      subtitle: 'Compare 2 crops side by side',
      icon: Icons.compare_arrows_rounded,
      color: kAmber,
      builder: (_) => const _CropComparison(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: kPhotoHomeHero, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _glassBtn(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Features',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                            Text('10 AI-powered farming tools',
                                style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _features.length,
                    itemBuilder: (_, i) => _FeatureCard(feature: _features[i], index: i),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _glassBtn({required VoidCallback onTap, required Widget child}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kGlassColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kGlassBorder),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final int index;
  const _FeatureCard({required this.feature, required this.index});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openFeature(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGlassColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kGlassBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: feature.color.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: feature.color.withAlpha(100)),
                    ),
                    child: Icon(feature.icon, color: feature.color, size: 22),
                  ),
                  const Spacer(),
                  Text(feature.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 2),
                  const SizedBox(height: 4),
                  Text(feature.subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1);
  }

  void _openFeature(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: feature.builder));
  }
}

// ── Base sheet layout ───────────────────────────────────────────────────────
class _FeatureShell extends StatelessWidget {
  final String title;
  final Color accent;
  final IconData icon;
  final Widget body;
  const _FeatureShell({required this.title, required this.accent,
      required this.icon, required this.body});

  static Widget _glass({required Widget child, double radius = 14, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: kGlassSigma, sigmaY: kGlassSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: kGlassColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: kGlassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: kPhotoHomeHero, fit: BoxFit.cover),
          Container(color: const Color(0xCC000000)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: _glass(
                            radius: 18,
                            child: const SizedBox(width: 36, height: 36,
                                child: Center(child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(icon, color: accent, size: 22),
                      const SizedBox(width: 8),
                      Text(title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Irrigation Scheduler ─────────────────────────────────────────────────
class _IrrigationScheduler extends StatefulWidget {
  const _IrrigationScheduler();
  @override
  State<_IrrigationScheduler> createState() => _IrrigationSchedulerState();
}

class _IrrigationSchedulerState extends State<_IrrigationScheduler> {
  String _crop = 'Cotton';
  String _method = 'Drip';
  double _acres = 2.0;

  static const _crops = ['Cotton', 'Wheat', 'Tomato', 'Groundnut', 'Sugarcane', 'Maize'];
  static const _methods = ['Drip', 'Sprinkler', 'Flood'];
  static const _schedule = {
    'Cotton|Drip': '4 L/plant/day · Every day',
    'Cotton|Sprinkler': '25 mm · Every 5 days',
    'Cotton|Flood': '60 mm · Every 10 days',
    'Wheat|Drip': '3 L/m²/day · Every 3 days',
    'Wheat|Sprinkler': '20 mm · Every 7 days',
    'Wheat|Flood': '75 mm · Every 15 days',
    'Tomato|Drip': '5 L/plant/day · Every day',
    'Tomato|Sprinkler': '20 mm · Every 3 days',
    'Tomato|Flood': '50 mm · Every 7 days',
    'Groundnut|Drip': '3 L/plant/day · Every 2 days',
    'Groundnut|Sprinkler': '18 mm · Every 5 days',
    'Groundnut|Flood': '50 mm · Every 10 days',
    'Sugarcane|Drip': '6 L/plant/day · Every day',
    'Sugarcane|Sprinkler': '30 mm · Every 5 days',
    'Sugarcane|Flood': '80 mm · Every 7 days',
    'Maize|Drip': '4 L/plant/day · Every 2 days',
    'Maize|Sprinkler': '25 mm · Every 5 days',
    'Maize|Flood': '65 mm · Every 10 days',
  };

  @override
  Widget build(BuildContext context) {
    final key = '$_crop|$_method';
    final rec = _schedule[key] ?? '—';
    final totalLitres = _acres * 4047 * 0.005;

    return _FeatureShell(
      title: 'Irrigation Scheduler',
      accent: kOceanTeal,
      icon: Icons.water_drop_rounded,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Select Crop'),
                const SizedBox(height: 8),
                _chipRow(_crops, _crop, (v) => setState(() => _crop = v)),
                const SizedBox(height: 14),
                _label('Irrigation Method'),
                const SizedBox(height: 8),
                _chipRow(_methods, _method, (v) => setState(() => _method = v)),
                const SizedBox(height: 14),
                _label('Farm Size: ${_acres.toStringAsFixed(1)} acres'),
                Slider(
                  value: _acres, min: 0.5, max: 20,
                  divisions: 39,
                  activeColor: kOceanTeal, inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _acres = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.tips_and_updates_outlined, color: kOceanTeal, size: 18),
                  SizedBox(width: 8),
                  Text('Recommendation', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _resultRow('Schedule', rec),
                _resultRow('Total need/cycle', '${totalLitres.toStringAsFixed(0)} L'),
                _resultRow('Best time', '5–7 AM or after sunset'),
                _resultRow('Soil moisture check', 'Every 3 days with moisture meter'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Pest Network ─────────────────────────────────────────────────────────
class _PestNetwork extends StatelessWidget {
  const _PestNetwork();

  static const _reports = [
    {'pest': 'Pink Bollworm', 'crop': 'Cotton', 'village': 'Karjan', 'severity': 'High', 'daysAgo': '2'},
    {'pest': 'Yellow Rust', 'crop': 'Wheat', 'village': 'Padra', 'severity': 'Medium', 'daysAgo': '4'},
    {'pest': 'Whitefly', 'crop': 'Tomato', 'village': 'Savli', 'severity': 'Low', 'daysAgo': '5'},
    {'pest': 'Aphids', 'crop': 'Cotton', 'village': 'Waghodia', 'severity': 'Medium', 'daysAgo': '7'},
    {'pest': 'Early Blight', 'crop': 'Tomato', 'village': 'Dabhoi', 'severity': 'High', 'daysAgo': '8'},
    {'pest': 'Leaf Spot', 'crop': 'Groundnut', 'village': 'Karjan', 'severity': 'Low', 'daysAgo': '10'},
  ];

  Color _severityColor(String s) {
    switch (s) {
      case 'High': return kCoral;
      case 'Medium': return kSunsetOrange;
      default: return kForestSage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Pest Network',
      accent: kCoral,
      icon: Icons.bug_report_outlined,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: Row(children: [
              const Icon(Icons.location_on_outlined, color: kCoral, size: 16),
              const SizedBox(width: 8),
              const Text('Padra region · 25 km radius',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kCoral.withAlpha(50), borderRadius: BorderRadius.circular(20)),
                child: Text('${_reports.length} active', style: const TextStyle(color: kCoral, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          ..._reports.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _featureGlass(
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _severityColor(r['severity']!).withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.bug_report_outlined, color: _severityColor(r['severity']!), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['pest']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('${r['crop']} · ${r['village']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _severityColor(r['severity']!).withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(r['severity']!,
                            style: TextStyle(color: _severityColor(r['severity']!), fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 4),
                      Text('${r['daysAgo']}d ago', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ── 3. Insurance Advisor ────────────────────────────────────────────────────
class _InsuranceAdvisor extends StatelessWidget {
  const _InsuranceAdvisor();

  static const _schemes = [
    {
      'name': 'PM Fasal Bima Yojana',
      'short': 'PMFBY',
      'crops': 'All notified crops',
      'premium': '2% Kharif · 1.5% Rabi',
      'coverage': 'Yield loss, natural calamities',
      'deadline': 'Last date: 31 July (Kharif)',
      'color': 'ocean',
    },
    {
      'name': 'Restructured Weather Based Crop Insurance',
      'short': 'RWBCIS',
      'crops': 'Horticulture & plantation',
      'premium': '5% for commercial crops',
      'coverage': 'Adverse weather triggers',
      'deadline': 'Last date: 31 August',
      'color': 'sage',
    },
    {
      'name': 'Unified Package Insurance Scheme',
      'short': 'UPIS',
      'crops': 'All crops + assets',
      'premium': 'Bundled with farm loan',
      'coverage': 'Crop + life + assets',
      'deadline': 'At time of KCC loan',
      'color': 'sunset',
    },
  ];

  Color _color(String c) {
    switch (c) {
      case 'ocean': return kOceanTeal;
      case 'sage': return kForestSage;
      default: return kSunsetOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Insurance Advisor',
      accent: kForestSage,
      icon: Icons.shield_outlined,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded, color: kForestSage, size: 16),
                  SizedBox(width: 8),
                  Text('Available Government Schemes',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
                SizedBox(height: 6),
                Text('Subsidised crop insurance for Gujarat farmers. Contact your nearest CSC or bank branch to enroll.',
                    style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._schemes.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _featureGlass(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _color(s['color']!).withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s['short']!, style: TextStyle(color: _color(s['color']!), fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s['name']!,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  _resultRow('Crops', s['crops']!),
                  _resultRow('Premium', s['premium']!),
                  _resultRow('Covers', s['coverage']!),
                  _resultRow('Enroll by', s['deadline']!),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ── 4. Profit Calculator ────────────────────────────────────────────────────
class _ProfitCalculator extends StatefulWidget {
  const _ProfitCalculator();
  @override
  State<_ProfitCalculator> createState() => _ProfitCalculatorState();
}

class _ProfitCalculatorState extends State<_ProfitCalculator> {
  String _crop = 'Cotton';
  double _acres = 2.0;
  double _yieldPerAcre = 6.0; // quintals
  double _pricePerQuintal = 6800;
  double _inputCost = 15000;

  static const _defaults = {
    'Cotton': {'yield': 6.0, 'price': 6800.0, 'cost': 18000.0},
    'Wheat': {'yield': 18.0, 'price': 2200.0, 'cost': 12000.0},
    'Tomato': {'yield': 80.0, 'price': 1200.0, 'cost': 25000.0},
    'Groundnut': {'yield': 10.0, 'price': 5600.0, 'cost': 14000.0},
    'Sugarcane': {'yield': 300.0, 'price': 310.0, 'cost': 35000.0},
  };

  static const _crops = ['Cotton', 'Wheat', 'Tomato', 'Groundnut', 'Sugarcane'];

  @override
  Widget build(BuildContext context) {
    final revenue = _acres * _yieldPerAcre * _pricePerQuintal;
    final totalCost = _acres * _inputCost;
    final profit = revenue - totalCost;
    final roi = totalCost > 0 ? (profit / totalCost * 100) : 0.0;

    return _FeatureShell(
      title: 'Profit Calculator',
      accent: kSunsetOrange,
      icon: Icons.calculate_outlined,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Crop'),
                const SizedBox(height: 8),
                _chipRow(_crops, _crop, (v) {
                  final d = _defaults[v]!;
                  setState(() {
                    _crop = v;
                    _yieldPerAcre = d['yield']!;
                    _pricePerQuintal = d['price']!;
                    _inputCost = d['cost']!;
                  });
                }),
                const SizedBox(height: 14),
                _label('Farm Area: ${_acres.toStringAsFixed(1)} acres'),
                Slider(value: _acres, min: 0.5, max: 20, divisions: 39,
                    activeColor: kSunsetOrange, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _acres = v)),
                _label('Expected Yield: ${_yieldPerAcre.toStringAsFixed(0)} q/acre'),
                Slider(value: _yieldPerAcre, min: 1, max: 500, divisions: 499,
                    activeColor: kSunsetOrange, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _yieldPerAcre = v)),
                _label('Market Price: ₹${_pricePerQuintal.toStringAsFixed(0)}/quintal'),
                Slider(value: _pricePerQuintal, min: 200, max: 20000, divisions: 198,
                    activeColor: kSunsetOrange, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _pricePerQuintal = v)),
                _label('Input Cost: ₹${_inputCost.toStringAsFixed(0)}/acre'),
                Slider(value: _inputCost, min: 1000, max: 100000, divisions: 990,
                    activeColor: kSunsetOrange, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _inputCost = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.bar_chart_rounded, color: kSunsetOrange, size: 18),
                  SizedBox(width: 8),
                  Text('Estimate', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _resultRow('Total Revenue', '₹${revenue.toStringAsFixed(0)}'),
                _resultRow('Total Cost', '₹${totalCost.toStringAsFixed(0)}'),
                const Divider(height: 16, color: Color(0x28FFFFFF)),
                Row(children: [
                  const Expanded(child: Text('Net Profit',
                      style: TextStyle(color: Colors.white70, fontSize: 13))),
                  Text('₹${profit.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: profit >= 0 ? const Color(0xFF4ADE80) : kCoral,
                        fontSize: 16, fontWeight: FontWeight.w800,
                      )),
                ]),
                const SizedBox(height: 4),
                _resultRow('ROI', '${roi.toStringAsFixed(1)}%'),
                _resultRow('Per acre profit', '₹${(profit / _acres).toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 5. Soil Test Booking ────────────────────────────────────────────────────
class _SoilTestBooking extends StatefulWidget {
  const _SoilTestBooking();
  @override
  State<_SoilTestBooking> createState() => _SoilTestBookingState();
}

class _SoilTestBookingState extends State<_SoilTestBooking> {
  String? _lab;
  String? _date;
  bool _booked = false;

  static const _labs = [
    {'name': 'GSAU Soil Lab, Anand', 'dist': '42 km', 'fee': '₹50/sample'},
    {'name': 'ICAR Research Station, Vadodara', 'dist': '18 km', 'fee': '₹80/sample'},
    {'name': 'Padra Agriculture Office', 'dist': '3 km', 'fee': '₹30/sample'},
    {'name': 'Krishi Vigyan Kendra, Karjan', 'dist': '22 km', 'fee': '₹40/sample'},
  ];

  @override
  Widget build(BuildContext context) {
    if (_booked) {
      return _FeatureShell(
        title: 'Soil Test Booking',
        accent: kForestSage,
        icon: Icons.science_outlined,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: kForestSage, size: 72),
              const SizedBox(height: 16),
              const Text('Booking Confirmed!',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('$_lab\nSlot: $_date',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Collect soil from 4 corners + centre (0–20 cm depth). Mix and send 500g.',
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _FeatureShell(
      title: 'Soil Test Booking',
      accent: kForestSage,
      icon: Icons.science_outlined,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Select Lab'),
                const SizedBox(height: 10),
                ..._labs.map((l) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _lab = l['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _lab == l['name'] ? kForestSage.withAlpha(60) : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _lab == l['name'] ? kForestSage : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l['name']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${l['dist']} · ${l['fee']}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (_lab == l['name'])
                            const Icon(Icons.check_circle_rounded, color: kForestSage, size: 20),
                        ],
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                _label('Preferred Date'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: ['Mon 19 May', 'Tue 20 May', 'Wed 21 May', 'Thu 22 May'].map((d) =>
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _date = d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _date == d ? kForestSage.withAlpha(60) : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _date == d ? kForestSage : Colors.white24),
                          ),
                          child: Text(d,
                              style: TextStyle(
                                color: _date == d ? Colors.white : Colors.white60,
                                fontSize: 12, fontWeight: _date == d ? FontWeight.w700 : FontWeight.w500,
                              )),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (_lab != null && _date != null)
                        ? () => setState(() => _booked = true)
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (_lab != null && _date != null)
                              ? kButtonGradient
                              : [Colors.white24, Colors.white24],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Confirm Booking',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 6. Smart Weather Alerts ─────────────────────────────────────────────────
class _WeatherAlerts extends StatefulWidget {
  const _WeatherAlerts();
  @override
  State<_WeatherAlerts> createState() => _WeatherAlertsState();
}

class _WeatherAlertsState extends State<_WeatherAlerts> {
  double _tempHigh = 40;
  double _tempLow = 10;
  double _windSpeed = 50;
  double _rainfall = 20;
  bool _frostAlert = true;
  bool _hailAlert = true;

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Smart Weather Alerts',
      accent: kAmber,
      icon: Icons.notifications_active_outlined,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _featureGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.tune_rounded, color: kAmber, size: 18),
                  SizedBox(width: 8),
                  Text('Alert Thresholds', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                _label('High Temperature: ${_tempHigh.toStringAsFixed(0)}°C'),
                Slider(value: _tempHigh, min: 30, max: 50, divisions: 20,
                    activeColor: kCoral, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _tempHigh = v)),
                _label('Low Temperature: ${_tempLow.toStringAsFixed(0)}°C'),
                Slider(value: _tempLow, min: 0, max: 20, divisions: 20,
                    activeColor: kOceanTeal, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _tempLow = v)),
                _label('Wind Speed: ${_windSpeed.toStringAsFixed(0)} km/h'),
                Slider(value: _windSpeed, min: 20, max: 100, divisions: 16,
                    activeColor: kIndigoGrad, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _windSpeed = v)),
                _label('Heavy Rainfall: ${_rainfall.toStringAsFixed(0)} mm in 24h'),
                Slider(value: _rainfall, min: 5, max: 100, divisions: 19,
                    activeColor: kOceanTeal, inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _rainfall = v)),
                const SizedBox(height: 8),
                _switchRow('Frost Warning (< 4°C)', _frostAlert,
                    (v) => setState(() => _frostAlert = v)),
                _switchRow('Hail Alert', _hailAlert,
                    (v) => setState(() => _hailAlert = v)),
                const SizedBox(height: 14),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alert thresholds saved!'))),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: kButtonGradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Save Alerts',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Switch(value: value, onChanged: onChanged,
              activeThumbColor: kAmber, activeTrackColor: kAmber.withAlpha(80),
              inactiveThumbColor: Colors.white38, inactiveTrackColor: Colors.white24),
        ],
      ),
    );
  }
}

// ── 7. Equipment Rental ─────────────────────────────────────────────────────
class _EquipmentRental extends StatelessWidget {
  const _EquipmentRental();

  static const _equipment = [
    {'name': 'Tractor (45 HP)', 'owner': 'Ramesh Patel', 'village': 'Padra', 'rate': '₹800/hr', 'avail': 'Available', 'icon': 'tractor'},
    {'name': 'Rotavator', 'owner': 'Suresh Farms', 'village': 'Karjan', 'rate': '₹600/hr', 'avail': 'Available', 'icon': 'tool'},
    {'name': 'Combine Harvester', 'owner': 'Desai Agri', 'village': 'Savli', 'rate': '₹2,500/acre', 'avail': 'Booked till 20 May', 'icon': 'harvester'},
    {'name': 'Paddy Transplanter', 'owner': 'KVK Waghodia', 'village': 'Waghodia', 'rate': '₹1,200/acre', 'avail': 'Available', 'icon': 'tool'},
    {'name': 'Power Weeder', 'owner': 'Bhai Rentals', 'village': 'Padra', 'rate': '₹400/day', 'avail': 'Available', 'icon': 'tool'},
    {'name': 'Drone Sprayer', 'owner': 'AgroTech Vadodara', 'village': 'Vadodara', 'rate': '₹600/acre', 'avail': 'Available', 'icon': 'drone'},
  ];

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Equipment Rental',
      accent: kIndigo,
      icon: Icons.agriculture_rounded,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _equipment.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _featureGlass(
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: kIndigo.withAlpha(60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.agriculture_rounded, color: kIndigoGrad, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('${e['owner']} · ${e['village']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.currency_rupee_rounded, color: kAmber, size: 12),
                        Text(e['rate']!, style: const TextStyle(color: kAmber, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: e['avail']!.startsWith('Available')
                            ? kForestSage.withAlpha(60) : kSunsetOrange.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e['avail']!.startsWith('Available') ? 'Free' : 'Busy',
                        style: TextStyle(
                          color: e['avail']!.startsWith('Available') ? kForestSage : kSunsetOrange,
                          fontSize: 10, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${e['owner']}...'))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kAmber.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Contact',
                              style: TextStyle(color: kAmber, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

// ── 8. Mandi Live Auction ───────────────────────────────────────────────────
class _MandiAuction extends StatefulWidget {
  const _MandiAuction();
  @override
  State<_MandiAuction> createState() => _MandiAuctionState();
}

class _MandiAuctionState extends State<_MandiAuction> {
  String _selectedMandi = 'Vadodara APMC';

  static const _mandis = ['Vadodara APMC', 'Padra Mandi', 'Karjan Mandi', 'Savli Mandi'];
  static const _auctions = [
    {'crop': 'Cotton', 'lot': '45 q', 'start': '₹6,200', 'current': '₹6,950', 'time': '10:24 AM', 'status': 'Live'},
    {'crop': 'Chili', 'lot': '20 q', 'start': '₹4,500', 'current': '₹6,400', 'time': '9:45 AM', 'status': 'Closed'},
    {'crop': 'Groundnut', 'lot': '60 q', 'start': '₹5,000', 'current': '₹5,800', 'time': '11:00 AM', 'status': 'Upcoming'},
    {'crop': 'Tomato', 'lot': '30 q', 'start': '₹800', 'current': '₹1,250', 'time': '10:50 AM', 'status': 'Live'},
    {'crop': 'Onion', 'lot': '50 q', 'start': '₹650', 'current': '₹1,100', 'time': '9:20 AM', 'status': 'Closed'},
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'Live': return kCoral;
      case 'Upcoming': return kOceanTeal;
      default: return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Mandi Live Auction',
      accent: kSunsetOrange,
      icon: Icons.gavel_rounded,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _featureGlass(
              child: Row(
                children: [
                  const Icon(Icons.store_outlined, color: kSunsetOrange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedMandi,
                      dropdownColor: const Color(0xFF1A2B3C),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                      isExpanded: true,
                      items: _mandis.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _selectedMandi = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: _auctions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _featureGlass(
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _statusColor(a['status']!).withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.gavel_rounded, color: _statusColor(a['status']!), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['crop']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            Text('Lot: ${a['lot']} · Start: ${a['start']}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(a['current']!,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(a['status']!).withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(a['status']!,
                                style: TextStyle(color: _statusColor(a['status']!), fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 9. Knowledge Reels ──────────────────────────────────────────────────────
class _KnowledgeReels extends StatelessWidget {
  const _KnowledgeReels();

  static const _reels = [
    {'title': 'How to detect pink bollworm early', 'channel': 'KVK Vadodara', 'duration': '3:42', 'views': '12K', 'tag': 'Cotton'},
    {'title': 'Drip irrigation setup for 1 acre', 'channel': 'Jain Irrigation', 'duration': '5:18', 'views': '28K', 'tag': 'Irrigation'},
    {'title': 'Soil health card – how to read it', 'channel': 'ICAR India', 'duration': '4:05', 'views': '8K', 'tag': 'Soil'},
    {'title': 'Vermicompost preparation at home', 'channel': 'Organic India', 'duration': '6:30', 'views': '45K', 'tag': 'Organic'},
    {'title': 'PMFBY claim process step by step', 'channel': 'Govt Gujarat', 'duration': '7:15', 'views': '19K', 'tag': 'Insurance'},
    {'title': 'Wheat sowing: row spacing tips', 'channel': 'GSAU Anand', 'duration': '3:55', 'views': '6K', 'tag': 'Wheat'},
    {'title': 'Using mobile apps to track weather', 'channel': 'ClimaGrowth', 'duration': '2:45', 'views': '3K', 'tag': 'Technology'},
  ];

  static const _tagColors = {
    'Cotton': kOceanTeal, 'Irrigation': kIndigo, 'Soil': kForestSage,
    'Organic': kForestSage, 'Insurance': kSunsetOrange,
    'Wheat': kSunsetOrange, 'Technology': kPlum,
  };

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Knowledge Reels',
      accent: kPlum,
      icon: Icons.play_circle_outline_rounded,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = _reels[i];
          final tagColor = _tagColors[r['tag']] ?? kAmber;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: ${r['title']}'))),
              child: _featureGlass(
                child: Row(
                  children: [
                    Container(
                      width: 72, height: 54,
                      decoration: BoxDecoration(
                        color: kGlassBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.play_circle_filled_rounded, color: tagColor, size: 32)),
                          Positioned(
                            bottom: 4, right: 6,
                            child: Text(r['duration']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['title']!, maxLines: 2,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text(r['channel']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            const Spacer(),
                            const Icon(Icons.visibility_outlined, color: Colors.white38, size: 11),
                            const SizedBox(width: 3),
                            Text(r['views']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ]),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tagColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(r['tag']!, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
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

// ── 10. Crop Comparison ─────────────────────────────────────────────────────
class _CropComparison extends StatefulWidget {
  const _CropComparison();
  @override
  State<_CropComparison> createState() => _CropComparisonState();
}

class _CropComparisonState extends State<_CropComparison> {
  String _cropA = 'Cotton';
  String _cropB = 'Groundnut';

  static const _crops = ['Cotton', 'Wheat', 'Tomato', 'Groundnut', 'Sugarcane', 'Maize', 'Onion', 'Chili'];
  static const _data = {
    'Cotton': {'season': 'Kharif', 'duration': '150–180d', 'yield': '6 q/acre', 'price': '₹6,800/q', 'water': 'Medium', 'difficulty': 'High', 'profit': '₹20,000/acre'},
    'Wheat': {'season': 'Rabi', 'duration': '120–140d', 'yield': '18 q/acre', 'price': '₹2,200/q', 'water': 'Medium', 'difficulty': 'Low', 'profit': '₹15,000/acre'},
    'Tomato': {'season': 'All year', 'duration': '90–120d', 'yield': '80 q/acre', 'price': '₹1,200/q', 'water': 'High', 'difficulty': 'High', 'profit': '₹60,000/acre'},
    'Groundnut': {'season': 'Kharif', 'duration': '110–130d', 'yield': '10 q/acre', 'price': '₹5,600/q', 'water': 'Low–Med', 'difficulty': 'Medium', 'profit': '₹35,000/acre'},
    'Sugarcane': {'season': 'Year-round', 'duration': '10–14 mo', 'yield': '300 q/acre', 'price': '₹310/q', 'water': 'Very High', 'difficulty': 'Medium', 'profit': '₹25,000/acre'},
    'Maize': {'season': 'Kharif', 'duration': '90–110d', 'yield': '20 q/acre', 'price': '₹1,800/q', 'water': 'Medium', 'difficulty': 'Low', 'profit': '₹12,000/acre'},
    'Onion': {'season': 'Rabi', 'duration': '100–120d', 'yield': '60 q/acre', 'price': '₹900/q', 'water': 'Medium', 'difficulty': 'Medium', 'profit': '₹20,000/acre'},
    'Chili': {'season': 'Kharif/Rabi', 'duration': '150–180d', 'yield': '15 q/acre', 'price': '₹5,500/q', 'water': 'Medium', 'difficulty': 'High', 'profit': '₹50,000/acre'},
  };

  static const _attributes = ['season', 'duration', 'yield', 'price', 'water', 'difficulty', 'profit'];
  static const _attrLabels = {
    'season': 'Season', 'duration': 'Duration', 'yield': 'Avg Yield',
    'price': 'Market Price', 'water': 'Water Need', 'difficulty': 'Difficulty', 'profit': 'Est. Profit',
  };
  static const _attrIcons = {
    'season': Icons.wb_sunny_outlined, 'duration': Icons.timelapse_outlined,
    'yield': Icons.grain_rounded, 'price': Icons.currency_rupee_rounded,
    'water': Icons.water_drop_outlined, 'difficulty': Icons.trending_up_rounded,
    'profit': Icons.bar_chart_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final a = _data[_cropA]!;
    final b = _data[_cropB]!;

    return _FeatureShell(
      title: 'Crop Comparison',
      accent: kAmber,
      icon: Icons.compare_arrows_rounded,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Crop pickers
          Row(
            children: [
              Expanded(child: _picker(_cropA, (v) => setState(() => _cropA = v))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('VS', style: TextStyle(color: kAmber, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              Expanded(child: _picker(_cropB, (v) => setState(() => _cropB = v))),
            ],
          ),
          const SizedBox(height: 14),
          // Comparison table
          _featureGlass(
            child: Column(
              children: _attributes.map((attr) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Icon(_attrIcons[attr], color: kAmber, size: 16),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(_attrLabels[attr]!,
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                      Expanded(
                        child: Text(a[attr]!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ),
                      Container(width: 1, height: 16, color: const Color(0x38FFFFFF)),
                      Expanded(
                        child: Text(b[attr]!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _picker(String selected, ValueChanged<String> onChanged) {
    return _featureGlass(
      child: DropdownButton<String>(
        value: selected,
        dropdownColor: const Color(0xFF1A2B3C),
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 18),
        items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────
Widget _featureGlass({required Widget child, double radius = 14, EdgeInsetsGeometry padding = const EdgeInsets.all(14)}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: kGlassSigma, sigmaY: kGlassSigma),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: kGlassColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: kGlassBorder, width: 1),
        ),
        child: child,
      ),
    ),
  );
}

Widget _label(String text) => Text(text,
    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600));

Widget _chipRow(List<String> options, String selected, ValueChanged<String> onSelect) {
  return Row(
    children: options.map((opt) {
      final sel = selected == opt;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: opt != options.last ? 8 : 0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? kAmber : const Color(0x28FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? kAmber : kGlassBorder),
                ),
                child: Center(
                  child: Text(opt,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white60,
                        fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      )),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _resultRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13))),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    ],
  ),
);
