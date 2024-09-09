import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_book_cinema/movie_cards/movie_card.dart';
import 'package:flutter_book_cinema/movie_cards/ridged_card.dart';

class SwipeToConfirmCard extends StatelessWidget {
  const SwipeToConfirmCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedRidgedCard(
      width: double.infinity,
      height: 150,
      color: Colors.white,
      topRidge: true,
      bottomRidge: false,
      ridgeDepth: 1,
      ridgeWidth: 20,
      ridgeCount: 6,
      borderRadius: 16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dotted border
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ticket_blue,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  color: ticket_blue),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(6),
                padding: const EdgeInsets.all(12),
                color: Color.fromARGB(224, 255, 255, 255)!,
                strokeWidth: 2,
                dashPattern: const [6, 3],
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SWIPE TO',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'CONFIRM',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// You'll need to add this custom painter for the dotted border
class DottedBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double strokeWidth;
  final Color color;
  final List<double> dashPattern;
  final BorderType borderType;
  final Radius radius;

  const DottedBorder({
    Key? key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.borderType = BorderType.Rect,
    this.dashPattern = const <double>[3, 1],
    this.padding = const EdgeInsets.all(2),
    this.radius = const Radius.circular(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: CustomPaint(
              painter: _DottedCustomPaint(
                strokeWidth: strokeWidth,
                radius: radius,
                color: color,
                borderType: borderType,
                dashPattern: dashPattern,
              ),
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }
}

class _DottedCustomPaint extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final BorderType borderType;
  final List<double> dashPattern;
  final Radius radius;

  _DottedCustomPaint({
    this.strokeWidth = 1,
    this.color = Colors.black,
    this.borderType = BorderType.Rect,
    this.dashPattern = const <double>[3, 1],
    this.radius = const Radius.circular(0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;

    Path path;
    if (borderType == BorderType.RRect) {
      path = _getRRectPath(size, radius);
    } else if (borderType == BorderType.Oval) {
      path = _getOvalPath(size);
    } else {
      path = _getRectPath(size);
    }

    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(dashPattern),
      ),
      paint,
    );
  }

  Path _getRRectPath(Size size, Radius radius) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          radius,
        ),
      );
  }

  Path _getOvalPath(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  Path _getRectPath(Size size) {
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldRepaint(_DottedCustomPaint oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.borderType != borderType ||
        oldDelegate.dashPattern != dashPattern;
  }
}

enum BorderType { Rect, RRect, Oval }

class CircularIntervalList<T> {
  final List<T> _items;
  int _index = 0;

  CircularIntervalList(this._items);

  T get next {
    if (_index >= _items.length) _index = 0;
    return _items[_index++];
  }
}

Path dashPath(
  Path source, {
  required CircularIntervalList<double> dashArray,
  DashOffset? dashOffset,
}) {
  dashOffset = dashOffset ?? const DashOffset.absolute(0.0);
  final Path dest = Path();
  for (final PathMetric metric in source.computeMetrics()) {
    double distance = dashOffset._calculate(metric.length);
    bool draw = true;
    while (distance < metric.length) {
      final double len = dashArray.next;
      if (draw) {
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
    }
  }
  return dest;
}

class DashOffset {
  final double start;
  final bool proportional;

  const DashOffset.percentage(this.start) : proportional = true;
  const DashOffset.absolute(this.start) : proportional = false;

  double _calculate(double length) {
    return proportional ? start * length : start;
  }
}
