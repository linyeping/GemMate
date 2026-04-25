import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/ollama_service.dart';
import '../services/local_gemma_service.dart';
import '../services/flashcard_generator.dart';
import '../stores/chat_store.dart';
import '../stores/flashcard_store.dart';
import '../stores/connection_store.dart';
import '../models/chat_message.dart';
import '../models/flashcard.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../l10n/app_localizations.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();

  File? _image;
  String? _imageBase64;
  String _analysisResult = '';
  bool _isAnalyzing = false;
  bool _isOfflineMode = false;
  bool _isMathMode = false; // ← Math Solver mode

  static const _mathPrompt =
      'This is a handwritten math or science problem. '
      'Please solve it step by step:\n'
      '1. State clearly what the problem is asking.\n'
      '2. Show every calculation step.\n'
      '3. State the final answer on its own line.\n'
      'Be educational and use plain text (no LaTeX).';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _imageBase64 = base64Encode(bytes);
        _analysisResult = '';
        _promptController.clear();
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null || _imageBase64 == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _isOfflineMode = !ConnectionStore().isLaptopConnected;
    });

    try {
      String response;
      if (!_isOfflineMode) {
        // ONLINE: Use Ollama Vision
        final userPrompt = _promptController.text.trim().isNotEmpty
            ? _promptController.text.trim()
            : _isMathMode
                ? _mathPrompt
                : 'Analyze this image. If it contains text or notes, summarize '
                  'the key points. If it contains a diagram or chart, explain '
                  'what it shows. Respond in plain text without LaTeX formatting.';

        response = await OllamaService().chatWithImage(_imageBase64!, userPrompt);
      } else {
        // OFFLINE: Use ML Kit OCR + Local Gemma
        final inputImage = InputImage.fromFilePath(_image!.path);
        final textRecognizer = TextRecognizer();
        final recognizedText = await textRecognizer.processImage(inputImage);
        final ocrText = recognizedText.text;
        await textRecognizer.close();

        if (ocrText.trim().isEmpty) {
          final l10n = AppLocalizations.of(context);
          response = '${l10n.noTextDetected}\n\n${l10n.connectLaptopForImageAnalysis}';
        } else {
          final userPrompt = _promptController.text.trim().isNotEmpty
              ? _promptController.text.trim()
              : _isMathMode
                  ? _mathPrompt
                  : 'Analyze the following content and summarize the key points.';

          // Cap OCR text to keep the total prompt within the local model's
          // 2048-token context window. ~3500 chars is a safe upper bound for
          // mixed CJK/Latin text after accounting for the fixed prefix/suffix
          // and the model's response budget.
          const int maxOcrChars = 3500;
          String safeOcr = ocrText.trim();
          bool truncated = false;
          if (safeOcr.length > maxOcrChars) {
            safeOcr = safeOcr.substring(0, maxOcrChars);
            truncated = true;
          }

          final combinedPrompt =
              'The following text was extracted from a photo via OCR'
              '${truncated ? ' (truncated to first $maxOcrChars chars)' : ''}:\n\n'
              '---\n$safeOcr\n---\n\n'
              'User instruction: $userPrompt\n\n'
              '${_isMathMode ? '' : 'If it contains notes, summarize the key points. '}'
              'Respond in plain text without LaTeX formatting.';

          response = await LocalGemmaService().generate(combinedPrompt);
        }
      }

      setState(() {
        _analysisResult = response;
      });

      // Save to chat history
      _saveToChatHistory();

    } catch (e) {
      setState(() {
        _analysisResult = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _saveToChatHistory() {
    final chatStore = ChatStore();
    chatStore.createNewSession();
    chatStore.renameSession(chatStore.activeSession!.id, 'Photo Analysis');
    
    if (_imageBase64 != null) {
      chatStore.addMessage(ChatMessage(
        content: _promptController.text.isNotEmpty ? _promptController.text : 'Analyze this image',
        isUser: true,
        imageBase64: _imageBase64,
      ));
    }
    
    chatStore.addMessage(ChatMessage(
      content: _analysisResult,
      isUser: false,
      modelUsed: _isOfflineMode ? ModelUsed.localE2B : ModelUsed.remoteE2B,
    ));
  }

  Future<void> _generateFlashcards() async {
    if (_analysisResult.isEmpty) return;
    setState(() => _isAnalyzing = true);
    try {
      final generator = FlashcardGenerator(OllamaService());
      final cards = await generator.generate(
        [ChatMessage(content: _analysisResult, isUser: false)],
        'Photo Analysis',
      );
      if (cards.isNotEmpty) {
        FlashcardStore().addCards(cards);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generated ${cards.length} flashcards!')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// In Math Solver mode: extract numbered steps from the solution and turn
  /// each step into a front/back flashcard.
  Future<void> _generateMathStepCards(AppLocalizations l10n) async {
    if (_analysisResult.isEmpty) return;
    setState(() => _isAnalyzing = true);
    try {
      final stepRe = RegExp(r'(?:^|\n)\s*\d+[\.\)]\s+(.+?)(?=\n\s*\d+[\.\)]|\Z)',
          dotAll: true);
      final steps = stepRe
          .allMatches(_analysisResult)
          .map((m) => m.group(1)?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      if (steps.isEmpty) {
        // Fall back to regular card generation
        await _generateFlashcards();
        return;
      }

      final groupId = 'math_${DateTime.now().millisecondsSinceEpoch}';
      final cards = steps.asMap().entries.map((e) => Flashcard(
        id: '${groupId}_${e.key}',
        groupId: groupId,
        groupName: l10n.mathSolver,
        front: 'Step ${e.key + 1}',
        back: e.value,
      )).toList();

      FlashcardStore().addCards(cards);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.saveMathCards}: ${cards.length} cards')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyCamera), centerTitle: true),
      body: _buildBody(theme, l10n),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_image == null) return _buildPickerState(theme, l10n);
    if (_isAnalyzing) return _buildLoadingState(theme, l10n);
    if (_analysisResult.isNotEmpty) return _buildResponseState(theme, l10n);
    return _buildPreviewState(theme, l10n);
  }

  Widget _buildPickerState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode toggle
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeChip(
                    label: '🔍 ${l10n.generalMode}',
                    selected: !_isMathMode,
                    onTap: () => setState(() => _isMathMode = false),
                  ),
                  _ModeChip(
                    label: '✍️ ${l10n.mathSolver}',
                    selected: _isMathMode,
                    onTap: () => setState(() => _isMathMode = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            NeumorphicContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: 100,
              child: Icon(
                _isMathMode ? Icons.functions : Icons.camera_enhance_outlined,
                size: 80,
                color: _isMathMode
                    ? const Color(0xFFF72585)
                    : theme.colorScheme.primary,
              ),
            ),
            if (_isMathMode) ...[
              const SizedBox(height: 16),
              Text(
                l10n.solveStepByStep,
                style: const TextStyle(
                    color: Color(0xFFF72585),
                    fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 32),
            NeumorphicButton(
              onTap: () => _pickImage(ImageSource.camera),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt),
                  const SizedBox(width: 12),
                  Text(l10n.takePhoto,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicButton(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library),
                  const SizedBox(width: 12),
                  Text(l10n.pickFromGallery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewState(ThemeData theme, AppLocalizations l10n) {
    // Auto-fill the prompt when entering math mode
    if (_isMathMode && _promptController.text.isEmpty) {
      _promptController.text = _mathPrompt;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Mode badge
          if (_isMathMode)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF72585).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF72585).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.functions, size: 14, color: Color(0xFFF72585)),
                  const SizedBox(width: 6),
                  Text(l10n.mathSolver,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF72585))),
                ],
              ),
            ),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(_image!,
                height: 280, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          NeumorphicContainer(
            isPressed: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            borderRadius: 20,
            child: TextField(
              controller: _promptController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: l10n.imagePromptHint,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Quick-prompt chips — differ by mode ─────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _isMathMode
                  // Math Solver: math-specific shortcuts only
                  ? [
                      _actionChip(l10n.solveStepByStep, Icons.functions,
                          color: const Color(0xFFF72585)),
                      _actionChip(l10n.explainKeyPoints,
                          Icons.lightbulb_outline,
                          color: const Color(0xFFF72585)),
                    ]
                  // General OCR: no math chip
                  : [
                      _actionChip(l10n.explainKeyPoints, Icons.lightbulb_outline),
                      _actionChip(l10n.translate, Icons.translate),
                      _actionChip(l10n.summarize, Icons.short_text),
                    ],
            ),
          ),
          const SizedBox(height: 28),
          NeumorphicButton(
            onTap: _analyzeImage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(l10n.sendToAI,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          TextButton(
              onPressed: () => setState(() {
                    _image = null;
                    _promptController.clear();
                  }),
              child: Text(l10n.retry)),
        ],
      ),
    );
  }

  Widget _actionChip(String label, IconData icon,
      {Color? color}) {
    final c = color ?? const Color(0xFF4361EE);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: c),
        label: Text(label,
            style: TextStyle(fontSize: 12, color: c)),
        backgroundColor: c.withValues(alpha: 0.08),
        side: BorderSide(color: c.withValues(alpha: 0.25)),
        onPressed: () {
          setState(() {
            _promptController.text =
                label == AppLocalizations.of(context).solveStepByStep
                    ? _mathPrompt
                    : label;
          });
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(_isOfflineMode ? l10n.extractingText : l10n.analyzingImage,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResponseState(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_image!, height: 60, width: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Text(l10n.analysisComplete, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        Expanded(
          child: NeumorphicContainer(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(_analysisResult, style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onTap: () => setState(() => _analysisResult = ''),
                      child: Center(child: Text(l10n.askFollowUp)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeumorphicButton(
                      onTap: _isMathMode
                          ? () => _generateMathStepCards(l10n)
                          : _generateFlashcards,
                      child: Center(
                        child: Text(
                          _isMathMode ? l10n.saveMathCards : l10n.flashcards,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isMathMode
                                ? const Color(0xFFF72585)
                                : null,
                            fontWeight: _isMathMode
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NeumorphicButton(
                onTap: () => setState(() {
                  _image = null;
                  _analysisResult = '';
                  _promptController.clear();
                }),
                child: Center(
                    child: Text(l10n.newPhoto,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mode toggle chip ──────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF72585)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
