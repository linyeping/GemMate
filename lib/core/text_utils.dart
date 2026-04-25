// ─────────────────────────────────────────────────────────────────────────────
// Heuristic patterns that strongly suggest a code block
// ─────────────────────────────────────────────────────────────────────────────
final _codeKeywords = RegExp(
  r'#include\s*<|'          // C/C++ includes
  r'\bint main\s*\(|'       // C/C++ main
  r'\bvoid\s+\w+\s*\(|'    // C/C++ void functions
  r'\bimport\s+[\w.]+\s*;|' // Java/Dart imports
  r'\bpublic\s+class\s+|'  // Java class
  r'\bdef\s+\w+\s*\(|'     // Python def
  r'\bfn\s+\w+\s*\(|'      // Rust fn
  r'\bfunc\s+\w+\s*\(|'    // Go func
  r'console\.log\s*\(|'    // JS
  r'\bconst\s+\w+\s*=|'    // JS/TS const
  r'\blet\s+\w+\s*=',      // JS/TS let
);

/// Detects whether [line] looks like it belongs to a code block
/// (contains typical programming patterns that break markdown if bare).
bool _looksLikeCode(String line) =>
    _codeKeywords.hasMatch(line) ||
    line.trimLeft().startsWith('//') ||   // line comment
    line.trimLeft().startsWith('#!') ||   // shebang
    (line.contains('(') && line.contains(')') && line.contains(';'));

/// Wraps consecutive "bare code" lines that are NOT already inside a
/// fenced code block with a generic ``` fence.
/// This is a last-resort fallback for models that ignore the system prompt.
String autoFenceBareCcode(String text) {
  // If there are already fenced blocks, check line-by-line for naked code
  final lines = text.split('\n');
  final out = <String>[];
  bool inFence = false;
  bool inBareCode = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    // Track real fences
    if (trimmed.startsWith('```')) {
      inFence = !inFence;
      if (inBareCode) {
        // Close the auto-fence we opened
        out.add('```');
        inBareCode = false;
      }
      out.add(line);
      continue;
    }

    if (inFence) {
      out.add(line);
      continue;
    }

    // Outside any fence: check if this looks like naked code
    if (_looksLikeCode(line)) {
      if (!inBareCode) {
        out.add('```'); // open with no lang tag (generic)
        inBareCode = true;
      }
      out.add(line);
    } else {
      if (inBareCode && trimmed.isNotEmpty) {
        // Non-empty non-code line ends the bare-code block
        out.add('```');
        inBareCode = false;
      } else if (inBareCode && trimmed.isEmpty) {
        // Blank line inside bare code is fine — keep accumulating
        out.add(line);
        continue;
      }
      out.add(line);
    }
  }

  if (inBareCode) out.add('```'); // close if still open at EOF
  return out.join('\n');
}

/// Cleans up AI-model output for display:
///  • Strips bold / italic / header markdown from prose
///  • Converts LaTeX notation to plain-text equivalents
///  • Leaves fenced code blocks (``` ... ```) completely untouched
///    so that underscores, braces, and special chars inside code are preserved
String sanitizeResponse(String text) {
  // ── 1. Split on fenced code blocks ────────────────────────────────────────
  // Pattern captures: opening fence+lang, body, closing fence.
  // Segments alternate: [prose, code, prose, code, …]
  final fenceRegex = RegExp(r'(```[^\n]*\n[\s\S]*?```)', multiLine: true);

  final parts = <_TextPart>[];
  int cursor = 0;
  for (final m in fenceRegex.allMatches(text)) {
    if (m.start > cursor) {
      parts.add(_TextPart(text.substring(cursor, m.start), isCode: false));
    }
    parts.add(_TextPart(m.group(0)!, isCode: true));
    cursor = m.end;
  }
  if (cursor < text.length) {
    parts.add(_TextPart(text.substring(cursor), isCode: false));
  }

  // ── 2. Sanitise only the prose segments ───────────────────────────────────
  final buffer = StringBuffer();
  for (final part in parts) {
    if (part.isCode) {
      buffer.write(part.text); // code blocks: pass through unchanged
    } else {
      buffer.write(_sanitizeProse(part.text));
    }
  }

  return buffer.toString().trim();
}

class _TextPart {
  final String text;
  final bool isCode;
  const _TextPart(this.text, {required this.isCode});
}

String _sanitizeProse(String text) {
  String r = text;

  // Remove Markdown bold / italic (** __ * _), but only in prose
  r = r.replaceAll(RegExp(r'\*\*([^*\n]+)\*\*'), r'$1');   // **bold**
  r = r.replaceAll(RegExp(r'\*([^*\n]+)\*'), r'$1');        // *italic*
  r = r.replaceAll(RegExp(r'__([^_\n]+)__'), r'$1');        // __bold__
  r = r.replaceAll(RegExp(r'_([^_\n]+)_'), r'$1');          // _italic_

  // Remove Markdown headers
  r = r.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

  // Remove LaTeX delimiters
  r = r.replaceAll(RegExp(r'\\\['), '');
  r = r.replaceAll(RegExp(r'\\\]'), '');
  r = r.replaceAll(RegExp(r'\\\('), '');
  r = r.replaceAll(RegExp(r'\\\)'), '');
  r = r.replaceAll(RegExp(r'\$\$'), '');
  r = r.replaceAll(r'$', '');

  // Common LaTeX → plain text
  r = r.replaceAllMapped(
      RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
      (m) => '(${m[1]}/${m[2]})');
  r = r.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]*)\}'), (m) => 'sqrt(${m[1]})');
  r = r.replaceAllMapped(
      RegExp(r'\\text\{([^}]*)\}'), (m) => '${m[1]}');
  r = r.replaceAll(RegExp(r'\\times'), '×');
  r = r.replaceAll(RegExp(r'\\div'), '÷');
  r = r.replaceAll(RegExp(r'\\pm'), '±');
  r = r.replaceAll(RegExp(r'\\leq'), '≤');
  r = r.replaceAll(RegExp(r'\\geq'), '≥');
  r = r.replaceAll(RegExp(r'\\neq'), '≠');
  r = r.replaceAll(RegExp(r'\\infty'), '∞');
  r = r.replaceAll(RegExp(r'\\pi'), 'π');
  r = r.replaceAll(RegExp(r'\\quad'), ' ');
  r = r.replaceAll(RegExp(r'\\\\'), '\n');

  // Remove remaining LaTeX commands and leftover braces (prose only — safe here)
  r = r.replaceAll(RegExp(r'\\[a-zA-Z]+'), '');
  r = r.replaceAll(RegExp(r'[{}]'), '');

  // Clean up excess whitespace
  r = r.replaceAll(RegExp(r'  +'), ' ');
  r = r.replaceAll(RegExp(r'\n\n\n+'), '\n\n');

  return r;
}
