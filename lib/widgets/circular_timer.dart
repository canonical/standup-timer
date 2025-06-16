import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class CircularTimer extends ConsumerStatefulWidget {
  final CountDownController controller;
  final int duration;
  final VoidCallback onComplete;
  final bool isRunning;

  const CircularTimer({
    super.key,
    required this.controller,
    required this.duration,
    required this.onComplete,
    required this.isRunning,
  });

  @override
  ConsumerState<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends ConsumerState<CircularTimer> {
  @override
  void initState() {
    super.initState();
    // Ensure the timer starts if it should be running when first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isRunning) {
        widget.controller.start();
      }
    });
  }

  @override
  void didUpdateWidget(CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Respond to isRunning state changes
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        widget.controller.start();
      } else {
        widget.controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final ringColor = theme.colorScheme.tertiary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available space with minimum of 100px, maximum of 400px
        final availableSize = constraints.smallest.shortestSide;
        final calculatedSize = availableSize * 0.8;
        final timerSize = calculatedSize < 100.0 ? 100.0 : calculatedSize > 400.0 ? 400.0 : calculatedSize;
        final fontSize = (timerSize / 5).clamp(20.0, 48.0);
        
        return SizedBox(
          width: timerSize,
          height: timerSize,
          child: CircularCountDownTimer(
            key: const ValueKey('countdown_timer_widget'),
            duration: widget.duration,
            initialDuration: 0,
            controller: widget.controller,
            width: timerSize,
            height: timerSize,
            ringColor: ringColor,
            fillColor: theme.colorScheme.primary,
            strokeWidth: 8.0,
            strokeCap: StrokeCap.round,
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'monospace',
            ),
            textFormat: CountdownTextFormat.MM_SS,
            isReverse: true,
            isReverseAnimation: true,
            autoStart: false,
            onComplete: widget.onComplete,
            onChange: (String timeStamp) {
              final parts = timeStamp.split(':');
              final minutes = int.parse(parts[0]);
              final seconds = int.parse(parts[1]);
              final newTime = minutes * 60 + seconds;
              // Only update if the time actually changed to avoid unnecessary rebuilds
              final currentTime = ref.read(timerProvider).currentTime;
              if (newTime != currentTime) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ref.read(timerProvider.notifier).updateCurrentTime(newTime);
                  }
                });
              }
            },
          ),
        );
      },
    );
  }
}