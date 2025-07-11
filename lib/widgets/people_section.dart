import 'package:flutter/material.dart';
import 'add_person_widget.dart';

class PeopleSection extends StatefulWidget {
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
  final VoidCallback onClearAllParticipants;
  final VoidCallback onShuffleParticipants;
  final Function(int)? onPersonSelected;

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
    required this.onClearAllParticipants,
    required this.onShuffleParticipants,
    this.onPersonSelected,
  });

  @override
  State<PeopleSection> createState() => _PeopleSectionState();
}

class _PeopleSectionState extends State<PeopleSection> {

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
                  if (widget.showAddPerson)
                    AddPersonWidget(
                      nameController: widget.nameController,
                      onAddPerson: widget.onAddPerson,
                      onCancel: widget.onCancelAddPerson,
                    ),
                  Expanded(
                    child: widget.people.isEmpty
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
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  size: 20,
                  color: textSecondary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear') {
                    widget.onClearAllParticipants();
                  } else if (value == 'shuffle') {
                    widget.onShuffleParticipants();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    enabled: widget.people.isNotEmpty,
                    child: Row(
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: 16,
                          color: widget.people.isNotEmpty 
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Clear all',
                          style: TextStyle(
                            color: widget.people.isNotEmpty 
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'shuffle',
                    enabled: widget.people.length > 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.shuffle,
                          size: 16,
                          color: widget.people.length > 1 
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Shuffle order',
                          style: TextStyle(
                            color: widget.people.length > 1 
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: textSecondary,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(6),
                ),
                tooltip: 'Team options',
              ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: widget.hasValidClipboardContent ? widget.onPasteParticipantList : null,
                style: IconButton.styleFrom(
                  backgroundColor: widget.hasValidClipboardContent 
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(6),
                ),
                icon: Icon(
                  Icons.content_paste,
                  color: widget.hasValidClipboardContent 
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.outline,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onToggleAddPerson,
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
    
    return ListView.builder(
      itemCount: widget.people.length,
      itemBuilder: (context, index) {
        final isSelected = index == widget.currentPersonIndex;
        final itemBg = isSelected
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer;
        final itemBorder = isSelected
            ? theme.colorScheme.primary
            : Colors.transparent;
        final itemText = isSelected
            ? textPrimary
            : theme.colorScheme.onPrimaryContainer;
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: itemBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onPersonSelected != null ? () => widget.onPersonSelected!(index) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      widget.people[index],
                      style: TextStyle(
                        color: itemText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => widget.onRemovePerson(index),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(2),
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