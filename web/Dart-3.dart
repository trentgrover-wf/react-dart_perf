import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:react/react.dart' as react;

void main() {

  num counter = 0;

  void reactAnimate() {
    react.render(
        boxesView({'count': counter++}), querySelector('#example-container'));
    new Timer(Duration.ZERO, reactAnimate);
  }
  ;

  new Timer(Duration.ZERO, reactAnimate);
}

react.ComponentFactory boxViewInternal = react.registerComponent(() => new BoxViewInternal());
class BoxViewInternal extends react.Component {
  react.ReactElement render() {
    var count = this.props['count'];
    return (react.div({
      'className': 'box',
      'style': {
        'top': sin(count / 10) * 10,
        'left': cos(count / 10) * 10,
        'background': 'rgb(0, 0,' + (count % 255).toString() + ')'
      }
    }, count % 100));
  }
}

react.ComponentFactory boxView = react.registerComponent(() => new BoxView());
class BoxView extends react.Component {
  react.ReactElement render() {
    return (react.div({
      'className': "box-view"
    }, boxViewInternal({'count': this.props['count']})));
  }
}

react.ComponentFactory boxesView = react.registerComponent(() => new BoxesView());
class BoxesView extends react.Component {
  react.ReactElement render() {
    var N = 250;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      boxes.add(boxView({'key': i, 'count': this.props['count'] + i}));
    }
    return react.div({}, boxes);
  }
}
