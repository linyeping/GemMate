import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../core/utils.dart';

class ChatSessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final Function(String) onRename;
  final VoidCallback onDelete;

  const ChatSessionTile({
    super.key,
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = session.messages.isNotEmpty ? session.messages.last.content : 'No messages';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
          child: Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.colorScheme.onPrimaryContainer : null,
          ),
        ),
        subtitle: Text(
          '${AppUtils.truncate(lastMessage, 40)} • ${AppUtils.timeAgo(session.updatedAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            if (value == 'rename') {
              _showRenameDialog(context);
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Rename'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Controller lives inside StatefulBuilder so it's properly disposed
        // when the dialog is closed — avoids TextEditingController leaks on
        // every rename dialog open.
        final controller = TextEditingController(text: session.title);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Rename Chat'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter new title'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onRename(controller.text.trim());
                    controller.dispose();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
