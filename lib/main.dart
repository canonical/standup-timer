import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru/yaru.dart';
import 'package:window_size/window_size.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/timer_section.dart';
import 'widgets/people_section.dart';
import 'widgets/session_info.dart';
import 'providers/timer_provider.dart';
import 'providers/participants_provider.dart';
import 'dart:developer' as developer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await YaruWindowTitleBar.ensureInitialized();
  setWindowTitle('Daily Standup Timer');
  await DesktopWindow.setWindowSize(const Size(1200, 800));
  await DesktopWindow.setMinWindowSize(const Size(450, 650));

  runApp(const ProviderScope(child: MyApp()));
}

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

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> with WidgetsBindingObserver {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey _timerSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(participantsProvider.notifier).checkClipboardContent();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    super.dispose();
  }

  void _addPerson() {
    if (_nameController.text.trim().isNotEmpty) {
      ref.read(participantsProvider.notifier).addPerson(_nameController.text.trim());
      _nameController.clear();
    }
  }

  Future<void> _pasteParticipantList() async {
    try {
      final addedCount = await ref.read(participantsProvider.notifier).pasteParticipantList();
      if (mounted) {
        String message;
        if (addedCount > 0) {
          message = 'Added $addedCount new ${addedCount == 1 ? 'participant' : 'participants'}';
          // Reset timer when new participants are added
          ref.read(timerProvider.notifier).resetTimer();
        } else {
          message = 'No new participants added (duplicates were skipped)';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
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
  }

  void _removePerson(int index) {
    ref.read(participantsProvider.notifier).removePerson(index);
    final participantsState = ref.read(participantsProvider);
    if (participantsState.people.isEmpty) {
      ref.read(timerProvider.notifier).resetTimer();
    }
  }

  void _clearAllParticipants() {
    ref.read(participantsProvider.notifier).clearAllParticipants();
    ref.read(timerProvider.notifier).resetTimer();
  }

  void _shuffleParticipants() {
    ref.read(participantsProvider.notifier).shuffleParticipants();
  }

  void _previousPerson() {
    final participantsState = ref.read(participantsProvider);
    if (participantsState.currentPersonIndex > 0) {
      ref.read(participantsProvider.notifier).previousPerson();
      ref.read(timerProvider.notifier).restartTimer();
    }
  }

  void _nextPerson() {
    final participantsState = ref.read(participantsProvider);
    if (participantsState.currentPersonIndex < participantsState.people.length - 1) {
      ref.read(participantsProvider.notifier).nextPerson();
      ref.read(timerProvider.notifier).restartTimer();
    }
  }

  void _toggleTimer() {
    final participantsState = ref.read(participantsProvider);
    if (participantsState.people.isEmpty) return;
    
    ref.read(timerProvider.notifier).toggleTimer();
  }

  void _resetTimer() {
    ref.read(timerProvider.notifier).resetTimer();
    ref.read(participantsProvider.notifier).setCurrentPersonIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final participantsState = ref.watch(participantsProvider);
    
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space &&
              (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                  event.logicalKey == LogicalKeyboardKey.shiftRight ||
                  HardwareKeyboard.instance.isShiftPressed)) {
            _toggleTimer();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyV &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            _pasteParticipantList();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            final participantsState = ref.read(participantsProvider);
            if (participantsState.currentPersonIndex > 0) {
              _previousPerson();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            final participantsState = ref.read(participantsProvider);
            if (participantsState.currentPersonIndex < participantsState.people.length - 1) {
              _nextPerson();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _resetTimer();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: const YaruWindowTitleBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 800;
            final hasEnoughHeight = constraints.maxHeight > 550;
            // In narrow mode, only show people section if window is tall enough
            final showPeople = isNarrow ? constraints.maxHeight > 930 : hasEnoughHeight;

            return Padding(
              padding: EdgeInsets.all(isNarrow ? 12.0 : 24.0),
              child: isNarrow
                  ? Column(
                      children: [
                        Expanded(
                          flex: showPeople ? 2 : 3,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 500),
                            child: TimerSection(
                              key: _timerSectionKey,
                              controller: timerState.controller,
                              duration: timerState.duration,
                              isRunning: timerState.isRunning,
                              currentPersonIndex: participantsState.currentPersonIndex,
                              people: participantsState.people,
                              currentTime: timerState.currentTime,
                              showTeamMembersHeader: isNarrow && !showPeople,
                            onToggleTimer: _toggleTimer,
                            onResetTimer: _resetTimer,
                            onPreviousPerson: _previousPerson,
                            onNextPerson: _nextPerson,
                            onPersonSelected: (index) {
                              ref.read(participantsProvider.notifier).setCurrentPersonIndex(index);
                              ref.read(timerProvider.notifier).restartTimer();
                            },
                            onTimerComplete: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  final currentParticipants = ref.read(participantsProvider);
                                  if (currentParticipants.currentPersonIndex < currentParticipants.people.length - 1) {
                                    ref.read(participantsProvider.notifier).nextPerson();
                                    ref.read(timerProvider.notifier).restartTimer();
                                  } else {
                                    // Last person finished - move to end state to show comic
                                    ref.read(participantsProvider.notifier).setCurrentPersonIndex(currentParticipants.people.length);
                                    ref.read(timerProvider.notifier).setRunning(false);
                                  }
                                }
                              });
                            },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isNarrow && showPeople) ...[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PeopleSection(
                                    people: participantsState.people,
                                    currentPersonIndex: participantsState.currentPersonIndex,
                                    showAddPerson: participantsState.showAddPerson,
                                    hasValidClipboardContent:
                                        participantsState.hasValidClipboardContent,
                                    nameController: _nameController,
                                    onAddPerson: _addPerson,
                                    onRemovePerson: _removePerson,
                                    onToggleAddPerson: () {
                                      ref.read(participantsProvider.notifier).setShowAddPerson(true);
                                    },
                                    onCancelAddPerson: () {
                                      ref.read(participantsProvider.notifier).setShowAddPerson(false);
                                      _nameController.clear();
                                    },
                                    onPasteParticipantList: _pasteParticipantList,
                                    onClearAllParticipants: _clearAllParticipants,
                                    onShuffleParticipants: _shuffleParticipants,
                                    onPersonSelected: (index) {
                                      final currentIndex = ref.read(participantsProvider).currentPersonIndex;
                                      if (index != currentIndex) {
                                        ref.read(participantsProvider.notifier).setCurrentPersonIndex(index);
                                        ref.read(timerProvider.notifier).restartTimer();
                                      }
                                    },
                                    onMovePersonUp: (index) {
                                      ref.read(participantsProvider.notifier).movePersonUp(index);
                                    },
                                    onMovePersonDown: (index) {
                                      ref.read(participantsProvider.notifier).movePersonDown(index);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SessionInfo(people: participantsState.people),
                              ],
                            ),
                          ),
                        ] else
                          SessionInfo(people: participantsState.people),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPeople) ...[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PeopleSection(
                                    people: participantsState.people,
                                    currentPersonIndex: participantsState.currentPersonIndex,
                                    showAddPerson: participantsState.showAddPerson,
                                    hasValidClipboardContent:
                                        participantsState.hasValidClipboardContent,
                                    nameController: _nameController,
                                    onAddPerson: _addPerson,
                                    onRemovePerson: _removePerson,
                                    onToggleAddPerson: () {
                                      ref.read(participantsProvider.notifier).setShowAddPerson(true);
                                    },
                                    onCancelAddPerson: () {
                                      ref.read(participantsProvider.notifier).setShowAddPerson(false);
                                      _nameController.clear();
                                    },
                                    onPasteParticipantList: _pasteParticipantList,
                                    onClearAllParticipants: _clearAllParticipants,
                                    onShuffleParticipants: _shuffleParticipants,
                                    onPersonSelected: (index) {
                                      developer.log(
                                          'onPersonSelected called with index $index',
                                          name: 'Main');
                                      ref.read(participantsProvider.notifier).setCurrentPersonIndex(index);
                                      ref.read(timerProvider.notifier).restartTimer();
                                      developer.log(
                                          'Person selection completed',
                                          name: 'Main');
                                    },
                                    onMovePersonUp: (index) {
                                      ref.read(participantsProvider.notifier).movePersonUp(index);
                                    },
                                    onMovePersonDown: (index) {
                                      ref.read(participantsProvider.notifier).movePersonDown(index);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SessionInfo(people: participantsState.people),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                        ] else ...[
                          SizedBox(
                            width: 320,
                            child: SessionInfo(people: participantsState.people),
                          ),
                          const SizedBox(width: 24),
                        ],
                        Expanded(
                          flex: 2,
                          child: TimerSection(
                            key: _timerSectionKey,
                            controller: timerState.controller,
                            duration: timerState.duration,
                            isRunning: timerState.isRunning,
                            currentPersonIndex: participantsState.currentPersonIndex,
                            people: participantsState.people,
                            currentTime: timerState.currentTime,
                            showTeamMembersHeader: !showPeople,
                            onToggleTimer: _toggleTimer,
                            onResetTimer: _resetTimer,
                            onPreviousPerson: _previousPerson,
                            onNextPerson: _nextPerson,
                            onPersonSelected: (index) {
                              ref.read(participantsProvider.notifier).setCurrentPersonIndex(index);
                              ref.read(timerProvider.notifier).restartTimer();
                            },
                            onTimerComplete: () {
                              final currentParticipants = ref.read(participantsProvider);
                              if (currentParticipants.currentPersonIndex < currentParticipants.people.length - 1) {
                                ref.read(participantsProvider.notifier).nextPerson();
                                ref.read(timerProvider.notifier).restartTimer();
                              } else {
                                // Last person finished - move to end state to show comic
                                ref.read(participantsProvider.notifier).setCurrentPersonIndex(currentParticipants.people.length);
                                ref.read(timerProvider.notifier).setRunning(false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
