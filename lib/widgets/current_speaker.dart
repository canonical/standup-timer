import 'package:flutter/material.dart';

class CurrentSpeaker extends StatelessWidget {
  final int currentPersonIndex;
  final List<String> people;

  const CurrentSpeaker({
    super.key,
    required this.currentPersonIndex,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final accentBg = theme.colorScheme.primaryContainer;
    final accentText = theme.colorScheme.onPrimaryContainer;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 16.0 : 32.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 8 : 12, 
              vertical: 4
            ),
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
                  width: isNarrow ? 6 : 8,
                  height: isNarrow ? 6 : 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: isNarrow ? 6 : 8),
                Text(
                  people.isNotEmpty ? 'Currently Speaking' : '',
                  style: TextStyle(
                    color: accentText,
                    fontSize: isNarrow ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isNarrow ? 12 : 16),
          Text(
            people.isNotEmpty
                ? people[currentPersonIndex]
                : 'Please add participants',
            style: TextStyle(
              fontSize: isNarrow ? 24 : 32,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(
            people.isNotEmpty
                ? 'Person ${currentPersonIndex + 1} of ${people.length}'
                : '',
            style: TextStyle(
              color: textSecondary,
              fontSize: isNarrow ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
