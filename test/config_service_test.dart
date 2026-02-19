import 'package:flutter_test/flutter_test.dart';
import 'package:standup/services/config_service.dart';
import 'package:standup/services/github_provider.dart';
import 'package:standup/services/jenkins_provider.dart';

void main() {
  group('ConfigService.parseProviders', () {
    group('GitHub entries', () {
      test('parses a minimal GitHub entry', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - label: "Daily Builds"
    provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
''');
        expect(providers, hasLength(1));
        final p = providers[0] as GitHubProvider;
        expect(p.label, 'Daily Builds');
        expect(p.owner, 'canonical');
        expect(p.repo, 'checkbox');
        expect(p.workflow, 'daily.yaml');
        expect(p.token, isNull);
      });

      test('label defaults to owner/repo when omitted', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
''');
        expect(providers[0].label, 'canonical/checkbox');
      });

      test('per-entry token is used when present', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
    token: ghp_entry
''');
        expect((providers[0] as GitHubProvider).token, 'ghp_entry');
      });

      test('top-level github_token is applied when no per-entry token', () {
        final providers = ConfigService.parseProviders('''
github_token: ghp_default

workflows:
  - provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
''');
        expect((providers[0] as GitHubProvider).token, 'ghp_default');
      });

      test('per-entry token overrides top-level github_token', () {
        final providers = ConfigService.parseProviders('''
github_token: ghp_default

workflows:
  - provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
    token: ghp_override
''');
        expect((providers[0] as GitHubProvider).token, 'ghp_override');
      });

      test('throws FormatException when owner is missing', () {
        expect(
          () => ConfigService.parseProviders('''
workflows:
  - label: "Bad"
    provider: github
    repo: checkbox
    workflow: daily.yaml
'''),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('owner'),
          )),
        );
      });

      test('throws FormatException when repo is missing', () {
        expect(
          () => ConfigService.parseProviders('''
workflows:
  - provider: github
    owner: canonical
    workflow: daily.yaml
'''),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('repo'),
          )),
        );
      });

      test('throws FormatException when workflow is missing', () {
        expect(
          () => ConfigService.parseProviders('''
workflows:
  - provider: github
    owner: canonical
    repo: checkbox
'''),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('workflow'),
          )),
        );
      });
    });

    group('Jenkins entries', () {
      test('parses a minimal Jenkins entry', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - label: "Jenkins Job"
    provider: jenkins
    url: https://jenkins.example.com/job/my-job
''');
        expect(providers, hasLength(1));
        final p = providers[0] as JenkinsProvider;
        expect(p.label, 'Jenkins Job');
        expect(p.jobUrl, 'https://jenkins.example.com/job/my-job');
        expect(p.username, isNull);
        expect(p.token, isNull);
      });

      test('label defaults to url when omitted', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - provider: jenkins
    url: https://jenkins.example.com/job/my-job
''');
        expect(providers[0].label, 'https://jenkins.example.com/job/my-job');
      });

      test('parses Jenkins entry with credentials', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - provider: jenkins
    label: "Secure Job"
    url: https://jenkins.example.com/job/secure
    username: admin
    token: abc123
''');
        final p = providers[0] as JenkinsProvider;
        expect(p.username, 'admin');
        expect(p.token, 'abc123');
      });

      test('throws FormatException when url is missing', () {
        expect(
          () => ConfigService.parseProviders('''
workflows:
  - label: "Bad Jenkins"
    provider: jenkins
'''),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('url'),
          )),
        );
      });
    });

    group('mixed and edge cases', () {
      test('parses multiple entries of different providers', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - label: "GH"
    provider: github
    owner: canonical
    repo: checkbox
    workflow: daily.yaml
  - label: "Jenkins"
    provider: jenkins
    url: https://jenkins.example.com/job/x
''');
        expect(providers, hasLength(2));
        expect(providers[0], isA<GitHubProvider>());
        expect(providers[1], isA<JenkinsProvider>());
      });

      test('returns empty list when workflows key is absent', () {
        final providers = ConfigService.parseProviders('github_token: ghp_x\n');
        expect(providers, isEmpty);
      });

      test('returns empty list for empty workflows list', () {
        final providers = ConfigService.parseProviders('workflows:\n');
        expect(providers, isEmpty);
      });

      test('provider defaults to github when key is omitted', () {
        final providers = ConfigService.parseProviders('''
workflows:
  - owner: canonical
    repo: checkbox
    workflow: daily.yaml
''');
        expect(providers[0], isA<GitHubProvider>());
      });

      test('throws FormatException for unknown provider', () {
        expect(
          () => ConfigService.parseProviders('''
workflows:
  - provider: circleci
    label: "Bad"
'''),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('circleci'),
          )),
        );
      });
    });
  });
}
