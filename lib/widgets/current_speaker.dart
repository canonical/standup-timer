import 'package:flutter/material.dart';

class CurrentSpeaker extends StatelessWidget {
  final int currentPersonIndex;
  final List<String> people;
  final bool showTeamMembersHeader;

  const CurrentSpeaker({
    super.key,
    required this.currentPersonIndex,
    required this.people,
    this.showTeamMembersHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 12.0 : 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              people.isNotEmpty
                  ? people[currentPersonIndex]
                  : 'Please add participants',
              style: TextStyle(
                fontSize: isNarrow ? 24 : 32,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: isNarrow ? 3 : 1,
            ),
          ),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(
            (isNarrow && showTeamMembersHeader)
                ? 'Team Members'
                : (people.isNotEmpty
                    ? 'Person ${currentPersonIndex + 1} of ${people.length}'
                    : ''),
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
