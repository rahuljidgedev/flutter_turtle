import 'package:flutter/material.dart';

import 'turtle_commands.dart';
import 'turtle_state.dart';

class _TurtlePainter extends CustomPainter {
  final List<Instruction> commands;

  _TurtlePainter(this.commands);

  @override
  void paint(Canvas canvas, Size size) {
    var turtle = TurtleState();
    var context = PaintContext()
      ..canvas = canvas
      ..paint = (Paint()
        ..color = turtle.color
        ..strokeWidth = turtle.strokeWidth)
      ..center = Offset(size.width / 2, size.height / 2);
    commands.forEach((command) => command.exec(context));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// The animated turtle view.
class AnimatedTurtleView extends StatefulWidget {
  /// The commands.
  final List<TurtleCommand> commands;

  /// The child widget.
  final Widget child;

  /// Size of the canvas.
  final Size size;

  /// Whether the painting is complex enough to benefit from caching.
  final bool isComplex;

  /// The duration of the animation.
  final Duration animationDuration;

  /// Creates a new instance.
  AnimatedTurtleView({
    Key key,
    this.child,
    this.commands,
    this.isComplex = false,
    this.size = Size.zero,
    this.animationDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _AnimatedTurtleViewState createState() => _AnimatedTurtleViewState();
}

class _AnimatedTurtleViewState extends State<AnimatedTurtleView> {
  List<Instruction> _instructions = [];

  @override
  void initState() {
    super.initState();
    _instructions = TurtleCompiler.compile(widget.commands);
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder(
      child: widget.child,
      tween: Tween<double>(begin: 0, end: 1),
      duration: widget.animationDuration,
      builder: (context, value, child) {
        var instructions =
            _instructions.sublist(0, (_instructions.length * value).toInt());
        return CustomPaint(
          painter: _TurtlePainter(instructions),
          size: widget.size,
          isComplex: widget.isComplex,
          child: child,
        );
      });
}
