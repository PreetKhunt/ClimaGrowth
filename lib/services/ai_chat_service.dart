import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message_model.dart';
import '../models/soil_model.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class AiChatService {
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxHistory = 10;

  String _systemInstruction({
    required String language,
    WeatherModel? weather,
    SoilModel? soil,
    String cropName = '',
    String farmerName = '',
  }) {
    final langInstr = switch (language) {
      'gu' => 'Always respond in Gujarati (ગુજરાતી). Use simple, rural-friendly Gujarati.',
      'hi' => 'Always respond in Hindi (हिन्दी). Use simple, practical Hindi.',
      _ => 'Always respond in English. Keep language simple and accessible.',
    };
    return [
      'You are ClimaVOICE, a friendly expert AI farming assistant for Indian farmers in Padra, Gujarat, India.',
      langInstr,
      'Keep answers concise, practical, and actionable. Always include specific units (kg, liters, cm, °C, acres).',
      'Be warm and encouraging. Use examples relevant to Gujarat farming context.',
      if (farmerName.isNotEmpty) 'Farmer name: $farmerName.',
      if (cropName.isNotEmpty) 'Current crop: $cropName.',
      if (weather != null)
        'Current weather: ${weather.temperature}°C, humidity ${weather.humidity}%, condition: ${weather.condition}.',
      if (soil != null)
        'Soil: ${soil.soilType}, moisture ${soil.moistureLevel}%, health: ${soil.healthStatus}.',
      'Help with: crop selection, irrigation, fertilizers, pesticides, organic farming, market prices, government schemes.',
    ].join('\n');
  }

  List<Map<String, dynamic>> _buildContents(
    String message,
    List<ChatMessage> history,
  ) {
    final limited = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;
    return [
      ...limited.map((m) => {
            'role': m.isUser ? 'user' : 'model',
            'parts': [
              {'text': m.content}
            ],
          }),
      {
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      },
    ];
  }

  Future<String> _doRequest({
    required String message,
    required List<ChatMessage> history,
    required String language,
    WeatherModel? weather,
    SoilModel? soil,
    String cropName = '',
    String farmerName = '',
  }) async {
    final url = Uri.parse('$_endpoint?key=$kGeminiApiKey');
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {
            'text': _systemInstruction(
              language: language,
              weather: weather,
              soil: soil,
              cropName: cropName,
              farmerName: farmerName,
            ),
          },
        ],
      },
      'contents': _buildContents(message, history),
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    });

    print('ClimaVOICE Debug: POST $_endpoint');
    print(
        'ClimaVOICE Debug: API key prefix = ${kGeminiApiKey.length > 8 ? kGeminiApiKey.substring(0, 8) : kGeminiApiKey}...');
    print(
        'ClimaVOICE Debug: History size = ${history.length}, message = "$message"');

    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(_timeout);

    print('ClimaVOICE Debug: Response status = ${response.statusCode}');

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.isNotEmpty) {
              print('ClimaVOICE Debug: Got ${text.length} chars response ✓');
              return text;
            }
          }
        }
        print('ClimaVOICE Debug: Empty candidates in 200 response: ${response.body}');
        return _errorMsg(language);

      case 429:
        print('ClimaVOICE Debug: Rate limited (429)');
        return 'ClimaVOICE is thinking really hard right now. Try again in a moment.';

      case 400:
        print('ClimaVOICE Debug: Bad request (400): ${response.body}');
        return "I didn't quite catch that. Could you rephrase your question?";

      case 403:
        print('ClimaVOICE Debug: Forbidden (403): ${response.body}');
        return 'API access issue. Please check the API key in settings.';

      case 404:
        print('ClimaVOICE Debug: Model not found (404): ${response.body}');
        return 'AI model unavailable. Please try again later.';

      default:
        print(
            'ClimaVOICE Debug: Unexpected status ${response.statusCode}: ${response.body}');
        throw Exception('HTTP ${response.statusCode}');
    }
  }

  Future<String> sendMessage({
    required String message,
    required String language,
    List<ChatMessage> history = const [],
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
  }) async {
    if (kGeminiApiKey.isEmpty || kGeminiApiKey == 'YOUR_GEMINI_API_KEY') {
      print('ClimaVOICE Debug: ERROR — API key is placeholder! Update kGeminiApiKey in constants.dart');
      return 'API key not configured. Please add your Gemini API key to lib/utils/constants.dart (replace YOUR_GEMINI_API_KEY with your real key from aistudio.google.com).';
    }

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        return await _doRequest(
          message: message,
          history: history,
          language: language,
          weather: weather,
          soil: soil,
          cropName: cropName,
          farmerName: farmerName,
        );
      } on TimeoutException {
        print('ClimaVOICE Debug: Timeout on attempt ${attempt + 1}/3');
        if (attempt < 2) {
          final delay = Duration(seconds: 1 << attempt);
          print('ClimaVOICE Debug: Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
        } else {
          return _offlineMsg(language);
        }
      } catch (e) {
        print('ClimaVOICE Debug: Exception on attempt ${attempt + 1}/3: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: 1 << attempt));
        } else {
          return _errorMsg(language);
        }
      }
    }
    return _errorMsg(language);
  }

  Stream<String> sendMessageStream({
    required String message,
    required String language,
    List<ChatMessage> history = const [],
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
  }) async* {
    final fullText = await sendMessage(
      message: message,
      language: language,
      history: history,
      weather: weather,
      soil: soil,
      farmerName: farmerName,
      cropName: cropName,
    );
    for (final word in fullText.split(' ')) {
      yield '$word ';
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  String _offlineMsg(String lang) => switch (lang) {
        'gu' => 'ઇન્ટરનેટ કનેક્શન ઉપલબ્ધ નથી. કૃપા કરીને ફરી પ્રયાસ કરો.',
        'hi' => 'इंटरनेट कनेक्शन उपलब्ध नहीं है। कृपया पुनः प्रयास करें।',
        _ => 'Could not reach the server. Please check your internet and try again.',
      };

  String _errorMsg(String lang) => switch (lang) {
        'gu' => 'માફ કરશો, કંઈક ખોટું થયું. કૃપા કરીને ફરી પ્રયાસ કરો.',
        'hi' => 'क्षमा करें, कुछ गलत हो गया। कृपया पुनः प्रयास करें।',
        _ => 'Something went wrong. Please try again.',
      };
}
