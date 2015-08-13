import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;
import 'package:react-dart_perf/twitch/twitch.dart' as Twitch;

void main() {
  reactClient.setClientConfiguration();

  num counter = 0;

  void reactAnimate() {
    react.render(
        boxesView('boxesViewKey', {'count': counter++}), querySelector('#example-container'));
    new Timer(Duration.ZERO, reactAnimate);
  }
  ;

  new Timer(Duration.ZERO, reactAnimate);
}

var boxView = Twitch.registerComponent(() => new BoxView());
class BoxView extends Twitch.Component {
  render() {
    var count = this.props['count'];
    return (react.div({'className': "box-view"}, react.div({
      'className': 'box',
      'style': {
        'top': sin(count / 10) * 10,
        'left': cos(count / 10) * 10,
        'background': 'rgb(0, 0,' + (count % 255).toString() + ')'
      }
    }, count % 100)));
  }
}

var boxesView = Twitch.registerComponent(() => new BoxesView());
class BoxesView extends Twitch.Component {
  render() {
    var N = 250;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      boxes.add(boxView('boxView$i', {'key': '$i', 'count': this.props['count'] + i}));
    }
    return react.div({}, boxes);
  }
}
