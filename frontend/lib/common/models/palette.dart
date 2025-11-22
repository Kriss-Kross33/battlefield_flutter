// Palette pieces (consumable: removed only after successful drop)
import 'package:basic/common/common.dart';
import 'package:basic/core/constants/image_constants.dart';

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
