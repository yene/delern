import 'package:flutter/material.dart';

class CardDecorationWidget extends StatelessWidget {
  final Gradient gradient;
  final Widget child;

  const CardDecorationWidget({@required this.gradient, @required this.child})
      : assert(gradient != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          gradient: gradient,
        ),
        child: child,
      );
}
