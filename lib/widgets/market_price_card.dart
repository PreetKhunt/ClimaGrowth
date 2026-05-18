import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/market_price_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class MarketPriceCard extends StatelessWidget {
  final MarketPriceModel price;
  final bool isBest;
  final int index;

  const MarketPriceCard({
    super.key,
    required this.price,
    this.isBest = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: kPaddingSmall),
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: isBest
            ? kPrimaryGreen.withOpacity(0.08)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(
          color: isBest ? kPrimaryGreen.withOpacity(0.4) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isBest)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.star_rounded, color: kAccentYellow, size: 20),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(price.mandi, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(price.region, style: tt.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.price(price.price),
                style: tt.titleLarge?.copyWith(
                  color: kPrimaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('per quintal', style: tt.bodySmall),
            ],
          ),
        ],
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }
}
