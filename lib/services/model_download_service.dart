import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ModelDownloadStatus { idle, downloading, completed, error }

class ModelDownloadProgress {
  final double progress; // 0-100
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

  // hf-mirror.com is a CDN-backed static file mirror — unlike modelscope's
  // /api/v1/.../repo endpoint, it serves plain HTTP ranges and doesn't drop
  // the connection mid-stream on multi-GB downloads. Path layout matches
  // HuggingFace exactly, just swap the host.
  static const String modelUrlMirror =
    'https://hf-mirror.com/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/$modelFileName';

  // Kept around as a fallback if hf-mirror is unreachable.
  static const String modelUrlMirrorModelScope =
    'https://modelscope.cn/api/v1/models/LYP071333/Gemma4-E2B/repo?Revision=master&FilePath=$modelFileName';

  static String modelUrl = modelUrlMirror;
  static const String adbModelPath = '/sdcard/Download/$modelFileName';

  static void setUseMirror(bool useMirror) {
    modelUrl = useMirror ? modelUrlMirror : modelUrlOriginal;
  }

  bool _isInstalled = false;

  /// Flag to signal a running download to stop.
  static bool _cancelRequested = false;

  /// Request cancellation of an in-progress [downloadWithResume] call.
  /// The partial `.part` file is kept so the next attempt can resume.
  static void requestCancel() => _cancelRequested = true;

  // ---------------------------------------------------------------------------
  // Resumable HTTP download — bypasses FlutterGemma.fromNetwork() entirely
  // ---------------------------------------------------------------------------

  /// Downloads the model file with HTTP Range resume support.
  ///
  /// Returns the path to the completed file on success. Throws on failure.
  /// [onProgress] receives values from 0.0 to 100.0.
  ///
  /// If a `.part` file already exists from a prior interrupted download, this
  /// method sends an HTTP `Range` header so the server only sends the remaining
  /// bytes — no wasted bandwidth.
  static Future<String> downloadWithResume({
    required String url,
    String? token,
    void Function(double progress)? onProgress,
  }) async {
    _cancelRequested = false;

    final appDir = await getApplicationDocumentsDirectory();
    final finalPath = '${appDir.path}/$modelFileName';
    final partPath = '$finalPath.part';
    final partFile = File(partPath);

    // Check existing partial download
    int existingBytes = 0;
    if (partFile.existsSync()) {
      existingBytes = partFile.lengthSync();
      print('Download: resuming from $existingBytes bytes');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);

    try {
      final request = await client.getUrl(Uri.parse(url));

      // Resume from where we left off
      if (existingBytes > 0) {
        request.headers.set('Range', 'bytes=$existingBytes-');
      }
      if (token != null && token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      final response = await request.close();

      int totalBytes;
      IOSink sink;

      if (response.statusCode == 206) {
        // Partial content — resume supported
        final contentRange = response.headers.value('content-range');
        if (contentRange != null && contentRange.contains('/')) {
          totalBytes = int.parse(contentRange.split('/').last);
        } else {
          totalBytes = existingBytes + response.contentLength;
        }
        sink = partFile.openWrite(mode: FileMode.append);
        print('Download: server supports resume, total=$totalBytes');
      } else if (response.statusCode == 200) {
        // Full content — server doesn't support range, or existingBytes was 0
        existingBytes = 0;
        totalBytes = response.contentLength;
        sink = partFile.openWrite(mode: FileMode.write);
        print('Download: starting fresh, total=$totalBytes');
      } else if (response.statusCode == 416) {
        // Range not satisfiable — file might already be complete
        await response.drain();
        if (existingBytes > 500 * 1024 * 1024) {
          // Likely already fully downloaded
          if (File(finalPath).existsSync()) File(finalPath).deleteSync();
          partFile.renameSync(finalPath);
          return finalPath;
        }
        // Otherwise something is wrong, start over
        if (partFile.existsSync()) partFile.deleteSync();
        throw Exception('Range not satisfiable and file too small');
      } else {
        await response.drain();
        throw HttpException(
          'Download failed: HTTP ${response.statusCode}',
          uri: Uri.parse(url),
        );
      }

      int receivedBytes = existingBytes;

      await for (final chunk in response) {
        if (_cancelRequested) {
          await sink.flush();
          await sink.close();
          print('Download: cancelled at $receivedBytes bytes (partial file kept)');
          throw Exception('Download cancelled by user');
        }

        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes * 100);
        }
      }

      await sink.flush();
      await sink.close();

      // Verify file size — if server told us the total, check it
      final downloadedSize = File(partPath).lengthSync();
      if (totalBytes > 0 && downloadedSize < totalBytes * 0.99) {
        // Allow 1% tolerance for content-length rounding
        throw Exception(
          'Incomplete download: $downloadedSize / $totalBytes bytes');
      }

      // Rename .part → final
      if (File(finalPath).existsSync()) {
        File(finalPath).deleteSync();
      }
      partFile.renameSync(finalPath);
      print('Download: complete, ${downloadedSize ~/ (1024 * 1024)} MB');

      return finalPath;
    } finally {
      client.close();
    }
  }

  /// Delete partial download file if it exists.
  static Future<void> deletePartialDownload() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final partFile = File('${appDir.path}/$modelFileName.part');
      if (partFile.existsSync()) {
        partFile.deleteSync();
        print('Deleted partial download');
      }
    } catch (e) {
      print('deletePartialDownload error: $e');
    }
  }

  /// Check if a partial download exists and return its size in bytes.
  static Future<int> getPartialDownloadSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final partFile = File('${appDir.path}/$modelFileName.part');
      if (partFile.existsSync()) return partFile.lengthSync();
    } catch (_) {}
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Model state management
  // ---------------------------------------------------------------------------

  /// 检查模型是否已通过插件安装
  Future<bool> isModelInstalled() async {
    try {
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
