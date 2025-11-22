// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:basic/common/common.dart';
import 'package:flutter/material.dart';

import '../level_selection/levels.dart';

part 'widgets/grid_painter.dart';
part 'widgets/snap_grid_board.dart';

/// This widget defines the entirety of the screen that the player sees when
/// they are playing a level.
///
/// It is a stateful widget because it manages some state of its own,
/// such as whether the game is in a "celebration" state.
class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;
  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static const grid = 10;

  // Board pieces: id -> placement
  final Map<String, PlacedPiece> piecesOnBoard = {};

  // Selection state
  String? selectedId;
  bool enforceNoAdjacency = false;
  // Cache board cell size for sizing the off-grid pieces (palette)
  double? _cellSize;

  // Key not required in parent after refactor; board owns it

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap-to-Grid Board'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: _SnapGridBoard(
                grid: grid,
                piecesOnBoard: piecesOnBoard,
                selectedId: selectedId,
                enforceNoAdjacency: enforceNoAdjacency,
                consumePalettePiece: (id) {
                  final idx = palette.indexWhere((e) => e.id == id);
                  if (idx == -1) return null;
                  Piece? removed;
                  setState(() {
                    removed = palette.removeAt(idx);
                  });
                  return removed;
                },
                onSelect: (id) => setState(() => selectedId = id),
              ),
            ),

            // Palette (consumable) with DragTarget to return pieces.
            // Uses single-cell height and wraps to multiple lines if needed.
            DragTarget<_BoardDrag>(
              builder: (context, candidate, rejected) =>
                  _buildPalette(_cellSize ?? 40),
              onWillAcceptWithDetails: (details) {
                final data = details.data;
                // Only accept pieces coming from board
                return data.movingId != null;
              },
              onAcceptWithDetails: (details) {
                final data = details.data;
                if (data.movingId == null) return;
                setState(() {
                  final id = data.movingId!;
                  final placed = piecesOnBoard.remove(id);
                  if (placed != null) {
                    if (selectedId == id) selectedId = null;
                    final insertAt = placed.originalIndex ?? palette.length;
                    final safeIndex = insertAt.clamp(0, palette.length);
                    palette.insert(
                      safeIndex,
                      Piece(
                        id: placed.piece.id,
                        rows: placed.piece.rows,
                        cols: placed.piece.cols,
                        shipPath: placed.shipPath,
                        shipPathVertical: placed.piece.shipPathVertical,
                      ),
                    );
                  }
                });
              },
            ),

            // Rotation controls for selected piece
            if (selectedId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _rotateSelected(clockwise: false),
                      icon: const Icon(Icons.rotate_left),
                      label: const Text('Rotate'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _rotateSelected(clockwise: true),
                      icon: const Icon(Icons.rotate_right),
                      label: const Text('Rotate'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enforce spacing (no-adjacency)'),
                  const SizedBox(width: 8),
                  Switch(
                    value: enforceNoAdjacency,
                    onChanged: (v) => setState(() => enforceNoAdjacency = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compute effective size (rows, cols) after rotation
  (int, int) _effectiveSize(PlacedPiece placed) {
    // Ships are 1-cell thick; length is max(rows, cols)
    final odd = (placed.rotationQuarterTurns % 2) != 0;
    final length = max(placed.piece.rows, placed.piece.cols);
    final rows = odd ? length : 1;
    final cols = odd ? 1 : length;
    return (rows, cols);
  }

  // Rotate selected piece with collision/bounds checks
  void _rotateSelected({required bool clockwise}) {
    final id = selectedId;
    if (id == null) return;
    final placed = piecesOnBoard[id];
    if (placed == null) return;

    final nextTurns = (placed.rotationQuarterTurns + (clockwise ? 1 : -1)) % 4;
    final nextOdd = (nextTurns % 2) != 0;
    final nextRows = nextOdd ? placed.piece.cols : placed.piece.rows;
    final nextCols = nextOdd ? placed.piece.rows : placed.piece.cols;

    // Use stable pivot center to avoid drift
    final centerRow = placed.pivotRow;
    final centerCol = placed.pivotCol;

    // New top-left to preserve center; round to nearest cell
    final newRow = (centerRow - (nextRows - 1) / 2.0).round();
    final newCol = (centerCol - (nextCols - 1) / 2.0).round();

    // Hard bounds check (do NOT clamp to avoid drifting)
    if (newRow < 0 ||
        newCol < 0 ||
        newRow + nextRows > grid ||
        newCol + nextCols > grid) {
      return; // reject rotation near edges
    }

    // Collision + adjacency check; no local adjustments to preserve position
    if (!_fitsAndFree(newRow, newCol, nextRows, nextCols, id)) {
      return; // reject rotation if it would overlap/touch another ship
    }

    setState(() {
      placed.rotationQuarterTurns = (nextTurns + 4) % 4;
      placed.row = newRow;
      placed.col = newCol;
    });
  }

  Widget _buildPalette(double cell) {
    final children = <Widget>[];
    for (final piece in palette) {
      final w = max(1, piece.cols) * cell;
      final h = cell; // single-cell height
      children.add(
        Draggable<_BoardDrag>(
          key: ValueKey('palette-${piece.id}-${piece.cols}x${piece.rows}'),
          data: _BoardDrag.fromPalette(piece.id, piece.rows, piece.cols),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Material(
            child: RepaintBoundary(
              child: SizedBox(
                width: w,
                height: h,
                child: Container(
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      piece.id,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          childWhenDragging: const SizedBox.shrink(),
          child: SizedBox(
              width: w,
              height: h,
              child: Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                  piece.id,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              )),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: children,
      ),
    );
  }

  // Battleship fit check: disallow overlap and adjacency (1-cell margin)
  bool _fitsAndFree(int r, int c, int rows, int cols, String? movingId) {
    if (r + rows > grid || c + cols > grid) return false;

    final a = Rect.fromLTWH(
        c.toDouble(), r.toDouble(), cols.toDouble(), rows.toDouble());
    for (final entry in piecesOnBoard.entries) {
      if (entry.key == movingId) continue;
      final p = entry.value;
      final eff = _effectiveSize(p);
      Rect b;
      if (enforceNoAdjacency) {
        // Expand existing ship rect by 1 cell margin to enforce no-adjacency
        final left = (p.col - 1).clamp(0, grid).toDouble();
        final top = (p.row - 1).clamp(0, grid).toDouble();
        final width =
            (eff.$2 + (p.col > 0 ? 1 : 0) + (p.col + eff.$2 < grid ? 1 : 0))
                .toDouble();
        final height =
            (eff.$1 + (p.row > 0 ? 1 : 0) + (p.row + eff.$1 < grid ? 1 : 0))
                .toDouble();
        b = Rect.fromLTWH(left, top, width, height);
      } else {
        // Overlap-only check (no margin)
        b = Rect.fromLTWH(
          p.col.toDouble(),
          p.row.toDouble(),
          eff.$2.toDouble(),
          eff.$1.toDouble(),
        );
      }
      if (a.overlaps(b)) return false;
    }
    return true;
  }

  // Pick oriented image path if provided
  // ignore: unused_element
  String _imagePathFor(PlacedPiece placed) {
    final vertical = (placed.rotationQuarterTurns % 2) != 0;
    if (vertical && placed.piece.shipPathVertical != null) {
      return placed.piece.shipPathVertical!;
    }
    return placed.shipPath;
  }
}

// Data models

// Drag payload describing either a move or a placement from palette
class _BoardDrag {
  final String? movingId; // id of an existing board piece being moved
  final String? paletteId; // id of a palette piece being placed
  final int rows, cols;

  _BoardDrag._(this.movingId, this.paletteId, this.rows, this.cols);

  factory _BoardDrag.move(String id, int rows, int cols) =>
      _BoardDrag._(id, null, rows, cols);

  factory _BoardDrag.fromPalette(String paletteId, int rows, int cols) =>
      _BoardDrag._(null, paletteId, rows, cols);
}

// Grid painter
