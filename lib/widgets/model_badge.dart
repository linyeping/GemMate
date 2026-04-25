import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ModelBadge extends StatelessWidget {
  final ModelUsed modelUsed;
  final int? latencyMs;

  const ModelBadge({
    super.key,
    required this.modelUsed,
    this.latencyMs,
  });

  @override
  Widget build(BuildContext context) {
    if (modelUsed == ModelUsed.none) return const SizedBox.shrink();

    final isRemote = modelUsed == ModelUsed.remoteE2B;
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isRemote ? Icons.computer : Icons.phone_android,
          size: 11,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          isRemote ? 'Gemma 4 E4B · Laptop' : 'Gemma 4 E2B · On-device',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (latencyMs != null) ...[
          const SizedBox(width: 6),
          Text(
            '${(latencyMs! / 1000).toStringAsFixed(1)}s',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}
