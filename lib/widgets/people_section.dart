import 'package:flutter/material.dart';
import 'add_person_widget.dart';

class PeopleSection extends StatelessWidget {
  final List<String> people;
  final int currentPersonIndex;
  final bool showAddPerson;
  final bool hasValidClipboardContent;
  final TextEditingController nameController;
  final VoidCallback onAddPerson;
  final Function(int) onRemovePerson;
  final VoidCallback onToggleAddPerson;
  final VoidCallback onCancelAddPerson;
  final VoidCallback onPasteParticipantList;

  const PeopleSection({
    super.key,
    required this.people,
    required this.currentPersonIndex,
    required this.showAddPerson,
    required this.hasValidClipboardContent,
    required this.nameController,
    required this.onAddPerson,
    required this.onRemovePerson,
    required this.onToggleAddPerson,
    required this.onCancelAddPerson,
    required this.onPasteParticipantList,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(context, textPrimary, textSecondary, borderColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (showAddPerson)
                    AddPersonWidget(
                      nameController: nameController,
                      onAddPerson: onAddPerson,
                      onCancel: onCancelAddPerson,
                    ),
                  Expanded(
                    child: people.isEmpty
                        ? _buildEmptyState(context)
                        : _buildPeopleList(context, textPrimary, textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textPrimary, Color textSecondary, Color borderColor) {
    final theme = Theme.of(context);
    
    return Container(
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
          Row(
            children: [
              IconButton(
                onPressed: hasValidClipboardContent ? onPasteParticipantList : null,
                style: IconButton.styleFrom(
                  backgroundColor: hasValidClipboardContent 
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(6),
                ),
                icon: Icon(
                  Icons.content_paste,
                  color: hasValidClipboardContent 
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.outline,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onToggleAddPerson,
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
        ],
      ),
    );
  }

  Widget _buildPeopleList(BuildContext context, Color textPrimary, Color textSecondary) {
    final theme = Theme.of(context);
    
    return ListView.separated(
      itemCount: people.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final isActive = index == currentPersonIndex;
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
                  people[index],
                  style: TextStyle(
                    color: itemText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onRemovePerson(index),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'Click + to add members or paste a participant list',
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}