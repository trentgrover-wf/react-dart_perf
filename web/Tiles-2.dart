import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:tiles/tiles.dart';
import 'package:tiles/tiles_browser.dart';

void main() {
  initTilesBrowserConfiguration();

  num counter = 0;

  void reactAnimate() {
    mountComponent(boxesView(props: {'count': counter++}),
        querySelector('#example-container'));
    new Timer(Duration.ZERO, reactAnimate);
  }
  ;

  new Timer(Duration.ZERO, reactAnimate);
}

ComponentDescriptionFactory boxView = registerComponent(({props, children}) => new BoxView(props, children));
class BoxView extends Component {

  BoxView(props, [children]): super(props, children);

  render() {
    var count = this.props['count'];
    return div(
        props: {'class': 'box-view'},
        children: [
      div(
          props: {
        'class': 'box',
        'style':
            'top:${sin(count / 10) * 10}px; left:${cos(count / 10) * 10}px; background:rgb(0, 0, ${count % 255})'
      },
          children: (count % 100).toString())
    ]);
  }
}

ComponentDescriptionFactory boxesView = registerComponent(({props, children}) => new BoxesView(props, children));
class BoxesView extends Component {

  BoxesView(props, [children]): super(props, children);

  render() {
    var N = 250;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      boxes.add(boxView(props: {'count': this.props['count'] + i}, key: i));
    }
    return div(children: boxes);
  }
}
