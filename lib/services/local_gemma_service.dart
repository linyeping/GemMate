import 'package:flutter_gemma/flutter_gemma.dart';
import '../core/text_utils.dart';

class LocalGemmaService {
  // SINGLETON — same instance everywhere
  static final LocalGemmaService _instance = LocalGemmaService._();
  factory LocalGemmaService() => _instance;
  LocalGemmaService._();

  bool _isInitialized = false;
  bool get isAvailable => _isInitialized;

  static const String _strictSystemPrompt = 
      'Do not use thinking or reasoning blocks. Respond directly. '
      'CRITICAL FORMATTING RULES: '
      'Do NOT use any Markdown formatting. No ** for bold. No * for italic. No # for headers. '
      'Do NOT use LaTeX formatting. No \\frac, no \\sqrt, no \$\$ symbols. '
      'Write everything in plain text only. '
      'For math: write fractions as a/b, exponents as x^2, square roots as sqrt(x). '
      'For emphasis: just use regular text, no asterisks or special characters.';

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _isInitialized = true;
      print('LocalGemmaService: initialized successfully');
    } catch (e) {
      print('LocalGemmaService: init failed: $e');
      _isInitialized = false;
    }
  }

  Future<String> generate(String prompt) async {
    if (!_isInitialized) await initialize();
    
    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      final chat = await model.createChat();
      
      final fullPrompt = '$_strictSystemPrompt\n\n$prompt';
      await chat.addQueryChunk(Message(text: fullPrompt, isUser: true));
      final response = await chat.generateChatResponse();
      
      String result = 'No response';
      if (response is TextResponse) {
        result = response.token;
      } else {
        result = response.toString();
      }

      await model.close();
      return sanitizeResponse(result);
    } catch (e) {
      print('LocalGemma generate error: $e');
      throw Exception('Local model error: $e');
    }
  }

  Future<String> generateWithHistory(List<dynamic> history, String newMessage) async {
    if (!_isInitialized) await initialize();
    
    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      final chat = await model.createChat();
      
      // Inject system instructions as first message if possible, or prepend to first message
      await chat.addQueryChunk(Message(text: _strictSystemPrompt, isUser: false));

      final recent = history.length > 6 ? history.sublist(history.length - 6) : history;
      for (final msg in recent) {
        try {
          String? text;
          bool isUser = false;
          if (msg is Map) {
            text = msg['content']?.toString();
            isUser = msg['isUser'] ?? false;
          } else {
            text = msg.content?.toString();
            isUser = msg.isUser ?? false;
          }
          if (text != null && text.isNotEmpty) {
            await chat.addQueryChunk(Message(text: text, isUser: isUser));
          }
        } catch (_) {}
      }
      
      await chat.addQueryChunk(Message(text: newMessage, isUser: true));
      final response = await chat.generateChatResponse();
      
      String result = 'No response';
      if (response is TextResponse) {
        result = response.token;
      } else {
        result = response.toString();
      }

      await model.close();
      return sanitizeResponse(result);
    } catch (e) {
      print('LocalGemma generateWithHistory error: $e');
      throw Exception('Local model error: $e');
    }
  }
}
