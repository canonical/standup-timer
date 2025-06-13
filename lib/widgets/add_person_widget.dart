import 'package:flutter/material.dart';

class AddPersonWidget extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onAddPerson;
  final VoidCallback onCancel;

  const AddPersonWidget({
    super.key,
    required this.nameController,
    required this.onAddPerson,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
            controller: nameController,
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
            onSubmitted: (_) => onAddPerson(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: onAddPerson,
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
                onPressed: onCancel,
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
}