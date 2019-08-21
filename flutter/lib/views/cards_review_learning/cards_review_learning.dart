import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/cards_review_learning_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';

const _kCardPageRation = 0.9;
const double _kCardPadding = 8;

class CardsReviewLearning extends StatefulWidget {
  final DeckModel deck;

  const CardsReviewLearning({@required this.deck}) : assert(deck != null);

  @override
  _CardsReviewLearningState createState() => _CardsReviewLearningState();
}

class _CardsReviewLearningState extends State<CardsReviewLearning>
    with TickerProviderStateMixin {
  CardsReviewLearningBloc _bloc;
  final PageController _controller = PageController(viewportFraction: 0.7);
  int _currentCard = 0;
  int _allCards = 0;

  @override
  void initState() {
    _bloc = CardsReviewLearningBloc(deck: widget.deck);
    _controller.addListener(() {
      if (_controller.page.floor() != _currentCard) {
        setState(() {
          _currentCard = _controller.page.floor();
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final locale = localizations.of(context);
    if (_bloc?.locale != locale) {
      _bloc.onLocale.add(locale);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView(
        appBar: AppBar(
            title:
                Text('(${_currentCard + 1}/$_allCards) ${widget.deck.name}')),
        body: StreamBuilder<List<CardModel>>(
          stream: _bloc.doGetCardList,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done &&
                !snapshot.hasData) {
              return ProgressIndicatorWidget();
            } else {
              _allCards = snapshot.data.length;
              return PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          // On the first render, the _controller.page
                          // is null, this is a dirty hack
                          if (_controller.position.minScrollExtent == null ||
                              _controller.position.maxScrollExtent == null) {
                            Future.delayed(const Duration(microseconds: 1), () {
                              setState(() {});
                            });
                            return Container();
                          }
                          var value = _controller.page - index;
                          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                          final distortionValue =
                              Curves.easeOut.transform(value);
                          return Center(
                              child: SizedBox(
                                  width: distortionValue *
                                      MediaQuery.of(context).size.width *
                                      _kCardPageRation,
                                  child: child));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(_kCardPadding),
                          child: FlipCardWidget(
                            front: snapshot.data[index].front,
                            back: snapshot.data[index].back,
                            isMarkdown: widget.deck.markdown,
                            backgroundColor: specifyCardBackground(
                                widget.deck.type, snapshot.data[index].back),
                            onFlip: () {},
                            key: ValueKey(snapshot.data[index].key),
                          ),
                        ),
                      ));
            }
          },
        ),
        bloc: _bloc,
      );

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
