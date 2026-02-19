import 'dart:developer' as dev;
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'ci_provider.dart';
import 'github_provider.dart';
import 'jenkins_provider.dart';

/// Reads ~/.config/standup-timer/workflows.yaml and returns one [CiProvider]
/// per configured workflow entry.
///
/// Returns null if the config file does not exist.
/// Throws if the file exists but cannot be parsed.
///
/// Example config:
///
/// ```yaml
/// workflows:
///   - label: "Checkbox Daily Builds"
///     provider: github
///     owner: canonical
///     repo: checkbox
///     workflow: checkbox-daily-native-builds.yaml
///     token: ghp_xxxx         # optional; required for private repos
///
///   - label: "My Jenkins job"
///     provider: jenkins
///     url: https://jenkins.example.com/job/my-job
///     username: admin          # optional
///     token: abc123            # Jenkins API token
/// ```
class ConfigService {
  static String get configPath {
    // When running as a Snap, HOME points to the snap's private directory.
    // SNAP_REAL_HOME contains the actual user home directory.
    final home =
        Platform.environment['SNAP_REAL_HOME'] ??
        Platform.environment['HOME'] ??
        '';
    return '$home/.config/standup-timer/workflows.yaml';
  }

  static List<CiProvider>? loadProviders() {
    final file = File(configPath);
    if (!file.existsSync()) return null;

    final doc = loadYaml(file.readAsStringSync());
    final rawList = doc['workflows'] as YamlList? ?? YamlList.wrap([]);

    // Top-level token acts as a default for all GitHub entries that don't
    // specify their own token.
    final defaultGitHubToken = doc['github_token'] as String?;
    dev.log('[config] github_token present: ${defaultGitHubToken != null}', name: 'ci');
    dev.log('[config] loaded ${rawList.length} workflow(s)', name: 'ci');

    return rawList.map<CiProvider>((entry) {
      final provider = entry['provider'] as String? ?? 'github';
      final label = entry['label'] as String?;

      return switch (provider) {
        'github' => () {
            // Validate required GitHub fields.
            final owner = entry['owner'];
            if (owner is! String || owner.isEmpty) {
              throw FormatException(
                'GitHub workflow "${label ?? '<no label>'}" is missing required "owner" field in config.',
              );
            }
            final repo = entry['repo'];
            if (repo is! String || repo.isEmpty) {
              throw FormatException(
                'GitHub workflow "${label ?? '<no label>'}" is missing required "repo" field in config.',
              );
            }
            final workflow = entry['workflow'];
            if (workflow is! String || workflow.isEmpty) {
              throw FormatException(
                'GitHub workflow "${label ?? '$owner/$repo'}" is missing required "workflow" field in config.',
              );
            }

            final tok = (entry['token'] as String?) ?? defaultGitHubToken;
            final effectiveLabel = label ?? '$owner/$repo';
            dev.log(
              '[config] github entry "$effectiveLabel" token: ${tok != null ? "set" : "NOT SET"}',
              name: 'ci',
            );
            return GitHubProvider(
              label: effectiveLabel,
              owner: owner,
              repo: repo,
              workflow: workflow,
              // Per-entry token takes priority over the top-level default.
              token: tok,
            );
          }(),
        'jenkins' => () {
            // Validate required Jenkins fields.
            final url = entry['url'];
            if (url is! String || url.isEmpty) {
              throw FormatException(
                'Jenkins workflow "${label ?? '<no label>'}" is missing required "url" field in config.',
              );
            }
            final effectiveLabel = label ?? url;
            return JenkinsProvider(
              label: effectiveLabel,
              jobUrl: url,
              username: entry['username'] as String?,
              token: entry['token'] as String?,
            );
          }(),
        _ => throw FormatException('Unknown provider "$provider"'),
      };
    }).toList();
  }
}
