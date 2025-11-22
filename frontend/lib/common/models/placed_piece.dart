import 'package:basic/common/models/models.dart';

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
