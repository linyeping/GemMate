import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/flashcard.dart';
import '../stores/flashcard_store.dart';

/// Shows a QR code that encodes a flashcard deck.
/// Another device running GemMate can scan it in [QrScanScreen] to import.
///
/// QR payload format (JSON, compact):
///   {"v":1,"n":"deck name","c":[{"f":"front","b":"back"},…]}
///
/// Capacity: QR v40 / medium EC ≈ 2800 bytes → ~15 average-length cards fit
/// comfortably. Larger decks are truncated with a warning.
class QrShareScreen extends StatefulWidget {
  final String groupId;

  const QrShareScreen({super.key, required this.groupId});

  @override
  State<QrShareScreen> createState() => _QrShareScreenState();
}

class _QrShareScreenState extends State<QrShareScreen> {
  static const int _maxPayloadBytes = 2700;
  static const int _hardCardLimit = 30; // Never try to encode more than this

  late final String _groupName;
  late final List<Flashcard> _allCards;
  late final List<Flashcard> _encodedCards;
  late final String _payload;
  bool _truncated = false;

  @override
  void initState() {
    super.initState();
    final store = FlashcardStore();
    _groupName = store.getGroupName(widget.groupId);
    _allCards = store.getCardsInGroup(widget.groupId);
    _buildPayload();
  }

  void _buildPayload() {
    // Build card list incrementally until payload exceeds limit
    final cards = <Map<String, String>>[];
    for (final card in _allCards.take(_hardCardLimit)) {
      cards.add({'f': card.front, 'b': card.back});
      final candidate = jsonEncode({'v': 1, 'n': _groupName, 'c': cards});
      if (utf8.encode(candidate).length > _maxPayloadBytes) {
        cards.removeLast();
        _truncated = true;
        break;
      }
    }
    if (_allCards.length > _hardCardLimit) _truncated = true;
    _encodedCards = _allCards.take(cards.length).toList();
    _payload = jsonEncode({'v': 1, 'n': _groupName, 'c': cards});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Deck via QR',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Deck info
            Text(
              _groupName,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Sharing ${_encodedCards.length} of ${_allCards.length} cards',
              style:
                  const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            // Truncation warning
            if (_truncated) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFBE0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFFBE0B)
                          .withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFFBE0B), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deck too large for a single QR code. '
                        'Only the first ${_encodedCards.length} cards are included.',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFFBE0B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // QR code
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: isDark ? 0.4 : 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: _payload,
                version: QrVersions.auto,
                size: 260,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Row(children: [
                    Icon(Icons.smartphone, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Open GemMate on another device',
                            style: TextStyle(fontSize: 13))),
                  ]),
                  SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.style_outlined,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('Go to Flashcards → Scan QR',
                            style: TextStyle(fontSize: 13))),
                  ]),
                  SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.qr_code_scanner,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('Point camera at this code',
                            style: TextStyle(fontSize: 13))),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Copy JSON button (for manual sharing)
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _payload));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Deck JSON copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy JSON to clipboard'),
            ),
          ],
        ),
      ),
    );
  }
}
