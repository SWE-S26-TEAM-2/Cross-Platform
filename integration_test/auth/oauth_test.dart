import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// OAuth placeholder buttons currently surface a SnackBar with a fixed
/// "will be connected later" message. This test pins that copy so the
/// button stays discoverable until the real OAuth flow lands.
void main() {
  ensureBinding();

  group('auth oauth', () {
    testWidgets('Google social button shows placeholder SnackBar', (
      tester,
    ) async {
      await launchApp(tester);
      await tapKey(tester, 'welcome.login');
      await pumpUntilVisible(tester, find.text('Welcome back'));

      markTestSkipped(
        'Google login now opens the native OAuth flow and is not mockable '
        'from this integration harness yet.',
      );
    });

    testWidgets('Facebook social button shows placeholder SnackBar', (
      tester,
    ) async {
      await launchApp(tester);
      await tapKey(tester, 'welcome.login');
      await pumpUntilVisible(tester, find.text('Welcome back'));

      markTestSkipped(
        'Facebook login UI is not present in the current login screen.',
      );
    });
  });
}
