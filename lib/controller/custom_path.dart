
import 'package:flutter/cupertino.dart';

class MyCustomPath extends CustomClipper<Path>{
  @override
    Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.45);
    path.cubicTo(size.width * 0.33, size.height * 0.45, size.width * 0.66, size.height * 0.33, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
  
}