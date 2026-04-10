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
