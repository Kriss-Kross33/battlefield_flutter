import 'dart:math';

import 'package:basic/common/models/placed_piece.dart';

class GridBoardHelper {
  static List<({int row, int col})> occupiedCells(PlacedPiece p) {
    final (rows, cols) = effectiveSize(p);
    return [
      for (var dr = 0; dr < rows; dr++)
        for (var dc = 0; dc < cols; dc++) (row: p.row + dr, col: p.col + dc),
    ];
  }

  // Compute effective size (rows, cols) after rotation
  static (int, int) effectiveSize(PlacedPiece placed) {
    // Ships are 1-cell thick; length is max(rows, cols)
    final odd = (placed.rotationQuarterTurns % 2) != 0;
    final length = max(placed.piece.rows, placed.piece.cols);
    final rows = odd ? length : 1;
    final cols = odd ? 1 : length;
    return (rows, cols);
  }
}
