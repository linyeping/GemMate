import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  List<QuizResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await StorageService().loadQuizResults();
    if (mounted) {
      setState(() {
        _results = raw.reversed.toList(); // newest first
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmpty()
              : _buildContent(theme),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No exam results yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          const Text(
            'Generate a quiz and tap "⏱ Exam Mode"\nto track your progress',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────────────────

  Widget _buildContent(ThemeData theme) {
    final recent = _results.take(50).toList();
    final avgPct =
        recent.map((r) => r.percentage).reduce((a, b) => a + b) /
            recent.length;
    final bestPct = recent.map((r) => r.percentage).reduce(max);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Summary row ─────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
                child: _summaryCard(
                    'Avg', '${(avgPct * 100).toInt()}%',
                    Icons.trending_up, theme.colorScheme.primary, theme)),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard(
                    'Best', '${(bestPct * 100).toInt()}%',
                    Icons.star_rounded, const Color(0xFFFFBE0B), theme)),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard('Total', '${recent.length}',
                    Icons.assignment_turned_in_outlined,
                    const Color(0xFF06D6A0), theme)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Bar chart ────────────────────────────────────────────────────
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score trend  (last ${min(10, recent.length)} exams)',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 130,
                  child: _ScoreBarChart(
                    results: recent
                        .take(10)
                        .toList()
                        .reversed
                        .toList(), // oldest → newest L→R
                    primaryColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Result list ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('All Results',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        ...recent
            .asMap()
            .entries
            .map((e) => _resultTile(e.value, theme)),
      ],
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────

  Widget _summaryCard(String label, String value, IconData icon,
      Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Result tile ────────────────────────────────────────────────────────────

  Widget _resultTile(QuizResult r, ThemeData theme) {
    final pct = (r.percentage * 100).toInt();
    Color color;
    if (r.percentage >= 0.8) {
      color = const Color(0xFF06D6A0);
    } else if (r.percentage >= 0.6) {
      color = const Color(0xFFFFBE0B);
    } else {
      color = const Color(0xFFEF476F);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Center(
            child: Text('$pct%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
        ),
        title: Text(r.topic,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${r.score}/${r.total} correct  •  ${r.timeFormatted}'),
        trailing: Text(
          _relDate(r.timestamp),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  String _relDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content:
            const Text('This permanently deletes all exam results.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService().saveQuizResults([]);
              if (mounted) {
                setState(() => _results = []);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFEF476F))),
          ),
        ],
      ),
    );
  }
}

// ── Bar chart ──────────────────────────────────────────────────────────────────

class _ScoreBarChart extends StatelessWidget {
  final List<QuizResult> results;
  final Color primaryColor;

  const _ScoreBarChart(
      {required this.results, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarPainter(results: results),
      child: const SizedBox.expand(),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<QuizResult> results;
  _BarPainter({required this.results});

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;

    final n = results.length;
    final slotW = size.width / n;
    final barW = (slotW * 0.55).clamp(8.0, 36.0);
    final chartH = size.height - 20; // 20 px reserved for labels above bars

    // Baseline
    canvas.drawLine(
      Offset(0, chartH),
      Offset(size.width, chartH),
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    for (int i = 0; i < n; i++) {
      final r = results[i];
      final barH = (chartH * r.percentage).clamp(2.0, chartH);
      final cx = i * slotW + slotW / 2;
      final top = chartH - barH;

      Color barColor;
      if (r.percentage >= 0.8) {
        barColor = const Color(0xFF06D6A0);
      } else if (r.percentage >= 0.6) {
        barColor = const Color(0xFFFFBE0B);
      } else {
        barColor = const Color(0xFFEF476F);
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, top, barW, barH),
        const Radius.circular(5),
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [barColor, barColor.withValues(alpha: 0.45)],
          ).createShader(
              Rect.fromLTWH(cx - barW / 2, top, barW, barH)),
      );

      // Percentage label above bar
      final pct = '${(r.percentage * 100).toInt()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: pct,
          style: TextStyle(
              color: barColor,
              fontSize: 9,
              fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, top - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.results != results;
}
