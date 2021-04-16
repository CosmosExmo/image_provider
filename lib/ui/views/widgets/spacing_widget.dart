import 'package:flutter/material.dart';

class SpacingWidget extends StatelessWidget {
  final Axis axis;
  const SpacingWidget({Key key, this.axis = Axis.vertical}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return SizedBox(width: 30);
    }

    return SizedBox(height: 30);
  }
}
