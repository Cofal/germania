import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Icon icon;
  final Color color;
  final VoidCallback? onPressed;

  const CircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: color,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: icon,
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
