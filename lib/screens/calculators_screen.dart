import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'calculators/calc_crop_insurance.dart';
import 'calculators/calc_fertilizer.dart';
import 'calculators/calc_land_area.dart';
import 'calculators/calc_loan_emi.dart';
import 'calculators/calc_pesticide_dosage.dart';
import 'calculators/calc_profit_margin.dart';
import 'calculators/calc_seed_quantity.dart';
import 'calculators/calc_soil_moisture.dart';
import 'calculators/calc_solar_pump.dart';
import 'calculators/calc_storage_transport.dart';
import 'calculators/calc_water_requirement.dart';
import 'calculators/calc_yield_prediction.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Calculators'),
        elevation: 0,
        centerTitle: true,
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildCalculatorsGrid(context),
          _buildHistoryTab(context),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: isDark ? const Color(0x14FFFFFF) : kBorder)),
        ),
        child: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.calculate_rounded), text: 'Calculators'),
            Tab(icon: Icon(Icons.history_rounded), text: 'History'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorsGrid(BuildContext context) {
    final calculators = [
      _CalcCard(
        icon: Icons.opacity_rounded,
        title: 'Water Requirement',
        subtitle: 'Irrigation planning',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WaterRequirementCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.grain_rounded,
        title: 'Fertilizer',
        subtitle: 'NPK dosage',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FertilizerCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.trending_up_rounded,
        title: 'Profit Margin',
        subtitle: 'Cost analysis',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfitMarginCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.credit_card_rounded,
        title: 'Loan EMI',
        subtitle: 'Monthly payment',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoanEMICalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.landscape_rounded,
        title: 'Land Area',
        subtitle: 'Unit conversion',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LandAreaCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.grain_rounded,
        title: 'Seed Quantity',
        subtitle: 'Planting needs',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SeedQuantityCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.show_chart_rounded,
        title: 'Yield Prediction',
        subtitle: 'Expected harvest',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const YieldPredictionCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.bug_report_rounded,
        title: 'Pesticide Dosage',
        subtitle: 'Safe application',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PesticideDosageCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.water_drop_outlined,
        title: 'Soil Moisture',
        subtitle: 'Irrigation timing',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SoilMoistureCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.solar_power_rounded,
        title: 'Solar Pump',
        subtitle: 'System sizing',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SolarPumpCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.shield_rounded,
        title: 'Crop Insurance',
        subtitle: 'PMFBY premium',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CropInsuranceCalc()),
        ),
      ),
      _CalcCard(
        icon: Icons.local_shipping_rounded,
        title: 'Storage & Transport',
        subtitle: 'Cost estimation',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StorageTransportCalc()),
        ),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(kPadding),
      itemCount: calculators.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => calculators[i],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 64, color: kTextMuted.withAlpha(100)),
            const SizedBox(height: 16),
            Text(
              'No calculations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your saved calculations will appear here',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalcCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kAmber.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: kAmber, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
