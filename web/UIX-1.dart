import 'dart:html' as html;
import 'dart:math';
import 'dart:async';

import 'package:uix/uix.dart';


main() {
  initUix();

  num counter = 0;

  final component = new BoxesView()..data = counter++;
  injectComponent(component, html.querySelector('#example-container'));

  void uixAnimate() {
    component.data = counter++;
    component.updateState();
    new Timer(Duration.ZERO, uixAnimate);
  };

  new Timer(Duration.ZERO, uixAnimate);
}

class BoxesView extends Component<num> {

  updateView() {
    num N = 250;
    num count = data;
    List<VNode> boxes = new List<VNode>();
    for (var i = 0; i < N; i++) {
      var inCount = count + i;
      boxes.add(
        vElement('div', classes: const ['box-view'])(
          vElement('div',
          classes: const ['box'],
          style: {
            'top': (sin(inCount / 10) * 10).toString() + 'px',
            'left': (cos(inCount / 10) * 10).toString() + 'px',
            'background': 'rgb(0, 0,' + (inCount % 255).toString() + ')'
          })
          (
              (count % 100).toString()
          )
        )
      );
    }
    updateRoot(vRoot()(boxes));
  }
}
