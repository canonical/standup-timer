/// A provider-agnostic model for a single CI job's latest run result.
class CiRun {
  final String label;
  final String status; // 'success' | 'failure' | 'in_progress' | 'queued' |
  //                      'cancelled' | 'skipped' | 'timed_out' |
  //                      'action_required' | 'unknown' | 'error'
  final String? branch;
  final DateTime? updatedAt;
  final String? runUrl;
  final String? fetchError;

  const CiRun({
    required this.label,
    required this.status,
    this.branch,
    this.updatedAt,
    this.runUrl,
    this.fetchError,
  });
}

/// Base class for any CI/CD provider.
/// Each configured workflow entry is backed by one [CiProvider] instance.
abstract class CiProvider {
  String get label;
  Future<CiRun> fetchLatestRun();
}
