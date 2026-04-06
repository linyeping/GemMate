String sanitizeResponse(String text) {
  String result = text;
  // Remove Markdown bold/italic
  result = result.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');  // **bold** → bold
  result = result.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');      // *italic* → italic
  result = result.replaceAll(RegExp(r'__([^_]+)__'), r'$1');      // __bold__ → bold
  result = result.replaceAll(RegExp(r'_([^_]+)_'), r'$1');        // _italic_ → italic
  // Remove Markdown headers
  result = result.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
  // Remove LaTeX delimiters
  result = result.replaceAll(RegExp(r'\\\['), '');
  result = result.replaceAll(RegExp(r'\\\]'), '');
  result = result.replaceAll(RegExp(r'\\\('), '');
  result = result.replaceAll(RegExp(r'\\\)'), '');
  result = result.replaceAll(RegExp(r'\$\$'), '');
  result = result.replaceAll(RegExp(r'\$'), '');
  // Common LaTeX to plain text
  result = result.replaceAllMapped(RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'), (m) => '(${m[1]}/${m[2]})');
  result = result.replaceAllMapped(RegExp(r'\\sqrt\{([^}]*)\}'), (m) => 'sqrt(${m[1]})');
  result = result.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (m) => '${m[1]}');
  result = result.replaceAll(RegExp(r'\\times'), '×');
  result = result.replaceAll(RegExp(r'\\div'), '÷');
  result = result.replaceAll(RegExp(r'\\pm'), '±');
  result = result.replaceAll(RegExp(r'\\leq'), '≤');
  result = result.replaceAll(RegExp(r'\\geq'), '≥');
  result = result.replaceAll(RegExp(r'\\neq'), '≠');
  result = result.replaceAll(RegExp(r'\\infty'), '∞');
  result = result.replaceAll(RegExp(r'\\pi'), 'π');
  result = result.replaceAll(RegExp(r'\\quad'), ' ');
  result = result.replaceAll(RegExp(r'\\\\'), '\n');
  // Remove remaining LaTeX commands
  result = result.replaceAll(RegExp(r'\\[a-zA-Z]+'), '');
  // Remove leftover curly braces from LaTeX
  result = result.replaceAll(RegExp(r'[{}]'), '');
  // Clean up extra whitespace
  result = result.replaceAll(RegExp(r'  +'), ' ');
  result = result.replaceAll(RegExp(r'\n\n\n+'), '\n\n');
  return result.trim();
}
