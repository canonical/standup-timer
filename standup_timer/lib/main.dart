import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'comic.dart';
import 'package:window_size/window_size.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:math'; // Add this import
import 'package:desktop_window/desktop_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YaruWindowTitleBar.ensureInitialized();
  setWindowTitle('Stand Up Timer App');
  await DesktopWindow.setWindowSize(const Size(700, 700));

  runApp(const MyApp());
}

List<String> _allNames = [
  'Person 1',
  'Person 2',
  'Person 3',
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          title: 'Stand-up Timer',
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const TimerPage(),
        );
      },
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final CountDownController _controller = CountDownController();

  final int _duration = 120; // Seconds
  bool _isRunning = false;
  bool _isDone = true;

  int _whosTalkingIndex = 0;

  late List<bool> _selectedNames;

  @override
  void initState() {
    super.initState();
    final random = Random.secure(); // Use a secure random generator
    _allNames.shuffle(random); // Shuffle the names
    // Create a list of selected names 1 if the name is selected, 0 if not
    _selectedNames = List<bool>.filled(_allNames.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const YaruWindowTitleBar(
        title: Text('Stand-up Timer'),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/2025.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Row(
          children: [
            // Left side: display the list of names with buttons
            SizedBox(
              width: 150, // Adjust the width as desired
              child: ListView.separated(
                itemCount: _allNames.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8.0), // Add spacing
                itemBuilder: (context, index) {
                  final name = _allNames[index];
                  final isSelected = _selectedNames[index];
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isSelected) {
                          _selectedNames[index] = false;
                        } else {
                          _selectedNames[index] = true;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      // Yaru-orange (or user accent) when ON,
                      // neutral surfaceVariant when OFF
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    child: Text(name),
                  );
                },
              ),
            ),
            // Right side: timer and controls
            Expanded(
              child: Center(
                child: _isDone
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Replace the text with ComicScreen widget when not running
                          _isRunning
                              ? const Text("🎆")
                              // : const ComicScreen(),
                              : const Text('Ready?',
                                  style: TextStyle(fontSize: 40)),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isDone = false;
                                _isRunning = true;
                                _whosTalkingIndex =
                                    _selectedNames.indexOf(true);
                                _controller.restart(duration: _duration);
                              });
                            },
                            child: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            // Compute the expected time based on the number of selected names
                            '\nExpected time: ${_selectedNames.where((name) => name).length * _duration ~/ 60} min',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularCountDownTimer(
                            duration: _duration,
                            initialDuration: 0,
                            controller: _controller,
                            width: 250,
                            height: 250,
                            ringColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fillColor: _isRunning
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary // animated fill
                                : Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                            strokeWidth: 10.0,
                            strokeCap: StrokeCap.round,
                            textStyle: TextStyle(
                              fontSize: 44,
                              // choose the colour based on _isRunning
                              color: _isRunning
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface // Yaru-aware
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            textFormat: CountdownTextFormat.MM_SS,
                            isReverse: true,
                            isReverseAnimation: true,
                            onComplete: () {
                              setState(() {
                                do {
                                  _whosTalkingIndex++;
                                } while (_whosTalkingIndex < _allNames.length &&
                                    !_selectedNames[_whosTalkingIndex]);
                                if (_whosTalkingIndex < _allNames.length) {
                                  _controller.restart(duration: _duration);
                                  _isRunning = true;
                                } else {
                                  _controller.reset();
                                  _controller.pause();
                                  _isRunning = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _whosTalkingIndex >= 0 &&
                                    _whosTalkingIndex < _allNames.length
                                ? _allNames[_whosTalkingIndex]
                                : "🎆",
                            style: TextStyle(
                              fontSize: 40,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Combined Stop/Resume button
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (_isRunning) {
                                      _controller.pause();
                                      _isRunning = false;
                                    } else {
                                      _controller.resume();
                                      _isRunning = true;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Text(_isRunning ? 'Stop' : 'Resume'),
                              ),
                              const SizedBox(width: 20),
                              // Next person button
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Move to the next person. keep increasing the index
                                    // until we find a person that is selected or we reach
                                    // the end of the list.
                                    do {
                                      _whosTalkingIndex++;
                                    } while (
                                        _whosTalkingIndex < _allNames.length &&
                                            !_selectedNames[_whosTalkingIndex]);
                                    if (_whosTalkingIndex < _allNames.length) {
                                      _controller.restart(duration: _duration);
                                      _isRunning = true;
                                    } else {
                                      _controller.reset();
                                      _controller.pause();
                                      _isRunning = false;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text(
                                  'Next person',
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Restart button
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.restart(duration: _duration);
                                    _controller.pause();
                                    _isRunning = false;
                                    // Assing the _whosTalkingIndex to the first person in the list
                                    // that is selected.
                                    _whosTalkingIndex =
                                        _selectedNames.indexOf(true);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: const Text('Restart'),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
