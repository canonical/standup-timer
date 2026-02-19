import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standup/comic.dart';
import 'package:standup/providers/workflows_provider.dart';
import 'package:standup/screens/dashboard_screen.dart';
import 'package:standup/widgets/timer_section.dart';

// Settled, no-op provider override so DashboardScreen builds without
// touching the filesystem.
class _FakeWorkflowsNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => const WorkflowsState(isLoading: false);
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [workflowsProvider.overrideWith(_FakeWorkflowsNotifier.new)],
      child: MaterialApp(home: Scaffold(body: child)),
    );

// Builds a TimerSection with sensible defaults; only override what matters.
TimerSection _section({
  List<String> people = const [],
  int currentPersonIndex = 0,
  bool isRunning = false,
  int duration = 120,
  int? currentTime,
}) =>
    TimerSection(
      controller: CountDownController(),
      duration: duration,
      isRunning: isRunning,
      currentPersonIndex: currentPersonIndex,
      people: people,
      currentTime: currentTime ?? duration,
      onToggleTimer: () {},
      onResetTimer: () {},
      onPreviousPerson: () {},
      onNextPerson: () {},
      onPersonSelected: (_) {},
      onTimerComplete: () {},
    );

void main() {
  group('TimerSection pre-start flow', () {
    testWidgets('shows ComicScreen in initial state with no participants',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(_wrap(_section()));
      await tester.pump();
      expect(find.byType(ComicScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('shows ComicScreen in initial state with participants',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(_wrap(_section(people: ['Alice', 'Bob'])));
      await tester.pump();
      expect(find.byType(ComicScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('shows timer UI (not ComicScreen) when timer is running',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(_wrap(_section(
        people: ['Alice', 'Bob'],
        isRunning: true,
        currentTime: 60, // mid-run
      )));
      await tester.pump();
      expect(find.byType(ComicScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('shows ComicScreen again after timer returns to initial state',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      // Pump with timer running (non-initial state).
      await tester.pumpWidget(_wrap(_section(
        people: ['Alice', 'Bob'],
        isRunning: true,
        currentTime: 60,
      )));
      await tester.pump();
      expect(find.byType(ComicScreen), findsNothing);

      // Reset to initial state.
      await tester.pumpWidget(_wrap(_section(
        people: ['Alice', 'Bob'],
        isRunning: false,
        currentTime: 120, // back to full duration
      )));
      await tester.pump();
      expect(find.byType(ComicScreen), findsOneWidget);
    });
  });

  group('TimerSection header', () {
    testWidgets('shows "Daily Standup" title in pre-start state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
          _wrap(_section(people: ['Alice', 'Bob', 'Carol'])));
      await tester.pump();
      expect(find.text('Daily Standup'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('shows participant count in pre-start state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
          _wrap(_section(people: ['Alice', 'Bob', 'Carol'])));
      await tester.pump();
      expect(find.text('3 participants'), findsOneWidget);
    });

    testWidgets('shows current person name while timer is running', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(_wrap(_section(
        people: ['Alice', 'Bob'],
        isRunning: true,
        currentTime: 60,
      )));
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Daily Standup'), findsNothing);
    });
  });
}
