import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Icon icon;
  final Color color;
  final VoidCallback? onPressed;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: color,
        shape: CircleBorder(),
      ),
      child: IconButton(
        icon: icon,
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
