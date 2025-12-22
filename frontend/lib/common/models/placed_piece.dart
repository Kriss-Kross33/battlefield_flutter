import 'package:basic/common/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'placed_piece.g.dart';

@JsonSerializable(explicitToJson: true)
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
  bool isRotatedVertically;
  PlacedPiece({
    required this.piece,
    required this.shipPath,
    required this.row,
    required this.col,
    this.originalIndex,
    this.isRotatedVertically = false,
  });

  PlacedPiece copyWith({
    Piece? piece,
    String? shipPath,
    int? row,
    int? col,
    int? originalIndex,
    bool? isRotatedVertically = false,
  }) {
    return PlacedPiece(
      piece: piece ?? this.piece,
      shipPath: shipPath ?? this.shipPath,
      row: row ?? this.row,
      col: col ?? this.col,
      originalIndex: originalIndex ?? this.originalIndex,
      isRotatedVertically: isRotatedVertically ?? this.isRotatedVertically,
    );
  }

  factory PlacedPiece.fromJson(Map<String, dynamic> json) =>
      _$PlacedPieceFromJson(json);

  Map<String, dynamic> toJson() => _$PlacedPieceToJson(this);
}
