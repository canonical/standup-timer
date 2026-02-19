import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'ci_provider.dart';

/// Fetches the latest run for a GitHub Actions workflow.
///
/// Config keys (from workflows.yaml):
///   provider: github
///   label:    "My workflow"         # display name (optional, defaults to owner/repo)
///   owner:    canonical
///   repo:     checkbox
///   workflow: checkbox-daily-native-builds.yaml   # filename or numeric id
///   token:    ghp_xxxx             # optional; required for private repos
class GitHubProvider implements CiProvider {
  @override
  final String label;
  final String owner;
  final String repo;
  final String workflow;
  final String? token;

  const GitHubProvider({
    required this.label,
    required this.owner,
    required this.repo,
    required this.workflow,
    this.token,
  });

  @override
  Future<CiRun> fetchLatestRun() async {
    final url =
        'https://api.github.com/repos/$owner/$repo'
        '/actions/workflows/$workflow/runs?per_page=1';

    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    dev.log('[github] GET $url', name: 'ci');
    dev.log('[github] auth: ${token != null && token!.isNotEmpty ? "present" : "none"}', name: 'ci');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      dev.log('[github] ${response.statusCode} for $label', name: 'ci');
      if (response.statusCode != 200) {
        dev.log('[github] body: ${response.body}', name: 'ci');
        return CiRun(
          label: label,
          status: 'error',
          fetchError: 'HTTP ${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final runs = data['workflow_runs'] as List?;
      if (runs == null || runs.isEmpty) {
        return CiRun(label: label, status: 'unknown');
      }

      final run = runs[0] as Map<String, dynamic>;
      final apiStatus = run['status'] as String?;
      final conclusion = run['conclusion'] as String?;

      final String status;
      if (apiStatus == 'completed') {
        status = conclusion ?? 'unknown';
      } else {
        status = apiStatus ?? 'unknown';
      }

      DateTime? updatedAt;
      final updatedAtStr = run['updated_at'] as String?;
      if (updatedAtStr != null) updatedAt = DateTime.tryParse(updatedAtStr);

      return CiRun(
        label: label,
        status: status,
        branch: run['head_branch'] as String?,
        updatedAt: updatedAt,
        runUrl: run['html_url'] as String?,
      );
    } catch (e) {
      return CiRun(label: label, status: 'error', fetchError: e.toString());
    }
  }
}
