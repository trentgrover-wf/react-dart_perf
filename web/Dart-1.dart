import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart' as reactClient;

void main() {
  reactClient.setClientConfiguration();

  num counter = 0;

  void reactAnimate() {
    react.render(
        boxesView({'count': counter++}), querySelector('#example-container'));
    new Timer(Duration.ZERO, reactAnimate);
  }
  ;

  new Timer(Duration.ZERO, reactAnimate);
}

var boxesView = react.registerComponent(() => new BoxesView());
class BoxesView extends react.Component {
  render() {
    var N = 250;
    var count = this.props['count'] + 1;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      var inCount = count + i;
      boxes.add(react.div({'className': "box-view"}, react.div({
        'className': 'box',
        'style': {
          'top': sin(inCount / 10) * 10,
          'left': cos(inCount / 10) * 10,
          'background': 'rgb(0, 0,' + (inCount % 255).toString() + ')'
        }
      }, inCount % 100)));
    }
    return react.div({}, boxes);
  }
}
