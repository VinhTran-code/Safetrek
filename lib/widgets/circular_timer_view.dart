import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularTimerView extends StatefulWidget {
  final int duration; // in seconds
  const CircularTimerView({super.key, required this.duration});

  @override
  State<CircularTimerView> createState() => _CircularTimerViewState();
}

class _CircularTimerViewState extends State<CircularTimerView> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get timerString {
    Duration duration = _controller.duration! * _controller.value;
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularTimerPainter(
              animation: _controller,
              backgroundColor: Colors.grey.shade200,
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Text(
                timerString,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace'
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _CircularTimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor, color;

  _CircularTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Vẽ vòng tròn nền
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    
    // Vẽ vòng tròn tiến trình
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
