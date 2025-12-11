import 'package:flutter/material.dart';

class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Color? splashColor;

  const AnimatedTap({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 120),
    this.splashColor,
  });

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  bool _pressed = false;

  void _handleHighlight(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
          ),
          child: InkWell(
            borderRadius: widget.borderRadius,
            splashFactory: InkRipple.splashFactory,
            splashColor: widget.splashColor,
            onHighlightChanged: _handleHighlight,
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}


