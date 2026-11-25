import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variable_blur/variable_blur.dart';

Widget _app(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: SizedBox(width: 200, height: 200, child: child)),
);

void main() {
  testWidgets('shows the child when sigma is 0', (tester) async {
    await tester.pumpWidget(
      _app(
        const VariableBlur(
          sigma: 0,
          blurSides: BlurSides.vertical(top: 0.3),
          child: Text('hello'),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the child when no side is blurred', (tester) async {
    await tester.pumpWidget(
      _app(
        const VariableBlur(
          sigma: 10,
          blurSides: BlurSides.vertical(),
          child: Text('hello'),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The blur itself needs a GPU and Impeller, which `flutter test` does not
  // have. It is checked by running the example app on a device.

  test('blur sides reject negative values', () {
    expect(() => BlurSides.vertical(top: -0.1), throwsAssertionError);
    expect(() => ResponsiveBlurSides.vertical(top: -1), throwsAssertionError);
  });
}
