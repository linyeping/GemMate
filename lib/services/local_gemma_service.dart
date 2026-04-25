import 'package:flutter_gemma/flutter_gemma.dart';
import '../core/text_utils.dart';
import '../stores/locale_store.dart';

class LocalGemmaService {
  // SINGLETON — same instance everywhere
  static final LocalGemmaService _instance = LocalGemmaService._();
  factory LocalGemmaService() => _instance;
  LocalGemmaService._();

  bool _isInitialized = false;
  bool get isAvailable => _isInitialized;

  static const String _strictFormattingRules =
      'Do not use thinking or reasoning blocks. Respond directly. '
      'CRITICAL FORMATTING RULES: '
      'Do NOT use ** for bold, * for italic, or # for headers in normal text. '
      'Do NOT use LaTeX formatting. No \\frac, no \\sqrt, no \$\$ symbols. '
      'For math: write fractions as a/b, exponents as x^2, square roots as sqrt(x). '
      'IMPORTANT CODE RULE: Whenever you write any code (any programming language, '
      'shell commands, config files, etc.), you MUST wrap it in a fenced code block '
      'with the language identifier. For example: '
      '```cpp\n#include <iostream>\nint main() {}\n``` '
      'or ```python\nprint("hello")\n``` '
      'NEVER output code as plain text. Always use triple backtick fences. '
      'The language tag (cpp, python, dart, js, etc.) is required.';

  // Build the system prompt fresh on every call so the current locale is
  // respected even if the user switched languages mid-session.
  String get _strictSystemPrompt =>
      '${LocaleStore().aiLanguageInstruction} $_strictFormattingRules';

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

  /// [systemPromptOverride] — when set, replaces the default formatting rules
  /// with a caller-specific system instruction (e.g. strict JSON for flashcard
  /// / quiz generation). Language instruction is appended automatically.
  Future<String> generate(String prompt, {String? systemPromptOverride}) async {
    if (!_isInitialized) await initialize();

    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
      final chat = await model.createChat();

      final systemPrompt = systemPromptOverride != null
          ? '${LocaleStore().aiLanguageInstruction} $systemPromptOverride'
          : _strictSystemPrompt;
      final fullPrompt = '$systemPrompt\n\n$prompt';
      await chat.addQueryChunk(Message(text: fullPrompt, isUser: true));
      final response = await chat.generateChatResponse();

      String result = 'No response';
      if (response is TextResponse) {
        result = response.token;
      } else {
        result = response.toString();
      }

      // NOTE: Do NOT call model.close() here — getActiveModel() returns a
      // shared singleton. Closing it corrupts subsequent calls (e.g. the next
      // OCR/chat request crashes with INTERNAL: Failed to invoke the compiled
      // model). Only close the per-request chat session.
      try { await chat.close(); } catch (_) {}
      return sanitizeResponse(autoFenceBareCcode(result));
    } catch (e) {
      print('LocalGemma generate error: $e');
      throw Exception('Local model error: $e');
    }
  }

  Future<String> generateWithHistory(List<dynamic> history, String newMessage) async {
    if (!_isInitialized) await initialize();

    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
      final chat = await model.createChat();
      
      // Prepend system instructions to the first user message (same pattern as
      // generate()) because flutter_gemma doesn't have a dedicated system-role
      // API — injecting it as isUser:false causes the model to treat it as an
      // assistant turn, which corrupts conversation context.
      bool systemInjected = false;
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
            // Inject system prompt before the very first user message.
            final enriched = (isUser && !systemInjected)
                ? '$_strictSystemPrompt\n\n$text'
                : text;
            if (isUser) systemInjected = true;
            await chat.addQueryChunk(Message(text: enriched, isUser: isUser));
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

      // See note in generate(): do not close the shared singleton model.
      try { await chat.close(); } catch (_) {}
      return sanitizeResponse(autoFenceBareCcode(result));
    } catch (e) {
      print('LocalGemma generateWithHistory error: $e');
      throw Exception('Local model error: $e');
    }
  }
}
