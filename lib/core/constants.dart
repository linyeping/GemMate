class AppConstants {
  static const String defaultOllamaHost = '192.168.1.103';
  static const int ollamaPort = 11434;
  static const String modelName = 'gemma4:e2b';
  static const String appName = 'GemmaStudy';
  static const int maxContextTokens = 4096;
  static const int maxStoredSessions = 50;
  static const int maxHistoryMessagesForContext = 10;
  
  static const int reviewReminderHours = 4;
  static const int inactivityReminderHours = 24;
  static const int dailyReminderHour = 9;

  static const String systemPrompt =
      'Do not use thinking or reasoning blocks. Respond directly.\n\nYou are GemmaStudy, a helpful study assistant. Explain concepts clearly. Be concise but thorough. Use examples and analogies.';

  static const String flashcardSystemPrompt =
      'Do not use thinking or reasoning blocks. Respond directly.\n\nGenerate flashcards as a JSON array ONLY. Each has "front" (question) and "back" (answer). Return ONLY the JSON array, no markdown.\nExample: [{"front":"What is X?","back":"X is..."}]';

  static const String quizSystemPrompt =
      'Do not use thinking or reasoning blocks. Respond directly.\n\nGenerate quiz questions as a JSON array ONLY. Each has "question", "options" (4 strings), "correct" (index 0-3), "explanation". Return ONLY JSON.\nExample: [{"question":"...","options":["A","B","C","D"],"correct":0,"explanation":"..."}]';

  static const String ocrSystemPrompt =
      'Do not use thinking or reasoning blocks. Respond directly.\n\nExtract and organize the text from this image. Provide a clear summary and explanation. Highlight key study concepts.';

  static const String welcomeMessage =
      '👋 Hi! I\'m GemmaStudy, your AI study companion.\n\nI can help you:\n• Explain concepts in your language\n• Create flashcards\n• Generate quizzes\n• Scan textbooks with camera\n• Build study plans\n\nWhat would you like to study?';
}
