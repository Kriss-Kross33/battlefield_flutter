// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:basic/core/constants/image_constants.dart';
import 'package:flutter/material.dart';

import '../level_selection/levels.dart';

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

  // Palette pieces (consumable: removed only after successful drop)
  final List<Piece> palette = [
    const Piece(id: 'P1', rows: 1, cols: 5, shipPath: ImageConstants.carrier),
    const Piece(id: 'P2', rows: 1, cols: 4, shipPath: ImageConstants.frigate),
    const Piece(id: 'P3', rows: 1, cols: 4, shipPath: ImageConstants.frigate),
    const Piece(
      id: 'P4',
      rows: 1,
      cols: 3,
      shipPath: ImageConstants.submarine,
    ),
    const Piece(
      id: 'P5',
      rows: 1,
      cols: 3,
      shipPath: ImageConstants.submarine,
    ),
    const Piece(
      id: 'P6',
      rows: 1,
      cols: 2,
      shipPath: ImageConstants.patrolBoat,
    ),
    const Piece(
      id: 'P7',
      rows: 1,
      cols: 2,
      shipPath: ImageConstants.patrolBoat,
    ),
    const Piece(
      id: 'P8',
      rows: 1,
      cols: 2,
      shipPath: ImageConstants.patrolBoat,
    ),
    const Piece(
      id: 'P9',
      rows: 1,
      cols: 2,
      shipPath: ImageConstants.patrolBoat,
    ),
  ];

  // Board pieces: id -> placement
  final Map<String, PlacedPiece> piecesOnBoard = {};

  // Hover highlight state
  int? _hoverRow, _hoverCol;
  int _hoverRows = 1, _hoverCols = 1;
  bool _hoverValid = false;

  // Selection state
  String? _selectedId;
  bool enforceNoAdjacency = false;
  // Cache board cell size for sizing the off-grid pieces (palette)
  double? _cellSize;

  void _clearHover() {
    _hoverRow = _hoverCol = null;
    _hoverRows = _hoverCols = 1;
    _hoverValid = false;
  }

  // Key to get the exact board RenderBox for precise local coordinates
  final GlobalKey _boardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snap-to-Grid Board')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = min(c.maxWidth, c.maxHeight);
                  final cell = size / grid;
                  _cellSize = cell;

                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      key: _boardKey,
                      width: size,
                      height: size,
                      child: Stack(
                        children: [
                          // Grid
                          CustomPaint(
                              size: Size(size, size),
                              painter: _GridPainter(grid: grid)),

                          // Hover highlight overlay
                          if (_hoverRow != null && _hoverCol != null)
                            Positioned(
                              left: _hoverCol! * cell,
                              top: _hoverRow! * cell,
                              width: _hoverCols * cell,
                              height: _hoverRows * cell,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (_hoverValid
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: .25),
                                    border: Border.all(
                                      color: _hoverValid
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Selected piece highlight overlay
                          if (_selectedId != null &&
                              piecesOnBoard.containsKey(_selectedId))
                            Builder(builder: (_) {
                              final placed = piecesOnBoard[_selectedId]!;
                              final dims = _effectiveSize(placed);
                              return Positioned(
                                left: placed.col * cell,
                                top: placed.row * cell,
                                width: dims.$2 * cell,
                                height: dims.$1 * cell,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent
                                          .withValues(alpha: .12),
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                          // Board-wide DragTarget to compute snap and accept moves/placements
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_selectedId != null) {
                                  setState(() => _selectedId = null);
                                }
                              },
                              child: DragTarget<_BoardDrag>(
                                builder: (context, cand, rej) =>
                                    const SizedBox.shrink(),
                                onWillAcceptWithDetails: (details) {
                                  final local = _local(details.offset, context);
                                  final p = details.data;
                                  final (r, cIdx) = _snapTopLeft(
                                      local.$1, local.$2, cell, p.cols, p.rows);
                                  final ok = _fitsAndFree(
                                      r, cIdx, p.rows, p.cols, p.movingId);
                                  setState(() {
                                    _hoverRow = r;
                                    _hoverCol = cIdx;
                                    _hoverRows = p.rows;
                                    _hoverCols = p.cols;
                                    _hoverValid = ok;
                                  });
                                  return ok;
                                },
                                onMove: (details) {
                                  final local = _local(details.offset, context);
                                  final p = details.data;
                                  final (r, cIdx) = _snapTopLeft(
                                      local.$1, local.$2, cell, p.cols, p.rows);
                                  final ok = _fitsAndFree(
                                      r, cIdx, p.rows, p.cols, p.movingId);
                                  setState(() {
                                    _hoverRow = r;
                                    _hoverCol = cIdx;
                                    _hoverRows = p.rows;
                                    _hoverCols = p.cols;
                                    _hoverValid = ok;
                                  });
                                },
                                onLeave: (_) {
                                  setState(_clearHover);
                                },
                                onAcceptWithDetails: (details) {
                                  final local = _local(details.offset, context);
                                  final p = details.data;
                                  final (r, cIdx) = _snapTopLeft(
                                      local.$1, local.$2, cell, p.cols, p.rows);

                                  setState(() {
                                    _clearHover();
                                    if (p.paletteId != null) {
                                      // Consume palette item and place it
                                      final id = p.paletteId!;
                                      final srcIndex =
                                          palette.indexWhere((e) => e.id == id);
                                      final src = palette[srcIndex];
                                      palette.removeAt(srcIndex);
                                      piecesOnBoard[id] = PlacedPiece(
                                        piece: Piece(
                                          id: id,
                                          rows: p.rows,
                                          cols: p.cols,
                                          shipPath: src.shipPath,
                                          shipPathVertical:
                                              src.shipPathVertical,
                                        ),
                                        row: r,
                                        col: cIdx,
                                        shipPath: src.shipPath,
                                        originalIndex: srcIndex,
                                      );
                                      // Initialize stable center pivot at placement
                                      final pr = p.rows.toDouble();
                                      final pc = p.cols.toDouble();
                                      piecesOnBoard[id]!.pivotRow =
                                          r + (pr - 1) / 2.0;
                                      piecesOnBoard[id]!.pivotCol =
                                          cIdx + (pc - 1) / 2.0;
                                    } else if (p.movingId != null) {
                                      // Move existing board piece
                                      final placed = piecesOnBoard[p.movingId]!;
                                      placed.row = r;
                                      placed.col = cIdx;
                                      // Update pivot to new position (using current orientation)
                                      final eff = _effectiveSize(placed);
                                      placed.pivotRow =
                                          placed.row + (eff.$1 - 1) / 2.0;
                                      placed.pivotCol =
                                          placed.col + (eff.$2 - 1) / 2.0;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),

                          // Render existing board pieces
                          ...piecesOnBoard.entries.map((e) {
                            final id = e.key;
                            final placed = e.value;
                            final dims = _effectiveSize(placed);
                            return Positioned(
                              key: ValueKey('piece-$id'),
                              left: placed.col * cell,
                              top: placed.row * cell,
                              width: dims.$2 * cell,
                              height: dims.$1 * cell,
                              child: Draggable<_BoardDrag>(
                                key: ValueKey('drag-$id'),
                                data: _BoardDrag.move(id, dims.$1, dims.$2),
                                dragAnchorStrategy: pointerDragAnchorStrategy,
                                onDragStarted: () {
                                  if (_selectedId != null) {
                                    setState(() => _selectedId = null);
                                  }
                                },
                                feedback: Material(
                                  child: RepaintBoundary(
                                    child: SizedBox(
                                      width: dims.$2 * cell,
                                      height: dims.$1 * cell,
                                      child: RotatedBox(
                                        quarterTurns:
                                            placed.rotationQuarterTurns % 4,
                                        child: Container(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: const SizedBox.shrink(),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedId =
                                          _selectedId == id ? null : id;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      _selectedId = id;
                                    });
                                  },
                                  onDoubleTap: () =>
                                      _rotateSelected(clockwise: true),
                                  child: SizedBox(
                                    width: dims.$2 * cell,
                                    height: dims.$1 * cell,
                                    child: RotatedBox(
                                      quarterTurns:
                                          placed.rotationQuarterTurns % 4,
                                      child: Container(
                                          color: Colors.blue,
                                          child: Center(
                                              child: Text(
                                            placed.piece.id,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
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
                    if (_selectedId == id) _selectedId = null;
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
            if (_selectedId != null)
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
    final id = _selectedId;
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

  // Convert a global drop offset to local coordinates inside the board
  (double, double) _local(Offset global, BuildContext ctx) {
    final box = _boardKey.currentContext!.findRenderObject() as RenderBox;
    final p = box.globalToLocal(global);
    return (p.dx, p.dy);
  }

  // Snap pixel coordinates to top-left cell, clamped to fit piece size
  (int, int) _snapTopLeft(double x, double y, double cell, int cols, int rows) {
    final rawCol = (x / cell).floor();
    final rawRow = (y / cell).floor();
    final col = rawCol.clamp(0, grid - cols);
    final row = rawRow.clamp(0, grid - rows);
    return (row, col);
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

class Piece {
  final String id;
  final int rows;
  final int cols;
  final String shipPath;
  final String? shipPathVertical;
  const Piece({
    required this.id,
    required this.shipPath,
    this.shipPathVertical,
    this.rows = 1,
    this.cols = 1,
  });
}

class PlacedPiece {
  final Piece piece;
  int row;
  int col;
  String shipPath;
  int? originalIndex;
  int rotationQuarterTurns = 0;
  // Stable pivot (center) in grid coordinates to avoid rotation drift
  double pivotRow = 0;
  double pivotCol = 0;
  // Cumulative turn count for smooth tweening without wraparounds
  double animTurns = 0.0;
  PlacedPiece(
      {required this.piece,
      required this.shipPath,
      required this.row,
      required this.col,
      this.originalIndex});
}

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

class _GridPainter extends CustomPainter {
  final int grid;
  _GridPainter({required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    final cell = size.width / grid;
    for (int i = 0; i <= grid; i++) {
      final o = i * cell;
      canvas.drawLine(Offset(o, 0), Offset(o, size.height), paint);
      canvas.drawLine(Offset(0, o), Offset(size.width, o), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
