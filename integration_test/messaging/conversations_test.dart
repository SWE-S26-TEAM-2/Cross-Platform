import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// Messaging / conversations placeholder.
///
/// No messaging screen exists under `lib/screens/messaging` (the directory
/// is empty) so this suite is intentionally a passing skip. Backend already
/// exposes /conversations/* (see Backend/app/routers/messaging.py); when the
/// Flutter UI lands, replace the skip with the real flow:
///   1. Open Messaging tab / drawer.
///   2. Compose a new message to `mockUsers[1]`.
///   3. Assert the message shows up in the conversation list.
///   4. PATCH read marker and assert unread-count drops to 0.
void main() {
  ensureBinding();

  group('messaging - conversations', () {
    testWidgets('skipped: messaging UI not implemented in lib/screens',
        (tester) async {
      await launchApp(tester);
      expect(find.text('Create an account'), findsOneWidget);

      markTestSkipped(
        'Messaging not implemented in lib/screens. Promote when '
        'ConversationListScreen + ConversationScreen are wired.',
      );
    });
  });
}
