import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// OAuth placeholder buttons currently surface a SnackBar with a fixed
/// "will be connected later" message. This test pins that copy so the
/// button stays discoverable until the real OAuth flow lands.
void main() {
  ensureBinding();

  group('auth oauth', () {
    testWidgets('Google social button shows placeholder SnackBar',
        (tester) async {
      await launchApp(tester);
      await tapKey(tester, 'welcome.login');
      await pumpUntilVisible(tester, find.text('Welcome back'));

      expect(byKey('login.google'), findsOneWidget);
      await tester.tap(byKey('login.google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Google login will be connected later'),
        findsOneWidget,
      );
    });

    testWidgets('Facebook social button shows placeholder SnackBar',
        (tester) async {
      await launchApp(tester);
      await tapKey(tester, 'welcome.login');
      await pumpUntilVisible(tester, find.text('Welcome back'));

      expect(byKey('login.facebook'), findsOneWidget);
      await tester.tap(byKey('login.facebook'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Facebook login will be connected later'),
        findsOneWidget,
      );
    });
  });
}
