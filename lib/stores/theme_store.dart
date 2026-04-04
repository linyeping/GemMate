import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/storage_service.dart';

class ThemeStore extends ChangeNotifier {
  static final ThemeStore _instance = ThemeStore._();
  factory ThemeStore() => _instance;
  ThemeStore._();

  final StorageService _storage = StorageService();
  AppColorScheme _currentScheme = AppColorScheme.ocean;
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 15.0;

  AppColorScheme get currentScheme => _currentScheme;
  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  Future<void> load() async {
    _currentScheme = await _storage.loadThemeScheme();
    _themeMode = await _storage.loadThemeMode();
    _fontSize = await _storage.loadFontSize();
    notifyListeners();
  }

  void setScheme(AppColorScheme scheme) {
    if (_currentScheme == scheme) return;
    _currentScheme = scheme;
    _storage.saveThemeScheme(scheme);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _storage.saveThemeMode(mode);
    notifyListeners();
  }

  void setFontSize(double size) {
    if (_fontSize == size) return;
    _fontSize = size;
    _storage.saveFontSize(size);
    notifyListeners();
  }
}
