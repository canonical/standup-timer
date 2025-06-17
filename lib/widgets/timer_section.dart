import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:confetti/confetti.dart';
import 'current_speaker.dart';
import 'circular_timer.dart';
import 'timer_controls.dart';
import 'navigation_controls.dart';
import 'celebration_screen.dart';
import '../comic.dart';

class TimerSection extends StatefulWidget {
  final CountDownController controller;
  final int duration;
  final bool isRunning;
  final int currentPersonIndex;
  final List<String> people;
  final int currentTime;
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
    required this.currentTime,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onPreviousPerson,
    required this.onNextPerson,
    required this.onPersonSelected,
    required this.onTimerComplete,
    this.showTeamMembersHeader = false,
  });

  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> {
  late ConfettiController _confettiController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onFinish() {
    _confettiController.play();
    // Stop the timer and show celebration screen
    widget.controller.pause();
    setState(() {
      _showCelebration = true;
    });
  }

  void _onResetFromCelebration() {
    setState(() {
      _showCelebration = false;
    });
    widget.onResetTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;
    
    // Show XKCD comic when no participants, timer hasn't started, or all speakers are done
    final timerInInitialState = widget.currentTime == widget.duration && !widget.isRunning && widget.currentPersonIndex == 0;
    final showComic = widget.people.isEmpty || 
        timerInInitialState ||
        (widget.people.isNotEmpty && widget.currentPersonIndex >= widget.people.length && !widget.isRunning && !_showCelebration);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              CurrentSpeaker(
                currentPersonIndex: widget.currentPersonIndex,
                people: widget.people,
                showTeamMembersHeader: widget.showTeamMembersHeader,
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 16.0 : 32.0),
                  child: _showCelebration
                      ? CelebrationScreen(
                          onResetTimer: _onResetFromCelebration,
                        )
                      : showComic
                          ? ComicScreen(
                              showTimerControls: widget.people.isNotEmpty && timerInInitialState,
                              isRunning: widget.isRunning,
                              isDisabled: widget.people.isEmpty,
                              onToggleTimer: widget.onToggleTimer,
                              onResetTimer: widget.onResetTimer,
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: CircularTimer(
                                      key: ValueKey('circular_timer_${widget.currentPersonIndex}${widget.duration}'),
                                      controller: widget.controller,
                                      duration: widget.duration,
                                      isRunning: widget.isRunning,
                                      onComplete: widget.onTimerComplete,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isNarrow ? 16 : 32),
                                TimerControls(
                                  isRunning: widget.isRunning,
                                  isDisabled: widget.people.isEmpty,
                                  onToggleTimer: widget.onToggleTimer,
                                  onResetTimer: widget.onResetTimer,
                                ),
                                const Spacer(),
                                NavigationControls(
                                  currentPersonIndex: widget.currentPersonIndex,
                                  peopleCount: widget.people.length,
                                  onPreviousPerson: widget.onPreviousPerson,
                                  onNextPerson: widget.onNextPerson,
                                  onPersonSelected: widget.onPersonSelected,
                                  onFinish: _onFinish,
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14159 / 2,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

}