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
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: currentPersonIndex > 0 ? onPreviousPerson : null,
          icon: Icon(
            Icons.chevron_left,
            size: isNarrow ? 14 : 16,
            color: currentPersonIndex > 0 ? buttonGhostText : disabledColor,
          ),
          label: Text(
            'Previous',
            style: TextStyle(
              color: currentPersonIndex > 0 ? buttonGhostText : disabledColor,
              fontSize: isNarrow ? 12 : 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 8 : 16, 
              vertical: isNarrow ? 6 : 8
            ),
          ),
        ),
        _buildDotNavigation(context),
        TextButton(
          onPressed:
              currentPersonIndex < peopleCount - 1 ? onNextPerson : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 8 : 16, 
              vertical: isNarrow ? 6 : 8
            ),
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
                  fontSize: isNarrow ? 12 : 14,
                ),
              ),
              SizedBox(width: isNarrow ? 2 : 4),
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
      ],
    );
  }

  Widget _buildDotNavigation(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;
    
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
            margin: EdgeInsets.symmetric(horizontal: isNarrow ? 1 : 2),
            width: isNarrow ? 10 : 12,
            height: isNarrow ? 10 : 12,
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