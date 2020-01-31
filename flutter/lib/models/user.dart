import 'dart:async';
import 'dart:math';

import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/card_reply_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/fcm.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:quiver/strings.dart';

/// An abstraction layer on top of FirebaseUser, plus data writing methods.
class User {
  FirebaseUser _dataSource;
  StreamSubscription _onlineSubscription;

  final StreamWithValue<bool> isOnline;
  final DataListAccessor<DeckModel> decks;

  User(this._dataSource)
      : assert(_dataSource != null),
        decks = DeckModelListAccessor(_dataSource.uid),
        isOnline = StreamWithLatestValue<bool>(FirebaseDatabase.instance
            .reference()
            .child('.info/connected')
            .onValue
            .mapPerEvent((event) => event.snapshot.value)) {
    // Subscribe ourselves to online status immediately because we always want
    // to know the current value, and that requires at least 1 subscription for
    // StreamWithLatestValue.
    _onlineSubscription = isOnline.updates.listen((isOnline) {
      if (isOnline) {
        // Update latest_online_at node immediately, and also schedule an
        // onDisconnect handler which will set latest_online_at node to the
        // timestamp on the server when a client is disconnected.
        (FirebaseDatabase.instance
                .reference()
                .child('latest_online_at')
                .child(uid)
                  ..onDisconnect().set(ServerValue.timestamp))
            .set(ServerValue.timestamp);
      }
    });
  }

  /// Update source of profile information (such as email, displayName etc) for
  /// this user. If in-place update is not possible, i.e. [newDataSource] is
  /// about a different user, this method returns false.
  bool updateDataSource(FirebaseUser newDataSource) {
    assert(newDataSource != null);
    if (newDataSource.uid == _dataSource.uid) {
      _dataSource = newDataSource;
      return true;
    }
    return false;
  }

  void dispose() {
    _onlineSubscription.cancel();
    decks.close();
  }

  /// Unique ID of the user used in Firebase Database and across the app.
  String get uid => _dataSource.uid;

  /// Display name. Can be null, e.g. for anonymous user.
  String get displayName =>
      isBlank(_dataSource.displayName) ? null : _dataSource.displayName;

  /// Photo URL. Can be null.
  String get photoUrl =>
      isBlank(_dataSource.photoUrl) ? null : _dataSource.photoUrl;

  /// Email. Can be null.
  String get email => isBlank(_dataSource.email) ? null : _dataSource.email;

  /// All providers (aka "linked accounts") for the current user. Empty for
  /// anonymously signed in.
  Iterable<String> get providers => _dataSource.providerData
      .map((p) => p.providerId)
      .where((p) => p != 'firebase');

  bool get isAnonymous => _dataSource.isAnonymous;

  Future<DeckModel> createDeck({
    @required DeckModel deckTemplate,
  }) async {
    final deck = deckTemplate.rebuild((b) => b..key = _newKey());
    final deckPath = 'decks/$uid/${deck.key}';
    final deckAccessPath = 'deck_access/${deck.key}/$uid';
    await _write({
      '$deckPath/name': deck.name,
      '$deckPath/markdown': deck.markdown,
      '$deckPath/deckType': deck.type.toString().toUpperCase(),
      '$deckPath/accepted': deck.accepted,
      '$deckPath/lastSyncAt': deck.lastSyncAt.millisecondsSinceEpoch,
      '$deckPath/category': deck.category,
      '$deckPath/access': deck.access.toString(),
      '$deckAccessPath/access': deck.access.toString(),
      '$deckAccessPath/email': email,
      '$deckAccessPath/displayName': displayName,
      '$deckAccessPath/photoUrl': photoUrl,
    });

    return deck;
  }

  Future<void> updateDeck({@required DeckModel deck}) {
    final deckPath = 'decks/$uid/${deck.key}';
    return _write({
      '$deckPath/name': deck.name,
      '$deckPath/markdown': deck.markdown,
      '$deckPath/deckType': deck.type.toString().toUpperCase(),
      '$deckPath/accepted': deck.accepted,
      '$deckPath/lastSyncAt': deck.lastSyncAt.millisecondsSinceEpoch,
      '$deckPath/category': deck.category,
    });
  }

  Future<void> deleteDeck({@required DeckModel deck}) async {
    // We want to enforce that the values in this map are all "null", because we
    // are only removing data.
    // ignore: prefer_void_to_null
    final updates = <String, Null>{
      'decks/$uid/${deck.key}': null,
      'learning/$uid/${deck.key}': null,
      'views/$uid/${deck.key}': null,
      if (deck.access == AccessType.owner) ...{
        'cards/${deck.key}': null,
        'deck_access/${deck.key}': null,
      },
    };

    if (deck.access == AccessType.owner) {
      // TODO(ksheremet): There's a possible problem here, which is,
      // deck.usersAccess is not yet loaded. We should have a mechanism
      // (perhaps, a Future?) that can wait until the data has arrived.
      final accessList = deck.usersAccess;
      accessList.value
          .forEach((a) => updates['decks/${a.key}/${deck.key}'] = null);
    }

    return _write(updates);
  }

  Future<void> createCard({
    @required CardModel card,
    bool addReversed = false,
  }) {
    final updates = <String, dynamic>{};

    void addCard({bool reverse = false}) {
      final cardKey = _newKey();
      final cardPath = 'cards/${card.deckKey}/$cardKey';
      final scheduledCardPath = 'learning/$uid/${card.deckKey}/$cardKey';
      var repeatAt = DateTime.now().millisecondsSinceEpoch.toDouble();
      if (reverse) {
        // Put reversed card into a random position behind to avoid it showing
        // right next to the forward card.
        repeatAt *= Random().nextDouble();
      }
      updates.addAll({
        '$cardPath/front': reverse ? card.back : card.front,
        '$cardPath/back': reverse ? card.front : card.back,
        // Important note: we ask server to fill in the timestamp, but we do not
        // update it in our object immediately. Something trivial like
        // 'await get(...).first' would work most of the time. But when offline,
        // Firebase "lies" to the application, replacing ServerValue.TIMESTAMP
        // with phone's time, although later it saves to the server correctly.
        // For this reason, we should never *update* createdAt because we risk
        // changing it (see the note above), in which case Firebase Database
        // will reject the update.
        '$cardPath/createdAt': ServerValue.timestamp,
        '$scheduledCardPath/level': 0,
        // Set random time to shuffle cards when they are created
        '$scheduledCardPath/repeatAt': repeatAt.floor(),
      });
    }

    addCard();
    if (addReversed) {
      addCard(reverse: true);
    }

    return _write(updates);
  }

  Future<void> updateCard({@required CardModel card}) {
    final cardPath = 'cards/${card.deckKey}/${card.key}';
    return _write({
      '$cardPath/front': card.front,
      '$cardPath/back': card.back,
    });
  }

  Future<void> deleteCard({@required CardModel card}) => _write({
        'cards/${card.deckKey}/${card.key}': null,
        'learning/$uid/${card.deckKey}/${card.key}': null,
      });

  Future<void> learnCard({
    @required ScheduledCardModel unansweredScheduledCard,
    @required bool knows,
    @required bool learnBeyondHorizon,
  }) {
    final cardReply =
        CardReplyModel.fromScheduledCard(unansweredScheduledCard, reply: knows);
    final scheduledCard = unansweredScheduledCard.answer(
        knows: knows, learnBeyondHorizon: learnBeyondHorizon);
    final scheduledCardPath =
        'learning/$uid/${scheduledCard.deckKey}/${scheduledCard.key}';
    final cardViewPath =
        'views/$uid/${scheduledCard.deckKey}/${scheduledCard.key}/${_newKey()}';
    return _write({
      '$scheduledCardPath/level': scheduledCard.level,
      '$scheduledCardPath/repeatAt':
          scheduledCard.repeatAt.millisecondsSinceEpoch,
      '$cardViewPath/levelBefore': cardReply.levelBefore,
      '$cardViewPath/reply': cardReply.reply,
      '$cardViewPath/timestamp': cardReply.timestamp.millisecondsSinceEpoch,
    });
  }

  Future<void> unshareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
  }) =>
      _write({
        'deck_access/${deck.key}/$shareWithUid': null,
        'decks/$shareWithUid/${deck.key}': null,
      });

  Future<void> shareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
    @required AccessType access,
    String sharedDeckName,
    String shareWithUserEmail,
  }) async {
    final deckAccessPath = 'deck_access/${deck.key}/$shareWithUid';
    final deckPath = 'decks/$shareWithUid/${deck.key}';
    final updates = <String, dynamic>{
      '$deckAccessPath/access': access.toString(),
      '$deckPath/access': access.toString(),
    };
    if ((await DeckAccessModel.get(deckKey: deck.key, key: shareWithUid).first)
            .key ==
        null) {
      // If there's no DeckAccess, assume the deck hasn't been shared yet, as
      // opposed to changing access level for a previously shared deck.
      updates.addAll({
        '$deckPath/name': deck.name,
        '$deckPath/markdown': deck.markdown,
        '$deckPath/deckType': deck.type.toString().toUpperCase(),
        '$deckPath/accepted': false,
        '$deckPath/lastSyncAt': 0,
        '$deckPath/category': deck.category,
        // Do not save displayName and photoUrl because these are populated by
        // Cloud functions.
        '$deckAccessPath/email': shareWithUserEmail,
      });
    }

    return _write(updates);
  }

  Future<void> addFCM({@required FCM fcm}) => _write({
        'fcm/$uid/${fcm.key}': {
          'name': fcm.name,
          'language': fcm.language,
        }
      });

  Future<void> cleanupDanglingScheduledCard(ScheduledCardModel sc) => _write({
        'learning/$uid/${sc.deckKey}/${sc.key}': null,
      });

  Future<void> _write(Map<String, dynamic> updates) async {
    // Firebase update() does not return until it gets response from the server.
    final updateFuture = FirebaseDatabase.instance.reference().update(updates);

    if (isOnline.value != true) {
      unawaited(updateFuture.catchError((error, stackTrace) => error_reporting
          .report('DataWriter', error, stackTrace,
              extra: {'updates': updates, 'online': false})));
      return;
    }

    try {
      await updateFuture;
    } catch (error, stackTrace) {
      unawaited(error_reporting.report('DataWriter', error, stackTrace,
          extra: {'updates': updates, 'online': true}));
      rethrow;
    }
  }

  String _newKey() => FirebaseDatabase.instance.reference().push().key;
}
