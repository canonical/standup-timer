import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/workflows_provider.dart';
import '../services/ci_provider.dart';
import '../services/config_service.dart';
import '../widgets/timer_controls.dart';

class DashboardScreen extends ConsumerWidget {
  final bool showTimerControls;
  final bool isRunning;
  final bool isDisabled;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onResetTimer;

  const DashboardScreen({
    super.key,
    this.showTimerControls = false,
    this.isRunning = false,
    this.isDisabled = false,
    this.onToggleTimer,
    this.onResetTimer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workflowsProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        _Header(
          state: state,
          onRefresh: () => ref.read(workflowsProvider.notifier).refresh(),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(child: _Body(state: state)),
        if (showTimerControls) ...[
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TimerControls(
              isRunning: isRunning,
              isDisabled: isDisabled,
              onToggleTimer: onToggleTimer ?? () {},
              onResetTimer: onResetTimer ?? () {},
            ),
          ),
        ],
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final WorkflowsState state;
  final VoidCallback onRefresh;

  const _Header({required this.state, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text('CI Status', style: theme.textTheme.titleSmall),
          const Spacer(),
          if (state.lastFetched != null)
            Text(
              _timeAgo(state.lastFetched!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 4),
          SizedBox(
            width: 36,
            height: 36,
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    tooltip: 'Refresh',
                    onPressed: onRefresh,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final WorkflowsState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.configError != null) {
      return _EmptyState(
        icon: Icons.settings_outlined,
        message: state.configError!,
        hint: '# ${ConfigService.configPath}\n\n'
            '# github_token: ghp_xxxx  # default token for all GitHub entries\n\n'
            'workflows:\n'
            '  - label: "Checkbox Daily Builds"\n'
            '    provider: github\n'
            '    owner: canonical\n'
            '    repo: checkbox\n'
            '    workflow: checkbox-daily-native-builds.yaml\n\n'
            '  - label: "My Jenkins job"\n'
            '    provider: jenkins\n'
            '    url: https://jenkins.example.com/job/my-job\n'
            '    # username: admin\n'
            '    # token: abc123',
      );
    }

    if (state.isLoading && state.runs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: state.runs.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: theme.colorScheme.outlineVariant,
      ),
      itemBuilder: (context, i) => _RunRow(run: state.runs[i]),
    );
  }
}

// ── Empty / error state ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? hint;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (hint != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  hint!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Single row ────────────────────────────────────────────────────────────────

class _RunRow extends StatelessWidget {
  final CiRun run;

  const _RunRow({required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon, badgeLabel) = _statusStyle(run.status, theme);
    final canOpen = run.runUrl != null;

    return Tooltip(
      message: run.fetchError ?? '',
      child: InkWell(
        onTap: canOpen
            ? () => launchUrl(
                  Uri.parse(run.runUrl!),
                  mode: LaunchMode.externalApplication,
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),

              // Label + branch/repo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      run.label,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (run.fetchError != null)
                      Text(
                        run.fetchError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (run.branch != null)
                      Text(
                        run.branch!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Time ago
              if (run.updatedAt != null)
                Text(
                  _timeAgo(run.updatedAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

              const SizedBox(width: 8),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ),

              if (canOpen) ...[
                const SizedBox(width: 4),
                Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.onSurfaceVariant),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static (Color, IconData, String) _statusStyle(String status, ThemeData theme) {
    return switch (status) {
      'success'         => (const Color(0xFF2DA44E), Icons.check_circle_outline, 'success'),
      'failure'         => (const Color(0xFFCF222E), Icons.cancel_outlined, 'failure'),
      'in_progress'     => (const Color(0xFF0969DA), Icons.sync, 'running'),
      'queued'          => (const Color(0xFFBF8700), Icons.schedule, 'queued'),
      'cancelled'       => (const Color(0xFF6E7781), Icons.block, 'cancelled'),
      'skipped'         => (const Color(0xFF6E7781), Icons.skip_next, 'skipped'),
      'timed_out'       => (const Color(0xFFBC4C00), Icons.timer_off, 'timed out'),
      'action_required' => (const Color(0xFFBF8700), Icons.warning_amber, 'needs action'),
      'error'           => (const Color(0xFFCF222E), Icons.error_outline, 'error'),
      _                 => (theme.colorScheme.onSurfaceVariant, Icons.help_outline, status),
    };
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
