import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// Library actions: assert each library section key is visible and the
/// logout IconButton (Key('library.logout')) returns the user to the
/// WelcomeScreen.
void main() {
  ensureBinding();

  group('library actions', () {
    testWidgets('Library tab exposes all section keys', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Library');

      const sections = [
        'library.section.liked',
        'library.section.playlists',
        'library.section.albums',
        'library.section.following',
        'library.section.stations',
      ];

      for (final key in sections) {
        expect(byKey(key), findsOneWidget, reason: 'missing $key');
      }

      expect(byKey('library.logout'), findsOneWidget);
    });

    testWidgets('library.logout returns to welcome screen', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Library');

      await tapKey(tester, 'library.logout');

      await pumpUntilVisible(tester, find.text('Create an account'));
      expect(find.text('Create an account'), findsOneWidget);
      expect(byKey('welcome.signup'), findsOneWidget);
      expect(byKey('welcome.login'), findsOneWidget);
    });
  });
}
