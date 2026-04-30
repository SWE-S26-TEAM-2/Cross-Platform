import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/main.dart';

void main() {
  testWidgets('app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SoundCloudApp()));

    await tester.pump();

    expect(find.byType(SoundCloudApp), findsOneWidget);
  });
}
