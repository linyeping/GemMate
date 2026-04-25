import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// A polished code block widget matching the Claude / Gemini web style:
///   ┌─────────────────────────────────────┐
///   │ dart                         [copy] │  ← header bar
///   ├─────────────────────────────────────┤
///   │  horizontally scrollable code       │
///   └─────────────────────────────────────┘
class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String language;

  const CodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1E1E2E);    // always-dark code area
    const headerColor = Color(0xFF2A2A3E);
    const langColor = Color(0xFF9CA3AF);
    const codeColor = Color(0xFFE2E8F0);

    final displayLang = widget.language.trim().isEmpty
        ? 'code'
        : widget.language.toLowerCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── header bar ──────────────────────────────────────────────────
          Container(
            height: 36,
            color: headerColor,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  displayLang,
                  style: const TextStyle(
                    color: langColor,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _copied
                        ? const Row(
                            key: ValueKey('copied'),
                            children: [
                              Icon(Icons.check, size: 14, color: Color(0xFF4ADE80)),
                              SizedBox(width: 4),
                              Text(
                                'Copied',
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            key: ValueKey('copy'),
                            children: [
                              Icon(Icons.copy_rounded, size: 14, color: langColor),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  color: langColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── code area ───────────────────────────────────────────────────
          Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: SelectableText(
                widget.code.trimRight(),
                style: const TextStyle(
                  color: codeColor,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.55,
                  // no word wrap — handled by horizontal scroll
                ),
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// flutter_markdown element builder
// flutter_markdown wraps fenced code blocks in a <pre><code class="language-X">
// element tree. This builder intercepts that and delegates to CodeBlockWidget.
// ─────────────────────────────────────────────────────────────────────────────

class CodeBlockBuilder extends MarkdownElementBuilder {
  // Tell flutter_markdown this builder handles a block-level element.
  // NOTE: flutter_markdown 0.7.x declares this as a method, not a getter.
  @override
  bool isBlockElement() => true;

  // ── KEY FIX ──────────────────────────────────────────────────────────────
  // flutter_markdown's MarkdownBuilder._addAnonymousBlockIfNeeded() only
  // calls _inlines.clear() when inline.children.isNotEmpty.  Because we
  // handle rendering entirely in visitElementAfterWithContext, our visitText
  // normally returns null — leaving _inlines non-empty at document end, which
  // triggers the `assert(_inlines.isEmpty)` crash at builder.dart:267.
  //
  // Returning SizedBox.shrink() (a non-null, zero-size widget) causes
  // children to be non-empty → _addAnonymousBlockIfNeeded clears _inlines →
  // assertion passes.  The zero-size widget is placed in the pre block's
  // discarded `current.children` list that is never rendered because our
  // visitElementAfterWithContext returns a non-null widget (which bypasses
  // defaultChild()).
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) =>
      const SizedBox.shrink();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // `element` is the <pre> node; its first child is <code class="language-X">
    final codeEl = (element.children?.isNotEmpty == true)
        ? element.children!.first
        : null;

    String rawCode = '';
    String language = '';

    if (codeEl is md.Element) {
      rawCode = codeEl.textContent;
      final cls = codeEl.attributes['class'] ?? '';
      if (cls.startsWith('language-')) {
        language = cls.substring('language-'.length);
      }
    } else {
      // Fallback: inline code that somehow reached this builder
      rawCode = element.textContent;
    }

    return CodeBlockWidget(code: rawCode, language: language);
  }
}
