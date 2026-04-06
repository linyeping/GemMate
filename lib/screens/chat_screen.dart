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
import '../widgets/message_bubble.dart';
import '../widgets/quick_action_chips.dart';
import '../widgets/connection_indicator.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/neumorphic_button.dart';
import 'chat_history_screen.dart';
import 'quiz_screen.dart';
import 'capture_screen.dart';
import '../l10n/app_localizations.dart';
import '../core/constants.dart';

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
        onError: (error) {
          print('Speech error: ${error.errorMsg}');
          if (error.permanent) {
            if (mounted) setState(() => _isListening = false);
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
    
    print('No matching locale found, using system default');
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

    final userMsg = ChatMessage(
      content: msgText,
      isUser: true,
      imageBase64: imageBase64,
    );
    
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
        response = await _router.route(_chatStore.activeMessages, msgText);
      }
      
      stopwatch.stop();
      
      final aiMsg = ChatMessage(
        content: response,
        isUser: false,
        modelUsed: _connectionStore.isConnected ? ModelUsed.remoteE2B : ModelUsed.none,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
      
      _chatStore.addMessage(aiMsg);
      await _storage.saveLastActive();
    } catch (e) {
      _chatStore.addMessage(ChatMessage(
        content: '❌ Error: ${e.toString()}',
        isUser: false,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleVoiceInput,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? const Color(0xFF06D6A0) : Colors.transparent,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 22,
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
                        hintText: _isListening ? '🎤 Listening...' : 'Message GemMate...',
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
            ),
          ),
        ],
      ),
    );
  }
}
