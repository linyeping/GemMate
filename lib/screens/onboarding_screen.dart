import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../services/model_download_service.dart';
import '../services/local_gemma_service.dart';
import '../stores/connection_store.dart';
import '../app/router.dart';
import '../l10n/app_localizations.dart';
import '../core/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _hfTokenController = TextEditingController();

  int _currentPage = 0;
  ModelDownloadStatus _downloadStatus = ModelDownloadStatus.idle;
  ModelDownloadProgress? _downloadProgress;
  bool _showTokenInput = false;
  bool _useMirror = true;

  @override
  void initState() {
    super.initState();
    ModelDownloadService.getUseMirror().then((v) {
      if (mounted) setState(() => _useMirror = v);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _hfTokenController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppRouter()),
      );
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloadStatus = ModelDownloadStatus.downloading;
      _downloadProgress = ModelDownloadProgress(progress: 0, status: ModelDownloadStatus.downloading);
    });

    try {
      final token = _hfTokenController.text.trim();

      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
      )
      .fromNetwork(
        ModelDownloadService.modelUrl,
        token: token.isNotEmpty ? token : null,
      )
      .withProgress((progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = ModelDownloadProgress(
              progress: progress.toDouble(),
              status: ModelDownloadStatus.downloading,
            );
          });
        }
      })
      .install();

      await ModelDownloadService().markInstalled();
      ConnectionStore().setLocalModelAvailable(true);
      await LocalGemmaService().initialize();

      if (mounted) {
        setState(() {
          _downloadStatus = ModelDownloadStatus.completed;
          _downloadProgress = ModelDownloadProgress(progress: 100, status: ModelDownloadStatus.completed);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadStatus = ModelDownloadStatus.error;
        });
      }
    }
  }

  Future<void> _loadFromFilePicker() async {
    setState(() => _downloadStatus = ModelDownloadStatus.downloading);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      final pickedPath = result?.files.isNotEmpty == true ? result!.files.first.path : null;
      if (pickedPath != null) {
        
        final appDir = await getApplicationDocumentsDirectory();
        final internalPath = '${appDir.path}/gemma-4-E2B-it.litertlm';
        final internalFile = File(internalPath);
        
        if (!internalFile.existsSync()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copying model to app storage (~30 seconds)...')),
            );
          }
          await File(pickedPath).copy(internalPath);
        }
        
        await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
            .fromFile(internalPath)
            .install();
        await ModelDownloadService().markInstalled();
        ConnectionStore().setLocalModelAvailable(true);
        await LocalGemmaService().initialize();
        
        if (mounted) setState(() => _downloadStatus = ModelDownloadStatus.completed);
      } else {
        setState(() => _downloadStatus = ModelDownloadStatus.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStatus = ModelDownloadStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _loadFromStorage() async {
    setState(() => _downloadStatus = ModelDownloadStatus.downloading);
    try {
      const externalPath = '/sdcard/Download/gemma-4-E2B-it.litertlm';
      final externalFile = File(externalPath);

      if (!externalFile.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'File not found!\n\n'
                'Put gemma-4-E2B-it.litertlm in /sdcard/Download/\n\n'
                'ADB command:\n'
                'adb push gemma-4-E2B-it.litertlm /sdcard/Download/'
              ),
              duration: Duration(seconds: 8),
            ),
          );
          setState(() => _downloadStatus = ModelDownloadStatus.idle);
        }
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final internalPath = '${appDir.path}/gemma-4-E2B-it.litertlm';
      final internalFile = File(internalPath);

      if (!internalFile.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copying model to app storage (~30 seconds)...')),
          );
        }
        await externalFile.copy(internalPath);
      }

      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromFile(internalPath)
          .install();
      await ModelDownloadService().markInstalled();
      ConnectionStore().setLocalModelAvailable(true);
      await LocalGemmaService().initialize();

      if (mounted) {
        setState(() => _downloadStatus = ModelDownloadStatus.completed);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemma 4 E2B installed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStatus = ModelDownloadStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: _downloadStatus == ModelDownloadStatus.downloading
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(l10n, theme),
                  _buildFeaturesPage(l10n, theme),
                  _buildDownloadPage(l10n, theme),
                ],
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final avatarPath = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicContainer(
            borderRadius: 100,
            padding: const EdgeInsets.all(20),
            child: ClipOval(
              child: Image.asset(avatarPath, width: 120, height: 120, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            AppConstants.appName,
            style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeMessage.split('\n').first,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Powered by Gemma 4",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 64),
          NeumorphicButton(
            onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.getStarted, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _featureCard("📚", l10n.flashcards),
              _featureCard("🧠", l10n.studyChat),
              _featureCard("📷", l10n.camera),
              _featureCard("📊", l10n.quizMe),
            ],
          ),
          const SizedBox(height: 64),
          NeumorphicButton(
            onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.next, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(String emoji, String text) {
    return NeumorphicContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDownloadPage(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_downloadStatus == ModelDownloadStatus.downloading) ...[
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(
                    width: 48, height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF4361EE)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Downloading Gemma 4 E2B...', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  NeumorphicContainer(
                    isPressed: true,
                    padding: const EdgeInsets.all(4),
                    borderRadius: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_downloadProgress?.progress ?? 0) / 100.0,
                        minHeight: 24,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    '${(_downloadProgress?.progress ?? 0).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4361EE)),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${((_downloadProgress?.progress ?? 0) * 2.6 / 100).toStringAsFixed(1)} GB / 2.6 GB',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                    SizedBox(width: 6),
                    Text('Keep app open. Do not lock phone.',
                      style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ]),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => setState(() => _downloadStatus = ModelDownloadStatus.idle),
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ] else if (_downloadStatus == ModelDownloadStatus.idle && !_showTokenInput) ...[
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.cloud_download_outlined, size: 64, color: Color(0xFF4361EE)),
                  const SizedBox(height: 20),
                  const Text('Download Gemma 4 E2B', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('~2.6 GB • One-time download • Works offline', 
                    style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 28),

                  NeumorphicButton(
                    onTap: _startDownload,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.download, color: Color(0xFF4361EE)),
                      const SizedBox(width: 8),
                      Text(l10n.downloadNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  NeumorphicButton(
                    onTap: _loadFromFilePicker,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.folder_open, color: Color(0xFF7209B7)),
                      const SizedBox(width: 8),
                      Text(l10n.languageCode == 'zh' ? '从设备加载' : 'Load from device', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  NeumorphicButton(
                    onTap: _loadFromStorage,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.usb, color: Color(0xFF06D6A0)),
                      const SizedBox(width: 8),
                      const Text('Load via ADB/USB', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('China mirror (hf-mirror.com)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Switch(
                      value: _useMirror,
                      activeColor: const Color(0xFF4361EE),
                      onChanged: (v) {
                        setState(() => _useMirror = v);
                        ModelDownloadService.saveUseMirror(v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => _showTokenInput = true),
                    child: Text(l10n.hfToken + " (${l10n.optional})"),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(l10n.skipForNow),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: Download on laptop first, then:\nadb push gemma-4-E2B-it.litertlm /sdcard/Download/\nThen tap "Load via ADB/USB"',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else if (_showTokenInput && _downloadStatus == ModelDownloadStatus.idle) ...[
            NeumorphicContainer(
              child: Column(
                children: [
                  Text(l10n.loginToHF, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  NeumorphicContainer(
                    isPressed: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _hfTokenController,
                      decoration: InputDecoration(hintText: l10n.hfToken, border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeumorphicButton(
                    onTap: () {
                      setState(() => _showTokenInput = false);
                      _startDownload();
                    },
                    child: Center(child: Text(l10n.login)),
                  ),
                  TextButton(onPressed: () => setState(() => _showTokenInput = false), child: Text(l10n.cancel)),
                ],
              ),
            ),
          ] else if (_downloadStatus == ModelDownloadStatus.completed) ...[
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Color(0xFF06D6A0)),
                  const SizedBox(height: 20),
                  const Text('Gemma 4 E2B Installed!', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF06D6A0))),
                  const SizedBox(height: 8),
                  const Text('GemmaStudy is ready to use offline.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  NeumorphicButton(
                    onTap: _completeOnboarding,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.rocket_launch, color: Color(0xFF06D6A0)),
                      const SizedBox(width: 8),
                      Text(l10n.startStudying, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                  ),
                ],
              ),
            ),
          ] else if (_downloadStatus == ModelDownloadStatus.error) ...[
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF476F)),
                  const SizedBox(height: 20),
                  Text(l10n.downloadFailed, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEF476F))),
                  const SizedBox(height: 8),
                  const Text('Try using ADB/USB method or switching download source.',
                    style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  NeumorphicButton(
                    onTap: () => setState(() => _downloadStatus = ModelDownloadStatus.idle),
                    child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(l10n.skipForNow),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: NeumorphicContainer(
            padding: EdgeInsets.zero,
            width: isActive ? 24 : 12,
            height: 12,
            borderRadius: 6,
            isPressed: !isActive,
            child: const SizedBox.shrink(),
          ),
        );
      }),
    );
  }
}
