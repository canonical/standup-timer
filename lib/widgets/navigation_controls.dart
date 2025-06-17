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

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isNarrow ? 32 : 40,
        maxHeight: isNarrow ? 48 : 60,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: TextButton(
                  onPressed: currentPersonIndex > 0 ? onPreviousPerson : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 6 : 8, vertical: isNarrow ? 4 : 6),
                    minimumSize: Size(isNarrow ? 80 : 100, isNarrow ? 32 : 36),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        size: isNarrow ? 16 : 18,
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
                            fontSize: 13,
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
                              horizontal: isNarrow ? 12 : 16, vertical: isNarrow ? 6 : 8),
                          minimumSize: Size(isNarrow ? 80 : 100, isNarrow ? 32 : 36),
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
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                              horizontal: isNarrow ? 6 : 8, vertical: isNarrow ? 4 : 6),
                          minimumSize: Size(isNarrow ? 80 : 100, isNarrow ? 32 : 36),
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
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              Icons.chevron_right,
                              size: isNarrow ? 16 : 18,
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
        ),
      ),
    );
  }

  Widget _buildDotNavigation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;
    final isVeryNarrow = screenWidth < 500;

    // Scale dots based on window size
    final dotSize = isVeryNarrow ? 8.0 : (isNarrow ? 10.0 : 12.0);
    final dotMargin = isVeryNarrow ? 1.0 : (isNarrow ? 1.5 : 2.0);

    final dots = List.generate(peopleCount, (index) {
      final isActive = index == currentPersonIndex;
      final theme = Theme.of(context);
      final activeDotColor = theme.colorScheme.primary;
      final inactiveDotColor = theme.colorScheme.outline;

      return GestureDetector(
        onTap: () => onPersonSelected(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: dotMargin),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? activeDotColor : inactiveDotColor,
            shape: BoxShape.circle,
          ),
        ),
      );
    });

    // Calculate available width and make scrollable if dots won't fit
    final totalDotsWidth = (dotSize + dotMargin * 2) * peopleCount;
    final availableWidth = MediaQuery.of(context).size.width / 3; // roughly 1/3 for center section
    
    if (totalDotsWidth > availableWidth || peopleCount > 6) {
      return SizedBox(
        height: dotSize,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: dots,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: dotSize,
        maxHeight: dotSize,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: dots,
        ),
      ),
    );
  }
}
