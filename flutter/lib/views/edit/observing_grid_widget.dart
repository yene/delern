import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:observable/observable.dart';

typedef ObservingGridItemBuilder<T> = Widget Function(T item);

// TODO(ksheremet): Refactor. This class has more responsibilities that
//  it should be. Get rid of 'up' icon.
class ObservingGridWidget<T extends KeyedListItem> extends StatefulWidget {
  const ObservingGridWidget({
    @required this.items,
    @required this.itemBuilder,
    @required this.maxCrossAxisExtent,
    @required this.emptyGridUserMessage,

    /// From which row 'up' icon is visible.
    @required this.upIconVisibleRow,
    Key key,
  }) : super(key: key);

  final DelayedInitializationObservableList<T> items;
  final ObservingGridItemBuilder<T> itemBuilder;
  final double maxCrossAxisExtent;
  final String emptyGridUserMessage;
  final int upIconVisibleRow;

  @override
  ObservingGridWidgetState<T> createState() => ObservingGridWidgetState<T>();
}

class ObservingGridWidgetState<T extends KeyedListItem>
    extends State<ObservingGridWidget<T>> {
  StreamSubscription<List<ListChangeRecord<T>>> _listSubscription;
  final ScrollController _scrollController = ScrollController();
  var _isUpIconVisible = false;
  var _currentScrollRow = 0.0;

  @override
  void initState() {
    _listSubscription = widget.items.listChanges.listen((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _listSubscription.cancel();
    super.dispose();
  }

  Widget _buildItem(T item) => widget.itemBuilder(item);

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: widget.items.initializationComplete,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ProgressIndicatorWidget();
        }

        if (widget.items.isEmpty) {
          return EmptyListMessageWidget(widget.emptyGridUserMessage);
        }

        return StatefulBuilder(
          builder: (context, contentState) => Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (scrollNotification) {
                        // We don't have exact height of row, we only
                        // have max width/height. This calculation is
                        // approximate.
                        _currentScrollRow = scrollNotification.metrics.pixels /
                                widget.maxCrossAxisExtent +
                            1;
                        if (_currentScrollRow > widget.upIconVisibleRow &&
                            !_isUpIconVisible) {
                          // Call set state of parent.
                          contentState(() {
                            _isUpIconVisible = true;
                          });
                        }
                        if (_currentScrollRow < widget.upIconVisibleRow &&
                            _isUpIconVisible) {
                          contentState(() {
                            _isUpIconVisible = false;
                          });
                        }
                        // Do not dispatch notification to further ancestors
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: widget.items.length,
                        controller: _scrollController,
                        itemBuilder: (context, index) =>
                            _buildItem(widget.items[index]),
                      ),
                    ),
                  ),
                ],
              ),
              if (_currentScrollRow > widget.upIconVisibleRow)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton(
                      // Because of 2 FAB button (add_card and up_button),
                      // it tries to do hero animation in Preview screen.
                      // The app doesn't know for what button to do.
                      // It crashes. User hero for add card on default.
                      heroTag: 'up_button',
                      backgroundColor: Colors.blueGrey,
                      tooltip: localizations.of(context).scrollToStartLabel,
                      onPressed: () {
                        _scrollController.animateTo(0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeIn);
                      },
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                )
            ],
          ),
        );
      });
}
