import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef LearningMethodTapCallback = void Function();

const _kLearningMethodSizeRatio = 0.5 * 0.7;
const double _kCardMargin = 16;
const double _kTextMargin = 8;
const double _kIconSizeRatio = _kLearningMethodSizeRatio * 0.4;

class LearningMethodWidget extends StatelessWidget {
  final String name;
  final String tooltip;
  final IconData icon;
  final LearningMethodTapCallback onTap;

  const LearningMethodWidget({
    @required this.name,
    @required this.tooltip,
    @required this.icon,
    @required this.onTap,
  })  : assert(name != null),
        assert(tooltip != null),
        assert(icon != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    final minSize =
        MediaQuery.of(context).size.shortestSide * _kLearningMethodSizeRatio;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minSize,
            minHeight: minSize,
          ),
          child: Card(
            color: app_styles.kLightPrimaryColor,
            margin: const EdgeInsets.all(_kCardMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: MediaQuery.of(context).size.shortestSide *
                      _kIconSizeRatio,
                  color: app_styles.kPrimarySwatch,
                ),
                Padding(
                  padding: const EdgeInsets.all(_kTextMargin),
                  child: Text(
                    name,
                    style: app_styles.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
