import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../stores/flashcard_store.dart';
import '../widgets/neumorphic_container.dart';
import 'deck_study_screen.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final FlashcardStore _store = FlashcardStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _store.groupIds;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            const Text('No flashcard decks yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Chat with Gemma and tap "Generate Flashcards"\nto create your first deck!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('My Decks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_store.totalCards} cards',
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 16,
            runSpacing: 20,
            children: groups.map((gid) => _buildDeckPile(gid, theme)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckPile(String groupId, ThemeData theme) {
    final cards = _store.getCardsInGroup(groupId);
    final groupName = _store.getGroupName(groupId);
    final dueCount = _store.getDueCountInGroup(groupId);
    final isDark = theme.brightness == Brightness.dark;
    final logoPath = isDark ? 'assets/Night.png' : 'assets/Day.jpg';

    final accentColors = [
      const Color(0xFF4361EE), const Color(0xFF7209B7), const Color(0xFFF72585),
      const Color(0xFF06D6A0), const Color(0xFF4CC9F0), const Color(0xFFFFBE0B),
    ];
    final accentColor = accentColors[groupId.hashCode.abs() % accentColors.length];

    final displayCount = cards.length.clamp(1, 4);
    final angles = [-6.0, -2.0, 2.0, 6.0];
    final offsets = [const Offset(-4, -3), const Offset(-2, -1), const Offset(2, 1), const Offset(4, 3)];

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 56) / 2; 
    final cardHeight = cardWidth * 1.35;

    return GestureDetector(
      onTap: () => _openDeck(groupId),
      onLongPress: () => _showDeckOptions(groupId, groupName),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < displayCount - 1; i++)
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(offsets[i].dx, offsets[i].dy)
                  ..rotateZ(angles[i] * pi / 180),
                child: Container(
                  width: cardWidth - 20,
                  height: cardHeight - 30,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 8, offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(logoPath,
                        width: 40, height: 40, fit: BoxFit.cover,
                        color: accentColor.withOpacity(0.15),
                        colorBlendMode: BlendMode.srcOver,
                      ),
                    ),
                  ),
                ),
              ),

            Container(
              width: cardWidth - 20,
              height: cardHeight - 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(isDark ? 0.25 : 0.08),
                    theme.colorScheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(isDark ? 0.2 : 0.12),
                    blurRadius: 12, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Column(
                      children: [
                        Icon(Icons.auto_stories, size: 32, color: accentColor),
                        const SizedBox(height: 10),
                        Text(
                          groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cards.length} cards',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        if (dueCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF476F).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$dueCount due',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFEF476F),
                                fontWeight: FontWeight.bold,
                              )),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06D6A0).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('✓ done',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF06D6A0),
                                fontWeight: FontWeight.bold,
                              )),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeck(String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeckStudyScreen(groupId: groupId),
      ),
    );
  }

  void _showDeckOptions(String groupId, String currentName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                )),
              const SizedBox(height: 24),
              Text(currentName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              ListTile(
                leading: const Icon(Icons.play_arrow, color: Color(0xFF4361EE)),
                title: const Text('Study this deck'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openDeck(groupId);
                },
              ),

              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFFFFBE0B)),
                title: const Text('Rename deck'),
                onTap: () {
                  Navigator.pop(ctx);
                  _renameDeck(groupId, currentName);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF476F)),
                title: const Text('Delete deck', style: TextStyle(color: Color(0xFFEF476F))),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteDeck(groupId, currentName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _renameDeck(String groupId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Deck name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _store.renameGroup(groupId, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteDeck(String groupId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text('All cards in this deck will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _store.deleteGroup(groupId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF476F))),
          ),
        ],
      ),
    );
  }
}
