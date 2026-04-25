import 'dart:convert';

List<Map<String, dynamic>> robustJsonParse(String response) {
  String text = response.trim();
  
  // Remove markdown code blocks
  text = text.replaceAll(RegExp(r'```json\s*', multiLine: true), '');
  text = text.replaceAll(RegExp(r'```\s*', multiLine: true), '');
  text = text.trim();
  
  // Remove any text before the first [ or {
  final firstBracket = text.indexOf('[');
  final firstBrace = text.indexOf('{');
  int startPos = -1;
  if (firstBracket >= 0 && (firstBrace < 0 || firstBracket < firstBrace)) {
    startPos = firstBracket;
  } else if (firstBrace >= 0) {
    startPos = firstBrace;
  }

  if (startPos != -1) {
    text = text.substring(startPos);
  }
  
  // Remove any text after the last ] or }
  final lastBracket = text.lastIndexOf(']');
  final lastBrace = text.lastIndexOf('}');
  int endPos = -1;
  if (lastBracket >= 0 && lastBracket > lastBrace) {
    endPos = lastBracket;
  } else if (lastBrace >= 0) {
    endPos = lastBrace;
  }

  if (endPos != -1) {
    text = text.substring(0, endPos + 1);
  }

  // === NEW FIX: Handle malformed format ["key":"val","key":"val"] ===
  // The model returns ["front":"X","back":"Y","front":"Z","back":"W"]
  // We need to convert this to [{"front":"X","back":"Y"},{"front":"Z","back":"W"}]
  if (text.startsWith('[') && !text.startsWith('[{')) {
    try {
      // Remove outer brackets
      String inner = text.substring(1, text.length - 1).trim();
      
      List<String> objectStrings = [];
      
      // Try splitting by "front" key (flashcards)
      if (inner.contains('"front"')) {
        final parts = inner.split(RegExp(r',\s*"front"'));
        for (int i = 0; i < parts.length; i++) {
          String part = i == 0 ? parts[i] : '"front"${parts[i]}';
          part = part.trim();
          if (part.endsWith(',')) part = part.substring(0, part.length - 1);
          if (!part.startsWith('{')) part = '{$part';
          if (!part.endsWith('}')) part = '$part}';
          objectStrings.add(part);
        }
      }
      // Try splitting by "question" key (quizzes)
      else if (inner.contains('"question"')) {
        final parts = inner.split(RegExp(r',\s*"question"'));
        for (int i = 0; i < parts.length; i++) {
          String part = i == 0 ? parts[i] : '"question"${parts[i]}';
          part = part.trim();
          if (part.endsWith(',')) part = part.substring(0, part.length - 1);
          if (!part.startsWith('{')) part = '{$part';
          if (!part.endsWith('}')) part = '$part}';
          objectStrings.add(part);
        }
      }
      
      if (objectStrings.isNotEmpty) {
        final results = <Map<String, dynamic>>[];
        for (final objStr in objectStrings) {
          try {
            final decoded = jsonDecode(objStr);
            if (decoded is Map) {
              results.add(Map<String, dynamic>.from(decoded));
            }
          } catch (e) {
            print('Failed to parse object: $objStr — $e');
          }
        }
        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      print('Malformed array fix failed: $e');
    }
  }
  // === END NEW FIX ===

  // Try 1: Parse as JSON array directly
  try {
    final decoded = jsonDecode(text);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (decoded is Map) {
      return [Map<String, dynamic>.from(decoded)];
    }
  } catch (_) {}

  // Try 2: Wrap in array brackets
  try {
    final wrapped = '[$text]';
    final decoded = jsonDecode(wrapped);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
  } catch (_) {}

  // Try 3: Fix common issues — trailing commas, missing commas
  try {
    String fixed = text;
    // Remove trailing comma before ] or }
    fixed = fixed.replaceAll(RegExp(r',\s*\]'), ']');
    fixed = fixed.replaceAll(RegExp(r',\s*\}'), '}');
    // Add missing comma between } {
    fixed = fixed.replaceAll(RegExp(r'\}\s*\{'), '},{');
    // Wrap in array if not already
    if (!fixed.startsWith('[')) {
      fixed = '[$fixed]';
    }
    final decoded = jsonDecode(fixed);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
  } catch (_) {}
  
  // Try 4: Extract individual JSON objects with regex
  try {
    final regex = RegExp(r'\{[^{}]+\}');
    final matches = regex.allMatches(text);
    if (matches.isNotEmpty) {
      final results = <Map<String, dynamic>>[];
      for (final match in matches) {
        try {
          String obj = match.group(0)!;
          // Remove trailing comma
          if (obj.endsWith(',')) obj = obj.substring(0, obj.length - 1);
          final decoded = jsonDecode(obj);
          if (decoded is Map) {
            results.add(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }
      if (results.isNotEmpty) return results;
    }
  } catch (_) {}
  
  print('robustJsonParse: Failed to parse: $text');
  return [];
}
