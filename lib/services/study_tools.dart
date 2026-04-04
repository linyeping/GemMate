import 'dart:convert';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import 'ollama_service.dart';

class StudyTools {
  final OllamaService _ollama = OllamaService();

  /// Execute a tool call from the agent
  Future<dynamic> executeTool(Map<String, dynamic> toolCall) async {
    final tool = toolCall['tool'] as String;
    final params = toolCall['params'] as Map<String, dynamic>;

    switch (tool) {
      case 'create_flashcards':
        return await createFlashcards(
          topic: params['topic'],
          count: params['count'] ?? 5,
        );
      case 'create_quiz':
        return await createQuiz(
          topic: params['topic'],
          difficulty: params['difficulty'] ?? 'medium',
        );
      case 'summarize':
        return await summarize(params['text']);
      case 'translate':
        return await translate(
          text: params['text'],
          from: params['from'] ?? 'en',
          to: params['to'] ?? 'zh',
        );
      case 'explain':
        return await explain(
          concept: params['concept'],
          level: params['level'] ?? 'intermediate',
        );
      default:
        return 'Unknown tool: $tool';
    }
  }

  Future<List<Flashcard>> createFlashcards({
    required String topic,
    int count = 5,
  }) async {
    final response = await _ollama.chat(
      'Create $count flashcards about "$topic". '
      'Return as JSON array: [{"front": "question", "back": "answer"}]. '
      'Make them concise. Front in English, back bilingual (English + Chinese). '
      'Return ONLY the JSON array.',
    );

    try {
      final list = jsonDecode(response) as List;
      return list.map((e) => Flashcard.fromJson(e)).toList();
    } catch (e) {
      // Fallback: return a single flashcard with the raw response
      return [Flashcard(front: topic, back: response, id: '', groupId: '', groupName: '')];
    }
  }

  Future<List<QuizQuestion>> createQuiz({
    required String topic,
    String difficulty = 'medium',
  }) async {
    final response = await _ollama.chat(
      'Create 5 $difficulty multiple-choice quiz questions about "$topic". '
      'Return as JSON array: [{"question": "...", "options": ["A","B","C","D"], "correct": 0}]. '
      'Questions in English, include Chinese explanation for each answer. '
      'Return ONLY the JSON array.',
    );

    try {
      final list = jsonDecode(response) as List;
      return list.map((e) => QuizQuestion.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> summarize(String text) async {
    return await _ollama.chat(
      'Summarize the following text in both English and Chinese. '
      'Keep it concise (max 200 words total):\n\n$text',
    );
  }

  Future<String> translate({
    required String text,
    String from = 'en',
    String to = 'zh',
  }) async {
    return await _ollama.chat(
      'Translate from $from to $to. '
      'Provide the translation and key vocabulary:\n\n$text',
    );
  }

  Future<String> explain({
    required String concept,
    String level = 'intermediate',
  }) async {
    return await _ollama.chat(
      'Explain "$concept" at $level level. '
      'Use both English and Chinese. '
      'Include a simple analogy and one example.',
    );
  }
}
