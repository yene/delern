import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
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
