import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/widgets/social_buttons.dart';

/// SOCIAL BUTTONS WIDGET TESTS
///
/// Coverage: WGT-006 (Social login buttons render)
/// Verifies that Google and Facebook social login buttons are present
/// and tappable on auth screens.
///
/// Note: Social login is not yet connected to real providers.
/// Buttons currently show placeholder snackbar messages.

void main() {
  group('SocialButtons widget', () {
    testWidgets('renders Google login button with correct text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      // Verify Google button exists with expected text
      expect(find.text('Continue with Google'), findsOneWidget);

      // Verify it's an ElevatedButton
      final googleButton = find.widgetWithText(
        ElevatedButton,
        'Continue with Google',
      );
      expect(googleButton, findsOneWidget);
    });

    testWidgets('renders Facebook login button with correct text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      // Verify Facebook button exists with expected text
      expect(find.text('Continue with Facebook'), findsOneWidget);

      // Verify it's an ElevatedButton
      final facebookButton = find.widgetWithText(
        ElevatedButton,
        'Continue with Facebook',
      );
      expect(facebookButton, findsOneWidget);
    });

    testWidgets('Google button is tappable and shows placeholder message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      final googleButton = find.widgetWithText(
        ElevatedButton,
        'Continue with Google',
      );

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Verify placeholder snackbar appears
      expect(
        find.text('Google login will be connected later'),
        findsOneWidget,
      );
    });

    testWidgets('Facebook button is tappable and shows placeholder message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      final facebookButton = find.widgetWithText(
        ElevatedButton,
        'Continue with Facebook',
      );

      await tester.tap(facebookButton);
      await tester.pumpAndSettle();

      // Verify placeholder snackbar appears
      expect(
        find.text('Facebook login will be connected later'),
        findsOneWidget,
      );
    });

    testWidgets('both social buttons are visible together', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      // Both buttons should be visible simultaneously
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);

      // Should have exactly 2 ElevatedButtons in the widget
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('social buttons are arranged in a column', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SocialButtons()),
        ),
      );

      // Verify buttons are in a Column layout
      final column = find.byType(Column);
      expect(column, findsWidgets);

      // Google button should appear before Facebook (higher on screen)
      final googleCenter = tester.getCenter(
        find.text('Continue with Google'),
      );
      final facebookCenter = tester.getCenter(
        find.text('Continue with Facebook'),
      );

      expect(
        googleCenter.dy,
        lessThan(facebookCenter.dy),
        reason: 'Google button should appear above Facebook button',
      );
    });
  });
}
