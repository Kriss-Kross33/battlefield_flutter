// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placed_piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacedPiece _$PlacedPieceFromJson(Map<String, dynamic> json) =>
    PlacedPiece(
        piece: Piece.fromJson(json['piece'] as Map<String, dynamic>),
        shipPath: json['shipPath'] as String,
        row: (json['row'] as num).toInt(),
        col: (json['col'] as num).toInt(),
        originalIndex: (json['originalIndex'] as num?)?.toInt(),
        isRotatedVertically: json['isRotatedVertically'] as bool? ?? false,
      )
      ..rotationQuarterTurns = (json['rotationQuarterTurns'] as num).toInt()
      ..pivotRow = (json['pivotRow'] as num).toDouble()
      ..pivotCol = (json['pivotCol'] as num).toDouble()
      ..animTurns = (json['animTurns'] as num).toDouble();

Map<String, dynamic> _$PlacedPieceToJson(PlacedPiece instance) =>
    <String, dynamic>{
      'piece': instance.piece.toJson(),
      'row': instance.row,
      'col': instance.col,
      'shipPath': instance.shipPath,
      'originalIndex': instance.originalIndex,
      'rotationQuarterTurns': instance.rotationQuarterTurns,
      'pivotRow': instance.pivotRow,
      'pivotCol': instance.pivotCol,
      'animTurns': instance.animTurns,
      'isRotatedVertically': instance.isRotatedVertically,
    };
