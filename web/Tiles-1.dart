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

ComponentDescriptionFactory boxesView = registerComponent(({props, children}) => new BoxesView(props, children));
class BoxesView extends Component {

  BoxesView(props, [children]): super(props, children);

  render() {
    var N = 250;
    var count = this.props['count'] + 1;
    var boxes = [];
    for (var i = 0; i < N; i++) {
      var inCount = count + i;
      boxes.add(div(
          props: {'class': 'box-view'},
          children: [
        div(
            props: {
          'class': 'box',
          'style':
              'top:${sin(inCount / 10) * 10}px; left:${cos(inCount / 10) * 10}px; background:rgb(0, 0, ${inCount % 255})'
        },
            children: (inCount % 100).toString())
      ]));
    }
    return div(children: boxes);
  }
}
