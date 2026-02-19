import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:standup/screens/dashboard_screen.dart';
import 'package:standup/providers/workflows_provider.dart';
import 'package:standup/services/ci_provider.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _EmptyNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => const WorkflowsState(isLoading: false);
}

class _LoadingNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => const WorkflowsState(isLoading: true);
}

class _ErrorNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => const WorkflowsState(
        isLoading: false,
        configError: 'Create ~/.config/standup-timer/workflows.yaml to monitor CI workflows.',
      );
}

class _WithRunsNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => WorkflowsState(
        isLoading: false,
        lastFetched: DateTime.now(),
        runs: const [
          CiRun(label: 'Checkbox Daily Builds', status: 'success', branch: 'main'),
          CiRun(label: 'Release pipeline', status: 'failure', branch: 'release/1.0'),
          CiRun(label: 'Nightly job', status: 'in_progress'),
        ],
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {required WorkflowsNotifier Function() notifier}) =>
    ProviderScope(
      overrides: [workflowsProvider.overrideWith(notifier)],
      child: MaterialApp(home: Scaffold(body: child)),
    );

Widget _wrapEmpty(Widget child) => _wrap(child, notifier: _EmptyNotifier.new);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('DashboardScreen', () {
    group('Start Standup button', () {
      testWidgets('not shown when onStartStandup is null', (tester) async {
        await tester.pumpWidget(_wrapEmpty(const DashboardScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Start Standup'), findsNothing);
      });

      testWidgets('shown when onStartStandup is provided', (tester) async {
        await tester.pumpWidget(_wrapEmpty(DashboardScreen(onStartStandup: () {})));
        await tester.pumpAndSettle();
        expect(find.text('Start Standup'), findsOneWidget);
      });

      testWidgets('tapping calls the callback when enabled', (tester) async {
        var called = false;
        await tester.pumpWidget(
            _wrapEmpty(DashboardScreen(onStartStandup: () => called = true)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start Standup'));
        expect(called, isTrue);
      });

      testWidgets('tapping does not call the callback when isDisabled', (tester) async {
        var called = false;
        await tester.pumpWidget(_wrapEmpty(DashboardScreen(
          onStartStandup: () => called = true,
          isDisabled: true,
        )));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start Standup'));
        expect(called, isFalse);
      });
    });

    group('header', () {
      testWidgets('shows CI Status title', (tester) async {
        await tester.pumpWidget(_wrapEmpty(const DashboardScreen()));
        await tester.pumpAndSettle();
        expect(find.text('CI Status'), findsOneWidget);
      });

      testWidgets('shows refresh button when not loading', (tester) async {
        await tester.pumpWidget(_wrapEmpty(const DashboardScreen()));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('shows loading indicator instead of refresh button when loading',
          (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _LoadingNotifier.new));
        await tester.pump(); // single frame — don't settle (loading never ends)
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.refresh), findsNothing);
      });

      testWidgets('shows time-ago label when lastFetched is set', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _WithRunsNotifier.new));
        await tester.pumpAndSettle();
        // lastFetched is DateTime.now() so the label should be 'just now'
        expect(find.text('just now'), findsOneWidget);
      });
    });

    group('body — config error state', () {
      testWidgets('shows config error message', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _ErrorNotifier.new));
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
              'Create ~/.config/standup-timer/workflows.yaml'),
          findsOneWidget,
        );
      });

      testWidgets('shows settings icon in error state', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _ErrorNotifier.new));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      });

      testWidgets('shows config file hint snippet', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _ErrorNotifier.new));
        await tester.pumpAndSettle();
        expect(find.textContaining('workflows:'), findsOneWidget);
      });
    });

    group('body — runs list', () {
      testWidgets('shows run labels', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _WithRunsNotifier.new));
        await tester.pumpAndSettle();
        expect(find.text('Checkbox Daily Builds'), findsOneWidget);
        expect(find.text('Release pipeline'), findsOneWidget);
        expect(find.text('Nightly job'), findsOneWidget);
      });

      testWidgets('shows run branch names', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _WithRunsNotifier.new));
        await tester.pumpAndSettle();
        expect(find.text('main'), findsOneWidget);
        expect(find.text('release/1.0'), findsOneWidget);
      });

      testWidgets('shows status badge labels', (tester) async {
        await tester.pumpWidget(
            _wrap(const DashboardScreen(), notifier: _WithRunsNotifier.new));
        await tester.pumpAndSettle();
        expect(find.text('success'), findsOneWidget);
        expect(find.text('failure'), findsOneWidget);
        expect(find.text('running'), findsOneWidget);
      });
    });
  });
}
