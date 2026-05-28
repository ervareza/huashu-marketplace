import 'package:flutter/material.dart';

class InkBrushDivider extends StatelessWidget {
  final double height;
  final Color color;

  const InkBrushDivider({
    super.key,
    this.height = 2.0,
    this.color = const Color(0xFFE2DFD5),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _InkBrushPainter(color: color),
    );
  }
}

class _InkBrushPainter extends CustomPainter {
  final Color color;

  _InkBrushPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Garis sapuan kuas melengkung mikro artistik
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.1,
      size.width * 0.5, size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.9,
      size.width, size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
