import 'package:flutter/material.dart';

class NavigationControls extends StatelessWidget {
  final int currentPersonIndex;
  final int peopleCount;
  final VoidCallback onPreviousPerson;
  final VoidCallback onNextPerson;
  final Function(int) onPersonSelected;

  const NavigationControls({
    super.key,
    required this.currentPersonIndex,
    required this.peopleCount,
    required this.onPreviousPerson,
    required this.onNextPerson,
    required this.onPersonSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonGhostText = theme.colorScheme.onSurfaceVariant;
    final disabledColor = theme.colorScheme.outline;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: currentPersonIndex > 0 ? onPreviousPerson : null,
          icon: Icon(
            Icons.chevron_left,
            size: 16,
            color: currentPersonIndex > 0 ? buttonGhostText : disabledColor,
          ),
          label: Text(
            'Previous',
            style: TextStyle(
              color: currentPersonIndex > 0 ? buttonGhostText : disabledColor,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        _buildDotNavigation(context),
        TextButton(
          onPressed:
              currentPersonIndex < peopleCount - 1 ? onNextPerson : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Icon(
                Icons.chevron_right,
                size: 16,
                color: currentPersonIndex < peopleCount - 1
                    ? buttonGhostText
                    : disabledColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDotNavigation(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(peopleCount, (index) {
        final isActive = index == currentPersonIndex;
        final theme = Theme.of(context);
        final activeDotColor = theme.colorScheme.primary;
        final inactiveDotColor = theme.colorScheme.outline;

        return GestureDetector(
          onTap: () => onPersonSelected(index),
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
}