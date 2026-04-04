import 'package:flutter/material.dart';
import '../services/model_download_service.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/animated_avatar.dart';
import '../l10n/app_localizations.dart';

class DownloadProgressWidget extends StatelessWidget {
  final ModelDownloadProgress? progress;
  final ModelDownloadStatus status;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  const DownloadProgressWidget({
    super.key,
    this.progress,
    required this.status,
    required this.onDownload,
    required this.onCancel,
    required this.onRetry,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    switch (status) {
      case ModelDownloadStatus.idle:
        return NeumorphicContainer(
          child: Column(
            children: [
              Text(l10n.onDeviceModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Text(l10n.downloadAIModelDesc, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.outline)),
              const SizedBox(height: 24),
              NeumorphicButton(
                onTap: onDownload,
                child: Center(child: Text(l10n.downloadNow, style: const TextStyle(fontWeight: FontWeight.bold))),
              ),
              TextButton(onPressed: onSkip, child: Text(l10n.skipForNow)),
            ],
          ),
        );

      case ModelDownloadStatus.downloading:
        return NeumorphicContainer(
          isPressed: true,
          child: Column(
            children: [
              const AnimatedAvatar(size: 48, isThinking: true),
              const SizedBox(height: 16),
              Text(progress?.percentText ?? '0%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(progress?.progressText ?? '', style: TextStyle(color: theme.colorScheme.outline)),
              const SizedBox(height: 24),
              NeumorphicContainer(
                isPressed: true,
                padding: EdgeInsets.zero,
                height: 8,
                child: LinearProgressIndicator(
                  value: progress?.progress ?? 0,
                  backgroundColor: Colors.transparent,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
            ],
          ),
        );

      case ModelDownloadStatus.completed:
        return NeumorphicContainer(
          accentBorderColor: Colors.green,
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(l10n.modelInstalled, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              NeumorphicButton(
                onTap: onSkip, // Navigate to main app
                child: Center(child: Text(l10n.startStudying, style: const TextStyle(fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        );

      case ModelDownloadStatus.error:
        return NeumorphicContainer(
          accentBorderColor: Colors.red,
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(l10n.downloadFailed, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onTap: onRetry,
                      child: Center(child: Text(l10n.retry)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(onPressed: onSkip, child: Text(l10n.skipForNow)),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
