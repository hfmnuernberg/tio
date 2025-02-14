import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/number_input_int_with_slider.dart';

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

  Future<void> unfocusAndSettle() async {
    await testTextInput.receiveAction(TextInputAction.done);
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
  final allowNegativeNumbers;

  const TestWrapper({
    super.key,
    this.defaultValue = 50,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.allowNegativeNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    return NumberInputIntWithSlider(
      min: min,
      max: max,
      defaultValue: defaultValue,
      step: step,
      label: 'Test',
      controller: TextEditingController(),
      allowNegativeNumbers: allowNegativeNumbers,
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('number input int with slider', () {
    group('number input int', () {
      testWidgets('increase input value when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '11');
      });

      testWidgets('do not increases input value higher than max when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10, max: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');
      });

      testWidgets('increase input value based on given step when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10, step: 5));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '15');
      });

      testWidgets('decrease input value when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '9');
      });

      testWidgets('do not decrease input value lower than min when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0');
      });

      testWidgets('decrease input value based on given step when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10, step: 5));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '5');
      });

      testWidgets('changes input value when entering new value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '20');

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');
      });

      testWidgets('changes input value to max when entering too high value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10, max: 20));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '30');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');
      });

      testWidgets('changes input value to min when entering too low value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 20, min: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '1');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');
      });

      testWidgets('do not change input value when entering invalid value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 20, min: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), 'test');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');
      });

      testWidgets('do not change input value when entering new empty value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 50));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');
      });
    });
  });

  group('slider int', () {
    testWidgets('increases input value when moving slider to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '51');
    });

    testWidgets('decreases input value when moving slider to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '49');
    });

    testWidgets('increases input value to max when moving slider far to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50, max: 100));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '100');
    });

    testWidgets('decreases input value to min when moving slider far to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50, min: 0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0');
    });

    testWidgets('changes input value to slider value when tapping on slider', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

      await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test slider'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');
    });
  });
}
