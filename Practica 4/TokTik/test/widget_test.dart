import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/main.dart';

void main() {
  testWidgets('TokTik app starts cleanly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
