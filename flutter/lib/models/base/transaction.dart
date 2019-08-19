import 'dart:async';

import 'package:delern_flutter/models/base/model.dart';
import 'package:delern_flutter/models/card_reply_model.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:firebase_database/firebase_database.dart';
import 'package:pedantic/pedantic.dart';

class Transaction {
  final _updates = <String, dynamic>{};

  static bool _isOnline = false;
  static DatabaseReference get _root => FirebaseDatabase.instance.reference();

  static void subscribeToOnlineStatus() {
    FirebaseDatabase.instance
        .reference()
        .child('.info/connected')
        .onValue
        .listen((event) {
      _isOnline = event.snapshot.value;
    });
  }

  void save(ReadonlyModel m) {
    if (m.key == null) {
      if (m is Model) {
        m.key = _root.child(m.rootPath).push().key;
      } else {
        throw ArgumentError(
            'Trying to save read-only value $m, but cannot assign a key!');
      }
      _updates.addAll(m.toMap(isNew: true));
    } else {
      _updates.addAll(m.toMap(isNew: false));
    }
  }

  void delete(Model m) {
    assert(m.key != null, 'Attempt to delete a model without a key!');
    _updates['${m.rootPath}/${m.key}'] = null;
  }

  void deleteAll(ReadonlyModel m) {
    // CardReplyModel assigns key from the beginning.
    assert(
        m.key == null || m is CardReplyModel,
        'Attempt to delete all models with the same root, but the key is '
        'specified!');
    _updates[m.rootPath] = null;
  }

  Future<void> commit() async {
    // Firebase update() does not return until it gets response from the server.
    final updateFuture = _root.update(_updates);

    if (!_isOnline) {
      unawaited(updateFuture.catchError((error, stackTrace) => error_reporting
          .report('Transaction', error, stackTrace,
              extra: {'updates': _updates, 'online': false})));
      return;
    }

    try {
      await updateFuture;
    } catch (error, stackTrace) {
      unawaited(error_reporting.report('Transaction', error, stackTrace,
          extra: {'updates': _updates, 'online': true}));
      rethrow;
    }
  }
}
