import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/recommendations_provider.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/recommendation_card.dart';
import 'recommendation_detail_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final crop = args?['crop'] as String? ?? 'your crop';
    final recProvider = context.watch<RecommendationsProvider>();
    final recs = recProvider.recommendations;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Regenerate',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: recs.isEmpty
          ? EmptyState(
              icon: Icons.agriculture_rounded,
              title: 'No Recommendations',
              subtitle:
                  'Fill in the crop form to generate personalised recommendations.',
              actionLabel: 'Fill Crop Form',
              onAction: () => Navigator.pop(context),
            )
          : ListView(
              padding: const EdgeInsets.all(kPadding),
              children: [
                // Summary banner
                _summaryBanner(crop, recs.length, tt)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2),

                const SizedBox(height: 20),

                // Category filter chips
                _categoryChips(context, recs.length),

                const SizedBox(height: 16),

                // Recommendation cards — staggered reveal
                ...recs.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecommendationCard(
                          rec: e.value,
                          index: e.key,
                          onLearnMore: () => Navigator.push(
                            context,
                            _detailRoute(e.value),
                          ),
                        ),
                      ),
                    ),

                const SizedBox(height: 20),

                // CTA: Go to AI Chat
                _chatCta(context, crop, tt),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _summaryBanner(String crop, int count, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryGreen, kSecondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendations for $crop',
                  style: tt.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                Text(
                  '$count personalised suggestions generated',
                  style: tt.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips(BuildContext context, int total) {
    final labels = ['All ($total)', 'Crop', 'Water', 'Fertilizer', 'Market'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => FilterChip(
          label: Text(labels[i]),
          selected: i == 0,
          onSelected: (_) {},
          selectedColor: kPrimaryGreen.withOpacity(0.15),
          checkmarkColor: kPrimaryGreen,
          labelStyle: TextStyle(
            color: i == 0 ? kPrimaryGreen : null,
            fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _chatCta(BuildContext context, String crop, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kAccentYellow.withOpacity(0.12),
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kAccentYellow.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy_rounded, color: kPrimaryGreen, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Have more questions?',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text('Ask ClimaVOICE about $crop farming',
                    style: tt.bodySmall),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Ask AI'),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }

  PageRoute _detailRoute(rec) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => RecommendationDetailScreen(rec: rec),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );
}
