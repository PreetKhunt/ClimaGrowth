import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/recommendation_model.dart';
import '../utils/constants.dart';

class RecommendationCard extends StatefulWidget {
  final RecommendationModel rec;
  final int index;
  final VoidCallback? onLearnMore;

  const RecommendationCard({
    super.key,
    required this.rec,
    this.index = 0,
    this.onLearnMore,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = _typeColor(widget.rec.type);

    return GestureDetector(
      onPanUpdate: (d) {
        setState(() {
          _tiltX = (d.localPosition.dy / 100 - 0.5) * 0.1;
          _tiltY = (d.localPosition.dx / 100 - 0.5) * -0.1;
        });
      },
      onPanEnd: (_) => setState(() { _tiltX = 0; _tiltY = 0; }),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(kRadius),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_typeIcon(widget.rec.type), color: color, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.rec.title,
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.rec.description,
                  style: tt.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (widget.onLearnMore != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: widget.onLearnMore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: Text(widget.rec.actionLabel ?? 'Learn More'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (widget.index * 100).ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Color _typeColor(RecommendationType t) {
    switch (t) {
      case RecommendationType.bestCrop: return kPrimaryGreen;
      case RecommendationType.water: return Colors.blue.shade600;
      case RecommendationType.fertilizer: return Colors.brown.shade600;
      case RecommendationType.pesticide: return kWarningOrange;
      case RecommendationType.organic: return kSecondaryGreen;
      case RecommendationType.income: return kAccentYellow;
      case RecommendationType.market: return Colors.purple.shade600;
    }
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
