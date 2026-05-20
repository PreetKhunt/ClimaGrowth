import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message_model.dart';
import '../models/soil_model.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class AiChatService {
  static const Duration _timeout = Duration(seconds: 30);

  String _currentModel = 'gemini-2.5-flash';
  final List<String> _modelFallbacks = [
    'gemini-2.5-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
  ];

  String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_currentModel:generateContent';

  final List<Map<String, dynamic>> _conversationHistory = [];

  String _buildSystemInstruction({
    required String language,
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
  }) {
    final langInstr = switch (language) {
      'gu' =>
        'Always respond in Gujarati (ગુજરાતી). Use simple, rural-friendly Gujarati.',
      'hi' => 'Always respond in Hindi (हिन्दी). Use simple, practical Hindi.',
      _ => 'Always respond in English. Keep language simple and accessible.',
    };

    const base = '''You are ClimaVOICE, a smart farming assistant for Indian farmers in Padra, Gujarat. You behave like a sharp, helpful village expert — direct, warm, and brief.

CRITICAL RULES FOR EVERY RESPONSE:

1. ANSWER ONLY WHAT IS ASKED. Do not add unrequested context, background, or related advice. If asked "price of tomato" — give only the price. Do not explain how to grow tomato, when to harvest, or what fertilizer to use.

2. KEEP RESPONSES SHORT. Default to 1-3 sentences. Maximum 4 sentences. Only go longer if the user explicitly asks "explain in detail" or "tell me everything about".

3. MATCH THE USER'S INTENT:
   - Question about price → give price range only
   - Question about timing → give date/time only
   - Question about quantity → give number with unit only
   - Question about yes/no → give yes or no with one-line reason
   - Question about "how to" → give 3-5 numbered steps maximum
   - Greeting like "hi" → reply with a warm 1-line greeting, do not list capabilities
   - Casual chat → respond casually in 1-2 sentences

4. NO EDUCATIONAL DUMPS. Never include phrases like "Here is everything you need to know..." or "Let me explain the complete process..." or "There are several factors to consider..."

5. NO UNNECESSARY DISCLAIMERS. Do not say "prices vary by region" or "consult local experts" unless directly relevant. Trust the user.

6. ASK BACK IF UNCLEAR. If a question is ambiguous, ask ONE short clarifying question instead of guessing and explaining everything.

7. USE NUMBERS AND UNITS. Include rupees, kg, acres, days, percentages, hours when relevant. Be specific.

8. END WITH ONE ACTIONABLE STEP if relevant. Example: "Sell now if prices stay above Rs 2000." Not a long paragraph.

9. SWITCH LANGUAGE NATURALLY. If user writes in Gujarati or Hindi, respond in that language. If they mix, respond in the dominant language.

10. NO REPETITION. Do not restate the question. Do not pad with filler.

EXAMPLES OF GOOD VS BAD RESPONSES:

User: "what is tomato price"
BAD: "The price of tomatoes in India varies significantly based on season, region, and quality. Currently in Gujarat mandis, tomato prices range from Rs 1500 to Rs 2800 per quintal. Tomato is a kharif and rabi crop that requires loamy soil..."
GOOD: "Tomato is selling at Rs 1800–2400 per quintal at Padra mandi today. Prices may rise next week as supply tightens."

User: "should I water cotton today"
BAD: "Cotton requires consistent watering during its various growth stages. Watering depends on soil type, current growth stage, weather conditions..."
GOOD: "No, skip today. Soil moisture is at 68% and rain is expected tomorrow afternoon."

User: "namaste"
BAD: "Namaste! I am ClimaVOICE, your AI farming assistant. I can help you with crop selection, weather forecasts, soil management, irrigation advice, fertilizer recommendations..."
GOOD: "Namaste! How can I help you today?"

User: "best fertilizer for wheat"
BAD: "Wheat is a major cereal crop in India and requires balanced nutrition for optimal yield. The fertilizer requirements depend on soil type, region, variety..."
GOOD: "Use DAP at sowing (50kg/acre) and urea in 2 splits at 25 and 50 days (40kg/acre each). NPK 12-32-16 works as an alternative."

Remember: Be the smart friend, not the textbook.''';

    return [
      base,
      langInstr,
      if (farmerName.isNotEmpty) 'Farmer name: $farmerName.',
      if (cropName.isNotEmpty) 'Current crop focus: $cropName.',
      if (weather != null)
        'Current weather: ${weather.temperature}°C, humidity ${weather.humidity}%, condition: ${weather.condition}.',
      if (soil != null)
        'Soil info: ${soil.soilType}, moisture ${soil.moistureLevel}%, health: ${soil.healthStatus}.',
    ].join('\n');
  }

  String _detectIntentHint(String userMessage) {
    final msg = userMessage.toLowerCase().trim();

    if (msg.contains('price') ||
        msg.contains('rate') ||
        msg.contains('cost') ||
        msg.contains('ભાવ') ||
        msg.contains('कीमत') ||
        msg.contains('दाम')) {
      return '[INTENT: PRICE QUERY - Respond with current price range only. Max 2 sentences.]';
    }

    if (msg.startsWith('hi') ||
        msg.startsWith('hello') ||
        msg.startsWith('hey') ||
        msg.contains('namaste') ||
        msg.contains('namaskar') ||
        msg.contains('કેમ છો') ||
        msg.contains('नमस्ते')) {
      return '[INTENT: GREETING - Respond with brief 1-line warm greeting. Do not list capabilities.]';
    }

    if (msg.startsWith('when') ||
        msg.startsWith('what time') ||
        msg.startsWith('kab') ||
        msg.contains('ક્યારે') ||
        msg.contains('कब')) {
      return '[INTENT: TIMING QUERY - Respond with specific time/date only. Max 1 sentence.]';
    }

    if (msg.startsWith('how much') ||
        msg.startsWith('how many') ||
        msg.contains('quantity') ||
        msg.contains('કેટલું') ||
        msg.contains('कितना')) {
      return '[INTENT: QUANTITY QUERY - Respond with number and unit only. Max 1 sentence.]';
    }

    if (msg.startsWith('should i') ||
        msg.startsWith('can i') ||
        msg.startsWith('is it') ||
        msg.contains('shall i') ||
        msg.startsWith('do i')) {
      return '[INTENT: YES/NO QUERY - Respond with Yes or No followed by 1-line reason only.]';
    }

    if (msg.startsWith('how to') ||
        msg.startsWith('how do i') ||
        msg.contains('steps') ||
        msg.contains('કેવી રીતે') ||
        msg.contains('कैसे')) {
      return '[INTENT: HOW-TO QUERY - Respond with 3-5 numbered steps maximum. No intro paragraph.]';
    }

    if (msg.startsWith('what is') ||
        msg.startsWith('what are') ||
        msg.contains('meaning of')) {
      return '[INTENT: DEFINITION QUERY - Respond with one clear definition sentence.]';
    }

    return '[INTENT: GENERAL - Keep response under 3 sentences.]';
  }

  String _enforceConcisenessIfNeeded(String response, String userMessage) {
    final userWantsDetail = userMessage.toLowerCase().contains('explain') ||
        userMessage.toLowerCase().contains('detail') ||
        userMessage.toLowerCase().contains('tell me everything') ||
        userMessage.toLowerCase().contains('describe') ||
        userMessage.toLowerCase().contains('elaborate');

    if (userWantsDetail) return response;

    if (response.length > 400) {
      final sentences = response.split(RegExp(r'(?<=[.!?])\s+'));
      if (sentences.length > 3) {
        return sentences.take(3).join(' ');
      }
    }

    return response;
  }

  Future<String> sendMessage({
    required String message,
    required String language,
    List<ChatMessage> history = const [],
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
    bool conciseResponses = true,
  }) async {
    print('ClimaVOICE Debug: sendMessage called with: $message');

    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    if (kGeminiApiKey.isEmpty || kGeminiApiKey == 'YOUR_GEMINI_API_KEY') {
      print('ClimaVOICE Debug: API key is missing or placeholder');
      throw Exception(
          'API key not configured. Please add your Gemini API key in constants.dart');
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('ClimaVOICE Debug: No internet connection detected');
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    // Sync provider history into internal history on first call
    if (_conversationHistory.isEmpty && history.isNotEmpty) {
      for (final msg in history.length > 20
          ? history.sublist(history.length - 20)
          : history) {
        _conversationHistory.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.content}
          ],
        });
      }
    }

    // Prepend intent hint in concise mode — invisible to user, guides Gemini
    final String sentMessage = conciseResponses
        ? '${_detectIntentHint(message)}\n\nUser question: $message'
        : message;

    _conversationHistory.add({
      'role': 'user',
      'parts': [
        {'text': sentMessage}
      ],
    });

    if (_conversationHistory.length > 20) {
      _conversationHistory.removeRange(0, _conversationHistory.length - 20);
    }

    final requestBody = {
      'systemInstruction': {
        'parts': [
          {
            'text': _buildSystemInstruction(
              language: language,
              weather: weather,
              soil: soil,
              farmerName: farmerName,
              cropName: cropName,
            ),
          },
        ],
      },
      'contents': _conversationHistory,
      'generationConfig': {
        'temperature': conciseResponses ? 0.5 : 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': conciseResponses ? 256 : 1024,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_ONLY_HIGH'
        },
      ],
    };

    print(
        'ClimaVOICE Debug: API key prefix = ${kGeminiApiKey.length > 8 ? kGeminiApiKey.substring(0, 8) : kGeminiApiKey}...');
    print(
        'ClimaVOICE Debug: History size = ${_conversationHistory.length}, message = "$message", concise = $conciseResponses');

    int retries = 0;
    while (retries < 4) {
      final url = Uri.parse('$_baseUrl?key=$kGeminiApiKey');
      print('ClimaVOICE Debug: POST $_baseUrl (attempt $retries)');
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestBody),
            )
            .timeout(_timeout);

        print('ClimaVOICE Debug: Response status = ${response.statusCode}');
        print(
            'ClimaVOICE Debug: Response preview = ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

        switch (response.statusCode) {
          case 200:
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final candidates = data['candidates'] as List?;

            if (candidates == null || candidates.isEmpty) {
              print('ClimaVOICE Debug: No candidates in response');
              throw Exception('No response generated. Try rephrasing.');
            }

            final candidate = candidates[0] as Map<String, dynamic>;

            if (candidate['finishReason'] == 'SAFETY') {
              return 'I cannot answer that due to safety guidelines. Please ask something else about farming.';
            }

            final parts = candidate['content']?['parts'] as List?;
            if (parts == null || parts.isEmpty) {
              throw Exception('Empty response from AI. Please try again.');
            }

            final aiText = parts[0]['text'] as String? ?? '';
            if (aiText.isEmpty) {
              throw Exception('Empty text in AI response. Please try again.');
            }

            final finalText = conciseResponses
                ? _enforceConcisenessIfNeeded(aiText, message)
                : aiText;

            _conversationHistory.add({
              'role': 'model',
              'parts': [
                {'text': finalText}
              ],
            });

            print(
                'ClimaVOICE Debug: Success, response length = ${finalText.length} chars');
            return finalText.trim();

          case 429:
            print('ClimaVOICE Debug: Rate limited (429) — attempt $retries');
            if (retries < 2) {
              await Future.delayed(Duration(seconds: 1 << retries));
              retries++;
              continue;
            }
            _conversationHistory.removeLast();
            throw Exception(
                'ClimaVOICE is busy right now. Please try again in a moment.');

          case 400:
            print('ClimaVOICE Debug: Bad request (400): ${response.body}');
            if (retries < 1 && _conversationHistory.length > 3) {
              _conversationHistory.removeRange(
                  0, _conversationHistory.length - 3);
              retries++;
              continue;
            }
            _conversationHistory.removeLast();
            throw Exception(
                "I didn't quite catch that. Could you rephrase your question?");

          case 403:
            print('ClimaVOICE Debug: Forbidden (403): ${response.body}');
            _conversationHistory.removeLast();
            throw Exception(
                'API key is invalid or Gemini API is not enabled in Google Cloud Console.');

          case 404:
            print('ClimaVOICE Debug: Not found (404): ${response.body}');
            _conversationHistory.removeLast();
            throw Exception(
                'AI model endpoint not found. Please contact support.');

          case 500:
            print(
                'ClimaVOICE Debug: Internal server error (500) — attempt $retries');
            if (retries < 2) {
              await Future.delayed(Duration(seconds: 1 << retries));
              retries++;
              continue;
            }
            _conversationHistory.removeLast();
            throw Exception(
                'Service temporarily unavailable. Please try again.');

          case 502:
          case 503:
          case 504:
            print(
                'ClimaVOICE Debug: Gateway error (${response.statusCode}) — attempt $retries');
            if (retries < 2) {
              await Future.delayed(Duration(seconds: 1 << retries));
              retries++;
              continue;
            }
            final fallbackIdx = _modelFallbacks.indexOf(_currentModel) + 1;
            if (fallbackIdx < _modelFallbacks.length) {
              _currentModel = _modelFallbacks[fallbackIdx];
              print(
                  'ClimaVOICE Debug: Switching to fallback model: $_currentModel');
              retries = 0;
              continue;
            }
            _conversationHistory.removeLast();
            return await _retryWithShorterPrompt(message, language);

          default:
            print(
                'ClimaVOICE Debug: Unexpected status ${response.statusCode}: ${response.body}');
            _conversationHistory.removeLast();
            throw Exception('Unexpected error (${response.statusCode}).');
        }
      } on TimeoutException {
        print('ClimaVOICE Debug: Request timed out — attempt $retries');
        if (retries < 2) {
          await Future.delayed(Duration(seconds: 1 << retries));
          retries++;
          continue;
        }
        _conversationHistory.removeLast();
        throw Exception(
            'Request timed out. Please check your connection and try again.');
      } catch (e) {
        print('ClimaVOICE Debug: Caught error on attempt $retries: $e');
        if (retries < 2 &&
            (e.toString().contains('SocketException') ||
                e.toString().contains('Connection'))) {
          await Future.delayed(Duration(seconds: 1 << retries));
          retries++;
          continue;
        }
        rethrow;
      }
    }

    _conversationHistory.removeLast();
    throw Exception('Failed after retries. Please try again later.');
  }

  Future<String> _retryWithShorterPrompt(
      String userMessage, String language) async {
    print('ClimaVOICE Debug: Retrying with minimal context');
    final originalHistory =
        List<Map<String, dynamic>>.from(_conversationHistory);
    _currentModel = _modelFallbacks.first;

    final langName = switch (language) {
      'gu' => 'Gujarati',
      'hi' => 'Hindi',
      _ => 'English',
    };

    final minimalContents = [
      {
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ]
      }
    ];

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {
            'text':
                'You are a helpful farming assistant. Answer briefly in $langName.'
          }
        ]
      },
      'contents': minimalContents,
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 200},
    });

    try {
      final url = Uri.parse('$_baseUrl?key=$kGeminiApiKey');
      final resp = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        _conversationHistory
          ..clear()
          ..addAll(originalHistory)
          ..add({
            'role': 'model',
            'parts': [
              {'text': text}
            ]
          });
        print('ClimaVOICE Debug: Fallback succeeded');
        return text.trim();
      }
    } catch (e) {
      print('ClimaVOICE Debug: Fallback also failed: $e');
    }

    _conversationHistory
      ..clear()
      ..addAll(originalHistory);
    throw Exception(
        'I am having trouble right now. Please try a shorter question or try again in a moment.');
  }

  Stream<String> sendMessageStream({
    required String message,
    required String language,
    List<ChatMessage> history = const [],
    WeatherModel? weather,
    SoilModel? soil,
    String farmerName = '',
    String cropName = '',
    bool conciseResponses = true,
  }) async* {
    try {
      final fullResponse = await sendMessage(
        message: message,
        language: language,
        history: history,
        weather: weather,
        soil: soil,
        farmerName: farmerName,
        cropName: cropName,
        conciseResponses: conciseResponses,
      );
      final words = fullResponse.split(' ');
      for (int i = 0; i < words.length; i++) {
        // Yield only the new delta word — provider appends these correctly
        yield words[i] + (i < words.length - 1 ? ' ' : '');
        await Future.delayed(const Duration(milliseconds: 30));
      }
    } catch (e) {
      yield 'Error: ${e.toString().replaceAll('Exception: ', '')}';
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
    print('ClimaVOICE Debug: Conversation history cleared');
  }

  List<Map<String, dynamic>> getHistory() => List.from(_conversationHistory);
}
