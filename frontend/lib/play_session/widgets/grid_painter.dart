part of '../play_session_screen.dart';

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
