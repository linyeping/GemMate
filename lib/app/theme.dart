import 'package:flutter/material.dart';

enum AppColorScheme {
  ocean, sunset, forest, lavender, aurora, cherry, midnight, candy
}

class GemmaStudyTheme {
  static Color currentHighlight = Colors.white;
  static Color currentShadow = const Color(0xFFA3B1C6);

  static ({Color bg, Color high, Color shadow, Color primary, String desc}) getNeumorphicColors(AppColorScheme scheme, bool isDark) {
    if (!isDark) {
      return switch (scheme) {
        AppColorScheme.ocean    => (bg: const Color(0xFFE0E5EC), high: Colors.white, shadow: const Color(0xFFA3B1C6), primary: const Color(0xFF1565C0), desc: 'Deep ocean blue with soft grey shadows'),
        AppColorScheme.sunset   => (bg: const Color(0xFFFFF1F0), high: Colors.white, shadow: const Color(0xFFEBCACA), primary: const Color(0xFFE65100), desc: 'Warm sunset hues with peach undertones'),
        AppColorScheme.forest   => (bg: const Color(0xFFF0F7F0), high: Colors.white, shadow: const Color(0xFFC8DAC8), primary: const Color(0xFF2E7D32), desc: 'Fresh forest green with natural shadows'),
        AppColorScheme.lavender => (bg: const Color(0xFFF7F0F9), high: Colors.white, shadow: const Color(0xFFD9C5DE), primary: const Color(0xFF7B1FA2), desc: 'Calming lavender purple with soft violet mist'),
        AppColorScheme.aurora   => (bg: const Color(0xFFF0F9F8), high: Colors.white, shadow: const Color(0xFFB8D1D1), primary: const Color(0xFF00695C), desc: 'Cool arctic teal inspired by the Northern Lights'),
        AppColorScheme.cherry   => (bg: const Color(0xFFFFF0F0), high: Colors.white, shadow: const Color(0xFFDAC0C0), primary: const Color(0xFFC62828), desc: 'Vibrant cherry red with warm rose shadows'),
        AppColorScheme.midnight => (bg: const Color(0xFFF0F2F9), high: Colors.white, shadow: const Color(0xFFC0C4D6), primary: const Color(0xFF1A237E), desc: 'Deep midnight navy with crisp evening air'),
        AppColorScheme.candy    => (bg: const Color(0xFFFFF0F7), high: Colors.white, shadow: const Color(0xFFE6CAD2), primary: const Color(0xFFE91E63), desc: 'Sweet cotton candy pink with playful highlights'),
      };
    } else {
      return switch (scheme) {
        AppColorScheme.ocean    => (bg: const Color(0xFF1D2023), high: const Color(0xFF282B2E), shadow: const Color(0xFF121416), primary: const Color(0xFF4DD0E1), desc: 'Dark marine depth with cyan neon glow'),
        AppColorScheme.sunset   => (bg: const Color(0xFF241A18), high: const Color(0xFF2F221F), shadow: const Color(0xFF191211), primary: const Color(0xFFFFAB40), desc: 'Dimming twilight with amber accents'),
        AppColorScheme.forest   => (bg: const Color(0xFF161D16), high: const Color(0xFF1F291F), shadow: const Color(0xFF0E130E), primary: const Color(0xFFA5D6A7), desc: 'Deep night woods with pine green highlights'),
        AppColorScheme.lavender => (bg: const Color(0xFF1D1824), high: const Color(0xFF282133), shadow: const Color(0xFF121019), primary: const Color(0xFFCE93D8), desc: 'Enchanted violet night with purple aura'),
        AppColorScheme.aurora   => (bg: const Color(0xFF121D1C), high: const Color(0xFF1A2928), shadow: const Color(0xFF0A1312), primary: const Color(0xFF80CBC4), desc: 'Mystical teal night with glowing horizon'),
        AppColorScheme.cherry   => (bg: const Color(0xFF221616), high: const Color(0xFF2D1B1B), shadow: const Color(0xFF170F0F), primary: const Color(0xFFFF8A80), desc: 'Velvet dark red with crimson undertones'),
        AppColorScheme.midnight => (bg: const Color(0xFF141624), high: const Color(0xFF1B1F33), shadow: const Color(0xFF0D0F1A), primary: const Color(0xFF7986CB), desc: 'Outer space navy with starlight blue'),
        AppColorScheme.candy    => (bg: const Color(0xFF24181D), high: const Color(0xFF332129), shadow: const Color(0xFF191014), primary: const Color(0xFFF48FB1), desc: 'Neon pink fantasy with sweet shadow play'),
      };
    }
  }

  static ThemeData lightTheme(AppColorScheme scheme) {
    final colors = getNeumorphicColors(scheme, false);
    currentHighlight = colors.high;
    currentShadow = colors.shadow;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: colors.primary, brightness: Brightness.light, surface: colors.bg),
      appBarTheme: AppBarTheme(backgroundColor: colors.bg, elevation: 0),
    );
  }

  static ThemeData darkTheme(AppColorScheme scheme) {
    final colors = getNeumorphicColors(scheme, true);
    currentHighlight = colors.high;
    currentShadow = colors.shadow;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.fromSeed(seedColor: colors.primary, brightness: Brightness.dark, surface: colors.bg),
      appBarTheme: AppBarTheme(backgroundColor: colors.bg, elevation: 0),
    );
  }
}
