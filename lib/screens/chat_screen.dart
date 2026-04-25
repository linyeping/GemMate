import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';
import '../stores/chat_store.dart';
import '../stores/flashcard_store.dart';
import '../stores/connection_store.dart';
import '../stores/locale_store.dart';
import '../services/ollama_service.dart';
import '../services/smart_router.dart';
import '../services/flashcard_generator.dart';
import '../services/quiz_generator.dart';
import '../services/local_gemma_service.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_action_chips.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/neumorphic_button.dart';
import 'dart:convert';
import 'chat_history_screen.dart';
import 'quiz_screen.dart';
import 'capture_screen.dart';
import 'mind_map_screen.dart';
import '../l10n/app_localizations.dart';
import '../core/constants.dart';
import '../services/streak_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatStore _chatStore = ChatStore();
  final ConnectionStore _connectionStore = ConnectionStore();
  final FlashcardStore _flashcardStore = FlashcardStore();
  final LocaleStore _localeStore = LocaleStore();
  final StorageService _storage = StorageService();
  
  late final SmartRouter _router;
  late final FlashcardGenerator _flashcardGenerator;
  late final QuizGenerator _quizGenerator;
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;

  // PDF context — set when user imports a PDF; cleared after next send
  PdfExtractResult? _pdfContext;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  List<stt.LocaleName> _availableLocales = [];

  @override
  void initState() {
    super.initState();
    final ollama = OllamaService();
    final localGemma = LocalGemmaService();
    _router = SmartRouter(
      localGemma: localGemma,
      connectionStore: _connectionStore,
    );
    _flashcardGenerator = FlashcardGenerator(ollama);
    _quizGenerator = QuizGenerator(ollama: ollama);
    
    _chatStore.addListener(_onChatStoreUpdate);
    _router.checkConnection();
    _initSpeech();

    _textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _chatStore.removeListener(_onChatStoreUpdate);
    _textController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        // `androidIntentLookup` switches the plugin from direct SpeechRecognizer
        // API to an intent-based lookup. This is the recommended path on
        // Samsung/OneUI devices where the direct API returns an empty locale
        // list even when Google Speech Services is installed. It also makes
        // the plugin pick Google as the backend more reliably than the OEM's.
        options: [stt.SpeechToText.androidIntentLookup],
        onError: (error) {
          print('Speech error: ${error.errorMsg}');
          if (mounted) setState(() => _isListening = false);

          // error_language_not_supported: device's recognizer (often Samsung's
          // default on Galaxy phones) can't handle the requested locale. Tell
          // the user how to switch to Google Speech Services, which covers
          // far more languages and supports on-demand language pack download.
          if (error.errorMsg == 'error_language_not_supported' && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 8),
                content: const Text(
                  'Voice input: your device\'s speech recognizer does not '
                  'support this language.\n\n'
                  'Fix: Settings → General management → Language & input → '
                  'On-screen keyboard / Voice input → switch to '
                  '"Google Speech Services", then download the language pack.',
                ),
              ),
            );
          } else if (error.errorMsg == 'error_permission' && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 8),
                content: const Text(
                  'Microphone access blocked.\n\n'
                  'Fix: Settings → Apps → GemMate → Permissions → Microphone '
                  '→ "Allow only while using the app".\n'
                  'Also check the system mic toggle in Quick Settings.',
                ),
              ),
            );
          }
        },
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      print('Speech available: $_speechAvailable');

      if (_speechAvailable) {
        _availableLocales = await _speech.locales();
        print('Available locales: ${_availableLocales.map((l) => l.localeId).toList()}');
      }
    } catch (e) {
      print('Speech init failed: $e');
      _speechAvailable = false;
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available. Check microphone permission in phone Settings.')),
          );
        }
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
    } else {
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required for voice input.')),
          );
        }
        return;
      }

      if (mounted) setState(() => _isListening = true);
      
      final localeId = _getLocaleId();
      print('Starting speech with locale: $localeId');

      try {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _textController.text = result.recognizedWords;
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _textController.text.length),
                );
              });
              if (result.finalResult) {
                if (mounted) setState(() => _isListening = false);
              }
            }
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 5),
          localeId: localeId.isNotEmpty ? localeId : null,
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            cancelOnError: false,
            partialResults: true,
            onDevice: true,
          ),
        );
      } catch (e) {
        print('Speech listen error: $e');
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice input failed. Try changing app language in Settings.')),
          );
        }
      }
    }
  }

  String _getLocaleId() {
    final locale = _localeStore.currentLocale;
    
    final preferred = <String, List<String>>{
      'zh': ['zh_CN', 'zh_TW', 'zh-CN', 'zh-TW', 'cmn-Hans-CN', 'yue-Hant-HK'],
      'ja': ['ja_JP', 'ja-JP'],
      'ko': ['ko_KR', 'ko-KR'],
      'fr': ['fr_FR', 'fr-FR'],
      'es': ['es_ES', 'es-ES', 'es_MX', 'es-MX'],
      'en': ['en_US', 'en-US', 'en_GB', 'en-GB'],
    };
    
    final candidates = preferred[locale.languageCode] ?? ['en_US'];
    
    for (final candidate in candidates) {
      for (final available in _availableLocales) {
        if (available.localeId == candidate || 
            available.localeId.replaceAll('-', '_') == candidate.replaceAll('-', '_')) {
          print('Using speech locale: ${available.localeId}');
          return available.localeId;
        }
      }
    }
    
    for (final available in _availableLocales) {
      if (available.localeId.startsWith(locale.languageCode)) {
        print('Using speech locale (fallback): ${available.localeId}');
        return available.localeId;
      }
    }

    // Last-resort fallback: prefer any available en_* locale over the system
    // default. Many Samsung devices ship with a recognizer whose system
    // default isn't actually supported (common on zh_CN users), so falling
    // through to null/empty causes `error_language_not_supported`. en_US is
    // almost universally present.
    for (final available in _availableLocales) {
      if (available.localeId.startsWith('en')) {
        print('No match for ${locale.languageCode}, falling back to ${available.localeId}');
        return available.localeId;
      }
    }

    // Absolute last resort: let the plugin pick whatever's first in the list.
    if (_availableLocales.isNotEmpty) {
      final first = _availableLocales.first.localeId;
      print('No en_* either, using first available: $first');
      return first;
    }

    print('No locales enumerated at all, using system default');
    return '';
  }

  void _onChatStoreUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? text, String? imageBase64}) async {
    final msgText = text ?? _textController.text;
    if (msgText.trim().isEmpty && imageBase64 == null) return;

    // If a PDF has been loaded, prepend its context to the actual query.
    // The user-visible message shows the question only; the model receives
    // the full PDF snippet + question.
    final pdfSnippet = _pdfContext;
    final modelQuery = pdfSnippet != null
        ? '${PdfService.buildContext(pdfSnippet, isRemote: _connectionStore.isLaptopConnected)}'
          '\n\nUser question: $msgText'
        : msgText;

    final userMsg = ChatMessage(
      content: pdfSnippet != null
          ? '📄 [${pdfSnippet.fileName}]\n$msgText'
          : msgText,
      isUser: true,
      imageBase64: imageBase64,
    );

    // Consume PDF context after one send
    if (pdfSnippet != null) setState(() => _pdfContext = null);

    _chatStore.addMessage(userMsg);
    _chatStore.updateLastTopic(msgText);
    _textController.clear();

    setState(() => _isLoading = true);
    final stopwatch = Stopwatch()..start();

    try {
      String response;
      if (imageBase64 != null) {
        response = await _router.ollama.chatWithImage(imageBase64, msgText);
      } else {
        response = await _router.route(_chatStore.activeMessages, modelQuery);
      }
      
      stopwatch.stop();
      
      final aiMsg = ChatMessage(
        content: response,
        isUser: false,
        modelUsed: _connectionStore.isLaptopConnected
            ? ModelUsed.remoteE2B
            : _connectionStore.isLocalModelAvailable
                ? ModelUsed.localE2B
                : ModelUsed.none,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
      
      _chatStore.addMessage(aiMsg);
      await _storage.saveLastActive();
      StreakService().recordStudy(); // fire-and-forget
    } catch (e) {
      _chatStore.addMessage(ChatMessage(
        content: '❌ Error: ${e.toString()}',
        isUser: false,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePdfImport() async {
    try {
      final result = await PdfService.pickAndExtract();
      if (result == null) return; // user cancelled

      setState(() => _pdfContext = result);

      // Show a snack with a brief summary + prompt hint
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
              '📄 "${result.fileName}" loaded '
              '(${result.extractedPages}/${result.totalPages} pages). '
              'Now type your question about this PDF.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF error: $e')),
        );
      }
    }
  }

  Future<void> _handleFlashcards(AppLocalizations l10n) async {
    final topic = _chatStore.activeSession?.lastTopic ?? '';
    if (topic.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final cards = await _flashcardGenerator.generate(_chatStore.activeMessages, topic);
      if (cards.isNotEmpty) {
        _flashcardStore.addCards(cards);
        
        final successMsg = _localeStore.languageCode == 'zh' 
            ? '✅ 已为您讨论的主题 "$topic" 生成了 ${cards.length} 张闪卡。' 
            : '✅ Generated ${cards.length} flashcards about "$topic".';

        _chatStore.addMessage(ChatMessage(
          content: successMsg,
          isUser: false,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSummary(AppLocalizations l10n) async {
    final messages = _chatStore.activeMessages;
    if (messages.isEmpty) return;

    final lang = _localeStore.languageCode;

    // Build a transcript of up to 30 messages, truncating long ones so we
    // don't overflow the local model's context window (~2 k tokens).
    final transcript = messages
        .where((m) => m.content.isNotEmpty)
        .take(30)
        .map((m) {
          final role = m.isUser ? (lang == 'zh' ? '我' : 'User') : 'AI';
          final body = m.content.length > 500
              ? '${m.content.substring(0, 500)}…'
              : m.content;
          return '$role: $body';
        })
        .join('\n\n');

    final instruction = switch (lang) {
      'zh' => '以下是对话内容，请直接输出3-5个要点总结，每行前面加 • 符号，不要输出任何其他内容：',
      'ja' => '以下の会話を読み、3〜5つの要点を • で始めてまとめてください。余計な説明は不要です：',
      'ko' => '다음 대화를 읽고 3-5개의 핵심 요점을 • 로 시작하여 요약해 주세요. 다른 내용은 출력하지 마세요：',
      'fr' => 'Lisez la conversation ci-dessous et résumez-la en 3 à 5 points clés, chacun commençant par •. Rien d\'autre :',
      'es' => 'Lee la conversación y resume en 3-5 puntos clave, cada uno comenzando con •. Solo los puntos:',
      _    => 'Read the conversation below and output ONLY 3-5 bullet points (each starting with •) that summarize the key topics. No preamble:',
    };

    final fullPrompt = '$instruction\n\n$transcript';

    // Show the user a placeholder message immediately so the UI feels responsive
    final userVisibleText = switch (lang) {
      'zh' => '📋 请总结我们的对话',
      'ja' => '📋 会話を要約してください',
      'ko' => '📋 대화 요약해주세요',
      'fr' => '📋 Résumez notre conversation',
      'es' => '📋 Resume nuestra conversación',
      _    => '📋 Summarize our conversation',
    };

    // Add user-visible message manually (doesn't go to model)
    _chatStore.addMessage(ChatMessage(content: userVisibleText, isUser: true));
    setState(() => _isLoading = true);
    final stopwatch = Stopwatch()..start();

    try {
      // Route with the full transcript embedded — local model gets everything
      final response = await _router.route([], fullPrompt);
      stopwatch.stop();
      _chatStore.addMessage(ChatMessage(
        content: response,
        isUser: false,
        modelUsed: _connectionStore.isLaptopConnected
            ? ModelUsed.remoteE2B
            : _connectionStore.isLocalModelAvailable
                ? ModelUsed.localE2B
                : ModelUsed.none,
        latencyMs: stopwatch.elapsedMilliseconds,
      ));
    } catch (e) {
      _chatStore.addMessage(ChatMessage(
        content: '❌ Error: ${e.toString()}',
        isUser: false,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Mind map ────────────────────────────────────────────────────────────────

  Future<void> _handleMindMap(AppLocalizations l10n) async {
    final messages = _chatStore.activeMessages;
    if (messages.isEmpty) return;

    final transcript = messages
        .where((m) => m.content.isNotEmpty)
        .take(20)
        .map((m) {
          final role = m.isUser ? 'User' : 'AI';
          final body = m.content.length > 300
              ? '${m.content.substring(0, 300)}…'
              : m.content;
          return '$role: $body';
        })
        .join('\n\n');

    // The system override tells the local model to wrap output in a ```json
    // code fence. sanitizeResponse() leaves fenced blocks untouched (it only
    // strips curly braces from prose), so the JSON survives sanitisation intact.
    const systemOverride =
        'You are a JSON generator. Output ONLY a single JSON code block '
        'wrapped in triple-backtick json fences (```json ... ```). '
        'No text before or after the code block. '
        'The JSON must have a "topic" string and a "children" array. '
        'Each child has a "label" string and its own "children" array. '
        '3-6 main branches, 2-4 items per branch, labels under 5 words.';

    final fullPrompt =
        'Generate a mind map JSON that captures the key topics from the '
        'conversation below.\n\nConversation:\n$transcript';

    setState(() => _isLoading = true);
    String? rawResponse;
    try {
      rawResponse = await _router.route(
        [],
        fullPrompt,
        systemPromptOverride: systemOverride,
      );
      debugPrint('[MindMap] raw response:\n$rawResponse');
      final jsonStr = _extractJsonObject(rawResponse);
      if (jsonStr == null) {
        throw Exception('No JSON object found in response');
      }
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MindMapScreen(data: data)),
        );
      }
    } catch (e) {
      debugPrint('[MindMap] error: $e\nraw: $rawResponse');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mindMapError),
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: () => _handleMindMap(l10n),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Extracts the first complete JSON object from [text].
  ///
  /// Handles two formats:
  ///  1. JSON wrapped in a ```json … ``` code fence (preferred — survives
  ///     sanitiseResponse which strips bare curly braces from prose).
  ///  2. Raw JSON anywhere in the text (brace-depth counting fallback).
  String? _extractJsonObject(String text) {
    // ── 1. Try code-fence unwrap first ──────────────────────────────────────
    final fenceMatch =
        RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
    final working = fenceMatch != null ? (fenceMatch.group(1) ?? text) : text;

    // ── 2. Brace-depth counting ──────────────────────────────────────────────
    int depth = 0;
    int start = -1;
    for (int i = 0; i < working.length; i++) {
      final c = working[i];
      if (c == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (c == '}') {
        depth--;
        if (depth == 0 && start != -1) return working.substring(start, i + 1);
      }
    }
    return null;
  }

  Future<void> _handleQuiz(AppLocalizations l10n) async {
    final topic = _chatStore.activeSession?.lastTopic ?? '';
    if (topic.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final questions = await _quizGenerator.generate(_chatStore.activeMessages, topic);
      if (mounted && questions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(questions: questions, topic: topic)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final session = _chatStore.activeSession;
    
    String displayTitle = session?.title ?? l10n.studyChat;
    if (displayTitle == 'New Chat') {
      displayTitle = l10n.newChat;
    }

    final messages = _chatStore.activeMessages;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicButton(
            padding: EdgeInsets.zero,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
            ),
            child: const Icon(Icons.menu),
          ),
        ),
        title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          const ConnectionIndicator(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _router.checkConnection(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return MessageBubble(
                    message: ChatMessage(
                      content: l10n.welcomeMessage,
                      isUser: false,
                    ),
                    isThinking: false,
                  );
                }
                final msg = messages[index - 1];
                if (msg.content == AppConstants.welcomeMessage) {
                  return const SizedBox.shrink();
                }
                return MessageBubble(
                  message: msg,
                  isThinking: _isLoading && index == messages.length && !msg.isUser,
                );
              },
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
          QuickActionChips(
            isLoading: _isLoading,
            onFlashcards: () => _handleFlashcards(l10n),
            onQuiz: () => _handleQuiz(l10n),
            onSummary: () => _handleSummary(l10n),
            onMindMap: () => _handleMindMap(l10n),
            onPlan: () => _sendMessage(text: l10n.promptPlan),
            onTranslate: () => _sendMessage(text: l10n.promptTranslate),
            onCamera: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CaptureScreen()),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PDF active banner
                if (_pdfContext != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4361EE).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF4361EE).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            size: 16, color: Color(0xFF4361EE)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '📄 ${_pdfContext!.fileName} ready — type your question',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF4361EE)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _pdfContext = null),
                          child: const Icon(Icons.close,
                              size: 16, color: Color(0xFF4361EE)),
                        ),
                      ],
                    ),
                  ),

                Row(
              children: [
                // PDF import button
                Tooltip(
                  message: l10n.importDocument,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handlePdfImport,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pdfContext != null
                            ? const Color(0xFF4361EE)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 20,
                        color: _pdfContext != null
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _toggleVoiceInput,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? const Color(0xFF06D6A0) : Colors.transparent,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 20,
                      color: _isListening ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: _isListening
                            ? '🎤 Listening...'
                            : _pdfContext != null
                                ? 'Ask about the PDF…'
                                : 'Message GemMate...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _textController.text.trim().isNotEmpty ? () => _sendMessage() : null,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _textController.text.trim().isNotEmpty
                          ? const Color(0xFF4361EE)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ), // Row
              ], // Column children
            ), // Column
          ),
        ],
      ),
    );
  }
}
