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
            final tok = (entry['token'] as String?) ?? defaultGitHubToken;
            dev.log('[config] github entry "${label ?? entry['owner']}/${entry['repo']}" token: ${tok != null ? "set" : "NOT SET"}', name: 'ci');
            return GitHubProvider(
              label: label ?? '${entry['owner']}/${entry['repo']}',
              owner: entry['owner'] as String,
              repo: entry['repo'] as String,
              workflow: entry['workflow'] as String,
              // Per-entry token takes priority over the top-level default.
              token: tok,
            );
          }(),
        'jenkins' => JenkinsProvider(
            label: label ?? (entry['url'] as String),
            jobUrl: entry['url'] as String,
            username: entry['username'] as String?,
            token: entry['token'] as String?,
          ),
        _ => throw FormatException('Unknown provider "$provider"'),
      };
    }).toList();
  }
}
