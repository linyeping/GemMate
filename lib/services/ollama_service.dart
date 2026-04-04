import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/chat_message.dart';
import '../stores/locale_store.dart';

class OllamaService {
  String host;
  int port;

  OllamaService({
    this.host = AppConstants.defaultOllamaHost,
    this.port = AppConstants.ollamaPort,
  });

  String get baseUrl => 'http://$host:$port';

  Future<bool> isReachable() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> chat(String prompt, {String? systemPrompt}) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = 
      'Do not use thinking or reasoning blocks. Respond directly.\n\n'
      '$langInstruction\n\n'
      '${systemPrompt ?? AppConstants.systemPrompt}';

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': AppConstants.modelName,
        'messages': [
          {'role': 'system', 'content': fullSystemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'stream': false,
        'options': {'num_ctx': AppConstants.maxContextTokens},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message']['content'] as String;
    } else {
      throw Exception('Ollama error: ${response.statusCode}');
    }
  }

  Future<String> chatWithHistory(List<ChatMessage> history, String newMessage) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = 
      'Do not use thinking or reasoning blocks. Respond directly.\n\n'
      '$langInstruction\n\n'
      '${AppConstants.systemPrompt}';

    final messages = <Map<String, dynamic>>[];
    messages.add({'role': 'system', 'content': fullSystemPrompt});

    final contextMessages = history.length > AppConstants.maxHistoryMessagesForContext
        ? history.sublist(history.length - AppConstants.maxHistoryMessagesForContext)
        : history;

    for (var msg in contextMessages) {
      if (msg.modelUsed == ModelUsed.none && !msg.isUser) continue;
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    messages.add({'role': 'user', 'content': newMessage});

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': AppConstants.modelName,
        'messages': messages,
        'stream': false,
        'options': {'num_ctx': AppConstants.maxContextTokens},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message']['content'] as String;
    } else {
      throw Exception('Ollama error: ${response.statusCode}');
    }
  }

  Future<String> chatWithImage(String base64Image, String prompt, {String? systemPrompt}) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = 
      'Do not use thinking or reasoning blocks. Respond directly.\n\n'
      '$langInstruction\n\n'
      '${systemPrompt ?? AppConstants.ocrSystemPrompt}';

    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': AppConstants.modelName,
        'messages': [
          {'role': 'system', 'content': fullSystemPrompt},
          {
            'role': 'user',
            'content': prompt,
            'images': [base64Image]
          },
        ],
        'stream': false,
        'options': {'num_ctx': AppConstants.maxContextTokens},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message']['content'] as String;
    } else {
      throw Exception('Ollama error: ${response.statusCode}');
    }
  }
}
