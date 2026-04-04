import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';
import '../models/flashcard.dart';
import '../app/theme.dart';

class StorageService {
  static const _sessionsKey = 'gemma_sessions';
  static const _flashcardsKey = 'gemma_flashcards';
  static const _hostKey = 'ollama_host';
  static const _themeModeKey = 'theme_mode';
  static const _themeSchemeKey = 'theme_scheme';
  static const _localeKey = 'app_locale';
  static const _dailyReminderKey = 'daily_reminder_on';
  static const _reviewReminderKey = 'review_reminder_on';
  static const _inactivityReminderKey = 'inactivity_reminder_on';
  static const _lastActiveKey = 'last_active_time';
  static const _fontSizeKey = 'chat_font_size';

  Future<void> saveSessions(List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  Future<List<ChatSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sessionsKey);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((j) => ChatSession.fromJson(j)).toList();
  }

  Future<void> saveFlashcards(List<Flashcard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cards.map((c) => c.toJson()).toList();
    await prefs.setString(_flashcardsKey, jsonEncode(jsonList));
  }

  Future<List<Flashcard>> loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_flashcardsKey);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((j) => Flashcard.fromJson(j)).toList();
  }

  Future<void> saveOllamaHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, host);
  }

  Future<String?> loadOllamaHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hostKey);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  Future<void> saveThemeScheme(AppColorScheme scheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeSchemeKey, scheme.index);
  }

  Future<AppColorScheme> loadThemeScheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeSchemeKey) ?? AppColorScheme.ocean.index;
    return AppColorScheme.values[index];
  }

  Future<void> saveLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
  }

  Future<String?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  Future<void> saveNotificationToggles({
    required bool daily,
    required bool review,
    required bool inactivity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, daily);
    await prefs.setBool(_reviewReminderKey, review);
    await prefs.setBool(_inactivityReminderKey, inactivity);
  }

  Future<Map<String, bool>> loadNotificationToggles() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'daily': prefs.getBool(_dailyReminderKey) ?? true,
      'review': prefs.getBool(_reviewReminderKey) ?? true,
      'inactivity': prefs.getBool(_inactivityReminderKey) ?? true,
    };
  }

  Future<void> saveLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> loadLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastActiveKey);
    return str != null ? DateTime.parse(str) : null;
  }

  Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 15.0;
  }
}
