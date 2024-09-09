import 'package:flutter/material.dart';

class BarcodeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barcode view - using a placeholder image for demonstration
        Container(
          width: 200,
          height: 80,
          color:
              Color.fromARGB(255, 0, 0, 0), // Background color of the barcode
          child: CustomPaint(
            painter: BarcodePainter(),
          ),
        ),
        const SizedBox(height: 8), // Space between the barcode and the text
        // Text below the barcode
        const Text(
          'Tk No. 123432',
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2.0;

    // Drawing barcode lines
    for (int i = 0; i < size.width; i += 4) {
      double x = i.toDouble();
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
