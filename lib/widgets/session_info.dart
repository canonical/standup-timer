import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class SessionInfo extends ConsumerStatefulWidget {
  final List<String> people;

  const SessionInfo({
    super.key,
    required this.people,
  });

  @override
  ConsumerState<SessionInfo> createState() => _SessionInfoState();
}

class _SessionInfoState extends ConsumerState<SessionInfo> {
  bool _isExpanded = false;
  final List<int> _durationOptions = [30, 60, 90, 120, 180, 300, 600];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final timerState = ref.watch(timerProvider);
    final durationMinutes = (timerState.duration / 60).round();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: textSecondary,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Total members:', '${widget.people.length}', textSecondary, textPrimary),
          const SizedBox(height: 8),
          _buildInfoRow('Expected duration:', '${widget.people.length * durationMinutes} min', textSecondary, textPrimary),
          const SizedBox(height: 8),
          _buildInfoRow('Time per person:', '${timerState.duration}s', textSecondary, textPrimary),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Divider(color: borderColor),
            const SizedBox(height: 12),
            Text(
              'Timer Configuration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durationOptions.map((seconds) {
                final isSelected = seconds == timerState.duration;
                return GestureDetector(
                  onTap: () => ref.read(timerProvider.notifier).setDuration(seconds),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '${seconds}s',
                      style: TextStyle(
                        color: isSelected 
                            ? theme.colorScheme.onPrimaryContainer
                            : textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}