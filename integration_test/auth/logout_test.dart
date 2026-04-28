import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// End-to-end logout flow:
///   launch app -> login as seeded mock user -> open Library tab ->
///   tap library.logout -> assert WelcomeScreen returns.
///
/// Replaces the previous TODO `simulateLogout` placeholder in
/// `app_test_helpers.dart`.
void main() {
  ensureBinding();

  group('auth logout', () {
    testWidgets('logout from Library tab returns to Welcome screen',
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // Sanity: we are on the shell with bottom nav.
      expect(byKey('nav.library'), findsOneWidget);

      await openBottomTab(tester, 'Library');
      expect(byKey('library.logout'), findsOneWidget);

      await tapKey(tester, 'library.logout');

      await pumpUntilVisible(tester, find.text('Create an account'));
      expect(byKey('welcome.signup'), findsOneWidget);
      expect(byKey('welcome.login'), findsOneWidget);

      // Bottom nav should be gone (we are back on the welcome screen).
      expect(byKey('nav.home'), findsNothing);
      expect(byKey('library.logout'), findsNothing);
    });

    testWidgets('helper simulateLogout drives the same UI flow',
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      await simulateLogout(tester);

      expect(find.text('Create an account'), findsOneWidget);
    });
  });
}
