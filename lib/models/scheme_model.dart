class SchemeModel {
  final String id;
  final String title;
  final String description;
  final String eligibility;
  final String link;
  final String type; // subsidy / loan / insurance / other

  const SchemeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eligibility,
    required this.link,
    required this.type,
  });

  factory SchemeModel.fromMap(String id, Map<String, dynamic> map) {
    return SchemeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      eligibility: map['eligibility'] ?? '',
      link: map['link'] ?? '',
      type: map['type'] ?? 'other',
    );
  }

  static List<SchemeModel> mockSchemes() => [
        const SchemeModel(
          id: '1',
          title: 'PM Kisan Samman Nidhi',
          description: 'Direct income support of ₹6,000/year to small and marginal farmers in three equal installments.',
          eligibility: 'All small/marginal farmers with less than 2 hectares of land. Must have Aadhaar.',
          link: 'https://pmkisan.gov.in',
          type: 'subsidy',
        ),
        const SchemeModel(
          id: '2',
          title: 'Pradhan Mantri Fasal Bima Yojana',
          description: 'Crop insurance scheme that provides financial support to farmers suffering crop loss/damage due to unforeseen events.',
          eligibility: 'All farmers growing notified crops. Premium: 2% (Kharif), 1.5% (Rabi), 5% (Commercial).',
          link: 'https://pmfby.gov.in',
          type: 'insurance',
        ),
        const SchemeModel(
          id: '3',
          title: 'Kisan Credit Card (KCC)',
          description: 'Short-term formal credit at reduced interest rates (4% with subsidy) for crop cultivation and maintenance.',
          eligibility: 'All farmers, including tenant farmers and oral lessees. Apply at any nationalized bank.',
          link: 'https://www.nabard.org/content.aspx?id=572',
          type: 'loan',
        ),
        const SchemeModel(
          id: '4',
          title: 'National Agriculture Market (e-NAM)',
          description: 'Online trading platform for agricultural commodities to get better prices directly from buyers.',
          eligibility: 'Farmers registered with local APMC. Free registration. Mobile app available.',
          link: 'https://enam.gov.in',
          type: 'other',
        ),
        const SchemeModel(
          id: '5',
          title: 'Gujarat Kheti Praval Yojana',
          description: 'State scheme providing subsidized agricultural inputs (seeds, fertilizers) to Gujarat farmers.',
          eligibility: 'Registered farmers in Gujarat with valid land records (7/12 extract).',
          link: 'https://agri.gujarat.gov.in',
          type: 'subsidy',
        ),
        const SchemeModel(
          id: '6',
          title: 'Soil Health Card Scheme',
          description: 'Free soil testing and health card issued every 2 years with crop-specific fertilizer recommendations.',
          eligibility: 'All farmers. Contact nearest Krishi Vigyan Kendra or Agriculture Department office.',
          link: 'https://soilhealth.dac.gov.in',
          type: 'subsidy',
        ),
      ];
}
