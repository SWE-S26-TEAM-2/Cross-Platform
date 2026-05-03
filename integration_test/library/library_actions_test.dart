import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// Library actions: assert each current library section is visible.
void main() {
  ensureBinding();

  group('library actions', () {
    testWidgets('Library tab exposes all section keys', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Library');

      const sections = [
        'Liked Tracks',
        'Playlists',
        'Albums',
        'Following',
        'Your insights',
        'Your uploads',
      ];

      for (final title in sections) {
        expect(find.text(title), findsOneWidget, reason: 'missing $title');
      }
    });

    testWidgets('library.logout returns to welcome screen', (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);
      await openBottomTab(tester, 'Library');

      markTestSkipped('LibraryScreen does not expose a logout control yet.');
    });
  });
}
