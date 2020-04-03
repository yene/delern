import 'package:flutter/material.dart';

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

@immutable
class ImageProgressIndicatorPlaceholderWidget extends StatelessWidget {
  const ImageProgressIndicatorPlaceholderWidget();

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.grey[600],
      height: 100,
      child: const Center(child: CircularProgressIndicator()));
}
