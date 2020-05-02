import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TagsWidget extends StatelessWidget {
  final BuiltSet<String> tags;
  final bool singleLine;
  final ValueNotifier<BuiltSet<String>> selection;

  const TagsWidget({
    @required this.tags,
    this.singleLine = false,
    this.selection,
    Key key,
  })  : assert(tags != null),
        super(key: key);

  static const _chipSpacing = 5.0;

  Widget _buildTag(String tag) {
    if (selection == null) {
      return Chip(
        label: Text(tag),
        // Reducing the padding here will not help shrinking the
        // height of the Chip widget because of materialTapTargetSize,
        // which has to be at least 48x48 for accessibility.
      );
    }

    return FilterChip(
      label: Text(tag),
      selected: selection.value.contains(tag) ?? false,
      onSelected: (selected) {
        selection.value = selection.value.rebuild(
          (tags) => selected ? tags.add(tag) : tags.remove(tag),
        );
      },
    );
  }

  /// Call [builder] if [selection] [ValueNotifier] is unset, otherwise, wrap
  /// the output of [builder] in a [ValueListenableBuilder].
  Widget _wrapSelectionListenableBuilder(Widget Function() builder) =>
      selection == null
          ? builder()
          : ValueListenableBuilder<BuiltSet<String>>(
              valueListenable: selection,
              builder: (context, value, child) => builder(),
            );

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    if (singleLine) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _wrapSelectionListenableBuilder(() => Row(
              children: tags
                  .map((tag) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _chipSpacing,
                        ),
                        child: _buildTag(tag),
                      ))
                  .toList(),
            )),
      );
    }

    return _wrapSelectionListenableBuilder(() => Wrap(
          spacing: _chipSpacing,
          alignment: WrapAlignment.spaceEvenly,
          children: tags.map(_buildTag).toList(),
        ));
  }
}
