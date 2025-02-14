import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) async {
    await pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(FinderBase<Element> finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> tapAtAndSettle(Offset location) async {
    await tapAt(location);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(FinderBase<Element> finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  Finder withinAlert(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Alert'), matching: matching);
}

class TestWrapper extends StatefulWidget {
  final bool isNew;
  final String label;
  final String value;

  const TestWrapper({
    super.key,
    this.label = 'Label',
    this.value = 'n/a',
    this.isNew = false,
  });

  @override
  State<TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.value;
  }

  Future<void> handleOpenDialog() async {
    final newText = await showEditTextDialog(
      context: context,
      label: widget.label,
      value: widget.value,
      isNew: widget.isNew,
    );
    setState(() => _text = newText ?? _text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(label: 'Title display', value: _text, excludeSemantics: true, child: Text(_text)),
        TextButton(onPressed: handleOpenDialog, child: Text('Open Dialog')),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('edit text dialog', () {
    testWidgets('shows new title when title change is submitted', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: 'Old title'));
      expect(tester.getSemantics(find.bySemanticsLabel('Title display')).value, 'Old title');

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));

      final textField = tester.withinAlert(find.bySemanticsLabel('Title input'));
      expect(tester.getSemantics(textField).value, 'Old title');

      await tester.enterTextAndSettle(tester.withinAlert(find.bySemanticsLabel('Title input')), 'Edited title');
      await tester.tapAndSettle(tester.withinAlert(find.bySemanticsLabel('Submit')));

      expect(tester.getSemantics(find.bySemanticsLabel('Title display')).value, 'Edited title');
    });

    testWidgets('hides edit text dialog when cancel is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));
      expect(find.bySemanticsLabel('Alert'), findsOneWidget);

      await tester.tapAndSettle(tester.withinAlert(find.text('Cancel')));
      expect(find.bySemanticsLabel('Alert'), findsNothing);
    });

    testWidgets('does not allow entering title longer than max value', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: ''));

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));
      await tester.enterTextAndSettle(
        tester.withinAlert(find.bySemanticsLabel('Title input')),
        'a'.padLeft(100 + 1, 'a'),
      );

      final textField = tester.withinAlert(find.bySemanticsLabel('Title input'));
      expect(tester.getSemantics(textField).value, 'a'.padLeft(100, 'a'));

      await tester.tapAndSettle(tester.withinAlert(find.bySemanticsLabel('Submit')));
      expect(tester.getSemantics(find.bySemanticsLabel('Title display')).value, 'a'.padLeft(100, 'a'));
    });

    testWidgets('shows old title when title change is canceled', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: 'Old title'));

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));
      await tester.enterTextAndSettle(tester.withinAlert(find.bySemanticsLabel('Title input')), 'Edited title');
      await tester.tapAndSettle(tester.withinAlert(find.text('Cancel')));

      expect(tester.getSemantics(find.bySemanticsLabel('Title display')).value, 'Old title');
    });

    testWidgets('disables submit button when title is empty', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: 'Old title'));

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));
      await tester.enterTextAndSettle(tester.withinAlert(find.bySemanticsLabel('Title input')), '');

      final submitButton = tester.withinAlert(find.bySemanticsLabel('Submit'));
      expect(tester.getSemantics(submitButton).hasFlag(SemanticsFlag.isEnabled), isFalse);
    });

    testWidgets('disables submit button when title has not changed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: 'Old title'));

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));

      final submitButton = tester.withinAlert(find.bySemanticsLabel('Submit'));
      expect(tester.getSemantics(submitButton).hasFlag(SemanticsFlag.isEnabled), isFalse);
    });

    testWidgets('submits title when title has not changed but is marked as new', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(label: 'Title input', value: 'New title', isNew: true));

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));
      await tester.enterTextAndSettle(tester.withinAlert(find.bySemanticsLabel('Title input')), 'Edited title');
      await tester.tapAndSettle(tester.withinAlert(find.bySemanticsLabel('Submit')));

      expect(tester.getSemantics(find.bySemanticsLabel('Title display')).value, 'Edited title');
    });

    testWidgets('does not close dialog when clicking outside of dialog', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tapAndSettle(find.bySemanticsLabel('Open Dialog'));

      final dialogRect = tester.getRect(find.bySemanticsLabel('Alert'));
      final Offset outsideTapOffset = Offset(dialogRect.left - 10, dialogRect.top + 10);
      await tester.tapAtAndSettle(outsideTapOffset);

      expect(find.bySemanticsLabel('Alert'), findsOneWidget);
    });
  });
}
