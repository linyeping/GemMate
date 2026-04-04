import '../core/constants.dart';
import '../core/utils.dart';
import '../models/chat_message.dart';
import '../models/flashcard.dart';
import '../stores/locale_store.dart';
import 'ollama_service.dart';

class FlashcardGenerator {
  final OllamaService ollama;

  FlashcardGenerator(this.ollama);

  Future<List<Flashcard>> generate(List<ChatMessage> history, String topic) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;
    final systemPrompt = '${AppConstants.flashcardSystemPrompt}\n\n'
        'Return ONLY a JSON array of flashcards. '
        'Each flashcard must have "front" and "back" fields as non-empty strings. '
        'Example: [{"front":"Question?","back":"Answer."}] '
        '$langInstruction';
    
    final groupId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Extract topic from first user message if topic param is empty
    final firstUserMsg = history.firstWhere(
      (m) => m.isUser == true,
      orElse: () => ChatMessage(isUser: true, content: 'Study Set'),
    );
    
    final groupName = topic.isNotEmpty 
        ? topic 
        : (firstUserMsg.content.length > 30 
            ? '${firstUserMsg.content.substring(0, 30)}...' 
            : firstUserMsg.content);

    try {
      final response = await ollama.chat(
        'Based on our conversation, generate flashcards about "$topic" as a JSON array. '
        'Return ONLY the JSON array, no other text.',
        systemPrompt: systemPrompt,
      );

      final parsedCards = AppUtils.safeJsonList<Map<String, dynamic>>(
        response,
        (json) => json,
      );

      return parsedCards.map((json) => Flashcard(
        id: DateTime.now().microsecondsSinceEpoch.toString() + '_${parsedCards.indexOf(json)}',
        groupId: groupId,
        groupName: groupName,
        front: json['front']?.toString() ?? '',
        back: json['back']?.toString() ?? '',
      )).where((f) => f.front.isNotEmpty && f.back.isNotEmpty).toList();
    } catch (e) {
      print('Flashcard generation error: $e');
      return [];
    }
  }
}
