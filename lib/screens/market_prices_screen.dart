import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/supply_product.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/market_data.dart';
import 'calculators/calc_profit_margin.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _cropFilter = 'All';
  String _productCategory = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _cropTypes = [
    'All', 'grain', 'vegetable', 'pulse', 'cash', 'spice', 'oilseed'
  ];
  static const _cropTypeLabels = {
    'All': 'All',
    'grain': 'Grains',
    'vegetable': 'Veggies',
    'pulse': 'Pulses',
    'cash': 'Cash',
    'spice': 'Spices',
    'oilseed': 'Oilseeds',
  };

  // ── Theme helpers ─────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF14171F) : const Color(0xFFFAF7F2);
  Color get _surface => _isDark ? const Color(0xFF1C2029) : Colors.white;
  Color get _textPrimary => _isDark ? const Color(0xFFE8E6E0) : const Color(0xFF1A1A1A);
  Color get _textMuted => _isDark ? const Color(0x8CE8E6E0) : const Color(0xFF757575);
  Color get _border => _isDark ? const Color(0x1AFFFFFF) : const Color(0x141A1A1A);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CropPrice> get _filteredCrops {
    var list = MarketData.cropPrices;
    if (_cropFilter != 'All') list = list.where((c) => c.type == _cropFilter).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  List<SupplyProduct> get _filteredProducts {
    if (_productCategory == 'All') return MarketData.allProducts;
    return MarketData.allProducts.where((p) => p.category == _productCategory).toList();
  }

  // ── Widget helpers ────────────────────────────────────────────────────────
  Widget _card({required Widget child, double radius = 14, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(_isDark ? 20 : 6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBtn({required VoidCallback onTap, required Widget icon}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: _card(
          radius: 12,
          child: SizedBox(width: 36, height: 36, child: Center(child: icon)),
        ),
      ),
    );
  }

  Widget _cartBtn(BuildContext context, CartProvider cart) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/cart'),
        child: _card(
          radius: 12,
          child: SizedBox(
            width: 44,
            height: 36,
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.shopping_cart_outlined,
                      color: _textPrimary, size: 20),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    top: 5,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: kAmber, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(
      String label, String value, String current, VoidCallback onTap) {
    final selected = current == value;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? kSunsetOrange : _surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: selected ? kSunsetOrange : _border),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: kSunsetOrange.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(_isDark ? 20 : 6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _textMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _iconBtn(
                    onTap: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: _textPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Market',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ProfitMarginCalc())),
                      child: _card(
                        radius: 12,
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Icon(Icons.trending_up_rounded, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _cartBtn(context, cart),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Solid TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _card(
                radius: 14,
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kSunsetOrange,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: _textMuted,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Crop Prices'),
                    Tab(text: 'Buy Supplies'),
                    Tab(text: 'My Orders'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildCropTab(),
                  _buildSuppliesTab(cart),
                  _buildOrdersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Crop Prices ────────────────────────────────────────────────────
  Widget _buildCropTab() {
    final crops = _filteredCrops;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _card(
            radius: 14,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: _textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(color: _textPrimary, fontSize: 14),
                    cursorColor: kSunsetOrange,
                    decoration: InputDecoration(
                      hintText: 'Search crops…',
                      hintStyle: TextStyle(color: _textMuted),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cropTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final type = _cropTypes[i];
              return _filterChip(
                _cropTypeLabels[type] ?? type,
                type,
                _cropFilter,
                () => setState(() => _cropFilter = type),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: crops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _CropPriceRow(crop: crops[i]),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Buy Supplies ───────────────────────────────────────────────────
  Widget _buildSuppliesTab(CartProvider cart) {
    final products = _filteredProducts;
    return Column(
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MarketData.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = MarketData.categories[i];
              return _filterChip(cat, cat, _productCategory,
                  () => setState(() => _productCategory = cat));
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _ProductCard(product: products[i], cart: cart),
          ),
        ),
      ],
    );
  }

  // ── Tab 3: My Orders ──────────────────────────────────────────────────────
  Widget _buildOrdersTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _orderCard(
          orderId: 'CG-2048',
          date: '12 May 2026',
          status: 'Delivered',
          statusColor: kForestSage,
          items: 'Urea 50kg × 2, Hybrid Tomato Seed 10g × 1',
          total: '₹970',
        ),
        const SizedBox(height: 10),
        _orderCard(
          orderId: 'CG-2047',
          date: '10 May 2026',
          status: 'In Transit',
          statusColor: kOceanTeal,
          items: 'Battery Sprayer 16L × 1, Imidacloprid 250ml × 3',
          total: '₹5,450',
        ),
        const SizedBox(height: 10),
        _orderCard(
          orderId: 'CG-2046',
          date: '8 May 2026',
          status: 'Processing',
          statusColor: kSunsetOrange,
          items: 'Drip Irrigation Kit 1 Acre × 1',
          total: '₹18,500',
        ),
      ],
    );
  }

  Widget _orderCard({
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String items,
    required String total,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(_isDark ? 20 : 6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(date,
                  style: TextStyle(color: _textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Order #$orderId',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(items, style: TextStyle(color: _textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          Text(total,
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Crop Price Row ────────────────────────────────────────────────────────────
class _CropPriceRow extends StatelessWidget {
  final CropPrice crop;
  const _CropPriceRow({required this.crop});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1C2029) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE8E6E0) : const Color(0xFF1A1A1A);
    final textMuted =
        isDark ? const Color(0x8CE8E6E0) : const Color(0xFF757575);
    final borderColor =
        isDark ? const Color(0x1AFFFFFF) : const Color(0x141A1A1A);
    final up = crop.change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: crop.photoUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: isDark
                    ? Colors.white10
                    : const Color(0xFFF0EDE8),
                child: Icon(Icons.grass_rounded,
                    color: isDark
                        ? Colors.white38
                        : const Color(0xFF9E9E9E),
                    size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(crop.mandi,
                    style: TextStyle(color: textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${crop.minPrice.toInt()}–${crop.maxPrice.toInt()}',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              Text('/quintal',
                  style: TextStyle(color: textMuted, fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: up
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${up ? '+' : ''}${crop.change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: up
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final SupplyProduct product;
  final CartProvider cart;
  const _ProductCard({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1C2029) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE8E6E0) : const Color(0xFF1A1A1A);
    final textMuted =
        isDark ? const Color(0x8CE8E6E0) : const Color(0xFF757575);
    final borderColor =
        isDark ? const Color(0x1AFFFFFF) : const Color(0x141A1A1A);
    final inCart = cart.contains(product.id);

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Photo — left 100px
            SizedBox(
              width: 100,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: isDark
                          ? Colors.white10
                          : const Color(0xFFF0EDE8),
                      child: Icon(Icons.inventory_2_outlined,
                          color: isDark
                              ? Colors.white30
                              : const Color(0xFFBDBDBD),
                          size: 36),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: kAmber,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${product.discount}% OFF',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
            // Details — right side
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.3)),
                        const SizedBox(height: 2),
                        Text(product.brand,
                            style: TextStyle(
                                color: textMuted, fontSize: 12)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₹${product.price.toInt()}',
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            Text('₹${product.mrp.toInt()}',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: textMuted,
                                )),
                          ],
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => inCart
                                ? cart.remove(product.id)
                                : cart.add(product),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: inCart ? kAmberDark : kAmber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                inCart ? 'Added' : 'Add to Cart',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
