import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_test_helpers.dart';

/// Upload flow placeholder.
///
/// The Cross-Platform app does not yet expose an UploadScreen under
/// `lib/screens/`. This file is a passing skip-with-reason scaffold that
/// will be promoted to a real e2e test once the upload UI lands.
///
/// What the future implementation should drive:
///   1. Login as a seeded mock user.
///   2. Tap the Home cloud-upload IconButton (currently a no-op).
///   3. Pick an audio file + cover art via a fake FilePicker channel.
///   4. Submit and assert SnackBar 'Upload queued' or navigate to track page.
///   5. In real-API mode (USE_MOCK_AUTH=false + BACKEND_URL set), assert
///      `POST /tracks/` returns 201 and the new track appears under
///      `/users/me/tracks`.
void main() {
  ensureBinding();

  group('upload flow', () {
    testWidgets('skipped: UploadScreen not implemented in lib/screens',
        (tester) async {
      await launchApp(tester);

      // Sanity-check we can reach the welcome screen (proves test harness
      // is wired) before skipping the unimplemented surface.
      expect(find.text('Create an account'), findsOneWidget);

      // Render a minimal placeholder Upload page in-memory so future authors
      // have a starting point. We intentionally do NOT pump it into the app
      // tree — this is just a reminder for the next iteration.
      const _UploadPlaceholder();

      markTestSkipped(
        'UploadScreen not implemented yet. See '
        'integration_test/upload/upload_flow_test.dart for the planned flow. '
        'Promote this test once lib/screens/upload/upload_screen.dart lands.',
      );
    });
  });
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Upload coming soon')),
    );
  }
}
