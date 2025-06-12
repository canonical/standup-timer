import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'current_speaker.dart';
import 'circular_timer.dart';
import 'timer_controls.dart';
import 'navigation_controls.dart';

class TimerSection extends StatelessWidget {
  final CountDownController controller;
  final int duration;
  final bool isRunning;
  final int currentPersonIndex;
  final List<String> people;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;
  final VoidCallback onPreviousPerson;
  final VoidCallback onNextPerson;
  final Function(int) onPersonSelected;
  final VoidCallback onTimerComplete;

  const TimerSection({
    super.key,
    required this.controller,
    required this.duration,
    required this.isRunning,
    required this.currentPersonIndex,
    required this.people,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onPreviousPerson,
    required this.onNextPerson,
    required this.onPersonSelected,
    required this.onTimerComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          CurrentSpeaker(
            currentPersonIndex: currentPersonIndex,
            people: people,
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.outline,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                CircularTimer(
                  controller: controller,
                  duration: duration,
                  onComplete: onTimerComplete,
                ),
                const SizedBox(height: 24),
                _buildProgressBar(context),
                const SizedBox(height: 32),
                TimerControls(
                  isRunning: isRunning,
                  onToggleTimer: onToggleTimer,
                  onResetTimer: onResetTimer,
                ),
                const SizedBox(height: 24),
                NavigationControls(
                  currentPersonIndex: currentPersonIndex,
                  peopleCount: people.length,
                  onPreviousPerson: onPreviousPerson,
                  onNextPerson: onNextPerson,
                  onPersonSelected: onPersonSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final progressBg = theme.colorScheme.outlineVariant;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
              Text(
                '2:00',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: progressBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 -
                  (double.tryParse(controller.getTime()?.toString() ?? '') ??
                          duration) /
                      duration,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}