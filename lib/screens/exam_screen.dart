import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';
import '../stores/flashcard_store.dart';
import '../widgets/quiz_option_tile.dart';
import 'exam_history_screen.dart';

class ExamScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String topic;

  /// Seconds allocated per question (default 45 s).
  final int secondsPerQuestion;

  const ExamScreen({
    super.key,
    required this.questions,
    required this.topic,
    this.secondsPerQuestion = 45,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _isAnswered = false;
  bool _resultSaved = false;

  late final int _totalSeconds;
  late int _remaining;
  Timer? _timer;
  late final Stopwatch _sw;

  @override
  void initState() {
    super.initState();
    // Reset question state from previous attempts
    for (final q in widget.questions) {
      q.selectedIndex = null;
    }
    _totalSeconds = widget.questions.length * widget.secondsPerQuestion;
    _remaining = _totalSeconds;
    _sw = Stopwatch()..start();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sw.stop();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _timer?.cancel();
          _finishExam();
        }
      });
    });
  }

  // ── Interaction ───────────────────────────────────────────────────────────

  void _handleOption(int index) {
    if (_isAnswered) return;
    setState(() {
      widget.questions[_currentIndex].selectedIndex = index;
      _isAnswered = true;
      if (widget.questions[_currentIndex].isCorrect) _score++;
    });
    // Auto-advance after brief feedback window
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && _isAnswered && !_isFinished) _next();
    });
  }

  void _next() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
      });
    } else {
      _finishExam();
    }
  }

  void _finishExam() {
    if (_isFinished) return;
    _timer?.cancel();
    _sw.stop();
    setState(() => _isFinished = true);
    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_resultSaved) return;
    _resultSaved = true;
    await StorageService().addQuizResult(QuizResult(
      topic: widget.topic,
      score: _score,
      total: widget.questions.length,
      timeTakenSeconds: _sw.elapsed.inSeconds,
      timestamp: DateTime.now(),
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _timeDisplay {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    final frac = _remaining / max(_totalSeconds, 1);
    if (frac > 0.5) return const Color(0xFF06D6A0);
    if (frac > 0.25) return const Color(0xFFFFBE0B);
    return const Color(0xFFEF476F);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isFinished) return _buildResults(theme);

    final question = widget.questions[_currentIndex];
    final progress =
        (_currentIndex + (_isAnswered ? 1.0 : 0.0)) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('⏱ ${widget.topic}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Timer bar ───────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Row(
              children: [
                // Circular countdown
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: _remaining / max(_totalSeconds, 1),
                        strokeWidth: 5,
                        backgroundColor:
                            Colors.grey.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_timerColor),
                      ),
                    ),
                    Text(
                      _timeDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _timerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} / ${widget.questions.length}',
                        style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Score: $_score correct',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Question + options ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.4),
                          width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        question.question,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(question.options.length, (i) {
                    return QuizOptionTile(
                      label: String.fromCharCode(65 + i),
                      text: question.options[i],
                      isSelected: question.selectedIndex == i,
                      isCorrect: question.correctIndex == i,
                      isRevealed: _isAnswered,
                      onTap: () => _handleOption(i),
                    );
                  }),

                  // Feedback + manual next
                  if (_isAnswered) ...[
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: question.isCorrect
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: question.isCorrect
                              ? Colors.green.withValues(alpha: 0.35)
                              : Colors.red.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            question.isCorrect
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: question.isCorrect
                                ? Colors.green
                                : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            question.isCorrect
                                ? 'Correct!'
                                : 'Incorrect — moving on…',
                            style: TextStyle(
                              color: question.isCorrect
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(
                        _currentIndex == widget.questions.length - 1
                            ? 'Finish Exam'
                            : 'Next Question',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResults(ThemeData theme) {
    final total = widget.questions.length;
    final pct = total > 0 ? _score / total : 0.0;
    final elapsed = _sw.elapsed.inSeconds;
    final mins = elapsed ~/ 60;
    final secs = elapsed % 60;

    Color resultColor;
    String message;
    if (pct >= 0.8) {
      resultColor = const Color(0xFF06D6A0);
      message = '🎯 Excellent!';
    } else if (pct >= 0.6) {
      resultColor = const Color(0xFFFFBE0B);
      message = '💪 Good effort!';
    } else {
      resultColor = const Color(0xFFEF476F);
      message = '📚 Keep practising!';
    }

    final wrongQs =
        widget.questions.where((q) => q.isAnswered && !q.isCorrect).toList();
    final skipped =
        widget.questions.where((q) => !q.isAnswered).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExamHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: resultColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Score ring
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 13,
                      color: resultColor,
                      backgroundColor:
                          resultColor.withValues(alpha: 0.12),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(pct * 100).toInt()}%',
                        style: theme.textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_score / $total',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stat chips
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _statChip(Icons.timer_outlined,
                    '${mins}m ${secs.toString().padLeft(2, '0')}s', theme),
                _statChip(Icons.check_circle_outline,
                    '$_score correct', theme),
                if (skipped > 0)
                  _statChip(
                      Icons.skip_next, '$skipped skipped', theme),
              ],
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ExamHistoryScreen()),
              ),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('View History'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 12),

            if (wrongQs.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _makeFlashcards(wrongQs),
                icon: const Icon(Icons.style_outlined),
                label: Text(
                    'Flashcards from ${wrongQs.length} wrong answer${wrongQs.length == 1 ? '' : 's'}'),
                style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14)),
              ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  void _makeFlashcards(List<QuizQuestion> wrongQs) {
    final groupId = 'exam_${DateTime.now().millisecondsSinceEpoch}';
    final cards = wrongQs.asMap().entries.map((e) {
      final q = e.value;
      return Flashcard(
        id: '${DateTime.now().microsecondsSinceEpoch}_${e.key}',
        groupId: groupId,
        groupName: 'Exam Errors: ${widget.topic}',
        front: q.question,
        back:
            'Correct: ${q.options[q.correctIndex]}\n\n${q.explanation}',
      );
    }).toList();
    FlashcardStore().addCards(cards);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Added ${cards.length} review card${cards.length == 1 ? '' : 's'}!')),
      );
    }
  }
}
