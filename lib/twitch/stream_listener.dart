library w_virtual_components.src.util.stream_listener;

import 'dart:async';

abstract class StreamListener {
  List<StreamSubscription> _subscriptions = [];
  Map<dynamic, List<StreamSubscription>> _keyedSubscriptions = {};

  void addSubscription(StreamSubscription subscription, [dynamic key]) {
    _subscriptions.add(subscription);
    if (key != null) {
      var keyedSubscriptions = _keyedSubscriptions.putIfAbsent(key, () => []);
      keyedSubscriptions.add(subscription);
    }
  }

  void cancelSubscriptions([dynamic key]) {
    if (key != null) {
      if (_keyedSubscriptions.containsKey(key)) {
        _keyedSubscriptions[key].forEach((s) {
          s.cancel();
          _subscriptions.remove(s);
        });
        _keyedSubscriptions.remove(key);
      }
    } else {
      _subscriptions.forEach((s) => s.cancel());
      _subscriptions.clear();
      _keyedSubscriptions.clear();
    }
  }
}
