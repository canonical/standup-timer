import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standup/widgets/current_speaker.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CurrentSpeaker', () {
    group('normal mode', () {
      testWidgets('shows the current person name', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: ['Alice', 'Bob', 'Carol'],
        )));
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Person 1 of 3'), findsOneWidget);
      });

      testWidgets('shows the correct name for non-zero index', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 2,
          people: ['Alice', 'Bob', 'Carol'],
        )));
        expect(find.text('Carol'), findsOneWidget);
        expect(find.text('Person 3 of 3'), findsOneWidget);
      });

      testWidgets('shows placeholder when people list is empty', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: [],
        )));
        expect(find.text('Please add participants'), findsOneWidget);
        expect(find.text('Person 1 of 0'), findsNothing);
      });
    });

    group('dashboard mode', () {
      testWidgets('shows "Daily Standup" instead of person name', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: ['Alice', 'Bob', 'Carol'],
          isDashboardMode: true,
        )));
        expect(find.text('Daily Standup'), findsOneWidget);
        expect(find.text('Alice'), findsNothing);
      });

      testWidgets('shows plural participant count', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: ['Alice', 'Bob', 'Carol'],
          isDashboardMode: true,
        )));
        expect(find.text('3 participants'), findsOneWidget);
        expect(find.text('Person 1 of 3'), findsNothing);
      });

      testWidgets('shows singular participant count for one person', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: ['Alice'],
          isDashboardMode: true,
        )));
        expect(find.text('1 participant'), findsOneWidget);
        expect(find.text('1 participants'), findsNothing);
      });

      testWidgets('shows placeholder when people list is empty', (tester) async {
        await tester.pumpWidget(_wrap(const CurrentSpeaker(
          currentPersonIndex: 0,
          people: [],
          isDashboardMode: true,
        )));
        expect(find.text('Please add participants'), findsOneWidget);
        expect(find.text('Daily Standup'), findsNothing);
      });
    });
  });
}
