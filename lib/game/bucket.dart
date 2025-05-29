import 'package:flutter/widgets.dart';

class Bucket {
  final double x;

  static const double width  = 100.0;
  static const double height = 100.0;
  static const String assetPath = 'assets/images/bucket.png';

  const Bucket({required this.x});

  Widget build(BuildContext context) {
    final screenW       = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 5,
      left: x * screenW - width / 2,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
