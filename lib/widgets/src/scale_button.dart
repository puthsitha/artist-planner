import 'package:flutter/material.dart';

class ScaleButton extends StatefulWidget {
  const ScaleButton({required this.child, super.key, this.onTap});

  final Widget child;
  final void Function()? onTap;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  double scale = 1;

  void scaleDown(_) {
    setState(() {
      scale = 0.80;
    });
  }

  void resetScale() {
    setState(() {
      scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: scaleDown,
      onTapUp: (_) {
        resetScale();
      },
      onTapCancel: resetScale,
      child: AnimatedScale(
        scale: scale,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
