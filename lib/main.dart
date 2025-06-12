import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:window_size/window_size.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:math';
import 'package:desktop_window/desktop_window.dart';

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
    return MaterialApp(
      title: 'Daily Standup Timer',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const TimerPage(),
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
  final TextEditingController _nameController = TextEditingController();

  final int _duration = 120; // Seconds
  bool _isRunning = false;
  
  int _currentPersonIndex = 0;
  List<String> _people = [];
  bool _showAddPerson = false;

  @override
  void initState() {
    super.initState();
    _people = List.from(_defaultNames);
    final random = Random.secure();
    _people.shuffle(random);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _addPerson() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _people.add(_nameController.text.trim());
        _nameController.clear();
        _showAddPerson = false;
      });
    }
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
  }

  void _previousPerson() {
    if (_currentPersonIndex > 0) {
      setState(() {
        _currentPersonIndex--;
        _controller.restart(duration: _duration);
        if (!_isRunning) _controller.pause();
      });
    }
  }

  void _nextPerson() {
    if (_currentPersonIndex < _people.length - 1) {
      setState(() {
        _currentPersonIndex++;
        _controller.restart(duration: _duration);
        if (!_isRunning) _controller.pause();
      });
    }
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF581C87), // purple-900
              Color(0xFF0F172A), // slate-900
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTimerSection(),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: _buildPeopleSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Daily Standup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.settings,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              _buildCurrentSpeaker(),
              const SizedBox(height: 32),
              _buildCircularTimer(),
              const SizedBox(height: 32),
              _buildTimerControls(),
              const SizedBox(height: 24),
              _buildNavigationControls(),
            ],
          ),
        ),
    );
  }

  Widget _buildCurrentSpeaker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF97316).withOpacity(0.2),
                const Color(0xFFEC4899).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people,
                color: Color(0xFFFB923C),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Now Speaking',
                style: TextStyle(
                  color: Color(0xFFFDBA74),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _people.isNotEmpty ? _people[_currentPersonIndex] : 'No one',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Person ${_currentPersonIndex + 1} of ${_people.length}',
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularTimer() {
    return SizedBox(
      width: 256,
      height: 256,
      child: CircularCountDownTimer(
        duration: _duration,
        initialDuration: 0,
        controller: _controller,
        width: 256,
        height: 256,
        ringColor: Colors.white.withOpacity(0.1),
        fillColor: const Color(0xFFF97316),
        fillGradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEC4899)],
        ),
        strokeWidth: 10.0,
        strokeCap: StrokeCap.round,
        textStyle: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textFormat: CountdownTextFormat.MM_SS,
        isReverse: true,
        isReverseAnimation: true,
        onComplete: () {
          setState(() {
            if (_currentPersonIndex < _people.length - 1) {
              _currentPersonIndex++;
              _controller.restart(duration: _duration);
            } else {
              _isRunning = false;
              _controller.pause();
            }
          });
        },
      ),
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.all(
              const Color(0xFFF97316),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isRunning ? 'Pause' : 'Start',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _resetTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentPersonIndex > 0 ? _previousPerson : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '← Previous',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _currentPersonIndex < _people.length - 1 ? _nextPerson : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Next →',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showAddPerson = true;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    padding: const EdgeInsets.all(8),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_showAddPerson) _buildAddPersonWidget(),
            Expanded(
              child: _people.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: _people.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final isActive = index == _currentPersonIndex;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFFF97316).withOpacity(0.2),
                                      const Color(0xFFEC4899).withOpacity(0.2),
                                    ],
                                  )
                                : null,
                            color: isActive ? null : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: isActive
                                ? Border.all(
                                    color: const Color(0xFFF97316).withOpacity(0.3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFFB923C)
                                      : const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _people[index],
                                  style: TextStyle(
                                    color: isActive
                                        ? const Color(0xFFFDBA74)
                                        : const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removePerson(index),
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF6B7280),
                                  size: 16,
                                ),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPersonWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter name...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFF97316),
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _addPerson(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _addPerson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAddPerson = false;
                    _nameController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 48,
            color: Color(0xFF6B7280),
          ),
          SizedBox(height: 12),
          Text(
            'No team members added yet',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
