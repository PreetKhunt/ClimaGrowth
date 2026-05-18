import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _feedbackCtrl = TextEditingController();
  double _rating = 4;

  static const _faqs = [
    ('How does the weather data get updated?', 'Weather data is fetched from Open-Meteo API every 3 hours using your GPS location. When offline, the last cached data is shown.'),
    ('Is my farm data private?', 'Yes, all your farm data is stored securely in Firebase and is only accessible to you. We never share personal data with third parties.'),
    ('How accurate is the AI chatbot?', 'ClimaVOICE uses Gemini AI and is provided with your local weather, soil, and crop context for accurate, region-specific answers. Always cross-check critical decisions.'),
    ('Can I use the app without internet?', 'Yes! Weather, recommendations, and chat history are cached locally. You can view them offline. New AI responses require internet.'),
    ('How do I switch language?', 'Go to Settings > Language and select English, Gujarati, or Hindi. The app will update immediately.'),
    ('What do the soil health colors mean?', 'Green = Good (60–80% moisture), Yellow = Moderate (40–60%), Red = Needs Attention (below 40% or above 85%).'),
    ('How do I set irrigation reminders?', 'Enable Irrigation Reminders in Settings > Notifications. Push notifications will be sent based on your soil moisture levels.'),
    ('Why are market prices approximate?', 'Current mock prices are based on historical averages for Padra region mandis. Real-time Agmarknet integration will be enabled in a future update.'),
    ('How do I report a problem?', 'Use the Feedback form below or contact support via email at climagrowth@support.in'),
    ('How do I apply for government schemes?', 'Go to Government Schemes > Select a scheme > Tap Apply Now. You will be redirected to the official government portal.'),
  ];

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(kPadding),
        children: [
          // Contact section
          Container(
            padding: const EdgeInsets.all(kPadding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimaryGreen, kSecondaryGreen]),
              borderRadius: BorderRadius.circular(kRadius),
            ),
            child: Column(
              children: [
                Text('Need Help?', style: tt.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text('Our support team is here for you', style: tt.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launch('tel:+919642421234'),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Call Support'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size(0, 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launch('mailto:climagrowth@support.in'),
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: const Text('Email Us'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size(0, 40),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          Text('Frequently Asked Questions', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen)),
          const SizedBox(height: 12),

          ..._faqs.asMap().entries.map((e) {
            final (q, a) = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(kRadius),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(q, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(a, style: tt.bodyMedium),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (e.key * 50).ms).fadeIn(duration: 300.ms);
          }),

          const SizedBox(height: 24),

          // Feedback form
          Container(
            padding: const EdgeInsets.all(kPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(kRadius),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send Feedback', style: tt.headlineMedium?.copyWith(color: kPrimaryGreen)),
                const SizedBox(height: 16),
                Center(
                  child: RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 36,
                    itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: kAccentYellow),
                    onRatingUpdate: (r) => setState(() => _rating = r),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your feedback or suggestion',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submitFeedback,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Feedback'),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _submitFeedback() {
    if (_feedbackCtrl.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: kPrimaryGreen,
      ),
    );
    _feedbackCtrl.clear();
    setState(() => _rating = 4);
  }
}
