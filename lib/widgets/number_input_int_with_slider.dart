import 'input/app_slider_int.dart';
import 'input/number_input_int.dart';
import 'package:flutter/material.dart';

class NumberInputIntWithSlider extends StatefulWidget {
  final int min;
  final int max;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final int stepIntervalInMs;
  final String label;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;
  final bool allowNegativeNumbers;

  const NumberInputIntWithSlider({
    super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.controller,
    this.stepIntervalInMs = 100,
    this.label = '',
    this.buttonRadius = 25,
    this.buttonGap = 10,
    this.relIconSize = 0.4,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
    this.allowNegativeNumbers = false,
  });

  @override
  State<NumberInputIntWithSlider> createState() => _NumberInputIntWithSliderState();
}

class _NumberInputIntWithSliderState extends State<NumberInputIntWithSlider> {
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberInputInt(
          defaultValue: widget.defaultValue,
          max: widget.max,
          min: widget.min,
          step: widget.step,
          controller: widget.controller,
          stepIntervalInMs: widget.stepIntervalInMs,
          label: widget.label,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          relIconSize: widget.relIconSize,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
          allowNegativeNumbers: widget.allowNegativeNumbers,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: AppSliderInt(
            semanticLabel: '${widget.label} slider',
            max: widget.max,
            min: widget.min,
            defaultValue: widget.defaultValue,
            step: widget.step,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}
