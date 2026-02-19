import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:confetti/confetti.dart';
import 'current_speaker.dart';
import 'circular_timer.dart';
import 'timer_controls.dart';
import 'navigation_controls.dart';
import 'celebration_screen.dart';
import '../screens/dashboard_screen.dart';
import '../comic.dart';

enum _PreStartView { comic, dashboard }

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
  _PreStartView _preStartView = _PreStartView.comic;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(TimerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to comic whenever the timer transitions back to initial state.
    final isInitialNow = widget.currentTime == widget.duration &&
        !widget.isRunning &&
        widget.currentPersonIndex == 0;
    final wasInitial = oldWidget.currentTime == oldWidget.duration &&
        !oldWidget.isRunning &&
        oldWidget.currentPersonIndex == 0;
    if (isInitialNow && !wasInitial) {
      setState(() => _preStartView = _PreStartView.comic);
    }
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
      _preStartView = _PreStartView.comic;
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
                isDashboardMode: showComic,
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
                          ? (_preStartView == _PreStartView.comic
                              ? ComicScreen(
                                  onNext: () => setState(() => _preStartView = _PreStartView.dashboard),
                                )
                              : DashboardScreen(
                                  onStartStandup: widget.people.isNotEmpty ? widget.onToggleTimer : null,
                                  isDisabled: widget.people.isEmpty,
                                ))
                          : Column(
                              children: [
                                Expanded(
                                  flex: 3,
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
                                SizedBox(height: isNarrow ? 12 : 20),
                                TimerControls(
                                  isRunning: widget.isRunning,
                                  isDisabled: widget.people.isEmpty,
                                  onToggleTimer: widget.onToggleTimer,
                                  onResetTimer: widget.onResetTimer,
                                ),
                                SizedBox(height: isNarrow ? 16 : 24),
                                NavigationControls(
                                  currentPersonIndex: widget.currentPersonIndex,
                                  peopleCount: widget.people.length,
                                  onPreviousPerson: widget.onPreviousPerson,
                                  onNextPerson: widget.onNextPerson,
                                  onPersonSelected: widget.onPersonSelected,
                                  onFinish: _onFinish,
                                ),
                                SizedBox(height: isNarrow ? 8 : 12),
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