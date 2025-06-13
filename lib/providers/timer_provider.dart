import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerState {
  final CountDownController controller;
  final int duration;
  final bool isRunning;
  final int currentTime;

  TimerState({
    required this.controller,
    required this.duration,
    required this.isRunning,
    required this.currentTime,
  });

  TimerState copyWith({
    CountDownController? controller,
    int? duration,
    bool? isRunning,
    int? currentTime,
  }) {
    return TimerState(
      controller: controller ?? this.controller,
      duration: duration ?? this.duration,
      isRunning: isRunning ?? this.isRunning,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  static const String _durationKey = 'timer_duration';

  TimerNotifier() : super(TimerState(
    controller: CountDownController(),
    duration: 120,
    isRunning: false,
    currentTime: 120,
  )) {
    _loadDuration();
  }

  Future<void> _loadDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDuration = prefs.getInt(_durationKey) ?? 120;
    if (savedDuration != state.duration) {
      state.controller.restart(duration: savedDuration);
      state.controller.pause();
      state = state.copyWith(
        duration: savedDuration,
        currentTime: savedDuration,
      );
    }
  }

  Future<void> _saveDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_durationKey, duration);
  }

  void _recreateController() {
    final newController = CountDownController();
    state = state.copyWith(
      controller: newController,
      isRunning: false,
      currentTime: state.duration,
    );
  }

  void toggleTimer() {
    print('TimerProvider: toggleTimer called, current isRunning: ${state.isRunning}');
    try {
      if (state.isRunning) {
        print('TimerProvider: Pausing timer');
        state.controller.pause();
        state = state.copyWith(isRunning: false);
      } else {
        print('TimerProvider: Starting timer');
        state.controller.start();
        state = state.copyWith(isRunning: true);
      }
      print('TimerProvider: New isRunning state: ${state.isRunning}');
    } catch (e) {
      print('TimerProvider: Controller error: $e');
      // Controller was disposed, create a new one
      _recreateController();
      if (!state.isRunning) {
        print('TimerProvider: Starting timer with new controller');
        state.controller.start();
        state = state.copyWith(isRunning: true);
      }
    }
  }

  void resetTimer() {
    try {
      state.controller.restart(duration: state.duration);
      state.controller.pause();
      state = state.copyWith(
        isRunning: false,
        currentTime: state.duration,
      );
    } catch (e) {
      // Controller was disposed, create a new one
      _recreateController();
    }
  }

  void restartTimer() {
    try {
      state.controller.restart(duration: state.duration);
      state = state.copyWith(
        currentTime: state.duration,
      );
      if (state.isRunning) {
        state.controller.start();
      } else {
        state.controller.pause();
      }
    } catch (e) {
      // Controller was disposed, create a new one
      _recreateController();
      if (state.isRunning) {
        state.controller.start();
      }
    }
  }

  void updateCurrentTime(int newTime) {
    state = state.copyWith(currentTime: newTime);
  }

  void setRunning(bool running) {
    state = state.copyWith(isRunning: running);
  }

  void setDuration(int newDuration) {
    state.controller.restart(duration: newDuration);
    state.controller.pause();
    state = state.copyWith(
      duration: newDuration,
      currentTime: newDuration,
      isRunning: false,
    );
    _saveDuration(newDuration);
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});