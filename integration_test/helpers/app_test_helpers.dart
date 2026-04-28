import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_project/main.dart' as app;
import 'package:my_project/mock_data/mock_users.dart';
import 'package:my_project/models/user.dart';

class TestAccounts {
  static const existingEmail = 'test@gmail.com';
  static const existingPassword = '12345678';
  static const alternateEmail = 'mohamed@gmail.com';
  static const alternatePassword = 'password123';
  static const missingEmail = 'nobody@example.com';
  static const newEmail = 'integration_new@example.com';
  static const newPassword = 'password123';
}

final List<User> _baselineUsers = [
  User(
    email: TestAccounts.existingEmail,
    password: TestAccounts.existingPassword,
  ),
  User(
    email: TestAccounts.alternateEmail,
    password: TestAccounts.alternatePassword,
  ),
  User(
    email: 'amira@gmail.com',
    userName: 'Amira Elwakeel',
    location: 'Giza, Egypt',
    followers: 0,
    following: 0,
    avatarUrl: '',
  ),
];

IntegrationTestWidgetsFlutterBinding ensureBinding() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
}

Future<void> resetMockUsers() async {
  mockUsers
    ..clear()
    ..addAll(
      _baselineUsers.map(
        (user) => User(
          email: user.email,
          password: user.password,
          userName: user.userName,
          location: user.location,
          followers: user.followers,
          following: user.following,
          avatarUrl: user.avatarUrl,
        ),
      ),
    );
}

Future<void> launchApp(WidgetTester tester) async {
  await resetMockUsers();
  app.main();
  await pumpUntilVisible(tester, find.text('Create an account'));
  await tester.pumpAndSettle();
}

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  var elapsed = Duration.zero;
  while (elapsed <= timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    elapsed += step;
  }
  throw TestFailure('Timed out waiting for finder: $finder');
}

// ============================================================================
// Legacy text-based finders (preserved for back-compat with existing suites)
// ============================================================================

Finder authFieldAt(int index) => find.byType(TextField).at(index);

Finder actionButton(String text) => find.widgetWithText(ElevatedButton, text);

Finder textButton(String text) => find.widgetWithText(TextButton, text);

Finder outlinedActionButton(String text) =>
    find.widgetWithText(OutlinedButton, text);

Finder textFormFieldByHint(String hintText) {
  return textFieldByHint(hintText);
}

Finder textFieldByHint(String hintText) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hintText,
    description: 'TextField with hint "$hintText"',
  );
}

// ============================================================================
// Key-based finders (preferred for new tests). Use these alongside the legacy
// helpers above so old suites keep working.
// ============================================================================

/// Convenience wrapper around `find.byKey(Key(value))`.
Finder byKey(String value) => find.byKey(Key(value));

/// Find a [TextFormField]/[TextField] by Key. Returns the underlying
/// [Finder] which can be passed to [WidgetTester.enterText].
Finder keyedField(String value) => byKey(value);

/// Find a button (ElevatedButton/OutlinedButton/TextButton/IconButton/etc.)
/// by Key. Mirrors [actionButton]/[outlinedActionButton] but selects on
/// Key instead of visible text, which is far more robust.
Finder keyedButton(String value) => byKey(value);

/// Tap a widget by Key and pump-and-settle.
Future<void> tapKey(
  WidgetTester tester,
  String value, {
  Duration settle = const Duration(milliseconds: 300),
}) async {
  final finder = byKey(value);
  expect(
    finder,
    findsWidgets,
    reason: 'Expected at least one widget with Key($value)',
  );
  await tester.tap(finder.first);
  await tester.pumpAndSettle(settle);
}

/// Enter text into a keyed field.
Future<void> enterTextByKey(
  WidgetTester tester,
  String value,
  String text,
) async {
  final finder = byKey(value);
  expect(finder, findsOneWidget, reason: 'No field with Key($value)');
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Matches the welcome tagline regardless of newline form. The original
/// asset uses `'Where artists\n& fans connect.'` while some integration
/// tests previously asserted a single-line copy. This finder accepts both
/// forms (anything starting with "Where artists") so tests no longer break
/// when the design wraps differently.
Finder welcomeTaglineFinder() => find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.data ?? '').trimLeft().startsWith('Where artists'),
      description: 'Text widget starting with "Where artists"',
    );

// ============================================================================
// Common high-level helpers
// ============================================================================

Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder, {
  Duration settle = const Duration(milliseconds: 300),
}) async {
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle(settle);
}

Future<void> enterLoginCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(textFormFieldByHint('Email address'), email);
  await tester.enterText(textFormFieldByHint('Password'), password);
  await tester.pump();
}

Future<void> loginAsSeededUser(WidgetTester tester) async {
  await tapAndSettle(tester, outlinedActionButton('Log in'));
  await enterLoginCredentials(
    tester,
    email: TestAccounts.existingEmail,
    password: TestAccounts.existingPassword,
  );
  await tapAndSettle(tester, actionButton('Log in'));
  await pumpUntilVisible(tester, find.text('Home'));
  await tester.pumpAndSettle();
}

Future<void> openBottomTab(WidgetTester tester, String label) async {
  await tapAndSettle(tester, find.text(label));
  await pumpUntilVisible(tester, find.text(label));
}

// ============================================================================
// Additional helpers for extended test coverage
// ============================================================================

/// Clears text from a TextField by selecting all and deleting.
Future<void> clearTextField(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, '');
  await tester.pump();
}

/// Performs rapid taps on a finder without waiting for settle.
/// Useful for testing debounce and duplicate-prevention logic.
Future<void> rapidTaps(
  WidgetTester tester,
  Finder finder, {
  int count = 5,
  Duration interval = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < count; i++) {
    await tester.tap(finder);
    await tester.pump(interval);
  }
}

/// Drives the actual logout UI: opens the Library tab and taps the
/// Key('library.logout') IconButton, then waits for the WelcomeScreen to
/// reappear. Replaces the previous TODO placeholder.
Future<void> simulateLogout(WidgetTester tester) async {
  await openBottomTab(tester, 'Library');
  await tapKey(tester, 'library.logout');
  await pumpUntilVisible(tester, find.text('Create an account'));
  await tester.pumpAndSettle();
}
