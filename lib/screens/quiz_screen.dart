import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/flashcard.dart';
import '../stores/flashcard_store.dart';
import '../widgets/quiz_option_tile.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String topic;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.topic,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _isAnswered = false;
  int _score = 0;
  bool _isFinished = false;

  void _handleOptionTap(int index) {
    if (_isAnswered) return;

    setState(() {
      widget.questions[_currentIndex].selectedIndex = index;
      _isAnswered = true;
      if (widget.questions[_currentIndex].isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isFinished) {
      return _buildResults(theme);
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${_currentIndex + 1} / ${widget.questions.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  question.question,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(question.options.length, (index) {
              final label = String.fromCharCode(65 + index); // A, B, C, D
              return QuizOptionTile(
                label: label,
                text: question.options[index],
                isSelected: question.selectedIndex == index,
                isCorrect: question.correctIndex == index,
                isRevealed: _isAnswered,
                onTap: () => _handleOptionTap(index),
              );
            }),
            if (_isAnswered) ...[
              const SizedBox(height: 24),
              Card(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            question.isCorrect ? Icons.check_circle : Icons.info_outline,
                            color: question.isCorrect ? Colors.green : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            question.isCorrect ? 'Correct!' : 'Explanation',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(question.explanation),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentIndex == widget.questions.length - 1 ? 'See Results' : 'Next Question'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final percentage = (_score / widget.questions.length);
    Color resultColor = Colors.red;
    String message = '📚 Keep studying!';
    
    if (percentage >= 0.8) {
      resultColor = Colors.green;
      message = '🎉 Great job!';
    } else if (percentage >= 0.5) {
      resultColor = Colors.orange;
      message = '💪 Nice effort!';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: resultColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 12,
                      color: resultColor,
                      backgroundColor: resultColor.withOpacity(0.1),
                    ),
                  ),
                  Text(
                    '${(_score / widget.questions.length * 100).toInt()}%',
                    style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You got $_score out of ${widget.questions.length} correct',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 48),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Chat'),
            ),
            const SizedBox(height: 12),
            if (_score < widget.questions.length)
              OutlinedButton(
                onPressed: _makeFlashcardsFromWrong,
                child: const Text('Make Flashcards from Wrong Answers'),
              ),
          ],
        ),
      ),
    );
  }

  void _makeFlashcardsFromWrong() {
    final wrongQuestions = widget.questions.where((q) => !q.isCorrect).toList();
    if (wrongQuestions.isEmpty) return;

    final String groupId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    final String groupName = 'Quiz Review: ${widget.topic}';

    final List<Flashcard> newCards = wrongQuestions.asMap().entries.map((entry) {
      final q = entry.value;
      final int idx = entry.key;
      return Flashcard(
        id: '${DateTime.now().microsecondsSinceEpoch}_$idx',
        groupId: groupId,
        groupName: groupName,
        front: q.question,
        back: 'Correct Answer: ${q.options[q.correctIndex]}\n\nExplanation: ${q.explanation}',
      );
    }).toList();

    FlashcardStore().addCards(newCards);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${newCards.length} review cards to your deck!')),
    );
    Navigator.pop(context);
  }
}
