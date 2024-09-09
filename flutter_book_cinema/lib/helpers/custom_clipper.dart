import 'package:flutter/material.dart';

class CustomClipper1 extends CustomClipper<Rect> {
  final double clipHeight;

  CustomClipper1(this.clipHeight);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, clipHeight, size.width, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
