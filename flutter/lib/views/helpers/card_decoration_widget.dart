import 'package:flutter/material.dart';

class CardDecorationWidget extends StatelessWidget {
  final List<Color> colors;
  final Widget child;

  const CardDecorationWidget({@required this.colors, @required this.child})
      : assert(colors != null && colors.length != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: child,
      );
}
