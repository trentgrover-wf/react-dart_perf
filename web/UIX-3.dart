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

$BoxViewInternal() => new BoxViewInternal();
class BoxViewInternal extends Component<num> {

  updateView() {
    num count = data;
    updateRoot(vRoot()(
      vElement('div',
      classes: const ['box'],
      style: {
        'top': (sin(count / 10) * 10).toString() + 'px',
        'left': (cos(count / 10) * 10).toString() + 'px',
        'background': 'rgb(0, 0,' + (count % 255).toString() + ')'
      })
      (
        (count % 100).toString()
      )
    )
    );
  }
}


$BoxView() => new BoxView();
class BoxView extends Component<num> {
  updateView() {
    updateRoot(vRoot()([
      vElement('div', classes: const ['box-view'])(
          vComponent($BoxViewInternal, data: data)
      )
    ]));
  }
}


class BoxesView extends Component<num> {

  updateView() {
    num N = 250;
    List<VNode> boxes = new List<VNode>();
    for (var i = 0; i < N; i++) {
      boxes.add(vComponent($BoxView, data: data + i));
    }
    updateRoot(vRoot()(boxes));
  }
}
