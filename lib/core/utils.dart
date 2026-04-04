import 'dart:convert';
import 'package:intl/intl.dart';

class AppUtils {
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return DateFormat.yMMMd().format(date);
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static List<T> safeJsonList<T>(String jsonStr, T Function(Map<String, dynamic>) fromJson) {
    try {
      String cleaned = jsonStr.trim();
      // Strip markdown if present
      if (cleaned.contains('```')) {
        final start = cleaned.indexOf('[');
        final end = cleaned.lastIndexOf(']');
        if (start != -1 && end != -1) {
          cleaned = cleaned.substring(start, end + 1);
        }
      }

      final List<dynamic> decoded = jsonDecode(cleaned);
      return decoded.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Safe JSON List Parse Error: $e');
      return [];
    }
  }
}
