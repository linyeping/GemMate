import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleStore extends ChangeNotifier {
  static final LocaleStore _instance = LocaleStore._();
  factory LocaleStore() => _instance;
  LocaleStore._();

  final StorageService _storage = StorageService();
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;

  String get languageName => switch (languageCode) {
    'zh' => '简体中文',
    'ja' => '日本語',
    'ko' => '한국어',
    'fr' => 'Français',
    'es' => 'Español',
    _ => 'English',
  };

  String get aiLanguageInstruction => switch (languageCode) {
    'zh' => 'Respond in Simplified Chinese (简体中文) only.',
    'ja' => 'Respond in Japanese (日本語) only.',
    'ko' => 'Respond in Korean (한국어) only.',
    'fr' => 'Respond in French (Français) only.',
    'es' => 'Respond in Spanish (Español) only.',
    _ => 'Respond in English only.',
  };

  static const supportedLocales = [
    Locale('en'), Locale('zh'), Locale('ja'), Locale('ko'), Locale('fr'), Locale('es'),
  ];

  Future<void> load() async {
    final saved = await _storage.loadLocale();
    if (saved != null) {
      _currentLocale = Locale(saved);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    _storage.saveLocale(locale.languageCode);
    notifyListeners();
  }
}
