import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/market_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _selectedTab = 0;

  // Mock data
  static const _mockUsers = [
    {'name': 'Ramesh Patel', 'village': 'Padra', 'farm': '4.5 ac', 'joined': '12 Jan 2026'},
    {'name': 'Suresh Desai', 'village': 'Karjan', 'farm': '8.0 ac', 'joined': '5 Feb 2026'},
    {'name': 'Dinesh Bhai', 'village': 'Savli', 'farm': '2.5 ac', 'joined': '20 Feb 2026'},
    {'name': 'Kantaben Shah', 'village': 'Waghodia', 'farm': '6.0 ac', 'joined': '8 Mar 2026'},
    {'name': 'Jitendra Parmar', 'village': 'Dabhoi', 'farm': '12.0 ac', 'joined': '15 Mar 2026'},
    {'name': 'Maniben Rathod', 'village': 'Padra', 'farm': '1.5 ac', 'joined': '2 Apr 2026'},
  ];

  static const _mockOrders = [
    {'id': 'CG-2048', 'user': 'Ramesh Patel', 'items': 'Urea 50kg × 2', 'total': '₹640', 'status': 'Delivered', 'date': '12 May'},
    {'id': 'CG-2047', 'user': 'Suresh Desai', 'items': 'Battery Sprayer 16L × 1', 'total': '₹3,200', 'status': 'In Transit', 'date': '10 May'},
    {'id': 'CG-2046', 'user': 'Dinesh Bhai', 'items': 'Drip Kit 1 Acre × 1', 'total': '₹18,500', 'status': 'Processing', 'date': '8 May'},
    {'id': 'CG-2045', 'user': 'Kantaben Shah', 'items': 'BT Cotton Seed × 3', 'total': '₹2,190', 'status': 'Delivered', 'date': '5 May'},
    {'id': 'CG-2044', 'user': 'Jitendra Parmar', 'items': 'NPK 50kg × 4', 'total': '₹5,800', 'status': 'Delivered', 'date': '2 May'},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() => setState(() => _selectedTab = _tabs.index));
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
          CachedNetworkImage(imageUrl: kPhotoSchemes, fit: BoxFit.cover),
          Container(color: const Color(0xCC000000)),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: kAmber, size: 24),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Admin Dashboard',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                            Text('ClimaGrowth · Padra, Gujarat',
                                style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                          child: _glass(
                            radius: 18,
                            child: const SizedBox(width: 36, height: 36,
                                child: Center(child: Icon(Icons.logout_rounded, color: Colors.white60, size: 18))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // TabBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _glass(
                    radius: 12,
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kAmber),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(text: 'Overview'), Tab(text: 'Users'),
                        Tab(text: 'Products'), Tab(text: 'Orders'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildOverview(),
                      _buildUsers(),
                      _buildProducts(),
                      _buildOrders(),
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

  // ── Overview ───────────────────────────────────────────────────────────────
  Widget _buildOverview() {
    final totalRevenue = _mockOrders.fold<int>(0, (sum, o) {
      final clean = (o['total'] as String).replaceAll(RegExp(r'[₹,]'), '');
      return sum + (int.tryParse(clean) ?? 0);
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Stat grid
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 1.8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: [
            _statCard('${_mockUsers.length}', 'Farmers', Icons.people_outline_rounded, kOceanTeal),
            _statCard('${MarketData.allProducts.length}', 'Products', Icons.inventory_2_outlined, kForestSage),
            _statCard('${_mockOrders.length}', 'Orders', Icons.receipt_long_outlined, kSunsetOrange),
            _statCard('₹${(totalRevenue / 1000).toStringAsFixed(1)}k', 'Revenue', Icons.currency_rupee_rounded, kAmber),
          ],
        ),
        const SizedBox(height: 16),
        // Recent activity
        _sectionLabel('RECENT ORDERS'),
        _glass(
          radius: 14,
          child: Column(
            children: _mockOrders.take(3).toList().asMap().entries.map((e) {
              final o = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: _statusColor(o['status']!).withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_outlined,
                              color: _statusColor(o['status']!), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o['id']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(o['user']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(o['total']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(o['status']!).withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(o['status']!,
                                  style: TextStyle(color: _statusColor(o['status']!), fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (e.key < 2) const Divider(height: 1, color: Color(0x28FFFFFF), indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Users ──────────────────────────────────────────────────────────────────
  Widget _buildUsers() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _glass(
          radius: 14,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.people_outline_rounded, color: kOceanTeal, size: 18),
              const SizedBox(width: 8),
              Text('${_mockUsers.length} registered farmers',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _glass(
          radius: 14,
          child: Column(
            children: _mockUsers.asMap().entries.map((e) {
              final u = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [kAmber, kIndigo]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(u['name']![0],
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('${u['village']} · ${u['farm']}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(u['joined']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (e.key < _mockUsers.length - 1)
                    const Divider(height: 1, color: Color(0x28FFFFFF), indent: 64),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Products ───────────────────────────────────────────────────────────────
  Widget _buildProducts() {
    final byCategory = <String, int>{};
    for (final p in MarketData.allProducts) {
      byCategory[p.category] = (byCategory[p.category] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _glass(
          radius: 14,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: kForestSage, size: 18),
              const SizedBox(width: 8),
              Text('${MarketData.allProducts.length} products across ${byCategory.length} categories',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionLabel('BY CATEGORY'),
        _glass(
          radius: 14,
          child: Column(
            children: byCategory.entries.toList().asMap().entries.map((e) {
              final cat = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined, color: kAmber, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(cat.key,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kAmber.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${cat.value} items',
                              style: const TextStyle(color: kAmber, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  if (e.key < byCategory.length - 1)
                    const Divider(height: 1, color: Color(0x28FFFFFF), indent: 44),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Orders ─────────────────────────────────────────────────────────────────
  Widget _buildOrders() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: _mockOrders.map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _glass(
          radius: 14,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(o['id']!,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(o['status']!).withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(o['status']!,
                        style: TextStyle(color: _statusColor(o['status']!), fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(o['user']!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const Spacer(),
                  Text(o['date']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(o['items']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(o['total']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered': return kForestSage;
      case 'In Transit': return kOceanTeal;
      case 'Processing': return kSunsetOrange;
      default: return Colors.white54;
    }
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return _glass(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(color: Colors.white54, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      );
}
