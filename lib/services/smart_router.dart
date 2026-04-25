import 'package:connectivity_plus/connectivity_plus.dart';
import 'ollama_service.dart';
import 'local_gemma_service.dart';
import 'model_download_service.dart';
import '../models/chat_message.dart';
import '../stores/connection_store.dart';

class SmartRouter {
  final OllamaService ollama = OllamaService();
  final LocalGemmaService localGemma;
  final ConnectionStore connectionStore;

  SmartRouter({
    required this.localGemma,
    required this.connectionStore,
  });

  Future<void> checkConnection() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasWifi = connectivity.contains(ConnectivityResult.wifi);
      final reachable = hasWifi ? await ollama.isReachable() : false;
      connectionStore.setLaptopConnected(reachable);
    } catch (e) {
      connectionStore.setLaptopConnected(false);
    }
    
    // Also check local model
    final modelInstalled = await ModelDownloadService().isModelInstalled();
    if (modelInstalled && !localGemma.isAvailable) {
      await localGemma.initialize();
    }
    connectionStore.setLocalModelAvailable(localGemma.isAvailable);
  }

  Future<String> route(
    List<ChatMessage> history,
    String prompt, {
    String? systemPromptOverride,
  }) async {
    // Check connections first
    await checkConnection();

    final hasLaptop = connectionStore.isLaptopConnected;
    final hasLocal = localGemma.isAvailable;

    print('SmartRouter: hasLaptop=$hasLaptop, hasLocal=$hasLocal');

    // Priority 1: Laptop available → use laptop
    if (hasLaptop) {
      print('SmartRouter: using laptop (Ollama - ${ollama.currentModel})');
      return await ollama.chatWithHistory(history, prompt);
    }

    // Priority 2: Local model available → use on-device
    if (hasLocal) {
      print('SmartRouter: using local model (Gemma 4 E2B on-device)');
      return await localGemma.generate(prompt, systemPromptOverride: systemPromptOverride);
    }

    // Priority 3: No laptop, but maybe model is installed but not initialized
    final modelInstalled = await ModelDownloadService().isModelInstalled();
    if (modelInstalled) {
      print('SmartRouter: model installed, trying to initialize...');
      await localGemma.initialize();
      if (localGemma.isAvailable) {
        connectionStore.setLocalModelAvailable(true);
        print('SmartRouter: initialized! using local model');
        return await localGemma.generate(prompt, systemPromptOverride: systemPromptOverride);
      }
    }

    throw Exception('No AI model available.\nConnect to laptop or download on-device model.');
  }
}
