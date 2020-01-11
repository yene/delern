import 'package:flutter/material.dart';

class TagsWidget extends StatelessWidget {
  final Iterable<String> tags;

  const TagsWidget({@required this.tags}) : assert(tags != null);

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 5,
        alignment: WrapAlignment.spaceEvenly,
        children: tags
            .map((tag) => Chip(
                  label: Text(tag),
                  // Reducing the padding here will not help shrinking the
                  // height of the Chip widget because of materialTapTargetSize,
                  // which has to be at least 48x48 for accessibility.
                ))
            .toList(),
      );
}
