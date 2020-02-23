import 'package:flutter/foundation.dart';
import 'package:quiver/time.dart';

var _clock = const Clock();

/// Global instance of the current time provider (may be swapped for testing).
Clock get clock => _clock;

@visibleForTesting
set clock(Clock newClock) {
  debugPrint('Swapping clock with now ${_clock.now()} for ${newClock.now()}.');
  _clock = newClock;
}
