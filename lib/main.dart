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
import 'services/ollama_service.dart';
import 'services/notification_service.dart';
import 'services/model_download_service.dart';
import 'services/local_gemma_service.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FlutterGemma init — must not crash the app
  try {
    await FlutterGemma.initialize();
  } catch (e) {
    print('FlutterGemma init skipped: $e');
  }

  // Initialize services — each wrapped separately so one failure doesn't block others
  try { await NotificationService().initialize(); } catch (e) { print('Notification init failed: $e'); }
  try { await LocaleStore().load(); } catch (e) { print('Locale load failed: $e'); }
  try { await ThemeStore().load(); } catch (e) { print('Theme load failed: $e'); }
  try { await ChatStore().load(); } catch (e) { print('Chat load failed: $e'); }
  try { await FlashcardStore().load(); } catch (e) { print('Flashcard load failed: $e'); }

  // Try to initialize local model if installed
  try {
    final downloadService = ModelDownloadService();
    final modelInstalled = await downloadService.isModelInstalled();
    if (modelInstalled) {
      final appDir = await getApplicationDocumentsDirectory();
      final internalPath = '${appDir.path}/gemma-4-E2B-it.litertlm';
      final internalFile = File(internalPath);
      
      // Check internal storage first (model was already copied here)
      if (internalFile.existsSync()) {
        print('Main: Found model in internal storage');
        await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
            .fromFile(internalPath)
            .install();
        print('Main: Model registered from internal storage');
      } else {
        // Try external storage and copy to internal
        const externalPath = '/sdcard/Download/gemma-4-E2B-it.litertlm';
        final externalFile = File(externalPath);
        if (externalFile.existsSync()) {
          print('Main: Copying model from external to internal storage...');
          await externalFile.copy(internalPath);
          await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
              .fromFile(internalPath)
              .install();
          print('Main: Model registered from external→internal copy');
        } else {
          // Model was installed via flutter_gemma's own download
          // Try to just get the active model — it may already be registered
          print('Main: No model file found, trying flutter_gemma internal...');
          try {
            await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
                .fromFile(internalPath)
                .install();
          } catch (e) {
            print('Main: flutter_gemma internal registration failed: $e');
            // Mark as not installed since we can't find the model
            await downloadService.deleteModel();
          }
        }
      }

      final localGemma = LocalGemmaService();
      await localGemma.initialize();
      ConnectionStore().setLocalModelAvailable(localGemma.isAvailable);
      print('Main: Local model ready: ${localGemma.isAvailable}');
    }
  } catch (e) {
    print('Main: Model init failed (non-fatal): $e');
  }

  // Load saved Ollama IP — must not crash
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('ollama_ip') ?? '192.168.1.103';
    OllamaService().updateBaseUrl(savedIp);
    final savedModel = prefs.getString('ollama_model') ?? 'gemma4:e2b';
    OllamaService().setModel(savedModel);
  } catch (e) {
    print('Main: Ollama config failed: $e');
  }

  // Check onboarding
  bool onboardingCompleted = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  } catch (e) {
    print('Main: Prefs failed: $e');
  }

  runApp(GemMateApp(showOnboarding: !onboardingCompleted));
}

class GemMateApp extends StatefulWidget {
  final bool showOnboarding;
  const GemMateApp({super.key, required this.showOnboarding});

  @override
  State<GemMateApp> createState() => _GemMateAppState();
}

class _GemMateAppState extends State<GemMateApp> {
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
      title: 'GemMate',
      debugShowCheckedModeBanner: false,
      locale: _localeStore.currentLocale,
      supportedLocales: LocaleStore.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: GemMateTheme.lightTheme(_themeStore.currentScheme),
      darkTheme: GemMateTheme.darkTheme(_themeStore.currentScheme),
      themeMode: _themeStore.themeMode,
      home: widget.showOnboarding ? const OnboardingScreen() : const AppRouter(),
    );
  }
}
