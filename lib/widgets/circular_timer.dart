import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class CircularTimer extends StatelessWidget {
  final CountDownController controller;
  final int duration;
  final VoidCallback onComplete;

  const CircularTimer({
    super.key,
    required this.controller,
    required this.duration,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final ringColor = theme.colorScheme.outlineVariant;

    return SizedBox(
      width: 192,
      height: 192,
      child: CircularCountDownTimer(
        duration: duration,
        initialDuration: 0,
        controller: controller,
        width: 192,
        height: 192,
        ringColor: ringColor,
        fillColor: theme.colorScheme.primary,
        strokeWidth: 8.0,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'monospace',
        ),
        textFormat: CountdownTextFormat.MM_SS,
        isReverse: true,
        isReverseAnimation: true,
        autoStart: false,
        onComplete: onComplete,
      ),
    );
  }
}