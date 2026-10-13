import 'package:flutter_test/flutter_test.dart';
import 'package:candy_ai/main.dart';

void main() {
  testWidgets('CandyAiApp renders LoginScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const CandyAiApp());
    expect(find.text('Continue with Google (Free)'), findsOneWidget);
  });
}
