import 'package:flutter/material.dart';

class CelebrationScreen extends StatelessWidget {
  final List<String> people;
  final VoidCallback onResetTimer;

  const CelebrationScreen({
    super.key,
    required this.people,
    required this.onResetTimer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.celebration,
          size: isNarrow ? 64 : 80,
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: isNarrow ? 16 : 24),
        Text(
          'Standup Complete!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isNarrow ? 8 : 12),
        Text(
          'Great job everyone! 🎉',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isNarrow ? 16 : 24),
        Container(
          padding: EdgeInsets.all(isNarrow ? 12 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Participants (${people.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: people.map((name) => Chip(
                  label: Text(
                    name,
                    style: TextStyle(
                      fontSize: isNarrow ? 12 : 14,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: isNarrow ? 24 : 32),
        ElevatedButton.icon(
          onPressed: onResetTimer,
          icon: const Icon(Icons.refresh),
          label: const Text('Start New Session'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 16 : 24,
              vertical: isNarrow ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }
}