import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ModelDownloadStatus { idle, downloading, completed, error }

class ModelDownloadProgress {
  final double progress; // 0-100 from flutter_gemma
  final ModelDownloadStatus status;
  ModelDownloadProgress({required this.progress, required this.status});
  String get percentText => '${progress.toStringAsFixed(0)}%';
  String get progressText => 'Downloading AI components...';
}

class ModelDownloadService {
  // 对齐文件名
  static const String modelFileName = 'gemma-4-E2B-it.litertlm';
  
  static const String modelUrlOriginal = 
    'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/$modelFileName';
  
  static const String modelUrlMirror = 
    'https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/$modelFileName';
  
  static String modelUrl = modelUrlMirror;
  static const String adbModelPath = '/sdcard/Download/$modelFileName';
  
  static void setUseMirror(bool useMirror) {
    modelUrl = useMirror ? modelUrlMirror : modelUrlOriginal;
  }
  
  bool _isInstalled = false;

  /// 检查模型是否已通过插件安装
  Future<bool> isModelInstalled() async {
    try {
      // 静态调用：检查特定文件名是否已安装
      final installed = await FlutterGemma.isModelInstalled(modelFileName);
      _isInstalled = installed;
      return _isInstalled;
    } catch (e) {
      return false;
    }
  }

  Future<void> markInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('model_installed', true);
    _isInstalled = true;
  }

  Future<void> deleteModel() async {
    try {
      await FlutterGemma.uninstallModel(modelFileName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('model_installed', false);
      _isInstalled = false;
    } catch (e) {
      print('Delete model error: $e');
    }
  }
  
  static Future<bool> getUseMirror() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('use_hf_mirror') ?? true;
  }
  
  static Future<void> saveUseMirror(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_hf_mirror', value);
    setUseMirror(value);
  }
}
