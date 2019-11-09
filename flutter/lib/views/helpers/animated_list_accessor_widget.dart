import 'dart:async';

import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:observable/observable.dart';

typedef AnimatedListAccessorItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  Animation<double> animation,
  // TODO(dotdoom): consider usefulness of index.
  int index,
);

typedef WidgetBuilder = Widget Function();

class AnimatedListAccessorWidget<T extends KeyedListItem>
    extends StatefulWidget {
  const AnimatedListAccessorWidget({
    @required this.list,
    @required this.itemBuilder,
    @required this.emptyMessageBuilder,
    this.controller,
    Key key,
  })  : assert(itemBuilder != null),
        super(key: key);

  final DataListAccessor<T> list;
  final AnimatedListAccessorItemBuilder<T> itemBuilder;
  final WidgetBuilder emptyMessageBuilder;
  final ScrollController controller;

  @override
  AnimatedListAccessorWidgetState<T> createState() =>
      AnimatedListAccessorWidgetState<T>();
}

class AnimatedListAccessorWidgetState<T extends KeyedListItem>
    extends State<AnimatedListAccessorWidget<T>> {
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();

  StreamSubscription<ListChangeRecord<T>> _listChangeSubscription;

  @override
  void initState() {
    _listChangeSubscription = widget.list.events.listen(_processListChanges);
    super.initState();
  }

  @override
  void dispose() {
    _listChangeSubscription.cancel();
    super.dispose();
  }

  void _processListChanges(ListChangeRecord<T> change) {
    if (_animatedListKey.currentState == null) {
      // The list state is not available because the widget has not been created
      // yet. This happens when the data was empty (no items) and we showed an
      // 'empty list' message instead of the list widget. Now that we got some
      // data, create the list widget!
      setState(() {});
      return;
    }
    change.removed.forEach((removedValue) => _animatedListKey.currentState
        .removeItem(
            change.index,
            (context, animation) => widget.itemBuilder(
                context, removedValue, animation, change.index)));
    for (var i = 0; i < change.addedCount; ++i) {
      _animatedListKey.currentState.insertItem(change.index + i);
    }

    // TODO(dotdoom): detect individual item changes rather than remove + add.
  }

  Widget _buildItem(
          BuildContext context, int index, Animation<double> animation) =>
      widget.itemBuilder(context, widget.list.value[index], animation, index);

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: widget.list.updates,
      builder: (context, snapshot) {
        if (!widget.list.hasValue) {
          return ProgressIndicatorWidget();
        }
        if (widget.list.value.isEmpty) {
          return widget.emptyMessageBuilder();
        }

        return AnimatedList(
          key: _animatedListKey,
          itemBuilder: _buildItem,
          initialItemCount: snapshot.data?.length ?? widget.list.value.length,
          controller: widget.controller,
        );
      });
}
