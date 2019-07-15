import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localization;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/non_scrolling_markdown.dart';
import 'package:flutter/material.dart';

class CardDisplayWidget extends StatelessWidget {
  final String front;
  final String back;
  final bool showBack;
  final Color backgroundColor;
  final bool isMarkdown;

  const CardDisplayWidget(
      {@required this.front,
      @required this.back,
      @required this.showBack,
      @required this.backgroundColor,
      @required this.isMarkdown});

  @override
  Widget build(BuildContext context) => Card(
        color: backgroundColor,
        margin: const EdgeInsets.all(8),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: _buildCardBody(context),
        ),
      );

  List<Widget> _buildCardBody(BuildContext context) {
    final widgetList = [
      _sideText(front, context),
    ];

    if (showBack) {
      widgetList
        ..add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 1),
        ))
        ..add(_sideText(back, context));
    }

    return widgetList;
  }

  Widget _sideText(String text, BuildContext context) {
    if (isMarkdown) {
      return buildNonScrollingMarkdown(text, context);
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: app_styles.primaryText,
    );
  }
}

const _kFlipCardDuration = Duration(seconds: 1);
const double _kCardBorderPadding = 16;

class FlipCardWidget extends StatefulWidget {
  final String front;
  final String back;
  final Color backgroundColor;
  final bool isMarkdown;

  const FlipCardWidget({
    @required this.front,
    @required this.back,
    @required this.isMarkdown,
    @required this.backgroundColor,
  });

  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  // We always see the front side of the card
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _kFlipCardDuration);
    _animation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -pi / 2), weight: 0.5),
      TweenSequenceItem(
          tween: Tween<double>(begin: pi / 2, end: 0), weight: 0.5)
    ]).animate(_controller)
      ..addListener(() {
        // When card is 50% turned, change the content of card (front to back,
        // back to front)
        if (_controller.value > 0.45 && _controller.value < 0.5) {
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    if (oldWidget != widget) {
      // If new widget, reset all values
      _reset();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Resets animation and show the front side of card
  void _reset() {
    _controller.reset();
    _isFront = true;
  }

  void _startAnimation() {
    if (!mounted) {
      return;
    }
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Widget _sideText(String text, BuildContext context) {
    if (widget.isMarkdown) {
      // TODO(ksheremet): Center text
      return buildNonScrollingMarkdown(text, context);
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: app_styles.primaryText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value),
            child: child,
          ),
      child: GestureDetector(
        onTap: () {
          // If card is not turning now, turn card
          if (!_controller.isAnimating) {
            _isFront = !_isFront;
            _startAnimation();
          }
        },
        child: Stack(
          children: <Widget>[
            Card(
              color: widget.backgroundColor,
              // Delete default margin which is 4
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(_kCardBorderPadding),
                child: LayoutBuilder(
                  builder: (context, viewportConstraints) =>
                      SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: _isFront == true
                          ? _sideText(widget.front, context)
                          : _sideText(widget.back, context),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.autorenew,
                      color: app_styles.kSecondaryTextDeckItemColor,
                    ),
                    Text(
                      localization.of(context).flip,
                      style: app_styles.secondaryText.copyWith(
                          color: app_styles.kSecondaryTextDeckItemColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ));
}
