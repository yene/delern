import 'package:delern_flutter/models/card_model.dart';
import 'package:test/test.dart';

void main() {
  group('CardModel', () {
    final card = (CardModelBuilder()
          ..front = '#feminine die #family #german Mutter'
          ..back = 'Mother')
        .build();

    test('tags', () async {
      expect(card.tags, {'#family', '#feminine', '#german'});
      expect(card.frontWithoutTags, 'die Mutter');
    });
  });
}
