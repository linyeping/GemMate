import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'l10n/app_localizations.dart';
import 'stores/chat_store.dart';
import 'stores/flashcard_store.dart';
import 'stores/locale_store.dart';
import 'stores/theme_store.dart';
import 'stores/connection_store.dart';
import 'services/notification_service.dart';
import 'services/model_download_service.dart';
import 'services/local_gemma_service.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();

  // Initialize services and stores
  await NotificationService().initialize();
  await LocaleStore().load();
  await ThemeStore().load();
  await ChatStore().load();
  await FlashcardStore().load();

  // Try to initialize local model if installed
  final downloadService = ModelDownloadService();
  final modelInstalled = await downloadService.isModelInstalled();
  if (modelInstalled) {
    try {
      const externalPath = '/sdcard/Download/gemma-4-E2B-it.litertlm';
      final externalFile = File(externalPath);
      final appDir = await getApplicationDocumentsDirectory();
      final internalPath = '${appDir.path}/gemma-4-E2B-it.litertlm';
      final internalFile = File(internalPath);

      if (externalFile.existsSync() && !internalFile.existsSync()) {
        print('Main: Copying model to internal storage (one-time, ~30 seconds)...');
        await externalFile.copy(internalPath);
        print('Main: Copy complete');
      }

      if (internalFile.existsSync()) {
        await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
            .fromFile(internalPath)
            .install();
        print('Main: Model registered from internal storage');
      }

      final localGemma = LocalGemmaService();
      await localGemma.initialize();
      ConnectionStore().setLocalModelAvailable(localGemma.isAvailable);
      print('Main: Local model ready: ${localGemma.isAvailable}');
    } catch (e) {
      print('Main: Local model init failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(GemmaStudyApp(showOnboarding: !onboardingCompleted));
}

class GemmaStudyApp extends StatefulWidget {
  final bool showOnboarding;
  const GemmaStudyApp({super.key, required this.showOnboarding});

  @override
  State<GemmaStudyApp> createState() => _GemmaStudyAppState();
}

class _GemmaStudyAppState extends State<GemmaStudyApp> {
  final LocaleStore _localeStore = LocaleStore();
  final ThemeStore _themeStore = ThemeStore();

  @override
  void initState() {
    super.initState();
    _localeStore.addListener(_onStateChange);
    _themeStore.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _localeStore.removeListener(_onStateChange);
    _themeStore.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemmaStudy',
      debugShowCheckedModeBanner: false,
      locale: _localeStore.currentLocale,
      supportedLocales: LocaleStore.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: GemmaStudyTheme.lightTheme(_themeStore.currentScheme),
      darkTheme: GemmaStudyTheme.darkTheme(_themeStore.currentScheme),
      themeMode: _themeStore.themeMode,
      home: widget.showOnboarding ? const OnboardingScreen() : const AppRouter(),
    );
  }
}
