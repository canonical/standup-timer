import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:standup/services/github_provider.dart';

http.Response _json(Object body, {int status = 200}) =>
    http.Response(json.encode(body), status,
        headers: {'content-type': 'application/json'});

Map<String, dynamic> _run({
  String status = 'completed',
  String? conclusion = 'success',
  String branch = 'main',
  String updatedAt = '2024-01-15T10:00:00Z',
  String htmlUrl = 'https://github.com/canonical/checkbox/actions/runs/1',
}) =>
    {
      'status': status,
      'conclusion': conclusion,
      'head_branch': branch,
      'updated_at': updatedAt,
      'html_url': htmlUrl,
    };

GitHubProvider _provider({String? token, required http.Client client}) =>
    GitHubProvider(
      label: 'Test Workflow',
      owner: 'canonical',
      repo: 'checkbox',
      workflow: 'daily.yaml',
      token: token,
      client: client,
    );

void main() {
  group('GitHubProvider.fetchLatestRun', () {
    group('status mapping', () {
      test('completed/success → success', () async {
        final p = _provider(
          client: MockClient((_) async =>
              _json({'workflow_runs': [_run(conclusion: 'success')]})),
        );
        final run = await p.fetchLatestRun();
        expect(run.status, 'success');
      });

      test('completed/failure → failure', () async {
        final p = _provider(
          client: MockClient((_) async =>
              _json({'workflow_runs': [_run(conclusion: 'failure')]})),
        );
        expect((await p.fetchLatestRun()).status, 'failure');
      });

      test('completed/cancelled → cancelled', () async {
        final p = _provider(
          client: MockClient((_) async =>
              _json({'workflow_runs': [_run(conclusion: 'cancelled')]})),
        );
        expect((await p.fetchLatestRun()).status, 'cancelled');
      });

      test('in_progress (not completed) → in_progress', () async {
        final p = _provider(
          client: MockClient((_) async => _json({
                'workflow_runs': [
                  _run(status: 'in_progress', conclusion: null)
                ]
              })),
        );
        expect((await p.fetchLatestRun()).status, 'in_progress');
      });

      test('queued → queued', () async {
        final p = _provider(
          client: MockClient((_) async => _json({
                'workflow_runs': [_run(status: 'queued', conclusion: null)]
              })),
        );
        expect((await p.fetchLatestRun()).status, 'queued');
      });

      test('empty runs list → unknown', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json({'workflow_runs': <dynamic>[]})),
        );
        expect((await p.fetchLatestRun()).status, 'unknown');
      });
    });

    group('field parsing', () {
      test('populates label, branch, updatedAt, runUrl', () async {
        final p = _provider(
          client: MockClient((_) async => _json({
                'workflow_runs': [
                  _run(
                    branch: 'release/1.0',
                    updatedAt: '2024-03-20T12:34:56Z',
                    htmlUrl: 'https://github.com/runs/42',
                  )
                ]
              })),
        );
        final run = await p.fetchLatestRun();
        expect(run.label, 'Test Workflow');
        expect(run.branch, 'release/1.0');
        expect(run.updatedAt, DateTime.parse('2024-03-20T12:34:56Z'));
        expect(run.runUrl, 'https://github.com/runs/42');
      });

      test('null updated_at leaves updatedAt null', () async {
        final runData = _run()..['updated_at'] = null;
        // rebuild without updated_at key
        final data = Map<String, dynamic>.from(runData);
        data.remove('updated_at');
        final p = _provider(
          client: MockClient(
              (_) async => _json({'workflow_runs': [data]})),
        );
        expect((await p.fetchLatestRun()).updatedAt, isNull);
      });
    });

    group('HTTP errors', () {
      test('HTTP 401 → status error with fetchError', () async {
        final p = _provider(
          client: MockClient((_) async => http.Response('Unauthorized', 401)),
        );
        final run = await p.fetchLatestRun();
        expect(run.status, 'error');
        expect(run.fetchError, contains('401'));
      });

      test('HTTP 404 → status error', () async {
        final p = _provider(
          client: MockClient((_) async => http.Response('Not Found', 404)),
        );
        expect((await p.fetchLatestRun()).status, 'error');
      });

      test('network exception → status error with message', () async {
        final p = _provider(
          client: MockClient((_) async => throw Exception('no network')),
        );
        final run = await p.fetchLatestRun();
        expect(run.status, 'error');
        expect(run.fetchError, contains('no network'));
      });
    });

    group('authentication', () {
      test('adds Authorization header when token is set', () async {
        http.Request? captured;
        final p = _provider(
          token: 'ghp_secret',
          client: MockClient((req) async {
            captured = req;
            return _json({'workflow_runs': [_run()]});
          }),
        );
        await p.fetchLatestRun();
        expect(captured!.headers['Authorization'], 'Bearer ghp_secret');
      });

      test('omits Authorization header when token is null', () async {
        http.Request? captured;
        final p = _provider(
          client: MockClient((req) async {
            captured = req;
            return _json({'workflow_runs': [_run()]});
          }),
        );
        await p.fetchLatestRun();
        expect(captured!.headers.containsKey('Authorization'), isFalse);
      });

      test('sends correct Accept and API version headers', () async {
        http.Request? captured;
        final p = _provider(
          client: MockClient((req) async {
            captured = req;
            return _json({'workflow_runs': [_run()]});
          }),
        );
        await p.fetchLatestRun();
        expect(captured!.headers['Accept'],
            'application/vnd.github+json');
        expect(
            captured!.headers['X-GitHub-Api-Version'], '2022-11-28');
      });
    });

    group('URL construction', () {
      test('requests the correct API endpoint', () async {
        Uri? requestedUrl;
        final p = _provider(
          client: MockClient((req) async {
            requestedUrl = req.url;
            return _json({'workflow_runs': [_run()]});
          }),
        );
        await p.fetchLatestRun();
        expect(
          requestedUrl.toString(),
          'https://api.github.com/repos/canonical/checkbox'
          '/actions/workflows/daily.yaml/runs?per_page=1',
        );
      });
    });
  });
}
