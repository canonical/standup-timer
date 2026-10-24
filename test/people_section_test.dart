import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standup/widgets/people_section.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

PeopleSection _buildSection({
  List<String> people = const ['Alice', 'Bob', 'Carol'],
  int currentPersonIndex = -1,
  bool showAddPerson = false,
  bool hasValidClipboardContent = false,
  required VoidCallback onAddPerson,
  required Function(int) onRemovePerson,
  required VoidCallback onToggleAddPerson,
  required VoidCallback onCancelAddPerson,
  required VoidCallback onPasteParticipantList,
  required VoidCallback onClearAllParticipants,
  required VoidCallback onShuffleParticipants,
  Function(int)? onPersonSelected,
  Function(int)? onMovePersonUp,
  Function(int)? onMovePersonDown,
}) {
  return PeopleSection(
    people: people,
    currentPersonIndex: currentPersonIndex,
    showAddPerson: showAddPerson,
    hasValidClipboardContent: hasValidClipboardContent,
    nameController: TextEditingController(),
    onAddPerson: onAddPerson,
    onRemovePerson: onRemovePerson,
    onToggleAddPerson: onToggleAddPerson,
    onCancelAddPerson: onCancelAddPerson,
    onPasteParticipantList: onPasteParticipantList,
    onClearAllParticipants: onClearAllParticipants,
    onShuffleParticipants: onShuffleParticipants,
    onPersonSelected: onPersonSelected,
    onMovePersonUp: onMovePersonUp,
    onMovePersonDown: onMovePersonDown,
  );
}

Future<void> _pump(WidgetTester tester, PeopleSection section) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: section)),
  );
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PeopleSection', () {
    group('header', () {
      testWidgets('shows Team Members title', (tester) async {
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.text('Team Members'), findsOneWidget);
      });

      testWidgets('shows paste and add buttons', (tester) async {
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.byIcon(Icons.content_paste), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('paste button calls callback when clipboard is valid',
          (tester) async {
        var pasted = false;
        await _pump(tester, _buildSection(
          hasValidClipboardContent: true,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () => pasted = true,
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.byIcon(Icons.content_paste));
        expect(pasted, isTrue);
      });

      testWidgets('paste button is disabled when clipboard is empty',
          (tester) async {
        var pasted = false;
        await _pump(tester, _buildSection(
          hasValidClipboardContent: false,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () => pasted = true,
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.byIcon(Icons.content_paste));
        expect(pasted, isFalse);
      });

      testWidgets('add button calls onToggleAddPerson', (tester) async {
        var toggled = false;
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () => toggled = true,
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.byIcon(Icons.add));
        expect(toggled, isTrue);
      });

      testWidgets('menu clear all calls onClearAllParticipants',
          (tester) async {
        var cleared = false;
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () => cleared = true,
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear all'));
        expect(cleared, isTrue);
      });

      testWidgets('menu shuffle calls onShuffleParticipants', (tester) async {
        var shuffled = false;
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () => shuffled = true,
        ));
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Shuffle order'));
        expect(shuffled, isTrue);
      });
    });

    group('people list', () {
      testWidgets('shows all people names', (tester) async {
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Carol'), findsOneWidget);
      });

      testWidgets('shows empty state when no people', (tester) async {
        await _pump(tester, _buildSection(
          people: const [],
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.text('No team members added'), findsOneWidget);
        expect(find.text('Alice'), findsNothing);
      });

      testWidgets('remove button calls onRemovePerson with index',
          (tester) async {
        final removed = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: removed.add,
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        // Tap Alice's close button
        await tester.tap(find.byIcon(Icons.close).first);
        expect(removed, [0]);
      });

      testWidgets('tapping a person calls onPersonSelected with index',
          (tester) async {
        final selected = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        await tester.tap(find.text('Bob'));
        expect(selected, [1]);
      });

      testWidgets('tapping already-selected person does not re-select',
          (tester) async {
        final selected = <int>[];
        await _pump(tester, _buildSection(
          currentPersonIndex: 1,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        await tester.tap(find.text('Bob'));
        expect(selected, isEmpty);
      });
    });

    group('add person form', () {
      testWidgets('hidden by default', (tester) async {
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.byType(TextField), findsNothing);
      });

      testWidgets('shown when showAddPerson is true', (tester) async {
        await _pump(tester, _buildSection(
          showAddPerson: true,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Enter team member name'), findsOneWidget);
      });
    });

    group('keyboard navigation', () {
      testWidgets('arrow down then enter selects focused person',
          (tester) async {
        final selected = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        // Focus the section (tap header — requests focus without picking a person)
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(selected, [0]);
      });

      testWidgets('arrow up from nothing focuses the last person',
          (tester) async {
        final selected = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(selected, [2]);
      });

      testWidgets('shift+arrow down moves person down', (tester) async {
        final movesDown = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: (i) {},
          onMovePersonDown: movesDown.add,
        ));
        // Focus the section, select the first item
        await tester.tap(find.text('Alice'));
        // Move it down
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(movesDown, [0]);
      });

      testWidgets('shift+arrow up moves person up', (tester) async {
        final movesUp = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: (i) {},
          onMovePersonUp: movesUp.add,
        ));
        await tester.tap(find.text('Carol'));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(movesUp, [2]);
      });

      testWidgets('shift+backspace removes focused person', (tester) async {
        final removed = <int>[];
        await _pump(tester, _buildSection(
          onAddPerson: () {},
          onRemovePerson: removed.add,
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.text('Bob'));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(removed, [1]);
      });
    });

    group('auto-scroll', () {
      final manyPeople = List.generate(40, (i) => 'Person $i');

      testWidgets('arrow up scrolls to bring far-away item into viewport',
          (tester) async {
        final selected = <int>[];
        await _pump(tester, _buildSection(
          people: manyPeople,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        // Focus the section without picking a person
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();

        // First arrow up focuses the last person but does not scroll
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(find.text('Person 39'), findsNothing);
        expect(find.text('Person 0'), findsOneWidget);

        // Second arrow up triggers _scrollTo → estimated animateTo → ensureVisible
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        await tester.pump(); // extra frame for postFrame ensureVisible
        expect(find.text('Person 38'), findsOneWidget);
        expect(find.text('Person 0'), findsNothing);
      });

      testWidgets('arrow down scrolls to bring far-away item into viewport',
          (tester) async {
        // Shrink the surface so fewer items fit the viewport
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, _buildSection(
          people: manyPeople,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();

        // Walk down past the end of the viewport
        for (var i = 0; i < 12; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }
        await tester.pump(); // extra frame for postFrame ensureVisible

        expect(find.text('Person 11'), findsOneWidget);
        expect(find.text('Person 0'), findsNothing);
      });

      testWidgets('arrow down scrolls when item is just past the viewport',
          (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, _buildSection(
          people: manyPeople,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        // Count how many rows are visible, then step one past the edge
        final visibleRows =
            tester.widgetList(find.textContaining('Person ')).length;
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();

        for (var i = 0; i <= visibleRows; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }
        await tester.pump(); // extra frame for postFrame ensureVisible

        // Focused index == visibleRows, which was unbuilt-unseen before scrolling
        expect(find.text('Person $visibleRows'), findsOneWidget);
        expect(find.text('Person 0'), findsNothing);
      });

      testWidgets(
          'arrow up scrolls to the top when item is near (not far away)',
          (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final selected = <int>[];
        await _pump(tester, _buildSection(
          people: manyPeople,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
          onPersonSelected: selected.add,
        ));
        await tester.tap(find.text('Team Members'));
        await tester.pumpAndSettle();

        // Walk to the bottom of the list
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        await tester.pump();
        expect(find.text('Person 38'), findsOneWidget);

        // Walk back up to the top — items are near/built, ensureVisible path
        for (var i = 38; i >= 0; i--) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
          await tester.pumpAndSettle();
        }
        await tester.pump();

        expect(find.text('Person 0'), findsOneWidget);
        expect(find.text('Person 38'), findsNothing);
      });
    });

    group('scroll on selection change (no keyboard)', () {
      final manyPeople = List.generate(40, (i) => 'Person $i');

      testWidgets(
          'scrolls when currentPersonIndex changes to a built-but-unseen item',
          (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, _buildSection(
          people: manyPeople,
          currentPersonIndex: 0,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.text('Person 0'), findsOneWidget);
        final visibleRows =
            tester.widgetList(find.textContaining('Person ')).length;

        // Change selection to an item just below the viewport — remounts nothing because
        // the elements update in place, so didUpdateWidget triggers _scrollTo
        await tester.pumpWidget(MaterialApp(home: Scaffold(
          body: _buildSection(
            people: manyPeople,
            currentPersonIndex: visibleRows,
            onAddPerson: () {},
            onRemovePerson: (_) {},
            onToggleAddPerson: () {},
            onCancelAddPerson: () {},
            onPasteParticipantList: () {},
            onClearAllParticipants: () {},
            onShuffleParticipants: () {},
          ),
        )));
        await tester.pumpAndSettle();
        await tester.pump(); // extra frame for postFrame ensureVisible

        expect(find.text('Person $visibleRows'), findsOneWidget);
        expect(find.text('Person 0'), findsNothing);
      });

      testWidgets(
          'scrolls when currentPersonIndex changes to a far-away item',
          (tester) async {
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, _buildSection(
          people: manyPeople,
          currentPersonIndex: 0,
          onAddPerson: () {},
          onRemovePerson: (_) {},
          onToggleAddPerson: () {},
          onCancelAddPerson: () {},
          onPasteParticipantList: () {},
          onClearAllParticipants: () {},
          onShuffleParticipants: () {},
        ));
        expect(find.text('Person 0'), findsOneWidget);

        // Jump selection to the very bottom (not built at all — estimate path)
        await tester.pumpWidget(MaterialApp(home: Scaffold(
          body: _buildSection(
            people: manyPeople,
            currentPersonIndex: 39,
            onAddPerson: () {},
            onRemovePerson: (_) {},
            onToggleAddPerson: () {},
            onCancelAddPerson: () {},
            onPasteParticipantList: () {},
            onClearAllParticipants: () {},
            onShuffleParticipants: () {},
          ),
        )));
        await tester.pumpAndSettle();
        await tester.pump();

        expect(find.text('Person 39'), findsOneWidget);
        expect(find.text('Person 0'), findsNothing);
      });
    });
  });
}
