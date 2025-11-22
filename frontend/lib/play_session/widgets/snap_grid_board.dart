part of '../play_session_screen.dart';

class _SnapGridBoard extends StatefulWidget {
  const _SnapGridBoard({
    super.key,
    required this.grid,
    required this.piecesOnBoard,
    this.selectedId,
    required this.enforceNoAdjacency,
    required this.consumePalettePiece,
    required this.onSelect,
  });

  final Map<String, PlacedPiece> piecesOnBoard;

  final int grid;
  final String? selectedId;
  final bool enforceNoAdjacency;
  final Piece? Function(String id) consumePalettePiece;
  final ValueChanged<String?> onSelect;

  @override
  State<_SnapGridBoard> createState() => _SnapGridBoardState();
}

class _SnapGridBoardState extends State<_SnapGridBoard> {
  // Hover highlight state
  int? _hoverRow, _hoverCol;
  int _hoverRows = 1, _hoverCols = 1;
  bool _hoverValid = false;

  void _clearHover() {
    _hoverRow = _hoverCol = null;
    _hoverRows = _hoverCols = 1;
    _hoverValid = false;
  }

  String? _selectedId;

  // Key to get the exact board RenderBox for precise local coordinates
  final GlobalKey _boardKey = GlobalKey();

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
    final col = rawCol.clamp(0, widget.grid - cols);
    final row = rawRow.clamp(0, widget.grid - rows);
    return (row, col);
  }

  // Battleship fit check: disallow overlap and adjacency (1-cell margin)
  bool _fitsAndFree(int r, int c, int rows, int cols, String? movingId) {
    if (r + rows > widget.grid || c + cols > widget.grid) return false;

    final a = Rect.fromLTWH(
        c.toDouble(), r.toDouble(), cols.toDouble(), rows.toDouble());
    for (final entry in widget.piecesOnBoard.entries) {
      if (entry.key == movingId) continue;
      final p = entry.value;
      final eff = _effectiveSize(p);
      Rect b;
      if (widget.enforceNoAdjacency) {
        // Expand existing ship rect by 1 cell margin to enforce no-adjacency
        final left = (p.col - 1).clamp(0, widget.grid).toDouble();
        final top = (p.row - 1).clamp(0, widget.grid).toDouble();
        final width = (eff.$2 +
                (p.col > 0 ? 1 : 0) +
                (p.col + eff.$2 < widget.grid ? 1 : 0))
            .toDouble();
        final height = (eff.$1 +
                (p.row > 0 ? 1 : 0) +
                (p.row + eff.$1 < widget.grid ? 1 : 0))
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

  void _rotateSelected({required bool clockwise}) {
    final id = _selectedId ?? widget.selectedId;
    if (id == null) return;
    final placed = widget.piecesOnBoard[id];
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
        newRow + nextRows > widget.grid ||
        newCol + nextCols > widget.grid) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = min(c.maxWidth, c.maxHeight);
        final cell = size / widget.grid;

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
                    painter: _GridPainter(grid: widget.grid)),

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
                          color: (_hoverValid ? Colors.green : Colors.red)
                              .withValues(alpha: .25),
                          border: Border.all(
                            color: _hoverValid ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Selected piece highlight overlay
                if (widget.selectedId != null &&
                    widget.piecesOnBoard.containsKey(widget.selectedId))
                  Builder(builder: (_) {
                    final placed = widget.piecesOnBoard[widget.selectedId]!;
                    final dims = _effectiveSize(placed);
                    return Positioned(
                      left: placed.col * cell,
                      top: placed.row * cell,
                      width: dims.$2 * cell,
                      height: dims.$1 * cell,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: .12),
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
                      widget.onSelect(null);
                    },
                    child: DragTarget<_BoardDrag>(
                      builder: (context, cand, rej) => const SizedBox.shrink(),
                      onWillAcceptWithDetails: (details) {
                        final local = _local(details.offset, context);
                        final p = details.data;
                        final (r, cIdx) = _snapTopLeft(
                            local.$1, local.$2, cell, p.cols, p.rows);
                        final ok =
                            _fitsAndFree(r, cIdx, p.rows, p.cols, p.movingId);
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
                        final ok =
                            _fitsAndFree(r, cIdx, p.rows, p.cols, p.movingId);
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
                            final src = widget.consumePalettePiece(id);
                            widget.piecesOnBoard[id] = PlacedPiece(
                              piece: Piece(
                                id: id,
                                rows: p.rows,
                                cols: p.cols,
                                shipPath: src?.shipPath ?? '',
                                shipPathVertical: src?.shipPathVertical,
                              ),
                              row: r,
                              col: cIdx,
                              shipPath: src?.shipPath ?? '',
                              originalIndex: null,
                            );
                            // Initialize stable center pivot at placement
                            final pr = p.rows.toDouble();
                            final pc = p.cols.toDouble();
                            widget.piecesOnBoard[id]!.pivotRow =
                                r + (pr - 1) / 2.0;
                            widget.piecesOnBoard[id]!.pivotCol =
                                cIdx + (pc - 1) / 2.0;
                          } else if (p.movingId != null) {
                            // Move existing board piece
                            final placed = widget.piecesOnBoard[p.movingId]!;
                            placed.row = r;
                            placed.col = cIdx;
                            // Update pivot to new position (using current orientation)
                            final eff = _effectiveSize(placed);
                            placed.pivotRow = placed.row + (eff.$1 - 1) / 2.0;
                            placed.pivotCol = placed.col + (eff.$2 - 1) / 2.0;
                          }
                        });
                      },
                    ),
                  ),
                ),

                // Render existing board pieces
                ...widget.piecesOnBoard.entries.map((e) {
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
                        widget.onSelect(null);
                      },
                      feedback: Material(
                        child: RepaintBoundary(
                          child: SizedBox(
                            width: dims.$2 * cell,
                            height: dims.$1 * cell,
                            child: RotatedBox(
                              quarterTurns: placed.rotationQuarterTurns % 4,
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
                          widget.onSelect(_selectedId == id ? null : id);
                        },
                        onLongPress: () {
                          widget.onSelect(id);
                        },
                        onDoubleTap: () => _rotateSelected(clockwise: true),
                        child: SizedBox(
                          width: dims.$2 * cell,
                          height: dims.$1 * cell,
                          child: RotatedBox(
                            quarterTurns: placed.rotationQuarterTurns % 4,
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
    );
  }

  // Effective size: 1-cell thick; length is max(rows, cols)
  (int, int) _effectiveSize(PlacedPiece placed) {
    final odd = (placed.rotationQuarterTurns % 2) != 0;
    final length = max(placed.piece.rows, placed.piece.cols);
    final rows = odd ? length : 1;
    final cols = odd ? 1 : length;
    return (rows, cols);
  }
}
