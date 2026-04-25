import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/storage_service.dart';
import '../services/smart_router.dart';
import '../services/local_gemma_service.dart';
import '../stores/connection_store.dart';
import '../core/constants.dart';

class ChatStore extends ChangeNotifier {
  static final ChatStore _instance = ChatStore._();
  factory ChatStore() => _instance;
  ChatStore._();

  final StorageService _storage = StorageService();
  final SmartRouter _router = SmartRouter(
    localGemma: LocalGemmaService(),
    connectionStore: ConnectionStore(),
  );

  List<ChatSession> _sessions = [];
  ChatSession? _activeSession;

  /// Only return sessions that have actual messages (ignore empty temp sessions)
  List<ChatSession> get sessions => List.unmodifiable(
    _sessions.where((s) => s.messages.isNotEmpty).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
  );

  ChatSession? get activeSession => _activeSession;
  List<ChatMessage> get activeMessages => _activeSession?.messages ?? [];

  Future<void> load() async {
    _sessions = await _storage.loadSessions();
    if (_sessions.isEmpty) {
      // Create a temporary active session but don't add to list yet
      _activeSession = ChatSession();
    } else {
      _activeSession = _sessions.first;
    }
    notifyListeners();
  }

  /// Sets up a new temporary session. It only enters history when the first message is added.
  void createNewSession() {
    _activeSession = ChatSession();
    notifyListeners();
  }

  void switchToSession(String id) {
    final session = _sessions.where((s) => s.id == id).firstOrNull;
    if (session != null) {
      _activeSession = session;
      notifyListeners();
    }
  }

  void renameSession(String id, String newTitle) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].title = newTitle;
      _saveToDisk();
      notifyListeners();
    }
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) {
      _activeSession = _sessions.isNotEmpty ? _sessions.first : ChatSession();
    }
    _saveToDisk();
    notifyListeners();
  }

  void deleteAllSessions() {
    _sessions.clear();
    _activeSession = ChatSession();
    _saveToDisk();
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    if (_activeSession == null) _activeSession = ChatSession();
    
    // If this is the first message in this session, add the session to our list
    if (!_sessions.contains(_activeSession)) {
      _sessions.insert(0, _activeSession!);
    }

    _activeSession!.messages.add(message);
    _activeSession!.updatedAt = DateTime.now();
    _activeSession!.autoTitle();
    
    // Limit stored sessions
    if (_sessions.length > AppConstants.maxStoredSessions) {
      _sessions.removeLast();
    }
    
    _saveToDisk();
    notifyListeners();
  }

  void updateLastTopic(String topic) {
    if (_activeSession != null) {
      _activeSession!.lastTopic = topic;
      _saveToDisk();
    }
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(content: text, isUser: true);
    addMessage(userMsg);

    try {
      final response = await _router.route(_activeSession!.messages, text);
      final conn = ConnectionStore();
      final modelUsed = conn.isLaptopConnected
          ? ModelUsed.remoteE2B
          : conn.isLocalModelAvailable
              ? ModelUsed.localE2B
              : ModelUsed.none;
      final aiMsg = ChatMessage(
        content: response,
        isUser: false,
        modelUsed: modelUsed,
      );
      addMessage(aiMsg);
    } catch (e) {
      addMessage(ChatMessage(content: 'Error: $e', isUser: false));
    }
  }

  void _saveToDisk() {
    // Only save sessions that have messages
    final sessionsToSave = _sessions.where((s) => s.messages.isNotEmpty).toList();
    _storage.saveSessions(sessionsToSave);
  }
}
