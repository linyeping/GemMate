import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../stores/theme_store.dart';

class ColorSchemePicker extends StatelessWidget {
  const ColorSchemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = ThemeStore();

    return ListenableBuilder(
      listenable: themeStore,
      builder: (context, _) {
        return Wrap(
          spacing: 12,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: AppColorScheme.values.map((scheme) {
            final isSelected = themeStore.currentScheme == scheme;
            final colors = _getSchemePrimaryColor(scheme);

            return InkWell(
              onTap: () => themeStore.setScheme(scheme),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scheme.name[0].toUpperCase() + scheme.name.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getSchemePrimaryColor(AppColorScheme scheme) {
    return switch (scheme) {
      AppColorScheme.ocean    => const Color(0xFF1565C0),
      AppColorScheme.sunset   => const Color(0xFFE65100),
      AppColorScheme.forest   => const Color(0xFF2E7D32),
      AppColorScheme.lavender => const Color(0xFF7B1FA2),
      AppColorScheme.aurora   => const Color(0xFF00695C),
      AppColorScheme.cherry   => const Color(0xFFC62828),
      AppColorScheme.midnight => const Color(0xFF1A237E),
      AppColorScheme.candy    => const Color(0xFFE91E63),
    };
  }
}
