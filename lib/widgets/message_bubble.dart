import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../stores/theme_store.dart';
import 'code_block.dart';
import 'model_badge.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isThinking;

  const MessageBubble({
    super.key,
    required this.message,
    this.isThinking = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final themeStore = ThemeStore();
    final fontSize = themeStore.fontSize;
    final isDark = theme.brightness == Brightness.dark;
    final aiAvatar = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ClipOval(
              child: Image.asset(
                aiAvatar,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.imageBase64 != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(message.imageBase64!),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? const Color(0xFF4361EE) 
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                  ),
                  child: isUser
                      ? SelectableText(
                          message.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          builders: {
                            'pre': CodeBlockBuilder(),
                          },
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSize,
                              height: 1.5,
                            ),
                            listBullet: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSize,
                            ),
                            // Remove the default grey box — CodeBlockBuilder
                            // renders its own styled container.
                            code: const TextStyle(inherit: false),
                            codeblockDecoration: const BoxDecoration(),
                            codeblockPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
                if (!isUser && message.modelUsed != ModelUsed.none)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: ModelBadge(
                      modelUsed: message.modelUsed,
                      latencyMs: message.latencyMs,
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
