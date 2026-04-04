import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/flashcard_screen.dart';
import '../screens/settings_screen.dart';
import '../stores/flashcard_store.dart';
import '../l10n/app_localizations.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 0;
  final FlashcardStore _flashcardStore = FlashcardStore();

  @override
  void initState() {
    super.initState();
    _flashcardStore.addListener(_updateBadge);
  }

  @override
  void dispose() {
    _flashcardStore.removeListener(_updateBadge);
    super.dispose();
  }

  void _updateBadge() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dueCount = _flashcardStore.dueCount;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChatScreen(),
          FlashcardScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: const Color(0xFF4361EE).withOpacity(0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline, size: 22),
            selectedIcon: const Icon(Icons.chat_bubble, size: 22, color: Color(0xFF4361EE)),
            label: l10n.studyChat,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: dueCount > 0,
              label: Text('$dueCount'),
              child: const Icon(Icons.style_outlined, size: 22),
            ),
            selectedIcon: Badge(
              isLabelVisible: dueCount > 0,
              label: Text('$dueCount'),
              child: const Icon(Icons.style, size: 22, color: Color(0xFF4361EE)),
            ),
            label: l10n.flashcards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined, size: 22),
            selectedIcon: const Icon(Icons.settings, size: 22, color: Color(0xFF4361EE)),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
