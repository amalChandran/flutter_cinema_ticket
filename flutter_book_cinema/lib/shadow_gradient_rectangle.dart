import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShadowGradientRectangle extends StatefulWidget {
  const ShadowGradientRectangle({Key? key}) : super(key: key);

  @override
  _ShadowGradientRectangleState createState() =>
      _ShadowGradientRectangleState();
}

class _ShadowGradientRectangleState extends State<ShadowGradientRectangle> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double widthPercentage = 0.7;
    return Center(
      child: SizedBox(
        width: screenWidth * widthPercentage,
        height: 100,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.006)
            ..rotateX(-0.8),
          alignment: FractionalOffset.center,
          child: GradientRectangle(),
        ),
      ),
    );
  }
}

class GradientRectangle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // You can adjust the width as needed
      height: 100, // You can adjust the height as needed
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(75, 2, 2, 2)!, // Light grey
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
