import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class SoilDoctorScreen extends StatefulWidget {
  const SoilDoctorScreen({super.key});

  @override
  State<SoilDoctorScreen> createState() => _SoilDoctorScreenState();
}

class _SoilDoctorScreenState extends State<SoilDoctorScreen> {
  XFile? _image;
  bool _analyzing = false;
  _SoilAnalysis? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 1024);
    if (picked != null) {
      setState(() {
        _image = picked;
        _result = null;
        _error = null;
      });
      await _analyze(picked);
    }
  }

  Future<void> _analyze(XFile file) async {
    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = file.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      const prompt = '''You are an expert soil analyst. Examine this soil photo carefully and respond ONLY with a JSON object in this exact format:
{
  "soilType": "Loamy / Sandy / Clay / Black Cotton / Red Laterite",
  "confidence": 85,
  "moistureEstimate": "Moist / Dry / Saturated",
  "color": "Dark Brown / Light Brown / Reddish / Black",
  "texture": "Fine / Coarse / Granular / Compacted",
  "deficiencies": ["Iron deficiency (yellowish tinge)", "Nitrogen low (pale color)"],
  "problems": ["Salt buildup visible", "Surface crust forming"],
  "recommendations": [
    "Apply 3 tons organic compost per acre",
    "Test pH — suspected alkalinity",
    "Improve drainage to prevent waterlogging"
  ],
  "overallHealth": "Good / Fair / Poor"
}
Respond ONLY with the JSON. No explanation, no markdown.''';

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$kGeminiApiKey');

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image}
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 600,
        }
      });

      final response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final cleaned = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final json = jsonDecode(cleaned) as Map<String, dynamic>;
        setState(() => _result = _SoilAnalysis.fromJson(json));
      } else {
        setState(
            () => _error = 'Analysis failed (${response.statusCode}). Try again.');
      }
    } catch (e) {
      setState(() => _error = 'Could not analyze image: $e');
    } finally {
      setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Soil Doctor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            GestureDetector(
              onTap: () => _showPickerSheet(context),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.onSurface.withAlpha(8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: cs.outlineVariant,
                      style: BorderStyle.solid),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              size: 48, color: cs.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('Tap to take or upload a soil photo',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Get instant AI soil analysis',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant.withAlpha(150),
                                  fontSize: 12)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.network(_image!.path, fit: BoxFit.cover,
                                width: double.infinity)
                            : Image.file(File(_image!.path),
                                fit: BoxFit.cover,
                                width: double.infinity),
                      ),
              ),
            ),

            if (_image != null && !_analyzing && _result == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _analyze(_image!),
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Analyze Soil'),
                ),
              ),
            ],

            if (_analyzing) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(
                  child: Text('Analyzing your soil...',
                      style:
                          TextStyle(color: cs.onSurfaceVariant))),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCoral.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kCoral.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: kCoral, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: kCoral, fontSize: 13))),
                  ],
                ),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResults(context, _result!),
            ],
          ],
        ),
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, _SoilAnalysis r) {
    final cs = Theme.of(context).colorScheme;
    final healthColor = r.overallHealth == 'Good'
        ? kForestSage
        : r.overallHealth == 'Fair'
            ? kSunsetOrange
            : kCoral;

    Widget section(String title, Widget body) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            body,
            const SizedBox(height: 16),
          ],
        );

    Widget resultCard(Widget child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: child,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall health badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: healthColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: healthColor.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, color: healthColor, size: 18),
              const SizedBox(width: 6),
              Text('Overall: ${r.overallHealth}',
                  style: TextStyle(
                      color: healthColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Identification
        section(
          'Soil Identification',
          resultCard(
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue(cs, 'Type', r.soilType),
                      _labelValue(cs, 'Color', r.color),
                      _labelValue(cs, 'Texture', r.texture),
                      _labelValue(cs, 'Moisture', r.moistureEstimate),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('${r.confidence}%',
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    Text('confidence',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),

        if (r.deficiencies.isNotEmpty)
          section(
            'Suspected Deficiencies',
            resultCard(Column(
              children: r.deficiencies
                  .map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: kSunsetOrange),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(d,
                                  style: TextStyle(
                                      color: cs.onSurface, fontSize: 13))),
                        ]),
                      ))
                  .toList(),
            )),
          ),

        if (r.problems.isNotEmpty)
          section(
            'Detected Problems',
            resultCard(Column(
              children: r.problems
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.report_rounded,
                              size: 16, color: kCoral),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(p,
                                  style: TextStyle(
                                      color: cs.onSurface, fontSize: 13))),
                        ]),
                      ))
                  .toList(),
            )),
          ),

        section(
          'Top Recommendations',
          resultCard(Column(
            children: r.recommendations
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: kForestSage.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: kForestSage,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(e.value,
                                  style: TextStyle(
                                      color: cs.onSurface, fontSize: 13))),
                        ],
                      ),
                    ))
                .toList(),
          )),
        ),

        // Re-analyze button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showPickerSheet(context),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Analyze Another Sample'),
          ),
        ),
      ],
    );
  }

  Widget _labelValue(ColorScheme cs, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SoilAnalysis {
  final String soilType, moistureEstimate, color, texture, overallHealth;
  final int confidence;
  final List<String> deficiencies, problems, recommendations;

  const _SoilAnalysis({
    required this.soilType,
    required this.moistureEstimate,
    required this.color,
    required this.texture,
    required this.overallHealth,
    required this.confidence,
    required this.deficiencies,
    required this.problems,
    required this.recommendations,
  });

  factory _SoilAnalysis.fromJson(Map<String, dynamic> j) => _SoilAnalysis(
        soilType: j['soilType'] ?? 'Unknown',
        moistureEstimate: j['moistureEstimate'] ?? 'Unknown',
        color: j['color'] ?? 'Unknown',
        texture: j['texture'] ?? 'Unknown',
        overallHealth: j['overallHealth'] ?? 'Fair',
        confidence: (j['confidence'] ?? 75) as int,
        deficiencies: List<String>.from(j['deficiencies'] ?? []),
        problems: List<String>.from(j['problems'] ?? []),
        recommendations: List<String>.from(j['recommendations'] ?? []),
      );
}
