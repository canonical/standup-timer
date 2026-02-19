import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ci_provider.dart';

/// Fetches the latest build status for a Jenkins job.
///
/// Config keys (from workflows.yaml):
///   provider: jenkins
///   label:    "My Jenkins job"    # display name
///   url:      https://jenkins.example.com/job/my-job
///   username: admin               # optional; for authenticated Jenkins
///   token:    abc123              # Jenkins API token
class JenkinsProvider implements CiProvider {
  @override
  final String label;
  final String jobUrl;
  final String? username;
  final String? token;
  final http.Client _client;

  JenkinsProvider({
    required this.label,
    required this.jobUrl,
    this.username,
    this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<CiRun> fetchLatestRun() async {
    // Strip trailing slash so we can append /lastBuild/api/json cleanly.
    final base = jobUrl.endsWith('/') ? jobUrl.substring(0, jobUrl.length - 1) : jobUrl;
    final url = '$base/lastBuild/api/json';

    final headers = <String, String>{};
    if (username != null && token != null) {
      final credentials = base64Encode(utf8.encode('$username:$token'));
      headers['Authorization'] = 'Basic $credentials';
    }

    try {
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return CiRun(
          label: label,
          status: 'error',
          fetchError: 'HTTP ${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      final building = data['building'] as bool? ?? false;
      final result = data['result'] as String?; // 'SUCCESS' | 'FAILURE' | 'ABORTED' | 'UNSTABLE' | null

      final String status;
      if (building) {
        status = 'in_progress';
      } else {
        status = switch (result) {
          'SUCCESS' => 'success',
          'FAILURE' => 'failure',
          'ABORTED' => 'cancelled',
          'UNSTABLE' => 'failure', // treat unstable as failure for visibility
          _ => 'unknown',
        };
      }

      DateTime? updatedAt;
      final timestamp = data['timestamp'] as int?;
      if (timestamp != null) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }

      // Jenkins returns the full URL to the build in the 'url' field.
      final runUrl = data['url'] as String?;

      return CiRun(
        label: label,
        status: status,
        updatedAt: updatedAt,
        runUrl: runUrl,
      );
    } catch (e) {
      return CiRun(label: label, status: 'error', fetchError: e.toString());
    }
  }
}
