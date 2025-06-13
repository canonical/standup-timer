import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class HorizontalTimer extends ConsumerStatefulWidget {
  final CountDownController controller;
  final int duration;
  final VoidCallback onComplete;

  const HorizontalTimer({
    super.key,
    required this.controller,
    required this.duration,
    required this.onComplete,
  });

  @override
  ConsumerState<HorizontalTimer> createState() => _HorizontalTimerState();
}

class _HorizontalTimerState extends ConsumerState<HorizontalTimer> {
  late int _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.duration;
  }

  @override
  void didUpdateWidget(HorizontalTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _currentTime = widget.duration;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Timer display text
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Center(
            child: CircularCountDownTimer(
              duration: widget.duration,
              initialDuration: 0,
              controller: widget.controller,
              width: double.infinity,
              height: 50,
              ringColor: Colors.transparent,
              fillColor: Colors.transparent,
              strokeWidth: 0,
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: 'monospace',
              ),
              isReverse: true,
              isReverseAnimation: true,
              autoStart: false,
              onComplete: widget.onComplete,
              onChange: (String timeStamp) {
                final parts = timeStamp.split(':');
                final minutes = int.parse(parts[0]);
                final seconds = int.parse(parts[1]);
                final newTime = minutes * 60 + seconds;
                if (_currentTime != newTime) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _currentTime = newTime;
                      });
                      ref.read(timerProvider.notifier).updateCurrentTime(newTime);
                    }
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progress = (widget.duration - _currentTime) / widget.duration;
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}