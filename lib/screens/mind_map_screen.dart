import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class MindMapNode {
  final String label;
  final List<MindMapNode> children;
  const MindMapNode({required this.label, required this.children});

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    final label =
        json['label'] as String? ?? json['topic'] as String? ?? '';
    final rawChildren = json['children'];
    final children = rawChildren is List
        ? rawChildren
            .whereType<Map<String, dynamic>>()
            .map(MindMapNode.fromJson)
            .toList()
        : <MindMapNode>[];
    return MindMapNode(label: label, children: children);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout engine
// ─────────────────────────────────────────────────────────────────────────────

const double _slotH  = 70.0;   // vertical space per leaf node
const double _levelW = 220.0;  // horizontal step between depth levels
const double _nodeW  = 155.0;  // non-root node width
const double _nodeH  = 44.0;   // non-root node height
const double _rootW  = 175.0;  // root node width
const double _rootH  = 54.0;   // root node height
const double _padH   = 40.0;   // horizontal canvas padding (left)
const double _padV   = 56.0;   // vertical canvas padding (top/bottom)

class _PlacedNode {
  final MindMapNode node;
  final double x, y;   // top-left corner
  final int depth;
  final int branch;    // which top-level branch (for colour)
  const _PlacedNode(this.node, this.x, this.y, this.depth, this.branch);
}

int _leafCount(MindMapNode n) =>
    n.children.isEmpty ? 1 : n.children.fold(0, (s, c) => s + _leafCount(c));

List<_PlacedNode> _buildLayout(MindMapNode root) {
  final placed = <_PlacedNode>[];
  final totalH = _leafCount(root) * _slotH;

  void place(
      MindMapNode node, double x, double y0, double y1, int depth, int branch) {
    final h = depth == 0 ? _rootH : _nodeH;
    final cy = (y0 + y1) / 2;
    placed.add(_PlacedNode(node, x, cy - h / 2, depth, branch));

    double cursor = y0;
    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      final childH = _leafCount(child) * _slotH;
      final b = depth == 0 ? i : branch;
      place(child, x + _levelW, cursor, cursor + childH, depth + 1, b);
      cursor += childH;
    }
  }

  place(root, _padH, _padV, _padV + totalH, 0, 0);
  return placed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Colour palette
// ─────────────────────────────────────────────────────────────────────────────

const _palette = [
  Color(0xFF4361EE),
  Color(0xFF7209B7),
  Color(0xFFF72585),
  Color(0xFF06D6A0),
  Color(0xFF4CC9F0),
  Color(0xFFFFBE0B),
  Color(0xFFEF476F),
];

Color _colourFor(int depth, int branch) {
  if (depth == 0) return const Color(0xFF4361EE);
  final base = _palette[branch % _palette.length];
  if (depth == 1) return base;
  // Lighten for deeper levels
  return Color.fromARGB(
    255,
    ((base.r * 255) + (255 - base.r * 255) * 0.45).round(),
    ((base.g * 255) + (255 - base.g * 255) * 0.45).round(),
    ((base.b * 255) + (255 - base.b * 255) * 0.45).round(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _MindMapPainter extends CustomPainter {
  final List<_PlacedNode> nodes;
  final bool isDark;

  _MindMapPainter(this.nodes, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // ── edges ──
    for (final p in nodes) {
      if (p.depth == 0) continue;

      // Find parent: the nearest ancestor whose children list contains this node
      _PlacedNode? parent;
      for (final candidate in nodes) {
        if (candidate.depth == p.depth - 1 &&
            candidate.node.children.contains(p.node)) {
          parent = candidate;
          break;
        }
      }
      if (parent == null) continue;

      final pW = parent.depth == 0 ? _rootW : _nodeW;
      final pH = parent.depth == 0 ? _rootH : _nodeH;
      final cH = _nodeH;

      final start = Offset(parent.x + pW, parent.y + pH / 2);
      final end   = Offset(p.x, p.y + cH / 2);
      final dx    = end.dx - start.dx;
      final cp1   = Offset(start.dx + dx * 0.45, start.dy);
      final cp2   = Offset(end.dx  - dx * 0.45, end.dy);

      final colour = _colourFor(p.depth, p.branch);
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy),
        Paint()
          ..color       = colour.withValues(alpha: 0.65)
          ..strokeWidth = p.depth == 1 ? 2.5 : 1.8
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round,
      );
    }

    // ── nodes ──
    for (final p in nodes) {
      final w = p.depth == 0 ? _rootW : _nodeW;
      final h = p.depth == 0 ? _rootH : _nodeH;
      final r = p.depth == 0 ? 18.0 : 12.0;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(p.x, p.y, w, h),
        Radius.circular(r),
      );
      final colour = _colourFor(p.depth, p.branch);

      // Shadow
      canvas.drawRRect(
        rect.shift(const Offset(0, 3)),
        Paint()..color = colour.withValues(alpha: isDark ? 0.35 : 0.18),
      );

      // Fill
      canvas.drawRRect(
        rect,
        Paint()..color = colour.withValues(alpha: p.depth == 0 ? 1.0 : 0.9),
      );

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: p.node.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: p.depth == 0 ? 14.5 : 12.0,
            fontWeight: p.depth <= 1 ? FontWeight.bold : FontWeight.w500,
            height: 1.25,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
        textAlign: TextAlign.center,
      )..layout(maxWidth: w - 14);

      tp.paint(
        canvas,
        Offset(p.x + (w - tp.width) / 2, p.y + (h - tp.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MindMapScreen extends StatelessWidget {
  /// The parsed JSON object from the AI response.
  /// Expected shape: {"topic":"…","children":[{"label":"…","children":[…]}]}
  final Map<String, dynamic> data;

  const MindMapScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build tree & layout (done once; errors surfaced gracefully)
    List<_PlacedNode> nodes = [];
    String? errorMsg;
    String topic = '';

    try {
      topic = data['topic'] as String? ?? '';
      final root = MindMapNode.fromJson({
        'label': topic,
        'children': data['children'] ?? [],
      });
      nodes = _buildLayout(root);
    } catch (e) {
      errorMsg = e.toString();
    }

    if (errorMsg != null || nodes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mindMap)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              l10n.mindMapError,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 15),
            ),
          ),
        ),
      );
    }

    // Compute canvas dimensions
    final maxX = nodes.fold(0.0, (m, p) => math.max(m, p.x + _nodeW)) + _padH;
    final maxY = nodes.fold(0.0, (m, p) => math.max(m, p.y + _nodeH)) + _padV;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.mindMap,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (topic.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF4361EE).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    topic,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4361EE)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.25,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(80),
              child: SizedBox(
                width: maxX,
                height: maxY,
                child: CustomPaint(
                  painter: _MindMapPainter(nodes, isDark: isDark),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12, top: 6),
            child: Text(
              l10n.mindMapHint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
