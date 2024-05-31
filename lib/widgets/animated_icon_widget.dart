import 'package:flutter/material.dart';

class AnimatedIconWidget extends StatefulWidget {
  final bool isSpeaking;

  const AnimatedIconWidget({super.key, required this.isSpeaking});

  @override
  AnimatedIconWidgetState createState() => AnimatedIconWidgetState();
}

class AnimatedIconWidgetState extends State<AnimatedIconWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AnimatedIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _controller,
      color: Colors.grey[600],
    );
  }
}
