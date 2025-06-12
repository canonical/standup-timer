import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru/yaru.dart';
import 'package:window_size/window_size.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:math';
import 'package:desktop_window/desktop_window.dart';
import 'widgets/timer_section.dart';
import 'widgets/people_section.dart';
import 'widgets/session_info.dart';
import 'services/participant_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YaruWindowTitleBar.ensureInitialized();
  setWindowTitle('Daily Standup Timer');
  await DesktopWindow.setWindowSize(const Size(1200, 800));

  runApp(const MyApp());
}

List<String> _defaultNames = [
  'Alice Johnson',
  'Bob Smith',
  'Carol Davis',
  'David Wilson',
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      child: MaterialApp(
        title: 'Daily Standup Timer',
        theme: yaruLight,
        darkTheme: yaruDark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const TimerPage(),
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  final CountDownController _controller = CountDownController();
  final TextEditingController _nameController = TextEditingController();

  final int _duration = 120; // Seconds
  bool _isRunning = false;

  int _currentPersonIndex = 0;
  List<String> _people = [];
  bool _showAddPerson = false;
  bool _hasValidClipboardContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedParticipants();
    _checkClipboardContent();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkClipboardContent();
    }
  }

  Future<void> _loadSavedParticipants() async {
    final savedParticipants = await ParticipantService.loadParticipantList();
    setState(() {
      _people = savedParticipants;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveParticipantList() async {
    await ParticipantService.saveParticipantList(_people);
  }

  Future<void> _checkClipboardContent() async {
    final hasValid = await ParticipantService.hasValidClipboardContent();
    setState(() {
      _hasValidClipboardContent = hasValid;
    });
  }

  void _addPerson() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _people.add(_nameController.text.trim());
        _nameController.clear();
        _showAddPerson = false;
      });
      _saveParticipantList();
    }
  }


  Future<void> _pasteParticipantList() async {
    try {
      final clipboardData = await ParticipantService.getClipboardContent();
      if (clipboardData.isNotEmpty) {
        final participants = ParticipantService.parseParticipantList(clipboardData);
        if (participants.isNotEmpty) {
          setState(() {
            _people.clear();
            _people.addAll(participants);
            final random = Random.secure();
            _people.shuffle(random);
            _currentPersonIndex = 0;
          });
          _saveParticipantList();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${participants.length} participants'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No valid participants found in clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to paste from clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    
    _checkClipboardContent();
  }

  void _removePerson(int index) {
    setState(() {
      _people.removeAt(index);
      if (_currentPersonIndex >= _people.length && _people.isNotEmpty) {
        _currentPersonIndex = _people.length - 1;
      } else if (_people.isEmpty) {
        _currentPersonIndex = 0;
      }
    });
    _saveParticipantList();
  }

  void _previousPerson() {
    if (_currentPersonIndex > 0) {
      setState(() {
        _currentPersonIndex--;
        _controller.restart(duration: _duration);
        _isRunning = true;
      });
    }
  }

  void _nextPerson() {
    if (_currentPersonIndex < _people.length - 1) {
      setState(() {
        _currentPersonIndex++;
        _controller.restart(duration: _duration);
        _isRunning = true;
      });
    }
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _controller.pause();
        _isRunning = false;
      } else {
        _controller.resume();
        _isRunning = true;
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _controller.restart(duration: _duration);
      _controller.pause();
      _isRunning = false;
      _currentPersonIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space) {
            _toggleTimer();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_currentPersonIndex > 0) {
              _previousPerson();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_currentPersonIndex < _people.length - 1) {
              _nextPerson();
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: const YaruWindowTitleBar(),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: PeopleSection(
                        people: _people,
                        currentPersonIndex: _currentPersonIndex,
                        showAddPerson: _showAddPerson,
                        hasValidClipboardContent: _hasValidClipboardContent,
                        nameController: _nameController,
                        onAddPerson: _addPerson,
                        onRemovePerson: _removePerson,
                        onToggleAddPerson: () {
                          setState(() {
                            _showAddPerson = true;
                          });
                        },
                        onCancelAddPerson: () {
                          setState(() {
                            _showAddPerson = false;
                            _nameController.clear();
                          });
                        },
                        onPasteParticipantList: _pasteParticipantList,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SessionInfo(people: _people),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: TimerSection(
                  controller: _controller,
                  duration: _duration,
                  isRunning: _isRunning,
                  currentPersonIndex: _currentPersonIndex,
                  people: _people,
                  onToggleTimer: _toggleTimer,
                  onResetTimer: _resetTimer,
                  onPreviousPerson: _previousPerson,
                  onNextPerson: _nextPerson,
                  onPersonSelected: (index) {
                    setState(() {
                      _currentPersonIndex = index;
                      _controller.restart(duration: _duration);
                      _isRunning = true;
                    });
                  },
                  onTimerComplete: () {
                    setState(() {
                      if (_currentPersonIndex < _people.length - 1) {
                        _currentPersonIndex++;
                        _controller.restart(duration: _duration);
                        _isRunning = true;
                      } else {
                        _isRunning = false;
                        _controller.pause();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
