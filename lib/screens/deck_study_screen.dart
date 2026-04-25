import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/flashcard.dart';
import '../stores/flashcard_store.dart';
import '../stores/locale_store.dart';

class DeckStudyScreen extends StatefulWidget {
  final String groupId;
  const DeckStudyScreen({super.key, required this.groupId});
  @override
  State<DeckStudyScreen> createState() => _DeckStudyScreenState();
}

class _DeckStudyScreenState extends State<DeckStudyScreen>
    with SingleTickerProviderStateMixin {
  final FlashcardStore _store = FlashcardStore();
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _showingFront = true;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _cards = _store.getCardsInGroup(widget.groupId);
    _initTts();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  Future<void> _initTts() async {
    // Map app locale to a TTS language code
    final lang = LocaleStore().languageCode;
    final ttsLang = const {
      'zh': 'zh-CN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'fr': 'fr-FR',
      'es': 'es-ES',
    }[lang] ?? 'en-US';

    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    _tts.stop();
    setState(() => _isSpeaking = false);
    if (_showingFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _showingFront = !_showingFront);
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      _tts.stop();
      _flipController.stop();
      setState(() {
        _currentIndex++;
        _showingFront = true;
        _isSpeaking = false;
        _flipController.reset();
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      _tts.stop();
      _flipController.stop();
      setState(() {
        _currentIndex--;
        _showingFront = true;
        _isSpeaking = false;
        _flipController.reset();
      });
    }
  }

  void _rateCard(int quality) {
    // SM-2 algorithm
    final card = _cards[_currentIndex];
    int newReps = card.repetitions;
    double newEF = card.easeFactor;
    int newInterval = card.interval;

    if (quality >= 3) {
      if (newReps == 0) { newInterval = 1; }
      else if (newReps == 1) { newInterval = 6; }
      else { newInterval = (newInterval * newEF).round(); }
      newReps++;
    } else {
      newReps = 0;
      newInterval = 1;
    }

    newEF = newEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEF < 1.3) newEF = 1.3;

    final updated = card.copyWith(
      repetitions: newReps,
      easeFactor: newEF,
      interval: newInterval,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
    );

    _store.updateCard(updated);
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groupName = _store.getGroupName(widget.groupId);

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(groupName)),
        body: const Center(child: Text('No cards in this deck')),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        centerTitle: true,
        actions: [
          // TTS speak button
          IconButton(
            tooltip: _isSpeaking ? 'Stop' : 'Read aloud',
            icon: Icon(
              _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
              color: _isSpeaking ? const Color(0xFF06D6A0) : null,
            ),
            onPressed: () {
              final card = _cards[_currentIndex];
              _speak(_showingFront ? card.front : card.back);
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1} / ${_cards.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _flipCard,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) _nextCard();
            if (details.primaryVelocity! > 200) _prevCard();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  minHeight: 6,
                  color: const Color(0xFF4361EE),
                  backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final isBack = angle > pi / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) 
                        ..rotateY(angle),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isBack
                                ? [const Color(0xFF06D6A0).withOpacity(0.1), theme.colorScheme.surface]
                                : [const Color(0xFF4361EE).withOpacity(0.1), theme.colorScheme.surface],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (isBack ? const Color(0xFF06D6A0) : const Color(0xFF4361EE)).withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isBack ? const Color(0xFF06D6A0) : const Color(0xFF4361EE)).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: isBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi), 
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lightbulb, color: Color(0xFF06D6A0), size: 28),
                                      const SizedBox(height: 16),
                                      const Text('Answer', style: TextStyle(
                                        fontSize: 12, color: Color(0xFF06D6A0),
                                        fontWeight: FontWeight.bold, letterSpacing: 2,
                                      )),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(card.back,
                                            style: const TextStyle(fontSize: 18, height: 1.6),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.help_outline, color: Color(0xFF4361EE), size: 28),
                                    const SizedBox(height: 16),
                                    const Text('Question', style: TextStyle(
                                      fontSize: 12, color: Color(0xFF4361EE),
                                      fontWeight: FontWeight.bold, letterSpacing: 2,
                                    )),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(card.front,
                                          style: const TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Tap to flip', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              if (!_showingFront) ...[
                const Text('How well did you know this?',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _rateButton('Again', const Color(0xFFEF476F), 1),
                    _rateButton('Hard', const Color(0xFFFFBE0B), 3),
                    _rateButton('Good', const Color(0xFF4361EE), 4),
                    _rateButton('Easy', const Color(0xFF06D6A0), 5),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex > 0)
                      TextButton.icon(
                        onPressed: _prevCard,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Prev'),
                      )
                    else
                      const SizedBox(),
                    const Text('Swipe or tap',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                    if (_currentIndex < _cards.length - 1)
                      TextButton.icon(
                        onPressed: _nextCard,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Next'),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rateButton(String label, Color color, int quality) {
    return GestureDetector(
      onTap: () => _rateCard(quality),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
