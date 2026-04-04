import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ollama_service.dart';
import '../core/constants.dart';
import '../stores/chat_store.dart';
import '../models/chat_message.dart';
import '../widgets/loading_indicator.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final OllamaService _ollama = OllamaService();
  File? _image;
  String? _imageBase64;
  String _analysisResult = '';
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _imageBase64 = base64Encode(bytes);
        _analysisResult = '';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBase64 == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      final response = await _ollama.chatWithImage(
        _imageBase64!,
        'Analyze this study material. Extract text and explain key concepts.',
        systemPrompt: AppConstants.ocrSystemPrompt,
      );
      
      setState(() {
        _analysisResult = response;
      });
    } catch (e) {
      setState(() {
        _analysisResult = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _sendToChat() {
    if (_analysisResult.isEmpty) return;
    
    final chatStore = ChatStore();
    if (_imageBase64 != null) {
      chatStore.addMessage(ChatMessage(
        content: 'I analyzed this image for you.',
        isUser: true,
        imageBase64: _imageBase64,
      ));
    }
    
    chatStore.addMessage(ChatMessage(
      content: _analysisResult,
      isUser: false,
      modelUsed: ModelUsed.remoteE2B,
    ));
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Study Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, height: 300, fit: BoxFit.cover),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text('No image selected', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyze with Gemma 4'),
              ),
            ],
            if (_isAnalyzing) const LoadingIndicator(message: '🔍 Analyzing...'),
            if (_analysisResult.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Analysis Result', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_analysisResult),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _sendToChat,
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Send to Chat'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
