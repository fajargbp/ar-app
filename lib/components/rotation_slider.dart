import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class RotationSlider extends StatefulWidget {
  final double degreesPerSecondInitialValue;
  final ValueChanged<double>? onDegreesPerSecondChange;

  const RotationSlider(
      {Key? key,
      this.degreesPerSecondInitialValue = 0.0,
      this.onDegreesPerSecondChange})
      : super(key: key);

  @override
  _RotationSliderState createState() => _RotationSliderState();
}

class _RotationSliderState extends State<RotationSlider> {
  late double degreesPerSecond;

  @override
  void initState() {
    degreesPerSecond = widget.degreesPerSecondInitialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Slider(
            value: degreesPerSecond,
            divisions: 8,
            min: 0.0,
            max: 360.0,
            onChangeEnd: (value) {
              degreesPerSecond = value;
              widget.onDegreesPerSecondChange?.call(degreesPerSecond);
            },
            onChanged: (double value) {
              setState(() {
                degreesPerSecond = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
