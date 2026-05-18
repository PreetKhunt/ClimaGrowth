import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

// ── Data model ─────────────────────────────────────────────────────────────
class _CropGuide {
  final String name;
  final String season;
  final String duration;
  final String photoUrl;
  final Color accent;
  final List<_Phase> phases;
  final List<String> idealSoils;
  final String waterNeed;
  const _CropGuide({
    required this.name, required this.season, required this.duration,
    required this.photoUrl, required this.accent, required this.phases,
    required this.idealSoils, required this.waterNeed,
  });
}

class _Phase {
  final String name;
  final String duration;
  final String description;
  final List<String> tasks;
  const _Phase({required this.name, required this.duration,
      required this.description, required this.tasks});
}

const _guides = [
  _CropGuide(
    name: 'Cotton', season: 'Kharif (Jun–Oct)', duration: '150–180 days',
    photoUrl: 'https://images.unsplash.com/photo-1591289009723-aef022138689?w=600',
    accent: Color(0xFF4A90C2), idealSoils: ['Black Cotton Soil', 'Loamy'], waterNeed: 'Medium',
    phases: [
      _Phase(name: 'Land Preparation', duration: '2–3 weeks before sowing',
          description: 'Deep ploughing and formation of ridges & furrows.',
          tasks: ['Deep plough 30–45 cm', 'Apply FYM 10 t/ha', 'Level the field', 'Form 60 cm ridges']),
      _Phase(name: 'Sowing', duration: 'June – July',
          description: 'Sow BT hybrid seeds after first monsoon showers.',
          tasks: ['Seed rate: 450 g/acre', 'Spacing: 90×60 cm', 'Seed treatment with Thiram', 'Sow at 3–4 cm depth']),
      _Phase(name: 'Vegetative Growth', duration: 'Weeks 4–8',
          description: 'Rapid leaf and stem growth; critical for canopy.',
          tasks: ['Top-dress Urea 25 kg/acre', 'First irrigation if no rain', 'Spray Profenofos for bollworm', 'Remove suckers if needed']),
      _Phase(name: 'Flowering & Boll', duration: 'Weeks 8–16',
          description: 'Flowers appear; boll setting determines yield.',
          tasks: ['Apply DAP 12 kg/acre', 'Spray Imidacloprid for whitefly', 'Withhold water 2 wks after boll set', 'Check for pink bollworm']),
      _Phase(name: 'Harvest', duration: 'October – November',
          description: 'Pick when 60%+ bolls are open; 2–3 pickings.',
          tasks: ['First picking at 60% boll opening', 'Store in dry gunny bags', 'Check moisture < 10%', 'Sell at APMC for best price']),
    ],
  ),
  _CropGuide(
    name: 'Wheat', season: 'Rabi (Nov–Mar)', duration: '120–140 days',
    photoUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600',
    accent: Color(0xFFD4A017), idealSoils: ['Loamy', 'Clay Loam'], waterNeed: 'Medium',
    phases: [
      _Phase(name: 'Land Preparation', duration: 'October',
          description: 'Fine seedbed to ensure uniform germination.',
          tasks: ['2–3 ploughings', 'Apply FYM 4–5 t/acre', 'Planking for levelling', 'Apply Zinc Sulphate if deficient']),
      _Phase(name: 'Sowing', duration: 'Nov 1–20',
          description: 'Timely sowing gives best yields; avoid late sowing.',
          tasks: ['Seed rate: 40–45 kg/acre', 'Row spacing: 20–22 cm', 'Seed treat with Carbendazim', 'Sow 5–6 cm deep']),
      _Phase(name: 'Tillering', duration: 'Weeks 3–6',
          description: 'Secondary shoots emerge; nutrients critical.',
          tasks: ['Irrigate at 20–21 DAS', 'Top-dress Urea 25 kg/acre', 'Apply 2,4-D for weeds', 'Watch for yellow rust']),
      _Phase(name: 'Heading', duration: 'Weeks 8–14',
          description: 'Grain filling stage; protect from aphids.',
          tasks: ['Irrigate at flag leaf stage', 'Spray Mancozeb for rust', 'Spray Acephate for aphids', 'Final Urea @ 15 kg/acre']),
      _Phase(name: 'Harvest', duration: 'March',
          description: 'Harvest at golden-yellow stage; thresh immediately.',
          tasks: ['Harvest at 20–25% moisture', 'Use combine harvester if > 2 acres', 'Sun-dry to < 12% moisture', 'Store in moisture-proof bags']),
    ],
  ),
  _CropGuide(
    name: 'Tomato', season: 'All Season', duration: '90–120 days',
    photoUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600',
    accent: Color(0xFFE55934), idealSoils: ['Sandy Loam', 'Loamy'], waterNeed: 'High',
    phases: [
      _Phase(name: 'Nursery', duration: '25–30 days',
          description: 'Raise seedlings in nursery beds or pro-trays.',
          tasks: ['Treat soil with Formalin', 'Sow 150–200 g seed/acre', 'Irrigate lightly twice daily', 'Apply DAP as starter dose']),
      _Phase(name: 'Transplanting', duration: 'Seedling age 25 days',
          description: 'Transplant in evening or on cloudy day.',
          tasks: ['Spacing: 60×45 cm', 'Apply Trichoderma at transplant', 'First irrigation immediately', 'Install stakes after 2 weeks']),
      _Phase(name: 'Vegetative', duration: 'Weeks 2–5',
          description: 'Rapid growth; establish strong plant frame.',
          tasks: ['Fertigate NPK 20:20:0 twice/week', 'Spray Mancozeb for early blight', 'Drip irrigation 4–6 L/plant/day', 'Pinch suckers below 2nd truss']),
      _Phase(name: 'Flowering & Fruiting', duration: 'Weeks 5–10',
          description: 'Most critical phase for yield and quality.',
          tasks: ['Fertigate K2O 50 kg/ha', 'Spray Borax 0.5% for fruit set', 'Control Tuta absoluta with pheromone traps', 'Remove diseased fruits']),
      _Phase(name: 'Harvest', duration: 'Weeks 10–16',
          description: 'Harvest at breaker stage for distant markets.',
          tasks: ['Pick at breaker (pink) stage', 'Grade into A/B/C categories', 'Pre-cool in shade', 'Send to Padra Mandi early morning']),
    ],
  ),
  _CropGuide(
    name: 'Groundnut', season: 'Kharif (Jun–Oct)', duration: '110–130 days',
    photoUrl: 'https://images.unsplash.com/photo-1567892737950-30c4db37cd89?w=600',
    accent: Color(0xFF6B8E5A), idealSoils: ['Sandy Loam', 'Red Sandy'], waterNeed: 'Low–Medium',
    phases: [
      _Phase(name: 'Land Preparation', duration: 'May–June',
          description: 'Light sandy soils needed for pod penetration.',
          tasks: ['Plough 20–25 cm deep', 'Apply Gypsum 200 kg/acre', 'Ensure good drainage', 'Apply FYM 4 t/acre']),
      _Phase(name: 'Sowing', duration: 'June 15 – July 15',
          description: 'Sow after 50–60 mm monsoon rain.',
          tasks: ['Seed rate: 50 kg/acre (GJG-31)', 'Shell pods just before sowing', 'Treat with Rhizobium + Trichoderma', 'Sow 4–5 cm deep, 30×10 cm']),
      _Phase(name: 'Pegging', duration: 'Weeks 4–6',
          description: 'Gynophores enter soil to form pods.',
          tasks: ['Light earthing up at pegging', 'Apply Gypsum 100 kg/acre around plants', 'Spray Carbendazim for tikka disease', 'Irrigate if no rain > 12 days']),
      _Phase(name: 'Pod Filling', duration: 'Weeks 7–14',
          description: 'Pods swell; critical water stage.',
          tasks: ['Irrigate at 10-day intervals', 'Spray Mancozeb for late leaf spot', 'Avoid waterlogging', 'Apply potash as foliar spray']),
      _Phase(name: 'Harvest', duration: 'October',
          description: 'Harvest when inner pod wall shows dark marks.',
          tasks: ['Test harvest 5–10 plants first', 'Dig with blade harrow or manually', 'Windrow and sun-dry 4–5 days', 'Thresh, clean and store at < 8% moisture']),
    ],
  ),
  _CropGuide(
    name: 'Sugarcane', season: 'Year-round', duration: '10–14 months',
    photoUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
    accent: Color(0xFF8E5572), idealSoils: ['Loamy', 'Clay Loam', 'Black Cotton'], waterNeed: 'Very High',
    phases: [
      _Phase(name: 'Planting', duration: 'October–February',
          description: 'Setts planted in furrows; October plant preferred.',
          tasks: ['Sett size: 2–3 buds, 25–30 cm', 'Apply FYM 10 t/acre at planting', 'Treat with Carbendazim', 'Furrow spacing: 90–120 cm']),
      _Phase(name: 'Tillering', duration: 'Months 2–4',
          description: 'Side shoots emerge to form the final stand.',
          tasks: ['Gap filling at 30 DAS', 'Apply Urea 25 kg/acre at 45 DAS', 'Spray Atrazine for weed control', 'Earthing up after first top dressing']),
      _Phase(name: 'Grand Growth', duration: 'Months 4–9',
          description: 'Rapid height gain; 80% of yield formed here.',
          tasks: ['Irrigate every 7–10 days in summer', 'Apply DAP + MOP 25 kg/acre each', 'Propping/tying for lodging prevention', 'Control early shoot borer with Chlorpyrifos']),
      _Phase(name: 'Maturation', duration: 'Months 9–12',
          description: 'Sugar accumulation; withhold irrigation.',
          tasks: ['Stop irrigation 4 weeks before harvest', 'Test Brix value (target > 18)', 'Trash mulching to prevent regrowth', 'Book transport in advance']),
      _Phase(name: 'Harvest', duration: '10–14 months after planting',
          description: 'Manual or mechanical cutting at ground level.',
          tasks: ['Cut at ground level for good ratoon', 'Deliver to sugar mill within 24 hours', 'Remove dry leaves (trashing)', 'Apply Urea to ratoon immediately']),
    ],
  ),
];

// ── Wizard data ────────────────────────────────────────────────────────────
const _wizardRecommendations = {
  'kharif|black|rain': ['Cotton', 'Soybean', 'Pigeon Pea'],
  'kharif|black|irrigation': ['Cotton', 'Soybean', 'Groundnut'],
  'kharif|sandy|rain': ['Groundnut', 'Pearl Millet', 'Green Gram'],
  'kharif|sandy|irrigation': ['Groundnut', 'Maize', 'Sesame'],
  'kharif|loam|rain': ['Maize', 'Soybean', 'Cotton'],
  'kharif|loam|irrigation': ['Sugarcane', 'Cotton', 'Maize'],
  'rabi|black|rain': ['Wheat', 'Gram', 'Mustard'],
  'rabi|black|irrigation': ['Wheat', 'Gram', 'Sugarcane'],
  'rabi|sandy|rain': ['Mustard', 'Pearl Millet', 'Gram'],
  'rabi|sandy|irrigation': ['Wheat', 'Mustard', 'Potato'],
  'rabi|loam|rain': ['Wheat', 'Mustard', 'Gram'],
  'rabi|loam|irrigation': ['Wheat', 'Tomato', 'Onion'],
  'summer|black|irrigation': ['Tomato', 'Okra', 'Brinjal'],
  'summer|sandy|irrigation': ['Groundnut', 'Watermelon', 'Cucumber'],
  'summer|loam|irrigation': ['Tomato', 'Capsicum', 'Okra'],
};

// ── Screen ──────────────────────────────────────────────────────────────────
class GuidanceScreen extends StatefulWidget {
  const GuidanceScreen({super.key});

  @override
  State<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Widget _glass({required Widget child, double radius = 16, EdgeInsetsGeometry? padding}) {
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
                      const Expanded(
                        child: Text('Crop Guidance',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _glass(
                    radius: 14,
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kAmber),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      tabs: const [Tab(text: 'Crop Guides'), Tab(text: 'Crop Wizard')],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [_buildGuidesTab(), _buildWizardTab()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Crop Guides ─────────────────────────────────────────────────────
  Widget _buildGuidesTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _guides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CropCard(guide: _guides[i]),
    );
  }

  // ── Tab 2: Crop Wizard ─────────────────────────────────────────────────────
  Widget _buildWizardTab() => _CropWizard(glass: _glass);
}

// ── Crop Guide Card ─────────────────────────────────────────────────────────
class _CropCard extends StatelessWidget {
  final _CropGuide guide;
  const _CropCard({required this.guide});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _openDetail(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kGlassBorder, width: 1),
              ),
              child: Row(
                children: [
                  // Photo
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                    child: CachedNetworkImage(
                      imageUrl: guide.photoUrl, width: 110, height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Info
                  Expanded(
                    child: Container(
                      color: kGlassColor,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(guide.name,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.calendar_today_outlined, color: guide.accent, size: 12),
                            const SizedBox(width: 4),
                            Text(guide.season,
                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.timelapse_outlined, color: guide.accent, size: 12),
                            const SizedBox(width: 4),
                            Text(guide.duration,
                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ]),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: guide.accent.withAlpha(60),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: guide.accent.withAlpha(100)),
                            ),
                            child: Text('${guide.phases.length} phases',
                                style: TextStyle(color: guide.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: kGlassColor,
                    padding: const EdgeInsets.only(right: 12),
                    child: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CropDetailScreen(guide: guide)),
    );
  }
}

// ── Crop Detail Screen ──────────────────────────────────────────────────────
class _CropDetailScreen extends StatelessWidget {
  final _CropGuide guide;
  const _CropDetailScreen({required this.guide});

  Widget _glass({required Widget child, double radius = 16, EdgeInsetsGeometry? padding}) {
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
          CachedNetworkImage(imageUrl: guide.photoUrl, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
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
                      Text(guide.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      // Info pills
                      _glass(
                        radius: 14,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            _infoPill(Icons.wb_sunny_outlined, guide.season, guide.accent),
                            const SizedBox(width: 8),
                            _infoPill(Icons.timelapse_outlined, guide.duration, guide.accent),
                            const SizedBox(width: 8),
                            _infoPill(Icons.water_drop_outlined, '${guide.waterNeed} Water', guide.accent),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Ideal soils
                      _glass(
                        radius: 14,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.landscape_outlined, color: kAmber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Best soils: ${guide.idealSoils.join(', ')}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 10),
                        child: Text('GROWING PHASES',
                            style: TextStyle(color: Colors.white54, fontSize: 11,
                                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      ),
                      ...guide.phases.asMap().entries.map((e) =>
                          _PhaseCard(phase: e.value, index: e.key, accent: guide.accent)),
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

  Widget _infoPill(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatefulWidget {
  final _Phase phase;
  final int index;
  final Color accent;
  const _PhaseCard({required this.phase, required this.index, required this.accent});

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: kGlassColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGlassBorder, width: 1),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: widget.accent.withAlpha(60),
                              shape: BoxShape.circle,
                              border: Border.all(color: widget.accent.withAlpha(120)),
                            ),
                            child: Center(
                              child: Text('${widget.index + 1}',
                                  style: TextStyle(color: widget.accent,
                                      fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.phase.name,
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(widget.phase.duration,
                                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white54, size: 20,
                          ),
                        ],
                      ),
                      if (_expanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0x28FFFFFF)),
                        const SizedBox(height: 12),
                        Text(widget.phase.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                        const SizedBox(height: 10),
                        ...widget.phase.tasks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  color: widget.accent, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(t, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.index * 80)).slideY(begin: 0.08);
  }
}

// ── Crop Wizard ─────────────────────────────────────────────────────────────
class _CropWizard extends StatefulWidget {
  final Widget Function({required Widget child, double radius, EdgeInsetsGeometry? padding}) glass;
  const _CropWizard({required this.glass});

  @override
  State<_CropWizard> createState() => _CropWizardState();
}

class _CropWizardState extends State<_CropWizard> {
  String? _season;
  String? _soil;
  String? _water;
  bool _showResult = false;

  List<String> get _recommendations {
    if (_season == null || _soil == null || _water == null) return [];
    final key = '${_season!.toLowerCase()}|${_soil!.toLowerCase()}|${_water!.toLowerCase()}';
    return _wizardRecommendations[key] ?? ['Cotton', 'Wheat', 'Groundnut'];
  }

  void _reset() => setState(() {
        _season = null; _soil = null; _water = null; _showResult = false;
      });

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        widget.glass(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: kAmber, size: 20),
                  SizedBox(width: 8),
                  Text('Crop Wizard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Answer 3 questions to get personalised crop recommendations.',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 20),
              _question('Which season are you planting for?',
                  ['Kharif', 'Rabi', 'Summer'], _season,
                  (v) => setState(() => _season = v)),
              const SizedBox(height: 16),
              _question('What is your soil type?',
                  ['Black', 'Sandy', 'Loam'], _soil,
                  (v) => setState(() => _soil = v)),
              const SizedBox(height: 16),
              _question('Water availability?',
                  ['Rain', 'Irrigation'], _water,
                  (v) => setState(() => _water = v)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (_season != null && _soil != null && _water != null)
                        ? () => setState(() => _showResult = true)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (_season != null && _soil != null && _water != null)
                              ? kButtonGradient
                              : [Colors.white24, Colors.white24],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Get Recommendations',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _question(String label, List<String> options, String? selected, ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? kAmber : const Color(0x28FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? kAmber : kGlassBorder),
                      ),
                      child: Center(
                        child: Text(opt,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.white70,
                              fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final recs = _recommendations;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        widget.glass(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: kForestSage, size: 20),
                  SizedBox(width: 8),
                  Text('Recommended Crops', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Based on: $_season season · $_soil soil · $_water',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 16),
              ...recs.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: kAmber.withAlpha(60),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(color: kAmber, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.value,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.star_rounded, color: kAmber, size: 16),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _reset,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x28FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: const Center(
                      child: Text('Start Over', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
