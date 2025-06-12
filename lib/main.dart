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
      appBar: const YaruWindowTitleBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildTimerSection(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _buildPeopleSection()),
                  const SizedBox(height: 16),
                  _buildSessionInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildCurrentSpeaker(),
          Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.outline,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                _buildCircularTimer(),
                const SizedBox(height: 24),
                _buildProgressBar(),
                const SizedBox(height: 32),
                _buildTimerControls(),
                const SizedBox(height: 24),
                _buildNavigationControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSpeaker() {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final accentBg = theme.colorScheme.primaryContainer;
    final accentText = theme.colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Currently Speaking',
                  style: TextStyle(
                    color: accentText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _people.isNotEmpty
                ? _people[_currentPersonIndex]
                : 'No one selected',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Person ${_currentPersonIndex + 1} of ${_people.length}',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTimer() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final ringColor = theme.colorScheme.outlineVariant;

    return SizedBox(
      width: 192,
      height: 192,
      child: CircularCountDownTimer(
        duration: _duration,
        initialDuration: 0,
        controller: _controller,
        width: 192,
        height: 192,
        ringColor: ringColor,
        fillColor: theme.colorScheme.primary,
        strokeWidth: 8.0,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'monospace',
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

  Widget _buildProgressBar() {
    final theme = Theme.of(context);
    final progressBg = theme.colorScheme.outlineVariant;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
              Text(
                '2:00',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: progressBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 -
                  (double.tryParse(_controller.getTime()?.toString() ?? '') ??
                          _duration) /
                      _duration,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControls() {
    final theme = Theme.of(context);
    final buttonSecondaryBg = theme.colorScheme.secondaryContainer;
    final buttonSecondaryText = theme.colorScheme.onSecondaryContainer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _resetTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonSecondaryBg,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: buttonSecondaryText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reset',
                style: TextStyle(
                  color: buttonSecondaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRunning ? Icons.pause : Icons.play_arrow,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isRunning ? 'Pause' : 'Start Timer',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
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
    final theme = Theme.of(context);
    final buttonGhostText = theme.colorScheme.onSurfaceVariant;
    final disabledColor = theme.colorScheme.outline;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _currentPersonIndex > 0 ? _previousPerson : null,
          icon: Icon(
            Icons.chevron_left,
            size: 16,
            color: _currentPersonIndex > 0 ? buttonGhostText : disabledColor,
          ),
          label: Text(
            'Previous',
            style: TextStyle(
              color: _currentPersonIndex > 0 ? buttonGhostText : disabledColor,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        _buildDotNavigation(),
        TextButton(
          onPressed:
              _currentPersonIndex < _people.length - 1 ? _nextPerson : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Next',
                style: TextStyle(
                  color: _currentPersonIndex < _people.length - 1
                      ? buttonGhostText
                      : disabledColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: _currentPersonIndex < _people.length - 1
                    ? buttonGhostText
                    : disabledColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDotNavigation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_people.length, (index) {
        final isActive = index == _currentPersonIndex;
        final theme = Theme.of(context);
        final activeDotColor = theme.colorScheme.primary;
        final inactiveDotColor = theme.colorScheme.outline;

        return GestureDetector(
          onTap: () => setState(() {
            _currentPersonIndex = index;
            _controller.restart(duration: _duration);
            if (!_isRunning) _controller.pause();
          }),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? activeDotColor : inactiveDotColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeopleSection() {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showAddPerson = true;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(6),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_showAddPerson) _buildAddPersonWidget(),
                  Expanded(
                    child: _people.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: _people.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final isActive = index == _currentPersonIndex;
                              final itemBg = isActive
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest;
                              final itemBorder = isActive
                                  ? theme.colorScheme.primary
                                  : Colors.transparent;
                              final itemText = isActive
                                  ? theme.colorScheme.onPrimaryContainer
                                  : textPrimary;
                              final dotColor = isActive
                                  ? theme.colorScheme.primary
                                  : textSecondary;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: itemBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: itemBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _people[index],
                                        style: TextStyle(
                                          color: itemText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removePerson(index),
                                      icon: Icon(
                                        Icons.close,
                                        color: theme.colorScheme.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddPersonWidget() {
    final theme = Theme.of(context);
    final inputBg = theme.colorScheme.surface;
    final inputBorder = theme.colorScheme.outline;
    final inputText = theme.colorScheme.onSurface;
    final placeholderText = theme.colorScheme.onSurfaceVariant;
    final addPersonBg = theme.colorScheme.surfaceContainerHighest;
    final buttonSecondaryBg = theme.colorScheme.secondaryContainer;
    final buttonSecondaryText = theme.colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: addPersonBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: inputBorder),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(color: inputText),
            decoration: InputDecoration(
              hintText: 'Enter team member name',
              hintStyle: TextStyle(color: placeholderText),
              filled: true,
              fillColor: inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: (_) => _addPerson(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _addPerson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add Member',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                  backgroundColor: buttonSecondaryBg,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: buttonSecondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.outline;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 48,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No team members added',
            style: TextStyle(
              color: textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Click + to add members',
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Total members:', '${_people.length}', textSecondary,
              textPrimary),
          const SizedBox(height: 8),
          _buildInfoRow('Expected duration:', '${_people.length * 2} min',
              textSecondary, textPrimary),
          const SizedBox(height: 8),
          _buildInfoRow(
              'Time per person:', '2 min', textSecondary, textPrimary),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
