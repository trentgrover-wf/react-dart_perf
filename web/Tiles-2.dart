import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:squares/squares.dart';
import 'package:squares/squares_browser.dart';

void main() {
  initTilesBrowserConfiguration();

  num counter = 0;

  void reactAnimate() {
    mountComponent(boxesView()..props = {'count': counter++},
        querySelector('#example-container'));
    new Timer(Duration.ZERO, reactAnimate);
  }
  ;

  new Timer(Duration.ZERO, reactAnimate);
}

ComponentDescriptionFactory boxView = registerComponent(
    ({props, children}) => new BoxView()
  ..props = props
  ..children = children);
class BoxView extends Component {
  render() {
    var count = this.props['count'];
    return div(
        props: {'className': 'box-view'},
        children: [
      div(
          props: {
        'className': 'box',
        'style':
            'top:${sin(count / 10) * 10}px; left:${cos(count / 10) * 10}px; background:rgb(0, 0, ${count % 255})'
      },
          children: (count % 100).toString())
    ]);
  }
}

ComponentDescriptionFactory boxesView = registerComponent(
    ({props, children}) => new BoxesView()
  ..props = props
  ..children = children);
class BoxesView extends Component {
  render() {
    var N = 250;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      boxes.add(boxView()
        ..key = i
        ..props = {'count': this.props['count'] + i});
    }
    return div(children: boxes);
  }
}
