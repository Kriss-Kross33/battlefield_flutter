import 'package:json_annotation/json_annotation.dart';

part 'piece.g.dart';

@JsonSerializable()
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

  factory Piece.fromJson(Map<String, dynamic> json) => _$PieceFromJson(json);

  Map<String, dynamic> toJson() => _$PieceToJson(this);
}
