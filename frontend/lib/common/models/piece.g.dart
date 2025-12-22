// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Piece _$PieceFromJson(Map<String, dynamic> json) => Piece(
  id: json['id'] as String,
  shipPath: json['shipPath'] as String,
  shipPathVertical: json['shipPathVertical'] as String?,
  rows: (json['rows'] as num?)?.toInt() ?? 1,
  cols: (json['cols'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$PieceToJson(Piece instance) => <String, dynamic>{
  'id': instance.id,
  'rows': instance.rows,
  'cols': instance.cols,
  'shipPath': instance.shipPath,
  'shipPathVertical': instance.shipPathVertical,
};
