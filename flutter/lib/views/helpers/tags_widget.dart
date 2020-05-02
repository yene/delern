import 'package:flutter/material.dart';

class TagsWidget extends StatelessWidget {
  static const _chipSpacing = 5.0;

  final Iterable<String> tags;
  final bool singleLine;

  const TagsWidget({
    @required this.tags,
    this.singleLine = false,
  }) : assert(tags != null);

  @override
  Widget build(BuildContext context) {
    final tagChips = tags
        .map((tag) => Chip(
              label: Text(tag),
              // Reducing the padding here will not help shrinking the
              // height of the Chip widget because of materialTapTargetSize,
              // which has to be at least 48x48 for accessibility.
            ))
        .toList();

    if (tagChips.isEmpty) {
      return const SizedBox.shrink();
    }

    if (singleLine) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tagChips
              .map((chip) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _chipSpacing,
                    ),
                    child: chip,
                  ))
              .toList(),
        ),
      );
    }

    return Wrap(
      spacing: _chipSpacing,
      alignment: WrapAlignment.spaceEvenly,
      children: tagChips,
    );
  }
}
