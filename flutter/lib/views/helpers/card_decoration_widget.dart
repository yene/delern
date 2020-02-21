import 'package:flutter/material.dart';

class CardDecorationWidget extends StatelessWidget {
  final Color color;
  final Widget child;

  const CardDecorationWidget({@required this.color, @required this.child})
      : assert(color != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) => Card(
        color: color,
        child: child,
      );
}
