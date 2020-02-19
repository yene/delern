import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:flutter/material.dart';

class CardDecorationWidget extends StatelessWidget {
  final Gradient gradient;
  final Widget child;

  const CardDecorationWidget({@required this.gradient, @required this.child})
      : assert(gradient != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) => Card(
        elevation: app_styles.kCardElevation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            gradient: gradient,
          ),
          child: child,
        ),
      );
}
