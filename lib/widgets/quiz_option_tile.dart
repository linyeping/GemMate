import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isRevealed;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isRevealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color borderColor = _getBorderColor(theme);
    Color? backgroundColor = _getBackgroundColor(theme);
    Widget? trailing;

    if (isRevealed) {
      if (isCorrect) {
        trailing = const Icon(Icons.check_circle, color: Colors.green);
      } else if (isSelected && !isCorrect) {
        trailing = const Icon(Icons.cancel, color: Colors.red);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: isRevealed ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected || (isRevealed && isCorrect) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isRevealed && !isCorrect && !isSelected 
                        ? theme.colorScheme.onSurface.withOpacity(0.5) 
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ThemeData theme) {
    if (!isRevealed) {
      if (isSelected) return theme.colorScheme.primary;
      return switch (label) {
        'A' => Colors.blue,
        'B' => Colors.green,
        'C' => Colors.orange,
        'D' => Colors.purple,
        _ => theme.colorScheme.outline,
      };
    }
    if (isCorrect) return Colors.green;
    if (isSelected && !isCorrect) return Colors.red;
    return theme.colorScheme.outline.withOpacity(0.3);
  }

  Color? _getBackgroundColor(ThemeData theme) {
    if (!isRevealed) {
      if (isSelected) return theme.colorScheme.primaryContainer.withOpacity(0.3);
      return null;
    }
    if (isCorrect) return Colors.green.withOpacity(0.1);
    if (isSelected && !isCorrect) return Colors.red.withOpacity(0.1);
    return null;
  }
}
