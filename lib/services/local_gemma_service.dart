import 'package:flutter_gemma/flutter_gemma.dart';

class LocalGemmaService {
  // SINGLETON — same instance everywhere
  static final LocalGemmaService _instance = LocalGemmaService._();
  factory LocalGemmaService() => _instance;
  LocalGemmaService._();

  bool _isInitialized = false;
  bool get isAvailable => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // flutter_gemma already installed the model
      // We just need to mark as ready to get the active model later
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
      await chat.addQueryChunk(Message(text: prompt, isUser: true));
      final response = await chat.generateChatResponse();
      
      String result = 'No response';
      if (response is TextResponse) {
        result = response.token;
      } else {
        result = response.toString();
      }

      await model.close();
      return result;
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
      return result;
    } catch (e) {
      print('LocalGemma generateWithHistory error: $e');
      throw Exception('Local model error: $e');
    }
  }
}
