import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/recommendation_model.dart';
import '../utils/constants.dart';

class RecommendationDetailScreen extends StatelessWidget {
  final RecommendationModel rec;

  const RecommendationDetailScreen({super.key, required this.rec});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kPrimaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(rec.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryGreen, kSecondaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(_typeIcon(rec.type), size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(kPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  Text(rec.description, style: tt.bodyLarge).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  if (rec.detailContent != null) ...[
                    Text('Detailed Guide', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen))
                        .animate(delay: 200.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(kPadding),
                      decoration: BoxDecoration(
                        color: kPrimaryGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(kRadius),
                        border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
                      ),
                      child: Text(rec.detailContent!, style: tt.bodyMedium),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
                  ],

                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Recommendations'),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(RecommendationType t) {
    switch (t) {
      case RecommendationType.bestCrop: return Icons.eco_rounded;
      case RecommendationType.water: return Icons.water_drop_rounded;
      case RecommendationType.fertilizer: return Icons.science_rounded;
      case RecommendationType.pesticide: return Icons.bug_report_rounded;
      case RecommendationType.organic: return Icons.nature_rounded;
      case RecommendationType.income: return Icons.trending_up_rounded;
      case RecommendationType.market: return Icons.storefront_rounded;
    }
  }
}
