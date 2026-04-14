import '../models/chat_message.dart';
import '../models/quiz_question.dart';
import '../stores/locale_store.dart';
import '../stores/connection_store.dart';
import '../core/json_utils.dart';
import 'ollama_service.dart';
import 'local_gemma_service.dart';

class QuizGenerator {
  final OllamaService ollama;

  QuizGenerator({required this.ollama});

  Future<List<QuizQuestion>> generate(List<ChatMessage> history, String topic, {int count = 5}) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;

    final conversationText = history.map((m) => '${m.isUser ? "User" : "AI"}: ${m.content}').join('\n');

    final prompt = 'Based on this conversation, create a quiz.\n\n'
        'YOU MUST respond with ONLY a valid JSON array. No other text.\n'
        'DO NOT include any explanation before or after the JSON.\n'
        'DO NOT use markdown code blocks.\n'
        'Each object MUST have exactly these keys: "question", "options", "correctIndex".\n'
        '"options" must be an array of exactly 4 strings.\n'
        '"correctIndex" must be 0, 1, 2, or 3.\n\n'
        'CORRECT FORMAT EXAMPLE:\n'
        '[{"question":"What is X?","options":["A","B","C","D"],"correctIndex":0}]\n\n'
        'Conversation content:\n$conversationText\n\n'
        'Respond with ONLY the JSON array:';

    try {
      // Route: laptop-online → Ollama; else on-device Gemma.
      final useLocal = !ConnectionStore().isLaptopConnected &&
          LocalGemmaService().isAvailable;
      final String responseText;
      if (useLocal) {
        responseText = await LocalGemmaService().generate(
          prompt,
          systemPromptOverride: 'Respond with ONLY a JSON array.',
        );
      } else {
        responseText = await ollama.chat(
          prompt,
          systemPrompt: 'Respond with ONLY a JSON array. $langInstruction',
        );
      }

      final questions = robustJsonParse(responseText);
      
      return questions.map((json) {
        final question = json['question']?.toString() ?? '';
        final options = (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final correctIndex = json['correctIndex'] as int? ?? json['correct_index'] as int? ?? 0;
        
        if (question.isEmpty || options.length < 2) return null;
        
        // Pad options to 4 if needed
        final List<String> paddedOptions = List<String>.from(options);
        while (paddedOptions.length < 4) {
          paddedOptions.add('N/A');
        }

        return QuizQuestion(
          question: question,
          options: options.take(4).toList(),
          correctIndex: correctIndex.clamp(0, 3),
          explanation: json['explanation']?.toString() ?? '',
        );
      }).whereType<QuizQuestion>().toList();
    } catch (e) {
      print('Quiz generation error: $e');
      return [];
    }
  }
}
