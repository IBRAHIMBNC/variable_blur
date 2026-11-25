import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen lists the examples', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Variable Blur Examples'), findsOneWidget);
    expect(find.text('Tilt-Shift Photography'), findsOneWidget);
  });
}
