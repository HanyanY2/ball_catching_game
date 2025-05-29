import 'package:flutter/widgets.dart';

class Ball {
  double x;
  double y;

  static const double size = 40.0;
  static const String assetPath = 'assets/images/ball.png';

  Ball({required this.x, required this.y});

  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Positioned(
      left: x * w - size / 2,
      top:  y * h - size / 2,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
