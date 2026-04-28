import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// ProfileScreen route smoke. Drives the new '/profile' route registered in
/// `lib/main.dart` and asserts the username Text and section keys are visible.
void main() {
  ensureBinding();

  group('profile screen', () {
    testWidgets('navigates to /profile and renders username + tabs',
        (tester) async {
      await launchApp(tester);
      await loginAsSeededUser(tester);

      // Push the profile route directly using the navigator. The Home tab
      // does not yet expose a UI affordance to open the user's own profile,
      // so we rely on the named route registered in main.dart.
      final navigator = Navigator.of(
        tester.element(byKey('miniPlayer.root')),
        rootNavigator: true,
      );
      // ignore: unawaited_futures
      navigator.pushNamed('/profile');
      await tester.pumpAndSettle();

      // Username must be visible (mocked user defaults to 'Amira Elwakeel').
      expect(byKey('profile.username'), findsOneWidget);

      // Section "tabs" — the current ProfileScreen renders these as sections,
      // not tabs, but the keys are stable and provide the same testing
      // surface that future tabbed UIs will satisfy.
      expect(byKey('profile.playlistsTab'), findsOneWidget);
      expect(byKey('profile.tracksTab'), findsOneWidget);

      // Edit button (mapped to profile.followBtn for parity with the planned
      // public-profile follow control).
      expect(byKey('profile.followBtn'), findsOneWidget);
    });
  });
}
