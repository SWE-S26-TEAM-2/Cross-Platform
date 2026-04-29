import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart';

void main() {
  testWidgets('app launches to the welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SoundCloudApp());
    await tester.pumpAndSettle();

    expect(find.text('Where artists\n& fans connect.'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
