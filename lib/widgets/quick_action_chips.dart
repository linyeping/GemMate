import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'neumorphic_button.dart';

class QuickActionChips extends StatelessWidget {
  final VoidCallback onFlashcards;
  final VoidCallback onQuiz;
  final VoidCallback onPlan;
  final VoidCallback onTranslate;
  final VoidCallback onCamera;
  final VoidCallback onSummary;
  final VoidCallback onMindMap;
  final bool isLoading;

  const QuickActionChips({
    super.key,
    required this.onFlashcards,
    required this.onQuiz,
    required this.onPlan,
    required this.onTranslate,
    required this.onCamera,
    required this.onSummary,
    required this.onMindMap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _NeumorphicChip(
            label: '📝 ${l10n.makeFlashcards}',
            accentColor: const Color(0xFF7209B7), // secondaryPurple
            onTap: isLoading ? null : onFlashcards,
          ),
          _NeumorphicChip(
            label: '📊 ${l10n.quizMe}',
            accentColor: const Color(0xFFF72585), // accentPink
            onTap: isLoading ? null : onQuiz,
          ),
          _NeumorphicChip(
            label: '📋 ${l10n.studyPlan}',
            accentColor: const Color(0xFF4361EE), // primaryBlue
            onTap: isLoading ? null : onPlan,
          ),
          _NeumorphicChip(
            label: '🔄 ${l10n.translate}',
            accentColor: const Color(0xFF4CC9F0), // calmTeal
            onTap: isLoading ? null : onTranslate,
          ),
          _NeumorphicChip(
            label: '📷 ${l10n.camera}',
            accentColor: const Color(0xFFFFBE0B), // warningAmber
            onTap: isLoading ? null : onCamera,
          ),
          _NeumorphicChip(
            label: '📋 ${l10n.summarize}',
            accentColor: const Color(0xFF06D6A0),
            onTap: isLoading ? null : onSummary,
          ),
          _NeumorphicChip(
            label: '🗺 ${l10n.mindMap}',
            accentColor: const Color(0xFFEF476F),
            onTap: isLoading ? null : onMindMap,
          ),
        ],
      ),
    );
  }
}

class _NeumorphicChip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback? onTap;

  const _NeumorphicChip({
    required this.label,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: NeumorphicButton(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 20,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}
