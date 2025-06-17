import 'package:flutter/material.dart';

class NavigationControls extends StatelessWidget {
  final int currentPersonIndex;
  final int peopleCount;
  final VoidCallback onPreviousPerson;
  final VoidCallback onNextPerson;
  final Function(int) onPersonSelected;
  final VoidCallback? onFinish;

  const NavigationControls({
    super.key,
    required this.currentPersonIndex,
    required this.peopleCount,
    required this.onPreviousPerson,
    required this.onNextPerson,
    required this.onPersonSelected,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonGhostText = theme.colorScheme.onSurfaceVariant;
    final disabledColor = theme.colorScheme.outline;

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Row(
      children: [
        Expanded(
          child: Center(
            child: TextButton(
              onPressed: currentPersonIndex > 0 ? onPreviousPerson : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? 4 : 8, vertical: isNarrow ? 6 : 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: isNarrow ? 14 : 16,
                    color: currentPersonIndex > 0
                        ? buttonGhostText
                        : disabledColor,
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Previous',
                      style: TextStyle(
                        color: currentPersonIndex > 0
                            ? buttonGhostText
                            : disabledColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: _buildDotNavigation(context),
          ),
        ),
        Expanded(
          child: Center(
            child: currentPersonIndex == peopleCount - 1 && onFinish != null
                ? ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 12 : 16, vertical: isNarrow ? 8 : 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.celebration,
                          size: isNarrow ? 16 : 18,
                        ),
                        if (!isNarrow) ...[
                          const SizedBox(width: 6),
                          const Text(
                            'Finish',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  )
                : TextButton(
                    onPressed:
                        currentPersonIndex < peopleCount - 1 ? onNextPerson : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isNarrow ? 4 : 8, vertical: isNarrow ? 6 : 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isNarrow) ...[
                          Text(
                            'Next',
                            style: TextStyle(
                              color: currentPersonIndex < peopleCount - 1
                                  ? buttonGhostText
                                  : disabledColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          Icons.chevron_right,
                          size: isNarrow ? 14 : 16,
                          color: currentPersonIndex < peopleCount - 1
                              ? buttonGhostText
                              : disabledColor,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDotNavigation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    final dots = List.generate(peopleCount, (index) {
      final isActive = index == currentPersonIndex;
      final theme = Theme.of(context);
      final activeDotColor = theme.colorScheme.primary;
      final inactiveDotColor = theme.colorScheme.outline;

      return GestureDetector(
        onTap: () => onPersonSelected(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isNarrow ? 1 : 2),
          width: isNarrow ? 10 : 12,
          height: isNarrow ? 10 : 12,
          decoration: BoxDecoration(
            color: isActive ? activeDotColor : inactiveDotColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    });

    // If there are many dots and screen is narrow, make it scrollable
    if (isNarrow && peopleCount > 8) {
      return SizedBox(
        height: isNarrow ? 10 : 12,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: dots,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: dots,
    );
  }
}
