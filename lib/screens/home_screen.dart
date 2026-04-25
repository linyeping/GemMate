import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/streak_service.dart';
import '../stores/flashcard_store.dart';
import '../stores/chat_store.dart';
import '../widgets/neumorphic_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen: streak counter + pomodoro timer
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // ── streak ────────────────────────────────────────────────────────────────
  int _streak = 0;
  int _totalDays = 0;
  int _pomodorosToday = 0;

  // ── pomodoro ──────────────────────────────────────────────────────────────
  int _workMinutes  = 25;
  int _breakMinutes = 5;

  int get _workSecs  => _workMinutes  * 60;
  int get _breakSecs => _breakMinutes * 60;

  int _remaining = 25 * 60; // default until prefs load
  bool _isRunning = false;
  bool _isBreak   = false;
  Timer? _timer;

  // ── stores ────────────────────────────────────────────────────────────────
  final _flashcardStore = FlashcardStore();
  final _chatStore = ChatStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _flashcardStore.addListener(_onStoreChange);
    _chatStore.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _flashcardStore.removeListener(_onStoreChange);
    _chatStore.removeListener(_onStoreChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isRunning) {
      _pauseTimer();
    }
  }

  void _onStoreChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final streak    = await StreakService().getStreak();
    final total     = await StreakService().getTotalDays();
    final pomodoros = await StreakService().getPomodorosToday();
    final prefs     = await SharedPreferences.getInstance();
    final workMin   = prefs.getInt('pomodoro_work_min')  ?? 25;
    final breakMin  = prefs.getInt('pomodoro_break_min') ?? 5;
    if (mounted) {
      setState(() {
        _streak       = streak;
        _totalDays    = total;
        _pomodorosToday = pomodoros;
        _workMinutes  = workMin;
        _breakMinutes = breakMin;
        // Only reset timer if not currently running
        if (!_isRunning) _remaining = _workSecs;
      });
    }
  }

  // ── pomodoro controls ─────────────────────────────────────────────────────

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > 0) {
        setState(() => _remaining--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak   = false;
      _remaining = _workSecs;
    });
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (!_isBreak) {
      final count = await StreakService().recordPomodoro();
      await _loadData();
      if (mounted) {
        _showSessionCompleteDialog(count);
      }
    } else {
      if (mounted) {
        setState(() {
          _isBreak = false;
          _remaining = _workSecs;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).breakOver)),
        );
      }
    }
  }

  void _startBreak() {
    setState(() {
      _isBreak   = true;
      _remaining = _breakSecs;
    });
    _startTimer();
  }

  // ── Custom timer settings ─────────────────────────────────────────────────

  void _showTimerSettings(AppLocalizations l10n) {
    int tempWork  = _workMinutes;
    int tempBreak = _breakMinutes;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text(l10n.customTimer,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),

              // Work duration
              Row(children: [
                Text(l10n.workDuration,
                    style: const TextStyle(fontSize: 15)),
                const Spacer(),
                _MinutesPicker(
                  value: tempWork,
                  min: 1,
                  max: 120,
                  unit: l10n.minutesUnit,
                  onChanged: (v) => setModal(() => tempWork = v),
                ),
              ]),
              const SizedBox(height: 16),

              // Break duration
              Row(children: [
                Text(l10n.breakDuration,
                    style: const TextStyle(fontSize: 15)),
                const Spacer(),
                _MinutesPicker(
                  value: tempBreak,
                  min: 1,
                  max: 60,
                  unit: l10n.minutesUnit,
                  onChanged: (v) => setModal(() => tempBreak = v),
                ),
              ]),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _applyTimerSettings(tempWork, tempBreak);
                  },
                  child: Text(l10n.apply),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyTimerSettings(int workMin, int breakMin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoro_work_min',  workMin);
    await prefs.setInt('pomodoro_break_min', breakMin);
    _timer?.cancel();
    setState(() {
      _workMinutes  = workMin;
      _breakMinutes = breakMin;
      _isRunning    = false;
      _isBreak      = false;
      _remaining    = _workSecs;
    });
  }

  void _showSessionCompleteDialog(int count) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.sessionComplete, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pomodorosDoneToday(count),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.streakLabel(_streak),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startBreak();
            },
            child: Text(l10n.takeABreak),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _remaining = _workSecs);
            },
            child: Text(l10n.keepGoing),
          ),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 18
            ? l10n.goodAfternoon
            : l10n.goodEvening;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GemMate', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: l10n.customTimer,
            onPressed: () => _showTimerSettings(l10n),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(l10n.readyToStudy,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // ── stat cards row 1 ────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _StatCard(
                  emoji: '🔥',
                  value: '$_streak',
                  label: l10n.dayStreak,
                  color: Colors.orange,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  emoji: '📅',
                  value: '$_totalDays',
                  label: l10n.totalDays,
                  color: const Color(0xFF4361EE),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  emoji: '🍅',
                  value: '$_pomodorosToday',
                  label: l10n.today,
                  color: Colors.red,
                )),
              ],
            ),
            const SizedBox(height: 12),

            // ── stat cards row 2 ────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _StatCard(
                  emoji: '🗂',
                  value: '${_flashcardStore.totalCards}',
                  label: l10n.cards,
                  color: const Color(0xFF7209B7),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  emoji: '⏰',
                  value: '${_flashcardStore.dueCount}',
                  label: l10n.dueNow,
                  color: _flashcardStore.dueCount > 0 ? Colors.red : Colors.green,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  emoji: '💬',
                  value: '${_chatStore.sessions.length}',
                  label: l10n.chats,
                  color: const Color(0xFF06D6A0),
                )),
              ],
            ),

            const SizedBox(height: 32),

            // ── pomodoro timer ──────────────────────────────────────────────
            NeumorphicContainer(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isBreak ? Icons.coffee : Icons.timer,
                        color: _isBreak ? Colors.brown : const Color(0xFF4361EE),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isBreak ? l10n.breakTime : l10n.focusSession,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _isBreak ? Colors.brown : const Color(0xFF4361EE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Circular progress ring
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: _isBreak
                                ? _remaining / _breakSecs
                                : _remaining / _workSecs,
                            strokeWidth: 10,
                            color: _isBreak
                                ? Colors.brown
                                : const Color(0xFF4361EE),
                            backgroundColor:
                                (_isBreak ? Colors.brown : const Color(0xFF4361EE))
                                    .withValues(alpha: 0.1),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_remaining),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _isBreak ? l10n.timerRest : l10n.timerFocus,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.replay),
                        tooltip: l10n.reset,
                      ),
                      const SizedBox(width: 20),

                      // Start / Pause
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: FilledButton(
                          onPressed: _isRunning ? _pauseTimer : _startTimer,
                          style: FilledButton.styleFrom(
                            backgroundColor: _isBreak
                                ? Colors.brown
                                : const Color(0xFF4361EE),
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Finish early
                      IconButton.outlined(
                        onPressed: _isBreak || _remaining == _workSecs
                            ? null
                            : () => _showSessionCompleteDialog(_pomodorosToday),
                        icon: const Icon(Icons.skip_next),
                        tooltip: l10n.finishEarly,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sessionsCompletedToday(_pomodorosToday),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── tip ─────────────────────────────────────────────────────────
            NeumorphicContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isBreak ? l10n.breakTip : l10n.focusTip,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Minute selector: tap the number to type directly, or use +/- buttons.
class _MinutesPicker extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final String unit;
  final void Function(int) onChanged;

  const _MinutesPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<_MinutesPicker> createState() => _MinutesPickerState();
}

class _MinutesPickerState extends State<_MinutesPicker> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
    _focus = FocusNode();
    // Validate and clamp when focus leaves the field
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit(_ctrl.text);
    });
  }

  @override
  void didUpdateWidget(_MinutesPicker old) {
    super.didUpdateWidget(old);
    // Keep text in sync when parent changes value (e.g. via +/- buttons)
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit(String text) {
    final parsed = int.tryParse(text.trim());
    if (parsed == null) {
      // Invalid input — restore current value
      _ctrl.text = '${widget.value}';
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    _ctrl.text = '$clamped';
    widget.onChanged(clamped);
  }

  void _increment(int delta) {
    final next = (widget.value + delta).clamp(widget.min, widget.max);
    _ctrl.text = '$next';
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── minus ──────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: widget.value > widget.min ? () => _increment(-1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        // ── editable number ────────────────────────────────────────────────
        SizedBox(
          width: 58,
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.8,
                ),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onSubmitted: _commit,
            onTap: () {
              // Select all text so typing immediately replaces it
              _ctrl.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _ctrl.text.length,
              );
            },
          ),
        ),

        // ── plus ───────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: widget.value < widget.max ? () => _increment(1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        Text(' ${widget.unit}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
