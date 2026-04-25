import '../models/chat_message.dart';
import '../models/flashcard.dart';
import '../stores/locale_store.dart';
import '../stores/connection_store.dart';
import '../core/json_utils.dart';
import 'ollama_service.dart';
import 'local_gemma_service.dart';

class FlashcardGenerator {
  final OllamaService ollama;

  FlashcardGenerator(this.ollama);

  Future<List<Flashcard>> generate(List<ChatMessage> history, String topic) async {
    final langInstruction = LocaleStore().aiLanguageInstruction;

    final conversationText = history.map((m) => '${m.isUser ? "User" : "AI"}: ${m.content}').join('\n');

    final prompt = 'Based on this conversation, create flashcards.\n\n'
        'YOU MUST respond with ONLY a valid JSON array. No other text.\n'
        'DO NOT include any explanation before or after the JSON.\n'
        'DO NOT use markdown code blocks.\n'
        'Each object MUST have exactly two keys: "front" and "back".\n'
        'DO NOT use "question" or "answer" as keys.\n\n'
        'CORRECT FORMAT EXAMPLE:\n'
        '[{"front":"What is X?","back":"X is Y"},{"front":"What is Z?","back":"Z is W"}]\n\n'
        'Conversation content:\n$conversationText\n\n'
        'Respond with ONLY the JSON array:';

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
      // Route: laptop-online → Ollama; else on-device Gemma.
      final useLocal = !ConnectionStore().isLaptopConnected &&
          LocalGemmaService().isAvailable;
      final systemPrompt = 'Respond with ONLY a JSON array. $langInstruction';
      final String responseText;
      if (useLocal) {
        responseText = await LocalGemmaService().generate(
          prompt,
          systemPromptOverride: 'Respond with ONLY a JSON array.',
        );
      } else {
        responseText = await ollama.chat(prompt, systemPrompt: systemPrompt);
      }

      final cards = robustJsonParse(responseText);
      
      final base = DateTime.now().millisecondsSinceEpoch;
      return cards.asMap().entries.map((entry) {
        final idx = entry.key;
        final json = entry.value;
        final front = json['front']?.toString()
            ?? json['question']?.toString()
            ?? json['q']?.toString()
            ?? '';
        final back = json['back']?.toString()
            ?? json['answer']?.toString()
            ?? json['a']?.toString()
            ?? '';

        if (front.isEmpty || back.isEmpty) return null;

        return Flashcard(
          // Use stable index-based ID: avoids reference-equality pitfalls
          // with indexOf() and ensures uniqueness within a batch.
          id: '${base}_$idx',
          groupId: groupId,
          groupName: groupName,
          front: front,
          back: back,
        );
      }).whereType<Flashcard>().toList();
    } catch (e) {
      print('Flashcard generation error: $e');
      return [];
    }
  }
}
