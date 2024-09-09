import 'package:flutter/material.dart';

class RoundedRidgedCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color color;
  final bool topRidge;
  final bool bottomRidge;
  final double ridgeDepth;
  final double ridgeWidth;
  final int ridgeCount;
  final double borderRadius;

  const RoundedRidgedCard({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    this.color = Colors.blue,
    this.topRidge = false,
    this.bottomRidge = true,
    this.ridgeDepth = 10,
    this.ridgeWidth = 20,
    this.ridgeCount = 10,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoundedRidgedCardPainter(
        color: color,
        topRidge: topRidge,
        bottomRidge: bottomRidge,
        ridgeDepth: ridgeDepth,
        ridgeWidth: ridgeWidth,
        ridgeCount: ridgeCount,
        borderRadius: borderRadius,
      ),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.only(
          top: topRidge ? ridgeDepth : borderRadius,
          bottom: bottomRidge ? ridgeDepth : borderRadius,
          left: borderRadius,
          right: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class _RoundedRidgedCardPainter extends CustomPainter {
  final Color color;
  final bool topRidge;
  final bool bottomRidge;
  final double ridgeDepth;
  final double ridgeWidth;
  final int ridgeCount;
  final double borderRadius;

  _RoundedRidgedCardPainter({
    required this.color,
    required this.topRidge,
    required this.bottomRidge,
    required this.ridgeDepth,
    required this.ridgeWidth,
    required this.ridgeCount,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Top left corner
    path.moveTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    if (topRidge) {
      _addRidgeToPath(path, size, true);
    } else {
      path.lineTo(size.width - borderRadius, 0);
    }

    // Top right corner
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

    // Right side
    path.lineTo(size.width, size.height - borderRadius);

    // Bottom right corner
    path.quadraticBezierTo(
        size.width, size.height, size.width - borderRadius, size.height);

    if (bottomRidge) {
      _addRidgeToPath(path, size, false);
    } else {
      path.lineTo(borderRadius, size.height);
    }

    // Bottom left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    path.close();
    canvas.drawPath(path, paint);
  }

  void _addRidgeToPath(Path path, Size size, bool isTop) {
    final effectiveWidth = size.width - 2 * borderRadius;
    final totalWidth =
        ridgeWidth * ridgeCount * 2 - ridgeWidth; // Account for gaps
    final startX = borderRadius + (effectiveWidth - totalWidth) / 2;

    for (int i = 0; i < ridgeCount; i++) {
      final x1 = startX + (i * ridgeWidth * 2);
      final x2 = x1 + ridgeWidth;

      if (isTop) {
        path.lineTo(x1, 0);
        path.lineTo(x1, ridgeDepth);
        path.lineTo(x2, ridgeDepth);
        path.lineTo(x2, 0);
      } else {
        path.lineTo(x2, size.height);
        path.lineTo(x2, size.height - ridgeDepth);
        path.lineTo(x1, size.height - ridgeDepth);
        path.lineTo(x1, size.height);
      }
    }

    if (isTop) {
      path.lineTo(size.width - borderRadius, 0);
    } else {
      path.lineTo(borderRadius, size.height);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
