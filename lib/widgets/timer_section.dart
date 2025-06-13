import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'current_speaker.dart';
import 'circular_timer.dart';
import 'timer_controls.dart';
import 'navigation_controls.dart';
import '../comic.dart';

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
  final bool showTeamMembersHeader;

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
    this.showTeamMembersHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;
    
    // Show XKCD comic when no participants or all speakers are done
    final showComic = people.isEmpty || 
        (people.isNotEmpty && currentPersonIndex >= people.length && !isRunning);

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
            showTeamMembersHeader: showTeamMembersHeader,
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.outline,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isNarrow ? 16.0 : 32.0),
              child: showComic
                  ? const ComicScreen()
                  : Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: CircularTimer(
                              key: const ValueKey('circular_timer'),
                              controller: controller,
                              duration: duration,
                              onComplete: onTimerComplete,
                            ),
                          ),
                        ),
                        SizedBox(height: isNarrow ? 16 : 32),
                        TimerControls(
                          isRunning: isRunning,
                          isDisabled: people.isEmpty,
                          onToggleTimer: onToggleTimer,
                          onResetTimer: onResetTimer,
                        ),
                        const Spacer(),
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
          ),
        ],
      ),
    );
  }

}