import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isDisabled;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;

  const TimerControls({
    super.key,
    required this.isRunning,
    this.isDisabled = false,
    required this.onToggleTimer,
    required this.onResetTimer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonSecondaryBg = theme.colorScheme.secondaryContainer;
    final buttonSecondaryText = theme.colorScheme.onSecondaryContainer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRunning) ...[
          Tooltip(
            message: 'Esc',
            child: ElevatedButton(
              onPressed: onResetTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonSecondaryBg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: buttonSecondaryText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'reset_timer_controls'.tr(),
                    style: TextStyle(
                      color: buttonSecondaryText,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Tooltip(
          message: 'Shift + Spacebar',
          child: ElevatedButton(
            onPressed: isDisabled ? null : onToggleTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDisabled ? theme.disabledColor : theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRunning ? Icons.pause : Icons.play_arrow,
                  color: isDisabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning
                      ? 'pause_timer_controls'.tr()
                      : 'start_timer_timer_controls'.tr(),
                  style: TextStyle(
                    color: isDisabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}