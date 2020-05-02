import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

var _clock = const Clock();

/// Global instance of the current time provider (may be swapped for testing).
Clock get clock => _clock;

@visibleForTesting
set clock(Clock newClock) {
  // This code is visible for testing only and must never run in production.
  // ignore: avoid_print
  print('Swapping clock with now ${_clock.now()} for ${newClock.now()}.');
  _clock = newClock;
}
