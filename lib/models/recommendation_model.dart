enum RecommendationType {
  bestCrop,
  water,
  fertilizer,
  pesticide,
  organic,
  income,
  market,
}

class RecommendationModel {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String iconAsset;
  final String? actionLabel;
  final String? detailContent;

  const RecommendationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.actionLabel,
    this.detailContent,
  });

  static List<RecommendationModel> mock() => [
        const RecommendationModel(
          id: '1',
          type: RecommendationType.bestCrop,
          title: 'Grow Cotton Next Season',
          description:
              'Based on your black cotton soil, current humidity (68%), and Padra seasonal pattern, cotton yields the highest ROI this kharif season.',
          iconAsset: 'assets/icons/crop.png',
          actionLabel: 'Learn More',
          detailContent:
              'Cotton thrives in black cotton soil with temperatures between 25–35°C. Your current weather conditions align perfectly. Expected yield: 15–20 quintals/acre. Market price: ₹6,500/quintal at Padra mandi.',
        ),
        const RecommendationModel(
          id: '2',
          type: RecommendationType.water,
          title: 'Water: 2,200 L/acre/day',
          description:
              'Your drip irrigation system should run for 4 hours in the morning. Reduce by 30% when soil moisture exceeds 75%.',
          iconAsset: 'assets/icons/water.png',
          actionLabel: 'Set Reminder',
          detailContent:
              'Optimal irrigation schedule: 6:00 AM – 8:00 AM and 5:00 PM – 7:00 PM. Monitor soil moisture sensor readings. Target range: 60–75%.',
        ),
        const RecommendationModel(
          id: '3',
          type: RecommendationType.fertilizer,
          title: 'Apply NPK 20-20-0',
          description:
              'Apply 50 kg/acre of NPK 20-20-0 as basal dose. Follow up with Urea (25 kg/acre) after 30 days of germination.',
          iconAsset: 'assets/icons/fertilizer.png',
          actionLabel: 'View Schedule',
          detailContent:
              'Week 1: NPK 20-20-0 @ 50 kg/acre. Week 4: Urea @ 25 kg/acre. Week 8: MOP @ 20 kg/acre. Avoid fertilizing 2 days before expected rainfall.',
        ),
        const RecommendationModel(
          id: '4',
          type: RecommendationType.pesticide,
          title: 'Preventive Pesticide Plan',
          description:
              'Apply Imidacloprid (0.5 ml/L) as seed treatment to prevent sucking pests. Monitor for bollworm after 45 days.',
          iconAsset: 'assets/icons/pesticide.png',
          actionLabel: 'Safety Notes',
          detailContent:
              'SAFETY: Always wear gloves and mask when applying pesticides. Keep children away from treated fields for 48 hours. Spray in the evening to avoid harming pollinators.',
        ),
        const RecommendationModel(
          id: '5',
          type: RecommendationType.organic,
          title: 'Transition to Organic Farming',
          description:
              'Start your 3-year organic transition. Year 1: reduce chemical use by 50% and introduce vermicompost.',
          iconAsset: 'assets/icons/organic.png',
          actionLabel: 'See Full Plan',
          detailContent:
              'Year 1: Reduce chemicals 50%, add vermicompost 2 ton/acre. Year 2: Switch to bio-pesticides, green manuring. Year 3: Full organic certification eligible. Organic cotton premium: +₹2,000/quintal.',
        ),
        const RecommendationModel(
          id: '6',
          type: RecommendationType.income,
          title: 'Increase Income by 35%',
          description:
              'Process cotton into baled fiber locally before selling. Consider intercropping with moong dal to utilize field margins.',
          iconAsset: 'assets/icons/income.png',
          actionLabel: 'Explore Options',
          detailContent:
              'Value chain options: 1) Sell raw cotton @ ₹6,500/q. 2) Ginned cotton @ ₹9,200/q (+41%). 3) Intercrop moong dal: additional ₹8,000/acre income with minimal extra input.',
        ),
        const RecommendationModel(
          id: '7',
          type: RecommendationType.market,
          title: 'Best Price: Vadodara APMC',
          description:
              'Current best price for cotton is ₹6,850/quintal at Vadodara APMC. Padra local mandi offers ₹6,500/quintal.',
          iconAsset: 'assets/icons/market.png',
          actionLabel: 'View Mandis',
          detailContent:
              'Price comparison (today):\n• Vadodara APMC: ₹6,850/q ★ Best\n• Padra mandi: ₹6,500/q\n• Karjan mandi: ₹6,620/q\n• Savli mandi: ₹6,480/q\n\nTravel cost to Vadodara: ~₹200. Net benefit: +₹150/q.',
        ),
      ];
}
