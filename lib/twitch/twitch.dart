/// Twitch: A Faster Binding to React.js
///
/// Performance tests show over a 2x performance improvement when using this
/// wrapper instead of the react-dart wrapper.
library w_virtual_components.twitch;

import 'dart:html';
import 'dart:js';

import 'package:react-dart_perf/twitch/stream_listener.dart';

typedef Element _DOMNodeGetter();
typedef bool _StateSetter(Map<String, dynamic> newState);

/// A factory for creating new [Component] instances.
///
/// Dart does not provide a way to instantiate Types, so this fills that gap.
typedef Component ComponentFactory();

/// A registrar for [Component] types used to generate a [TwitchElementFactory]
/// with an API that works in the React style.
///
///     var myComponent = registerComponent(() => new _MyComponent());
///     class _MyComponent extends Component {
///       // ...
///     }
///
///     JsObject renderedComponent = myComponent(props, children);
///
TwitchElementFactory registerComponent(ComponentFactory componentFactory) {
  var proxy = new _JsProxy();
  return new TwitchElementFactory._(componentFactory, proxy);
}

/// A factory used to create new or update existing [TwitchElement] instances
/// for a single [Component] type.
class TwitchElementFactory implements Function {
  final ComponentFactory _componentFactory;
  Map<String, _TwitchElement> _elementInstanceMap = {};
  final _JsProxy _proxy;
  Map<String, dynamic> _prevProps;
  Map<String, dynamic> _prevState;

  // Instantiate via [registerComponent].
  TwitchElementFactory._(this._componentFactory, this._proxy);

  /// Returns a JsObject representing the proxied output of a [Component].
  ///
  /// [key] must be unique among instances of a single [Component] type. It is
  /// required to ensure that later invocations update an existing [Component]
  /// instead of creating a new instance.
  JsObject call(String instanceKey, Map<String, dynamic> props,
      [dynamic children]) {
    var shouldRender = true;
    // TODO: Ideally, this key could be generated internally,
    // removing the global uniqueness requirement from consumers.
    var element = _elementInstanceMap[instanceKey];
    if (element != null) {
      shouldRender = element.updateComponent(props, children);
    } else {
      element = new _TwitchElement(_componentFactory, _proxy,
          // Manage instance map. In some circumstance, React will oddly unmount
          // and then update components without firing willMount. So need to add
          // entries to map both when component didMount and didUpdate.
          onDidMount: () => _elementInstanceMap[instanceKey] = element,
          onDidUpdate: () => _elementInstanceMap[instanceKey] = element,
          onWillUnmount: () => _elementInstanceMap.remove(instanceKey));
      element.mountComponent(instanceKey, props, children);
    }
    return shouldRender ? element.render() : element.lastRenderedOutput;
  }
}

/// A facade connecting a [Component] instance to its underlying JavaScript
/// representation, accessible via a [_JsProxy].
class _TwitchElement {
  Component _component;
  final ComponentFactory _componentFactory;
  bool _isRendering = false;
  JsObject _jsComponent;
  JsObject _lastRenderedOutput;
  Function _onDidMount;
  Function _onDidUpdate;
  Function _onWillUnmount;
  Map<String, dynamic> _prevProps;
  Map<String, dynamic> _prevState;
  final _JsProxy _proxy;

  _TwitchElement(this._componentFactory, this._proxy,
      {void onWillUnmount(), void onDidMount(), void onDidUpdate()}) {
    _onDidMount = onDidMount;
    _onDidUpdate = onDidUpdate;
    _onWillUnmount = onWillUnmount;
  }

  Component get component => _component;

  JsObject get jsComponent => _jsComponent;

  JsObject get lastRenderedOutput => _lastRenderedOutput;

  void mountComponent(
      String instanceKey, Map<String, dynamic> props, dynamic children) {
    _isRendering = true;
    _component = _componentFactory();
    _component
      .._instanceKey = instanceKey
      .._state = _component.getInitialState()
      .._setStateDelegate = _setState
      .._redrawDelegate = _jsRedraw
      .._getDOMNodeDelegate = _jsFindDOMNode;
    var propsWithDefaults = _component.getDefaultProps()..addAll(props);
    _updateProps(propsWithDefaults, children);
    _component.componentWillMount();
  }

  bool updateComponent(Map<String, dynamic> props, dynamic children) {
    var shouldRender = false;
    _isRendering = true;
    var propsWithDefaults = _component.getDefaultProps()..addAll(props);
    _component.componentWillReceiveProps(propsWithDefaults);
    _prevProps = _component.props;
    var prevState = _component.state;
    shouldRender =
        _component.shouldComponentUpdate(propsWithDefaults, prevState);
    if (shouldRender) {
      _component.componentWillUpdate(propsWithDefaults, prevState);
    }
    // Update props regardless of whether shouldComponentUpdate.
    _updateProps(propsWithDefaults, children);
    if (!shouldRender) {
      _isRendering = false;
    }
    return shouldRender;
  }

  JsObject render() {
    var _lastRenderedOutput = _proxy.render(
        component, onJsWillMount, onJsDidMount, onJsDidUpdate, onJsWillUnmount);
    return _lastRenderedOutput;
  }

  void onJsWillMount(JsObject jsComponent) {
    _jsComponent = jsComponent;
  }

  void onJsDidMount() {
    _isRendering = false;
    _component._isMounted = true;
    _component.componentDidMount();
    _onDidMount();
  }

  void onJsDidUpdate() {
    _isRendering = false;
    _component.componentDidUpdate(_prevProps, _prevState);
    _onDidUpdate();
  }

  void onJsWillUnmount() {
    _component._componentWillUnmount();
    _onWillUnmount();
  }

  Element _jsFindDOMNode() {
    if (_jsComponent == null) {
      throw new StateError(
          'Ensure the component is mounted before calling `findDOMNode`');
    }
    return _proxy.findDOMNode(_jsComponent);
  }

  void _jsRedraw() {
    if (!_isRendering) {
      _proxy.redraw(_component, _jsComponent);
    }
  }

  bool _setState(Map<String, dynamic> newState) {
    var shouldRender = false;
    _prevState = component.state;
    var nextState = {}..addAll(_prevState)..addAll(newState);
    if (!_isRendering) {
      var nextProps = _component.props;
      shouldRender = _component.shouldComponentUpdate(nextProps, nextState);
      if (shouldRender) {
        _component.componentWillUpdate(nextProps, nextState);
      }
    }
    // Set state regardless of whether element should render or not.
    _component._state = nextState;
    return shouldRender;
  }

  void _updateProps(Map<String, dynamic> props, dynamic children) {
    if (children is! Iterable) {
      children = [children];
    }
    _component
      .._children = children
      .._props = props;
  }
}

/// A facade over dart:js interop.
class _JsProxy<TComponent extends Component> {
  static JsObject _React = context['React'];
  static JsObject _Twitch = context['Twitch'];
  JsFunction _jsComponentFactory;

  _JsProxy() {
    _jsComponentFactory = _Twitch.callMethod('createFactory');
  }

  Element findDOMNode(JsObject jsComponent) {
    return _React.callMethod('findDOMNode', [jsComponent]);
  }

  void redraw(Component component, JsObject jsComponent) {
    jsComponent.callMethod('setState',
        [new JsObject.jsify({'renderedComponent': component.render()})]);
  }

  JsObject render(Component component, void onJsWillMount(JsObject jsComponent),
      void onJsDidMount(), void onJsDidUpdate(), void onJsWillUnmount()) {
    return _jsComponentFactory.apply([
      new JsObject.jsify({
        'key': component.key,
        'renderedComponent': component.render(),
        'willMount': onJsWillMount,
        'didMount': onJsDidMount,
        'didUpdate': onJsDidUpdate,
        'willUnmount': onJsWillUnmount
      })
    ]);
  }
}

/// An extensible class used to create custom React components.
///
/// Instances of [Component] are connected to their JavaScript representations
/// via [TwitchElement].
abstract class Component extends StreamListener {
  List _children;
  Map<String, dynamic> _props;
  Map<String, dynamic> _state;
  String _instanceKey;
  bool _isMounted = false;
  _DOMNodeGetter _getDOMNodeDelegate;
  Function _redrawDelegate;
  _StateSetter _setStateDelegate;

  List get children => _children;

  String get instanceKey => _instanceKey;

  bool get isMounted => _isMounted;

  String get key => props['key'];

  Map<String, dynamic> get props => _props;

  Map<String, dynamic> get state => _state;

  Map<String, dynamic> getInitialState() => {};

  Map<String, dynamic> getDefaultProps() => {};

  Element getDOMNode() {
    return _getDOMNodeDelegate();
  }

  void componentWillMount() {}

  JsObject render();

  void componentDidMount() {}

  void componentWillReceiveProps(Map<String, dynamic> newProps) {}

  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) => true;

  void componentWillUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState) {}

  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState) {}

  void setState(Map<String, dynamic> newState) {
    var shouldRender = _setStateDelegate(newState);
    if (shouldRender) {
      redraw();
    }
  }

  void redraw() {
    _redrawDelegate();
  }

  void componentWillUnmount() {}

  void _componentWillUnmount() {
    cancelSubscriptions();
    componentWillUnmount();
  }
}
