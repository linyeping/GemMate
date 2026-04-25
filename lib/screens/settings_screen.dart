import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../services/ollama_service.dart';
import '../services/notification_service.dart';
import '../services/model_download_service.dart';
import '../services/local_gemma_service.dart';
import '../stores/chat_store.dart';
import '../stores/flashcard_store.dart';
import '../stores/theme_store.dart';
import '../stores/locale_store.dart';
import '../stores/connection_store.dart';
import '../widgets/color_scheme_picker.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final _themeStore = ThemeStore();
  final _localeStore = LocaleStore();
  final _downloadService = ModelDownloadService();
  
  final _ipController = TextEditingController(); // populated in _loadSettings
  final _hfTokenController = TextEditingController();
  bool _isModelInstalled = false;

  @override
  void initState() {
    super.initState();
    _localeStore.addListener(_onStateChange);
    _themeStore.addListener(_onStateChange);
    _loadSettings();
    _checkModelStatus();
  }

  @override
  void dispose() {
    _localeStore.removeListener(_onStateChange);
    _themeStore.removeListener(_onStateChange);
    _ipController.dispose();
    _hfTokenController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hfTokenController.text = prefs.getString('hf_token') ?? '';
      _ipController.text = prefs.getString('ollama_ip') ?? '192.168.1.103';
    });
  }

  Future<void> _checkModelStatus() async {
    final installed = await _downloadService.isModelInstalled();
    if (mounted) {
      setState(() => _isModelInstalled = installed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarPath = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Language
          _buildMenuEntry(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _localeStore.languageName,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _LanguagePage())),
          ),
          const SizedBox(height: 16),

          // 2. Appearance
          _buildMenuEntry(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: _themeStore.currentScheme.name.toUpperCase(),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ThemePage())),
          ),
          const SizedBox(height: 16),

          // 3. Notifications
          _buildMenuEntry(
            icon: Icons.notifications_active_outlined,
            title: l10n.notifications,
            subtitle: l10n.dailyReminder,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _NotificationPage())),
          ),
          const SizedBox(height: 16),

          // 4. Model Management
          _buildMenuEntry(
            icon: Icons.settings_suggest_outlined,
            title: l10n.modelManagement,
            subtitle: _isModelInstalled ? l10n.installed : l10n.notInstalled,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const _ModelManagementPage(),
              ));
              _checkModelStatus();
            },
          ),
          const SizedBox(height: 16),

          // 5. Connection
          _buildMenuEntry(
            icon: Icons.wifi_find,
            title: l10n.connection,
            subtitle: OllamaService().baseUrl.replaceAll('http://', '').replaceAll(':11434', ''),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => _ConnectionPage(
                controller: _ipController,
              )));
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // 6. Stats
          _buildMenuEntry(
            icon: Icons.bar_chart,
            title: l10n.stats,
            subtitle: '${FlashcardStore().totalCards} cards',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _StatsPage())),
          ),
          const SizedBox(height: 16),

          // 7. Danger Zone
          _buildMenuEntry(
            icon: Icons.warning_amber_rounded,
            title: l10n.dangerZone,
            subtitle: l10n.deleteChat,
            accentColor: theme.colorScheme.error,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DangerPage())),
          ),

          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                ClipOval(child: Image.asset(avatarPath, width: 48, height: 48)),
                const SizedBox(height: 8),
                Text(AppConstants.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuEntry({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? accentColor}) {
    return NeumorphicButton(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: accentColor ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// --- SUB PAGES ---

class _ModelManagementPage extends StatefulWidget {
  const _ModelManagementPage();
  @override
  State<_ModelManagementPage> createState() => _ModelManagementPageState();
}

class _ModelManagementPageState extends State<_ModelManagementPage> {
  final _downloadService = ModelDownloadService();
  final _hfTokenController = TextEditingController();
  bool _isInstalled = false;
  ModelDownloadStatus _downloadStatus = ModelDownloadStatus.idle;
  double _downloadProgress = 0;
  bool _useMirror = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _hfTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final installed = await _downloadService.isModelInstalled();
    final mirror = await ModelDownloadService.getUseMirror();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isInstalled = installed;
        _useMirror = mirror;
        _hfTokenController.text = prefs.getString('hf_token') ?? '';
      });
    }
  }

  Future<void> _startDownload() async {
    final prefs = await SharedPreferences.getInstance();
    final token = _hfTokenController.text.trim();
    await prefs.setString('hf_token', token);

    setState(() {
      _downloadStatus = ModelDownloadStatus.downloading;
      _downloadProgress = 0;
    });

    try {
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
            _downloadProgress = progress.toDouble();
          });
        }
      })
      .install();

      // `.fromNetwork(...).install()` stores the weights inside flutter_gemma's
      // internal `repo/` directory and registers that *directory path* as the
      // active model. The next time the native engine tries to load the model
      // it crashes with "Unsupported model format: .../app_flutter/repo"
      // because `createFromModelPath` only accepts a concrete `.litertlm`
      // file. Workaround: locate the downloaded `.litertlm`, copy it to a
      // stable path, and re-install via `.fromFile(...)` so the registered
      // path is a real file.
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final targetPath =
            '${appDir.path}/${ModelDownloadService.modelFileName}';
        if (!File(targetPath).existsSync()) {
          // flutter_gemma may store the download without a `.litertlm`
          // extension (e.g. `repo/model` or a hashed name). Pick the
          // largest regular file under appDir that is NOT our target — the
          // model weights dwarf any metadata file.
          File? found;
          int foundSize = 0;
          for (final entity in appDir.listSync(recursive: true)) {
            if (entity is File && entity.path != targetPath) {
              try {
                final size = entity.lengthSync();
                if (size > foundSize && size > 50 * 1024 * 1024) {
                  found = entity;
                  foundSize = size;
                }
              } catch (_) {}
            }
          }
          if (found != null) {
            print('Post-download: picked ${found.path} (${foundSize ~/ (1024 * 1024)} MB)');
            await found.copy(targetPath);
          }
        }
        if (File(targetPath).existsSync()) {
          // Clear any stale registration pointing at the repo/ directory
          // before re-installing, so the plugin's internal state is
          // overwritten rather than appended to.
          try {
            await FlutterGemma.uninstallModel(
                ModelDownloadService.modelFileName);
          } catch (_) {}
          await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
              .fromFile(targetPath)
              .install();
        }
      } catch (e) {
        print('Post-download re-registration failed: $e');
      }

      await _downloadService.markInstalled();
      ConnectionStore().setLocalModelAvailable(true);
      await LocalGemmaService().initialize();

      if (mounted) {
        setState(() {
          _downloadStatus = ModelDownloadStatus.completed;
          _downloadProgress = 100;
          _isInstalled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStatus = ModelDownloadStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _importFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() => _downloadStatus = ModelDownloadStatus.downloading);
        await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
            .fromFile(result.files.single.path!)
            .install();
        await _downloadService.markInstalled();
        ConnectionStore().setLocalModelAvailable(true);
        await LocalGemmaService().initialize();
        if (mounted) {
          setState(() {
            _downloadStatus = ModelDownloadStatus.completed;
            _isInstalled = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Model installed successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStatus = ModelDownloadStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadFromStorage() async {
    setState(() => _downloadStatus = ModelDownloadStatus.downloading);
    try {
      const path = '/sdcard/Download/gemma-4-E2B-it.litertlm';
      final file = File(path);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found at /sdcard/Download/gemma-4-E2B-it.litertlm\n\nadb push gemma-4-E2B-it.litertlm /sdcard/Download/'),
              duration: Duration(seconds: 8),
            ),
          );
          setState(() => _downloadStatus = ModelDownloadStatus.idle);
        }
        return;
      }

      // Copy to internal storage
      final appDir = await getApplicationDocumentsDirectory();
      final internalPath = '${appDir.path}/gemma-4-E2B-it.litertlm';
      if (!File(internalPath).existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copying to app storage (~30s)...')),
          );
        }
        await file.copy(internalPath);
      }

      await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
          .fromFile(internalPath)
          .install();
      await _downloadService.markInstalled();
      ConnectionStore().setLocalModelAvailable(true);
      await LocalGemmaService().initialize();
      if (mounted) {
        setState(() {
          _downloadStatus = ModelDownloadStatus.completed;
          _isInstalled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model installed successfully!')),
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

  Future<void> _deleteModel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Model?'),
        content: const Text('This will free ~2.6 GB. You can reinstall later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _downloadService.deleteModel();
      ConnectionStore().setLocalModelAvailable(false);
      setState(() {
        _isInstalled = false;
        _downloadStatus = ModelDownloadStatus.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.modelManagement)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // DOWNLOADING STATE
          if (_downloadStatus == ModelDownloadStatus.downloading)
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(width: 48, height: 48,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF4361EE))),
                const SizedBox(height: 20),
                const Text('Downloading Gemma 4 E2B...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // PROGRESS BAR
                NeumorphicContainer(
                  isPressed: true, padding: const EdgeInsets.all(4), borderRadius: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _downloadProgress / 100.0,
                      minHeight: 24,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // BIG PERCENTAGE
                Text(
                  '${_downloadProgress.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4361EE)),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_downloadProgress * 2.6 / 100).toStringAsFixed(1)} GB / 2.6 GB',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                  SizedBox(width: 6),
                  Text('Keep app open. Do not lock phone.',
                    style: TextStyle(fontSize: 12, color: Colors.orange)),
                ]),
              ]),
            )

          // INSTALLED STATE
          else if (_isInstalled)
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Icon(Icons.check_circle, size: 48, color: Color(0xFF06D6A0)),
                const SizedBox(height: 12),
                const Text('Gemma 4 E2B',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Installed ✓ • Works offline',
                  style: TextStyle(color: Color(0xFF06D6A0), fontSize: 13)),
                const SizedBox(height: 20),
                NeumorphicButton(
                  onTap: _deleteModel,
                  child: const Center(child: Text('Delete Model',
                    style: TextStyle(color: Color(0xFFEF476F)))),
                ),
              ]),
            )

          // NOT INSTALLED STATE
          else
            NeumorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Icon(Icons.cloud_download_outlined, size: 48, color: Color(0xFF4361EE)),
                const SizedBox(height: 12),
                const Text('Gemma 4 E2B',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('~2.6 GB • Not installed',
                  style: TextStyle(color: Color(0xFFFFBE0B), fontSize: 13)),
                const SizedBox(height: 24),

                // Download button
                NeumorphicButton(
                  onTap: _startDownload,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.download, size: 20, color: Color(0xFF4361EE)),
                    const SizedBox(width: 8),
                    Text(l10n.downloadNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 12),

                // Load from /sdcard/Download/
                NeumorphicButton(
                  onTap: _loadFromStorage,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.phone_android, size: 20, color: Color(0xFF06D6A0)),
                    SizedBox(width: 8),
                    Text('Load from /sdcard/Download/', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 12),

                // Browse files
                NeumorphicButton(
                  onTap: _importFile,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.folder_open, size: 20, color: Color(0xFF7209B7)),
                    SizedBox(width: 8),
                    Text('Browse files...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 20),

                // Mirror toggle
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('China mirror (no VPN)', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                Text(
                  _useMirror ? 'hf-mirror.com' : 'huggingface.co',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tip: adb push gemma-4-E2B-it.litertlm /sdcard/Download/',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          const SizedBox(height: 32),
          Align(alignment: Alignment.centerLeft, child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(l10n.loginToHF, style: theme.textTheme.titleSmall),
          )),
          NeumorphicContainer(
            isPressed: true,
            child: TextField(
              controller: _hfTokenController,
              decoration: InputDecoration(
                labelText: "${l10n.hfToken} (${l10n.optional})",
                border: InputBorder.none,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Only needed for private models", style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildItem(context, '🇺🇸', 'English', const Locale('en')),
          _buildItem(context, '🇨🇳', '简体中文', const Locale('zh')),
          _buildItem(context, '🇯🇵', '日本語', const Locale('ja')),
          _buildItem(context, '🇰🇷', '한국어', const Locale('ko')),
          _buildItem(context, '🇫🇷', 'Français', const Locale('fr')),
          _buildItem(context, '🇪🇸', 'Español', const Locale('es')),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String flag, String name, Locale locale) {
    final isSelected = LocaleStore().currentLocale.languageCode == locale.languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeumorphicButton(
        onTap: () => LocaleStore().setLocale(locale),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(child: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ThemePage extends StatefulWidget {
  const _ThemePage();
  @override
  State<_ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<_ThemePage> {
  final _themeStore = ThemeStore();

  @override
  void initState() {
    super.initState();
    _themeStore.addListener(_onChanged);
  }

  @override
  void dispose() {
    _themeStore.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, l10n.darkMode),
          NeumorphicContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.wb_sunny_outlined),
                NeumorphicButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onTap: () => _themeStore.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
                  child: Icon(isDark ? Icons.toggle_on : Icons.toggle_off, color: theme.colorScheme.primary, size: 32),
                ),
                const Icon(Icons.nightlight_outlined),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.fontSize),
          NeumorphicContainer(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('A', style: TextStyle(fontSize: 12)),
                    Text('${_themeStore.fontSize.toInt()}px',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: _themeStore.fontSize)),
                    const Text('A', style: TextStyle(fontSize: 24)),
                  ],
                ),
                Slider(
                  value: _themeStore.fontSize,
                  min: 12, max: 24, divisions: 12,
                  label: '${_themeStore.fontSize.toInt()}px',
                  activeColor: const Color(0xFF4361EE),
                  onChanged: (val) {
                    _themeStore.setFontSize(val);
                    // setState is called via listener, so Slider will rebuild
                  },
                ),
                // Preview text
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Preview text at ${_themeStore.fontSize.toInt()}px',
                    style: TextStyle(fontSize: _themeStore.fontSize),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.themeSettings),
          const NeumorphicContainer(child: ColorSchemePicker()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }
}

class _NotificationPage extends StatelessWidget {
  const _NotificationPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeumorphicContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(title: Text(l10n.dailyReminder), value: true, onChanged: (v){}),
                SwitchListTile(title: Text(l10n.reviewReminder), value: true, onChanged: (v){}),
                SwitchListTile(title: Text(l10n.inactivityReminder), value: true, onChanged: (v){}),
              ],
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicButton(
            onTap: () async {
              final service = NotificationService();
              final hasPermission = await service.requestPermission();
              if (hasPermission) {
                await service.showInstant(
                  title: '🎉 ${l10n.appName}',
                  body: 'Notifications are working! You will be reminded to study.',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent! Check your notification bar.')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification permission denied. Enable in phone Settings.')),
                  );
                }
              }
            },
            child: Center(child: Text(l10n.testNotification)),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPage extends StatefulWidget {
  final TextEditingController controller;
  const _ConnectionPage({required this.controller});

  @override
  State<_ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<_ConnectionPage> {
  bool _testingConnection = false;
  bool? _connectionSuccess;  // null = not tested, true = success, false = failed
  String _selectedModel = OllamaService().currentModel;

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _connectionSuccess = null;
    });
    try {
      final url = 'http://${widget.controller.text.trim()}:11434';
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        final success = response.statusCode == 200;
        setState(() {
          _testingConnection = false;
          _connectionSuccess = success;
        });
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ollama_ip', widget.controller.text.trim());
          OllamaService().updateBaseUrl(widget.controller.text.trim());
          ConnectionStore().setLaptopConnected(true);
        } else {
          ConnectionStore().setLaptopConnected(false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testingConnection = false;
          _connectionSuccess = false;
        });
        ConnectionStore().setLaptopConnected(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.connection)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeumorphicContainer(
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _connectionSuccess == null
                    ? Colors.transparent
                    : _connectionSuccess == true
                        ? const Color(0xFF06D6A0).withOpacity(0.15)  // light green
                        : const Color(0xFFEF476F).withOpacity(0.15),  // light red
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: '192.168.1.103',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.computer),
                ),
                onChanged: (_) {
                  // Reset color when user types
                  if (_connectionSuccess != null) {
                    setState(() => _connectionSuccess = null);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          NeumorphicButton(
            onTap: _testingConnection ? null : _testConnection,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_testingConnection)
                  const SizedBox(width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4361EE)))
                else
                  const Icon(Icons.wifi_find, color: Color(0xFF4361EE)),
                const SizedBox(width: 8),
                Text(
                  _testingConnection ? 'Testing...' : 'Test Connection',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (_connectionSuccess != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _connectionSuccess! ? Icons.check_circle : Icons.cancel,
                  color: _connectionSuccess! ? const Color(0xFF06D6A0) : const Color(0xFFEF476F),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _connectionSuccess! ? 'Connection successful!' : 'Connection failed. Check IP and WiFi.',
                  style: TextStyle(
                    color: _connectionSuccess! ? const Color(0xFF06D6A0) : const Color(0xFFEF476F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Text('Model', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          NeumorphicContainer(
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: const InputDecoration(border: InputBorder.none),
              items: const [
                DropdownMenuItem(value: 'gemma4:e2b', child: Text('Gemma 4 E2B (fast, 2B)')),
                DropdownMenuItem(value: 'gemma4:e4b', child: Text('Gemma 4 E4B (powerful, 4B)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedModel = value);
                  OllamaService().saveModel(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsPage extends StatelessWidget {
  const _StatsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stats)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(l10n.totalFlashcards, '${FlashcardStore().totalCards}', Colors.blue),
          _card(l10n.dueForReview, '${FlashcardStore().dueCount}', Colors.orange),
          _card(l10n.chatSessions, '${ChatStore().sessions.length}', Colors.purple),
          _card(l10n.cardsMastered, '${FlashcardStore().cards.where((c)=>c.repetitions>=3).length}', Colors.green),
        ],
      ),
    );
  }

  Widget _card(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: NeumorphicContainer(accentBorderColor: c, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: c))])),
  );
}

class _DangerPage extends StatelessWidget {
  const _DangerPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dangerZone)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeumorphicButton(
            onTap: () => _showConfirm(context, l10n.confirmClearAllFlashcards, FlashcardStore().clearAll),
            accentColor: theme.colorScheme.error,
            child: Center(child: Text(l10n.clearAllFlashcards)),
          ),
          const SizedBox(height: 16),
          NeumorphicButton(
            onTap: () => _showConfirm(context, l10n.confirmDeleteAllChats, ChatStore().deleteAllSessions),
            accentColor: theme.colorScheme.error,
            child: Center(child: Text(l10n.deleteAllChats)),
          ),
        ],
      ),
    );
  }

  void _showConfirm(BuildContext context, String title, VoidCallback onConfirm) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(l10n.deleteDataWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () { onConfirm(); Navigator.pop(context); }, child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
