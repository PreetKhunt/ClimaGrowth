import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/dynamic_theme.dart';
import '../utils/constants.dart';

class UIDesignerScreen extends StatefulWidget {
  const UIDesignerScreen({super.key});

  @override
  State<UIDesignerScreen> createState() => _UIDesignerScreenState();
}

class _UIDesignerScreenState extends State<UIDesignerScreen>
    with SingleTickerProviderStateMixin {
  late DynamicThemeData _draft;
  late TabController _tabCtrl;
  bool _initialized = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _draft = const DynamicThemeData();
    _tabCtrl = TabController(length: 6, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _draft = context.read<DynamicThemeProvider>().data;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onChanged(DynamicThemeData d) {
    setState(() {
      _draft = d;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    await context.read<DynamicThemeProvider>().save(_draft);
    setState(() => _dirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design saved and applied across the app'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _applyAndPreview() async {
    context.read<DynamicThemeProvider>().applyLive(_draft);
  }

  Future<void> _reset() async {
    await context.read<DynamicThemeProvider>().reset();
    setState(() {
      _draft = const DynamicThemeData();
      _dirty = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reset to ClimaGrowth default'),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _exportDesign() {
    final json = const JsonEncoder.withIndent('  ').convert(_draft.toJson());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Design JSON copied to clipboard'),
          behavior: SnackBarBehavior.floating),
    );
  }

  void _importDesign() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import Design'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: ctrl,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Paste design JSON here',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              try {
                final data = DynamicThemeData.fromJson(
                    jsonDecode(ctrl.text) as Map<String, dynamic>);
                Navigator.pop(context);
                _onChanged(data);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Invalid JSON – check and try again'),
                      behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  // ── Color picker ────────────────────────────────────────────────────────────
  Future<Color?> _pickColor(Color initial) async {
    return showDialog<Color>(
      context: context,
      builder: (_) => _ColorPickerDialog(initial: initial),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('UI Designer'),
            if (_dirty) ...[
              const SizedBox(width: 6),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: kAmber, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview_rounded),
            tooltip: 'Preview live in app',
            onPressed: _applyAndPreview,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import JSON',
            onPressed: _importDesign,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Export JSON',
            onPressed: _exportDesign,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to default',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Reset to default?'),
                content: const Text('All customizations will be lost.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _reset();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kCoral),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _dirty ? _save : null,
              style: FilledButton.styleFrom(backgroundColor: kAmber),
              child: const Text('Save Design',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPresetStrip(),
          _buildPreview(),
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: kAmber,
              labelColor: kAmber,
              unselectedLabelColor: kTextMuted,
              tabs: const [
                Tab(text: 'Colors'),
                Tab(text: 'Typography'),
                Tab(text: 'Spacing'),
                Tab(text: 'Components'),
                Tab(text: 'Effects'),
                Tab(text: 'Layout'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildColorsTab(),
                _buildTypographyTab(),
                _buildSpacingTab(),
                _buildComponentsTab(),
                _buildEffectsTab(),
                _buildLayoutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Preset strip ────────────────────────────────────────────────────────────
  Widget _buildPresetStrip() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: DynamicThemePresets.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final preset = DynamicThemePresets.all[i];
          return GestureDetector(
            onTap: () => _onChanged(preset.data),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  preset.data.primaryColor,
                  preset.data.secondaryColor,
                ]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                preset.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Live Preview ─────────────────────────────────────────────────────────────
  Widget _buildPreview() {
    final d = _draft;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? d.bgDarkColor : d.bgLightColor;
    final surface = isDark ? const Color(0xFF1C2029) : d.surfaceColor;
    final textColor = isDark ? Colors.white : d.textPrimaryColor;

    return Container(
      height: 210,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // AppBar
            Container(
              height: 38,
              color: bg,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                        color: d.primaryColor, borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                        child: Text('CG',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: 7),
                  Text('ClimaGrowth',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.notifications_outlined, color: textColor, size: 14),
                  const SizedBox(width: 6),
                  CircleAvatar(radius: 10, backgroundColor: d.primaryColor,
                      child: const Text('P', style: TextStyle(color: Colors.white, fontSize: 8))),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white12 : const Color(0x14000000)),
            // Content
            Expanded(
              child: Container(
                color: bg,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Hero card
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [d.primaryColor, d.secondaryColor],
                            begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(d.radius * 0.7),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(children: [
                        const Column(crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Good morning', style: TextStyle(color: Colors.white70, fontSize: 8)),
                              Text('Preet', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                            ]),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(d.buttonBorderRadius * 0.6)),
                          child: const Text('27°C', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    // Module chips
                    Row(children: [
                      _previewChip('W', d.weatherAccent, surface, d.radius),
                      const SizedBox(width: 4),
                      _previewChip('S', d.soilAccent, surface, d.radius),
                      const SizedBox(width: 4),
                      _previewChip('C', d.chatAccent, surface, d.radius),
                      const SizedBox(width: 4),
                      _previewChip('M', d.marketAccent, surface, d.radius),
                    ]),
                    const SizedBox(height: 6),
                    // Button preview
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: d.primaryColor,
                        borderRadius: BorderRadius.circular(d.buttonBorderRadius * 0.7),
                      ),
                      child: const Center(
                          child: Text('Calculate Yield',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom nav
            Container(
              height: 34,
              color: surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navDot(Icons.home_rounded, d.primaryColor),
                  _navDot(Icons.cloud_rounded, kTextMuted),
                  _navDot(Icons.chat_bubble_rounded, kTextMuted),
                  _navDot(Icons.storefront_rounded, kTextMuted),
                  _navDot(Icons.person_rounded, kTextMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewChip(String label, Color accent, Color surface, double radius) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(radius * 0.5),
            border: Border.all(color: accent.withAlpha(60)),
          ),
          child: Column(children: [
            Container(
                width: 14, height: 14,
                decoration:
                    BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 7, color: accent, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _navDot(IconData icon, Color color) =>
      Icon(icon, color: color, size: 16);

  // ── COLORS TAB ───────────────────────────────────────────────────────────────
  Widget _buildColorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Brand'),
        _colorTile('Primary (CTA buttons)', _draft.primaryColor,
            (c) => _onChanged(_draft.copyWith(primaryColor: c))),
        _colorTile('Secondary (links/outline)', _draft.secondaryColor,
            (c) => _onChanged(_draft.copyWith(secondaryColor: c))),
        _sectionHead('Backgrounds'),
        _colorTile('Light mode background', _draft.bgLightColor,
            (c) => _onChanged(_draft.copyWith(bgLightColor: c))),
        _colorTile('Dark mode background', _draft.bgDarkColor,
            (c) => _onChanged(_draft.copyWith(bgDarkColor: c))),
        _colorTile('Surface / Cards', _draft.surfaceColor,
            (c) => _onChanged(_draft.copyWith(surfaceColor: c))),
        _sectionHead('Text'),
        _colorTile('Text primary', _draft.textPrimaryColor,
            (c) => _onChanged(_draft.copyWith(textPrimaryColor: c))),
        _colorTile('Text secondary / muted', _draft.textSecondaryColor,
            (c) => _onChanged(_draft.copyWith(textSecondaryColor: c))),
        _colorTile('Border / divider', _draft.borderColor,
            (c) => _onChanged(_draft.copyWith(borderColor: c))),
        _sectionHead('Module Accents'),
        _colorTile('Weather  (sky blue)', _draft.weatherAccent,
            (c) => _onChanged(_draft.copyWith(weatherAccent: c))),
        _colorTile('Soil  (sage green)', _draft.soilAccent,
            (c) => _onChanged(_draft.copyWith(soilAccent: c))),
        _colorTile('Chat  (soft plum)', _draft.chatAccent,
            (c) => _onChanged(_draft.copyWith(chatAccent: c))),
        _colorTile('Market  (mustard gold)', _draft.marketAccent,
            (c) => _onChanged(_draft.copyWith(marketAccent: c))),
      ],
    );
  }

  Widget _colorTile(String label, Color color, void Function(Color) onPick) {
    return ListTile(
      dense: true,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: GestureDetector(
        onTap: () async {
          final c = await _pickColor(color);
          if (c != null) onPick(c);
        },
        child: Container(
          width: 44, height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12, width: 1.5),
          ),
          child: const Center(
              child: Icon(Icons.colorize_rounded, size: 14, color: Colors.white70)),
        ),
      ),
    );
  }

  // ── TYPOGRAPHY TAB ───────────────────────────────────────────────────────────
  Widget _buildTypographyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Font Families'),
        _dropRow('Display font', _draft.displayFont,
            ['Plus Jakarta Sans', 'Manrope', 'Sora', 'Outfit', 'Inter', 'DM Sans'],
            (v) => _onChanged(_draft.copyWith(displayFont: v!))),
        _dropRow('Body font', _draft.bodyFont,
            ['DM Sans', 'Inter', 'Manrope', 'Nunito Sans', 'Plus Jakarta Sans'],
            (v) => _onChanged(_draft.copyWith(bodyFont: v!))),
        _sectionHead('Heading Weight'),
        _radioRow(['400', '500', '600', '700', '800', '900'],
            _draft.headingWeightVal.toString(),
            (v) => _onChanged(_draft.copyWith(headingWeightVal: int.parse(v)))),
        _sectionHead('Font Sizes'),
        _sliderRow('H1 (display)', _draft.h1Size, 24, 48, 24,
            (v) => _onChanged(_draft.copyWith(h1Size: v))),
        _sliderRow('H2 (headline)', _draft.h2Size, 20, 36, 16,
            (v) => _onChanged(_draft.copyWith(h2Size: v))),
        _sliderRow('H3 (title)', _draft.h3Size, 14, 28, 14,
            (v) => _onChanged(_draft.copyWith(h3Size: v))),
        _sliderRow('Body', _draft.bodySize, 12, 18, 6,
            (v) => _onChanged(_draft.copyWith(bodySize: v))),
        _sliderRow('Caption', _draft.captionSize, 10, 14, 4,
            (v) => _onChanged(_draft.copyWith(captionSize: v))),
        _sectionHead('Spacing'),
        _sliderRow('Letter spacing', _draft.letterSpacingVal, -2, 4, 12,
            (v) => _onChanged(_draft.copyWith(letterSpacingVal: v))),
        _sliderRow('Line height', _draft.lineHeightVal, 1.0, 2.0, 20,
            (v) => _onChanged(_draft.copyWith(lineHeightVal: v))),
      ],
    );
  }

  // ── SPACING TAB ──────────────────────────────────────────────────────────────
  Widget _buildSpacingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Padding Scale'),
        _chipRow(
            ['compact (8px)', 'normal (16px)', 'comfortable (20px)', 'spacious (28px)'],
            ['compact', 'normal', 'comfortable', 'spacious'],
            _draft.paddingScale,
            (v) => _onChanged(_draft.copyWith(paddingScale: v))),
        _sectionHead('Border Radius'),
        _chipRow(
            ['sharp (0px)', 'soft (8px)', 'rounded (16px)', 'pill (100px)'],
            ['sharp', 'soft', 'rounded', 'pill'],
            _draft.borderRadiusScale,
            (v) => _onChanged(_draft.copyWith(borderRadiusScale: v))),
        _sectionHead('Card Elevation'),
        _chipRow(
            ['flat', 'subtle', 'raised', 'floating'],
            ['flat', 'subtle', 'raised', 'floating'],
            _draft.cardElevationLevel,
            (v) => _onChanged(_draft.copyWith(cardElevationLevel: v))),
      ],
    );
  }

  // ── COMPONENTS TAB ───────────────────────────────────────────────────────────
  Widget _buildComponentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Button Style'),
        _chipRow(
            ['Solid', 'Outlined', 'Ghost', 'Gradient', 'Glass'],
            ['solid', 'outlined', 'ghost', 'gradient', 'glass'],
            _draft.buttonStyle,
            (v) => _onChanged(_draft.copyWith(buttonStyle: v))),
        _sectionHead('Button Shape'),
        _chipRow(
            ['Rounded', 'Pill', 'Sharp'],
            ['rounded', 'pill', 'sharp'],
            _draft.buttonShape,
            (v) => _onChanged(_draft.copyWith(buttonShape: v))),
        _sectionHead('Button Size'),
        _chipRow(
            ['Small (32px)', 'Medium (44px)', 'Large (52px)'],
            ['small', 'medium', 'large'],
            _draft.buttonSize,
            (v) => _onChanged(_draft.copyWith(buttonSize: v))),
        const SizedBox(height: 12),
        _buttonPreview(),
        _sectionHead('Card Style'),
        _chipRow(
            ['Flat', 'Bordered', 'Elevated', 'Glass', 'Gradient'],
            ['flat', 'bordered', 'elevated', 'glass', 'gradient'],
            _draft.cardStyle,
            (v) => _onChanged(_draft.copyWith(cardStyle: v))),
        _sectionHead('Input Field Style'),
        _chipRow(
            ['Outlined', 'Filled', 'Underline', 'Floating label'],
            ['outlined', 'filled', 'underline', 'floating'],
            _draft.inputStyle,
            (v) => _onChanged(_draft.copyWith(inputStyle: v))),
      ],
    );
  }

  Widget _buttonPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Button preview', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: _draft.buttonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _draft.buttonStyle == 'outlined' ||
                        _draft.buttonStyle == 'ghost'
                    ? Colors.transparent
                    : _draft.primaryColor,
                foregroundColor: _draft.buttonStyle == 'outlined' ||
                        _draft.buttonStyle == 'ghost'
                    ? _draft.primaryColor
                    : Colors.white,
                side: _draft.buttonStyle == 'outlined'
                    ? BorderSide(color: _draft.primaryColor, width: 1.5)
                    : BorderSide.none,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_draft.buttonBorderRadius)),
              ),
              onPressed: () {},
              child: const Text('Calculate Yield'),
            ),
          ),
        ],
      ),
    );
  }

  // ── EFFECTS TAB ──────────────────────────────────────────────────────────────
  Widget _buildEffectsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Animation Speed'),
        _chipRow(
            ['Instant', 'Fast (200ms)', 'Normal (400ms)', 'Slow (800ms)'],
            ['instant', 'fast', 'normal', 'slow'],
            _draft.animationSpeed,
            (v) => _onChanged(_draft.copyWith(animationSpeed: v))),
        _sectionHead('Page Transition'),
        _chipRow(
            ['Fade', 'Slide →', 'Slide ↑', 'Scale'],
            ['fade', 'slide_h', 'slide_v', 'scale'],
            _draft.pageTransitionStyle,
            (v) => _onChanged(_draft.copyWith(pageTransitionStyle: v))),
        _sectionHead('Background Style'),
        _chipRow(
            ['Solid', 'Gradient', 'Ambient mesh'],
            ['solid', 'gradient', 'mesh'],
            _draft.bgStyle,
            (v) => _onChanged(_draft.copyWith(bgStyle: v))),
        _sectionHead('Glassmorphism'),
        _sliderRow('Blur sigma', _draft.glassSigmaVal, 0, 30, 30,
            (v) => _onChanged(_draft.copyWith(glassSigmaVal: v))),
      ],
    );
  }

  // ── LAYOUT TAB ───────────────────────────────────────────────────────────────
  Widget _buildLayoutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Bottom Navigation Style'),
        _chipRow(
            ['Standard', 'Floating pill', 'Glass', 'Minimalist'],
            ['standard', 'floating', 'glass', 'minimalist'],
            _draft.navStyle,
            (v) => _onChanged(_draft.copyWith(navStyle: v))),
        _sectionHead('Home Screen Layout'),
        _chipRow(
            ['Grid 2-col', 'Grid 3-col', 'List', 'Dashboard'],
            ['grid_2', 'grid_3', 'list', 'dashboard'],
            _draft.homeLayout,
            (v) => _onChanged(_draft.copyWith(homeLayout: v))),
        _sectionHead('Quick Action Card Style'),
        _chipRow(
            ['Square', 'Rectangle', 'Banner', 'Pill'],
            ['square', 'rectangle', 'banner', 'pill'],
            _draft.quickActionStyle,
            (v) => _onChanged(_draft.copyWith(quickActionStyle: v))),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionHead(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kAmber,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
        ),
      );

  Widget _sliderRow(String label, double val, double min, double max, int divs,
      ValueChanged<double> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(val.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall),
        ]),
        Slider(
          value: val, min: min, max: max, divisions: divs,
          activeColor: kAmber, onChanged: onChange,
        ),
      ],
    );
  }

  Widget _dropRow(String label, String val, List<String> opts,
      ValueChanged<String?> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        DropdownButton<String>(
          value: val,
          underline: const SizedBox(),
          items: opts
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500))))
              .toList(),
          onChanged: onChange,
        ),
      ]),
    );
  }

  Widget _radioRow(List<String> labels, String current, ValueChanged<String> onChange) {
    return Wrap(
      spacing: 6,
      children: labels.map((l) {
        final sel = l == current;
        return GestureDetector(
          onTap: () => onChange(l),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? kAmber : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? kAmber : kBorder),
            ),
            child: Text(l,
                style: TextStyle(
                    fontSize: 12,
                    color: sel ? Colors.white : null,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
          ),
        );
      }).toList(),
    );
  }

  Widget _chipRow(List<String> labels, List<String> values, String current,
      ValueChanged<String> onChange) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: List.generate(labels.length, (i) {
        final sel = values[i] == current;
        return GestureDetector(
          onTap: () => onChange(values[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? kAmber : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? kAmber : kBorder),
            ),
            child: Text(labels[i],
                style: TextStyle(
                    fontSize: 12,
                    color: sel ? Colors.white : null,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
          ),
        );
      }),
    );
  }
}

// ─── Color Picker Dialog ──────────────────────────────────────────────────────
class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selected;
  late TextEditingController _hexCtrl;
  String? _hexErr;

  static const List<Color> _swatches = [
    // ClimaGrowth palette
    Color(0xFFE55934), Color(0xFF1E3A5F), Color(0xFF4A90C2),
    Color(0xFF6B8E5A), Color(0xFF8E5572), Color(0xFFD4A017),
    // Warm tones
    Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFCC02),
    Color(0xFFFF5722), Color(0xFFE91E63), Color(0xFF9C27B0),
    // Cool tones
    Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFF1ABC9C),
    Color(0xFF00BCD4), Color(0xFF673AB7), Color(0xFF5C6BC0),
    // Neutrals
    Color(0xFF1A1A1A), Color(0xFF757575),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _hexCtrl = TextEditingController(text: _toHex(widget.initial));
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    super.dispose();
  }

  String _toHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Color? _fromHex(String hex) {
    hex = hex.replaceAll('#', '').trim();
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final v = int.tryParse(hex, radix: 16);
    return v != null ? Color(v) : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Color'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current color preview
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 44,
              decoration: BoxDecoration(
                  color: _selected,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12)),
            ),
            const SizedBox(height: 12),
            // Hex input
            TextField(
              controller: _hexCtrl,
              decoration: InputDecoration(
                labelText: 'Hex Color',
                hintText: '#E55934',
                errorText: _hexErr,
                prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) {
                final c = _fromHex(v);
                if (c != null) {
                  setState(() { _selected = c; _hexErr = null; });
                } else {
                  setState(() => _hexErr = v.length > 2 ? 'Invalid hex' : null);
                }
              },
            ),
            const SizedBox(height: 12),
            // Swatches grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _swatches.map((c) {
                final isSel = _selected.toARGB32() == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() {
                    _selected = c;
                    _hexCtrl.text = _toHex(c);
                    _hexErr = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isSel ? Colors.black54 : Colors.black12,
                          width: isSel ? 2.5 : 1),
                      boxShadow: isSel
                          ? [BoxShadow(color: c.withAlpha(100), blurRadius: 6, spreadRadius: 1)]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kAmber),
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
