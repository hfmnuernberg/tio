import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) async {
    await pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(FinderBase<Element> finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> tapAtCenterAndSettle(FinderBase<Element> finder) async {
    final Offset widgetCenter = getCenter(finder);
    await tapAt(widgetCenter);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(FinderBase<Element> finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  Future<void> dragFromCenterToTargetAndSettle(FinderBase<Element> finder, Offset to) async {
    final Offset widgetCenter = getCenter(finder);
    await dragFrom(widgetCenter, to);
    await pumpAndSettle();
  }
}

class TestWrapper extends StatelessWidget {
  final defaultValue;
  final min;
  final max;
  final step;

  const TestWrapper({
    super.key,
    this.defaultValue = 50.0,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return NumberInputDoubleWithSlider(
      min: min,
      max: max,
      defaultValue: defaultValue,
      step: step,
      label: 'Test',
      controller: TextEditingController(),
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('number input double with slider', () {
    group('number input double', () {
      testWidgets('increase input value when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '11.0');
      });

      testWidgets('do not increase input value higher than max when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, max: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');
      });

      testWidgets('increase input value based on given step when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, step: 0.1));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.1');
      });

      testWidgets('decrease input value when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '9.0');
      });

      testWidgets('do not decrease input value lower than min when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 0.0, min: 0.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');
      });

      testWidgets('decrease input value based on given step when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, step: 0.1));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '9.9');
      });

      testWidgets('changes input value when enter new value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '20.0');

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');
      });

      testWidgets('do not change input value when enter new empty value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 50.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test description input')).value, '50.0');

        await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test description'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test description input')).value, '50.0');
      });
    });
  });

  group('slider int', () {
    testWidgets('increases input value when moving slider to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '51.0');
    });

    testWidgets('decreases input value when moving slider to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '49.0');
    });

    testWidgets('increases input value to max when moving slider far to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0, max: 100.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '100.0');
    });

    testWidgets('decreases input value to min when moving slider far to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0, min: 0.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');
    });

    testWidgets('changes input value to slider value when tapping on slider', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 10.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

      await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test slider'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');
    });
  });
}
