# Twitch

> Fast Dart Binding for React.js

## Why Twitch?

The `react-dart` bindings are too slow for high-performance, highly-reactive
components. This is mostly due to the amount of `dart:js` interop involved in
the implementation, much of which can be avoided.

## Benefits

- Approximately 2x faster rendering performance for components.
- Works alongside existing components that use the `react-dart` wrapper.
- Can use `react-dart` DOM element factories inside `Twitch` components.
- Easy to upgrade existing `react-dart` components.
- Extra properties and more specific Types in method signatures.

## How It Works

- Component lifecycle fully managed in Dart.
- `props` and `state` are never proxied, and are more strongly typed.
- At render time, the JsObject returned by `render()` is passed to a JavaScript 
  proxy that simply echoes the output, without bouncing back into Dart code.
  
## API

##### `TwitchElementFactory registerComponent(ComponentFactory componentFactory)`

A registrar for `Component` types. Returns a `TwitchElementFactory`.

##### `class TwitchElementFactory`

A factory used to create new [TwitchElement] instances, or update existing
ones. This is API that you use when building up your virtual dom via calls to
`myComponent({'props': 'yes!'}, someDynamicChild)`. The factory creates internal
`_TwitchElement` instances, which connect [Component] instances with their 
underlying JavaScript representations.

```dart
class TwitchElementFactory implements Function {
  JsObject call(String instanceKey, Map<String, dynamic> props,
      [dynamic children]);
}
```

##### `class Component`

An extensible class used to create custom React components. It has a nearly
identical interface as the Component in `react-dart`, with some extra goodness.

``` dart
abstract class Component extends StreamListener {
  List get children;

  String get instanceKey;

  bool get isMounted;

  String get key;

  Map<String, dynamic> get props;

  Map<String, dynamic> get state;

  Map<String, dynamic> getInitialState();

  Map<String, dynamic> getDefaultProps();

  Element getDOMNode();

  void componentWillMount();

  JsObject render();

  void componentDidMount();

  void componentWillReceiveProps(Map<String, dynamic> newProps);

  bool shouldComponentUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState);

  void componentWillUpdate(
      Map<String, dynamic> nextProps, Map<String, dynamic> nextState);

  void componentDidUpdate(
      Map<String, dynamic> prevProps, Map<String, dynamic> prevState);

  void setState(Map<String, dynamic> newState);

  void redraw();

  void componentWillUnmount();
}
