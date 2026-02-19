import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ci_provider.dart';
import '../services/config_service.dart';

class WorkflowsState {
  final List<CiRun> runs;
  final bool isLoading;
  final String? configError;
  final DateTime? lastFetched;

  const WorkflowsState({
    this.runs = const [],
    this.isLoading = false,
    this.configError,
    this.lastFetched,
  });

  WorkflowsState copyWith({
    List<CiRun>? runs,
    bool? isLoading,
    String? configError,
    DateTime? lastFetched,
  }) {
    return WorkflowsState(
      runs: runs ?? this.runs,
      isLoading: isLoading ?? this.isLoading,
      configError: configError ?? this.configError,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }
}

class WorkflowsNotifier extends Notifier<WorkflowsState> {
  Timer? _refreshTimer;
  List<CiProvider>? _providers;

  @override
  WorkflowsState build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    // Schedule _init after build() returns so that `state` is initialized
    // before refresh() tries to read it.
    Future.microtask(_init);
    return const WorkflowsState(isLoading: true);
  }

  void _init() {
    try {
      _providers = ConfigService.loadProviders();
    } catch (e) {
      state = WorkflowsState(configError: 'Failed to parse config: $e');
      return;
    }

    if (_providers == null) {
      state = const WorkflowsState(
        configError: 'Create workflows.yaml to monitor CI workflows.',
      );
      return;
    }

    if (_providers!.isEmpty) {
      state = const WorkflowsState(
        configError: 'No workflows listed in workflows.yaml.',
      );
      return;
    }

    refresh();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 60), (_) => refresh());
  }

  Future<void> refresh() async {
    if (_providers == null) return;
    state = state.copyWith(isLoading: true);

    final runs = await Future.wait(
      _providers!.map((p) => p.fetchLatestRun()),
    );

    state = state.copyWith(
      runs: runs,
      isLoading: false,
      lastFetched: DateTime.now(),
    );
  }
}

final workflowsProvider =
    NotifierProvider<WorkflowsNotifier, WorkflowsState>(WorkflowsNotifier.new);
