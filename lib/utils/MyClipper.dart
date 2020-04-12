import 'package:flutter/cupertino.dart';

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0, size.height - 90);
    var controlPoint = Offset(60, size.height);
    var endPoint = Offset(size.width / .8, size.height);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;

    // Path path = new Path();
    // path.lineTo(0, size.height - 90);
    // var controlPoint = Offset(60, size.height);
    // var endPoint = Offset(size.width / .8, size.height);
    // path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    // path.lineTo(size.width, 0);
    // return path;
    
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}