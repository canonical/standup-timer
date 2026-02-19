import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:standup/screens/dashboard_screen.dart';
import 'package:standup/providers/workflows_provider.dart';

// Returns a settled, empty state without touching the filesystem.
class _FakeWorkflowsNotifier extends WorkflowsNotifier {
  @override
  WorkflowsState build() => const WorkflowsState(isLoading: false);
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        workflowsProvider.overrideWith(_FakeWorkflowsNotifier.new),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('DashboardScreen', () {
    testWidgets('does not show Start Standup button when onStartStandup is null',
        (tester) async {
      await tester.pumpWidget(_wrap(const DashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Start Standup'), findsNothing);
    });

    testWidgets('shows Start Standup button when onStartStandup is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(DashboardScreen(onStartStandup: () {})));
      await tester.pumpAndSettle();
      expect(find.text('Start Standup'), findsOneWidget);
    });

    testWidgets('tapping Start Standup calls the callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(DashboardScreen(
        onStartStandup: () => called = true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Standup'));
      expect(called, isTrue);
    });

    testWidgets('tapping Start Standup when isDisabled does not call the callback',
        (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(DashboardScreen(
        onStartStandup: () => called = true,
        isDisabled: true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Standup'));
      expect(called, isFalse);
    });
  });
}
