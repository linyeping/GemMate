import '../core/constants.dart';
import '../core/utils.dart';
import '../models/chat_message.dart';
import '../models/quiz_question.dart';
import '../stores/locale_store.dart';
import 'ollama_service.dart';

class QuizGenerator {
  final OllamaService ollama;

  QuizGenerator({required this.ollama});

  Future<List<QuizQuestion>> generate(List<ChatMessage> history, String topic, {int count = 5}) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final systemPrompt = '${AppConstants.quizSystemPrompt}\n\n$langInstruction';

    try {
      final response = await ollama.chat(
        'Generate $count quiz questions about "$topic" based on our conversation.',
        systemPrompt: systemPrompt,
      );

      return AppUtils.safeJsonList<QuizQuestion>(
        response,
        (json) => QuizQuestion.fromJson(json),
      );
    } catch (e) {
      print('Quiz generation error: $e');
      return [];
    }
  }
}
