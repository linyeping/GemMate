import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/text_utils.dart';
import '../models/chat_message.dart';
import '../stores/locale_store.dart';

class OllamaService {
  static final OllamaService _instance = OllamaService._();
  factory OllamaService() => _instance;
  OllamaService._() : _baseUrl = 'http://192.168.1.103:11434';

  String _baseUrl;
  String _model = 'gemma4:e2b';

  String get baseUrl => _baseUrl;
  String get currentModel => _model;

  static const String _strictSystemPrompt = 
      'Do not use thinking or reasoning blocks. Respond directly. '
      'CRITICAL FORMATTING RULES: '
      'Do NOT use any Markdown formatting. No ** for bold. No * for italic. No # for headers. '
      'Do NOT use LaTeX formatting. No \\frac, no \\sqrt, no \$\$ symbols. '
      'Write everything in plain text only. '
      'For math: write fractions as a/b, exponents as x^2, square roots as sqrt(x). '
      'For emphasis: just use regular text, no asterisks or special characters. '
      'Example: write "Step 1: Calculate the time" not "**Step 1: Calculate the time**"';

  void updateBaseUrl(String ip) {
    _baseUrl = 'http://$ip:11434';
    print('OllamaService: updated URL to $_baseUrl');
  }

  void setModel(String model) {
    _model = model;
    print('OllamaService: using model $_model');
  }

  Future<void> saveModel(String model) async {
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ollama_model', model);
    print('OllamaService: saved model preference $_model');
  }

  Future<bool> isReachable() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 5)); // Keep reachability check short
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> chat(String prompt, {String? systemPrompt}) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = 
      '$_strictSystemPrompt\n\n'
      '$langInstruction\n\n'
      '${systemPrompt ?? AppConstants.systemPrompt}';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': fullSystemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'options': {'num_ctx': AppConstants.maxContextTokens},
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['message']?['content'];
        if (content == null) throw Exception('Ollama returned null content');
        return sanitizeResponse(content.toString());
      } else {
        throw Exception('Ollama error: ${response.statusCode}');
      }
    } catch (e) {
      print('Ollama chat error: $e');
      rethrow;
    }
  }

  Future<String> chatWithHistory(List<ChatMessage> history, String newMessage) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = '$_strictSystemPrompt\n\n$langInstruction';

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

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'stream': false,
          'options': {'num_ctx': AppConstants.maxContextTokens},
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['message']?['content'];
        if (content == null) throw Exception('Ollama returned null content');
        return sanitizeResponse(content.toString());
      } else {
        throw Exception('Ollama error: ${response.statusCode}');
      }
    } catch (e) {
      print('Ollama history chat error: $e');
      rethrow;
    }
  }

  Future<String> chatWithImage(String base64Image, String prompt) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final fullSystemPrompt = '$_strictSystemPrompt\n\n$langInstruction';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': fullSystemPrompt},
            {
              'role': 'user',
              'content': prompt,
              'images': [base64Image]
            },
          ],
          'stream': false,
          'options': {'num_ctx': 4096},
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return sanitizeResponse(data['message']['content'] ?? 'No response');
      } else {
        throw Exception('Ollama error: ${response.statusCode}');
      }
    } catch (e) {
      print('Ollama image chat error: $e');
      rethrow;
    }
  }
}
