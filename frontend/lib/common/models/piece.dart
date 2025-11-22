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
