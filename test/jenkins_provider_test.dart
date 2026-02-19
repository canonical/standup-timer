import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:standup/services/jenkins_provider.dart';

http.Response _json(Object body, {int status = 200}) =>
    http.Response(json.encode(body), status,
        headers: {'content-type': 'application/json'});

Map<String, dynamic> _build({
  bool building = false,
  String? result = 'SUCCESS',
  int? timestamp = 1705312800000, // 2024-01-15T10:00:00Z in ms
  String? url = 'https://jenkins.example.com/job/my-job/42/',
}) =>
    {
      'building': building,
      'result': result,
      'timestamp': timestamp,
      'url': url,
    };

JenkinsProvider _provider({
  String jobUrl = 'https://jenkins.example.com/job/my-job',
  String? username,
  String? token,
  required http.Client client,
}) =>
    JenkinsProvider(
      label: 'Test Job',
      jobUrl: jobUrl,
      username: username,
      token: token,
      client: client,
    );

void main() {
  group('JenkinsProvider.fetchLatestRun', () {
    group('status mapping', () {
      test('SUCCESS → success', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(result: 'SUCCESS'))),
        );
        expect((await p.fetchLatestRun()).status, 'success');
      });

      test('FAILURE → failure', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(result: 'FAILURE'))),
        );
        expect((await p.fetchLatestRun()).status, 'failure');
      });

      test('ABORTED → cancelled', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(result: 'ABORTED'))),
        );
        expect((await p.fetchLatestRun()).status, 'cancelled');
      });

      test('UNSTABLE → failure', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(result: 'UNSTABLE'))),
        );
        expect((await p.fetchLatestRun()).status, 'failure');
      });

      test('null result → unknown', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(result: null))),
        );
        expect((await p.fetchLatestRun()).status, 'unknown');
      });

      test('building: true → in_progress regardless of result', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(building: true, result: 'SUCCESS'))),
        );
        expect((await p.fetchLatestRun()).status, 'in_progress');
      });
    });

    group('field parsing', () {
      test('populates label, updatedAt, runUrl', () async {
        final p = _provider(
          client: MockClient((_) async => _json(_build(
                timestamp: 1705312800000,
                url: 'https://jenkins.example.com/job/my-job/42/',
              ))),
        );
        final run = await p.fetchLatestRun();
        expect(run.label, 'Test Job');
        expect(run.updatedAt,
            DateTime.fromMillisecondsSinceEpoch(1705312800000));
        expect(run.runUrl, 'https://jenkins.example.com/job/my-job/42/');
      });

      test('null timestamp leaves updatedAt null', () async {
        final p = _provider(
          client: MockClient(
              (_) async => _json(_build(timestamp: null))),
        );
        expect((await p.fetchLatestRun()).updatedAt, isNull);
      });

      test('branch is always null (Jenkins has no branch concept here)', () async {
        final p = _provider(
          client: MockClient((_) async => _json(_build())),
        );
        expect((await p.fetchLatestRun()).branch, isNull);
      });
    });

    group('HTTP errors', () {
      test('HTTP 500 → status error with fetchError', () async {
        final p = _provider(
          client: MockClient(
              (_) async => http.Response('Server Error', 500)),
        );
        final run = await p.fetchLatestRun();
        expect(run.status, 'error');
        expect(run.fetchError, contains('500'));
      });

      test('HTTP 403 → status error', () async {
        final p = _provider(
          client: MockClient((_) async => http.Response('Forbidden', 403)),
        );
        expect((await p.fetchLatestRun()).status, 'error');
      });

      test('network exception → status error with message', () async {
        final p = _provider(
          client: MockClient((_) async => throw Exception('connection refused')),
        );
        final run = await p.fetchLatestRun();
        expect(run.status, 'error');
        expect(run.fetchError, contains('connection refused'));
      });
    });

    group('URL construction', () {
      test('appends /lastBuild/api/json to the job URL', () async {
        Uri? requestedUrl;
        final p = _provider(
          client: MockClient((req) async {
            requestedUrl = req.url;
            return _json(_build());
          }),
        );
        await p.fetchLatestRun();
        expect(requestedUrl.toString(),
            'https://jenkins.example.com/job/my-job/lastBuild/api/json');
      });

      test('strips trailing slash before appending path', () async {
        Uri? requestedUrl;
        final p = _provider(
          jobUrl: 'https://jenkins.example.com/job/my-job/',
          client: MockClient((req) async {
            requestedUrl = req.url;
            return _json(_build());
          }),
        );
        await p.fetchLatestRun();
        expect(requestedUrl.toString(),
            'https://jenkins.example.com/job/my-job/lastBuild/api/json');
      });
    });

    group('authentication', () {
      test('adds Basic auth header when username and token are set', () async {
        http.Request? captured;
        final p = _provider(
          username: 'admin',
          token: 'abc123',
          client: MockClient((req) async {
            captured = req;
            return _json(_build());
          }),
        );
        await p.fetchLatestRun();
        final expected =
            'Basic ${base64Encode(utf8.encode('admin:abc123'))}';
        expect(captured!.headers['Authorization'], expected);
      });

      test('omits Authorization header when credentials are absent', () async {
        http.Request? captured;
        final p = _provider(
          client: MockClient((req) async {
            captured = req;
            return _json(_build());
          }),
        );
        await p.fetchLatestRun();
        expect(captured!.headers.containsKey('Authorization'), isFalse);
      });

      test('omits Authorization header when only username is set', () async {
        http.Request? captured;
        final p = _provider(
          username: 'admin',
          client: MockClient((req) async {
            captured = req;
            return _json(_build());
          }),
        );
        await p.fetchLatestRun();
        expect(captured!.headers.containsKey('Authorization'), isFalse);
      });
    });
  });
}
