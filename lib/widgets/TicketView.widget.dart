import 'package:flutter/material.dart';

class TicketView extends StatelessWidget {
  final Widget child;
  const TicketView({this.child = const SizedBox(), super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomTicketShape(),
      child: child,
    );
  }
}

class CustomTicketShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(32)));
    path.addOval(Rect.fromCircle(center: Offset(0, (size.height / 3)), radius: 15));
    path.addOval(Rect.fromCircle(center: Offset(size.width, (size.height / 3)), radius: 15));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
