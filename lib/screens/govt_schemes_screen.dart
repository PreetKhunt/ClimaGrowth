import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme_model.dart';
import '../utils/constants.dart';

class GovtSchemesScreen extends StatefulWidget {
  const GovtSchemesScreen({super.key});

  @override
  State<GovtSchemesScreen> createState() => _GovtSchemesScreenState();
}

class _GovtSchemesScreenState extends State<GovtSchemesScreen> {
  String _filter = 'all';
  final _filters = ['all', 'subsidy', 'loan', 'insurance', 'other'];

  @override
  Widget build(BuildContext context) {
    final all = SchemeModel.mockSchemes();
    final filtered = _filter == 'all' ? all : all.where((s) => s.type == _filter).toList();
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Government Schemes'), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: kPadding),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final f = _filters[i];
                return FilterChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: f == _filter,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: kPrimaryGreen.withOpacity(0.15),
                  checkmarkColor: kPrimaryGreen,
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(kPadding),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => _schemeCard(filtered[i], tt, i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _schemeCard(SchemeModel scheme, TextTheme tt, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: kPadding, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor(scheme.type).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(scheme.type), color: _typeColor(scheme.type), size: 20),
          ),
          title: Text(scheme.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Chip(
            label: Text(scheme.type.toUpperCase(), style: const TextStyle(fontSize: 10)),
            backgroundColor: _typeColor(scheme.type).withOpacity(0.1),
            padding: EdgeInsets.zero,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme.description, style: tt.bodyMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(kRadiusSmall),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: kWarningOrange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Eligibility: ${scheme.eligibility}',
                            style: tt.bodySmall?.copyWith(color: kWarningOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launch(scheme.link),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Apply Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'subsidy': return kPrimaryGreen;
      case 'loan': return Colors.blue.shade600;
      case 'insurance': return Colors.purple.shade600;
      default: return kWarningOrange;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'subsidy': return Icons.volunteer_activism_rounded;
      case 'loan': return Icons.account_balance_rounded;
      case 'insurance': return Icons.shield_rounded;
      default: return Icons.info_rounded;
    }
  }
}
