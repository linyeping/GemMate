import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/connection_store.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectionStore(),
      builder: (context, _) {
        final isConnected = ConnectionStore().isConnected;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.green.withOpacity(0.15)
                : Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.computer : Icons.phone_android,
                size: 16,
                color: isConnected ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'Gemma 4 E2B' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: isConnected ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
