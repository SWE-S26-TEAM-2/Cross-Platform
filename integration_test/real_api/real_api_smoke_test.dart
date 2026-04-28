import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Real-API smoke scaffold.
///
/// Drives the live FastAPI backend over HTTP using Dio. Runs only when a
/// `BACKEND_URL` is provided via `--dart-define=BACKEND_URL=...`. When
/// unset (the default in CI today), the test reports as skipped instead
/// of failing so it can ship now and be enabled once the backend is
/// reachable from the runner.
///
/// Example:
///   flutter test integration_test/real_api/real_api_smoke_test.dart \
///     --dart-define=BACKEND_URL=http://localhost:8000/api
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');

  group('real API smoke', () {
    if (backendUrl.isEmpty) {
      testWidgets('skipped: BACKEND_URL not provided', (tester) async {
        markTestSkipped(
          'BACKEND_URL is empty. Pass '
          '--dart-define=BACKEND_URL=http://host:8000/api to enable.',
        );
      });
      return;
    }

    final dio = Dio(BaseOptions(
      baseUrl: backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ));

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'flutter_e2e_$timestamp@example.com';
    final username = 'flutter_e2e_$timestamp'
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .substring(0, 20);
    const password = 'Passw0rd!';

    testWidgets('GET / responds 200', (tester) async {
      final response = await dio.get('/');
      expect(response.statusCode, 200, reason: response.data?.toString());
    });

    testWidgets('register -> login -> /users/me round-trip', (tester) async {
      final register = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'captcha_token': 'test',
        },
      );
      expect(
        register.statusCode,
        anyOf(200, 201),
        reason: 'register failed: ${register.statusCode} ${register.data}',
      );

      final login = await dio.post(
        '/auth/login',
        data: {'identifier': email, 'password': password},
      );
      expect(
        login.statusCode,
        200,
        reason: 'login failed: ${login.statusCode} ${login.data}',
      );

      final accessToken = login.data is Map
          ? (login.data['access_token'] ?? login.data['accessToken'])
          : null;
      expect(accessToken, isNotNull, reason: 'no access token returned');

      final me = await dio.get(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      expect(me.statusCode, 200, reason: '/users/me failed: ${me.data}');
      if (me.data is Map) {
        final emailField = me.data['email'];
        if (emailField is String) {
          expect(emailField.toLowerCase(), email.toLowerCase());
        }
      }
    });
  });
}
