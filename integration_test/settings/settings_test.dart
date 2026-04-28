import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// Settings placeholder.
///
/// `lib/screens/settings/` is currently empty so settings flows cannot be
/// driven yet. This is a passing skip that will be promoted once the UI is
/// in place. Future test should cover:
///   * Theme toggle persistence
///   * Privacy toggle (PATCH /users/me/privacy)
///   * Username change with conflict (PATCH /users/me/username -> 409)
///   * Avatar upload (PUT /users/me/avatar multipart)
void main() {
  ensureBinding();

  group('settings', () {
    testWidgets('skipped: SettingsScreen not implemented', (tester) async {
      await launchApp(tester);
      expect(find.text('Create an account'), findsOneWidget);

      markTestSkipped(
        'SettingsScreen not implemented in lib/screens/settings. '
        'Backend endpoints already exist (PATCH /users/me/*).',
      );
    });
  });
}
