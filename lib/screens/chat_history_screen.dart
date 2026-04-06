import 'package:flutter/material.dart';
import '../stores/chat_store.dart';
import '../widgets/chat_session_tile.dart';
import '../widgets/neumorphic_button.dart';
import '../l10n/app_localizations.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatStore _chatStore = ChatStore();

  @override
  void initState() {
    super.initState();
    _chatStore.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _chatStore.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sessions = _chatStore.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatHistory),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicButton(
            padding: EdgeInsets.zero,
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicButton(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: () {
                _chatStore.createNewSession();
                Navigator.pop(context);
              },
              child: const Icon(Icons.add_comment_outlined),
            ),
          ),
        ],
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.noChatsYet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ChatSessionTile(
                  session: session,
                  isActive: _chatStore.activeSession?.id == session.id,
                  onTap: () {
                    _chatStore.switchToSession(session.id);
                    Navigator.pop(context);
                  },
                  onRename: (newTitle) => _chatStore.renameSession(session.id, newTitle),
                  onDelete: () => _chatStore.deleteSession(session.id),
                );
              },
            ),
    );
  }
}
