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

  /// Detect if a user message has an embedded PDF attachment prefix.
  /// Format: "📄 [filename.pdf]\nactual question"
  static _PdfUserContent? _parsePdfContent(String content) {
    if (!content.startsWith('📄 [')) return null;
    final bracketEnd = content.indexOf(']\n');
    if (bracketEnd == -1) return null;
    final fileName = content.substring(4, bracketEnd); // strip "📄 ["
    final question = content.substring(bracketEnd + 2).trim(); // skip "]\n"
    return _PdfUserContent(fileName: fileName, question: question);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final themeStore = ThemeStore();
    final fontSize = themeStore.fontSize;
    final isDark = theme.brightness == Brightness.dark;
    final aiAvatar = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    if (isUser) {
      return _UserBubble(
        message: message,
        theme: theme,
        fontSize: fontSize,
      );
    }

    // ── AI message: Gemini-style layout ──────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: avatar + "GemMate" label
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  aiAvatar,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GemMate',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Full-width content — no bubble background
          isThinking
              ? _ThinkingDots(fontSize: fontSize)
              : MarkdownBody(
                  data: message.content,
                  selectable: true,
                  builders: {'pre': CodeBlockBuilder()},
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize,
                      height: 1.5,
                    ),
                    listBullet: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize,
                    ),
                    code: const TextStyle(inherit: false),
                    codeblockDecoration: const BoxDecoration(),
                    codeblockPadding: EdgeInsets.zero,
                  ),
                ),

          // Model badge
          if (message.modelUsed != ModelUsed.none)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ModelBadge(
                modelUsed: message.modelUsed,
                latencyMs: message.latencyMs,
              ),
            ),
        ],
      ),
    );
  }
}

// ── User bubble ───────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  final double fontSize;

  const _UserBubble({
    required this.message,
    required this.theme,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final pdfContent = MessageBubble._parsePdfContent(message.content);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Optional image attachment
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

                // PDF attachment chip (shown above the question bubble)
                if (pdfContent != null) ...[
                  _PdfAttachmentChip(fileName: pdfContent.fileName),
                  const SizedBox(height: 4),
                ],

                // Main text bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(4),
                    ),
                  ),
                  child: SelectableText(
                    pdfContent != null ? pdfContent.question : message.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                    ),
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

// ── PDF attachment chip ───────────────────────────────────────────────────────

class _PdfAttachmentChip extends StatelessWidget {
  final String fileName;
  const _PdfAttachmentChip({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4361EE).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4361EE).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf_outlined,
              size: 16, color: Color(0xFF4361EE)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4361EE),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thinking dots animation ───────────────────────────────────────────────────

class _ThinkingDots extends StatefulWidget {
  final double fontSize;
  const _ThinkingDots({required this.fontSize});

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (t - i * 0.15).clamp(0.0, 1.0);
            final opacity = (0.3 + 0.7 * (0.5 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF4361EE),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _PdfUserContent {
  final String fileName;
  final String question;
  const _PdfUserContent({required this.fileName, required this.question});
}
