# react-dart_perf
Sample code to compare React component perf between JavaScript and React-Dart

## Benchmark Component

![Base React Component](/pics/component.png?raw=true)

- Simple component that renders animated balls onscreen as fast as the browser and React will allow (intended to be used to compare performance characteristics between identical implementations in JS and Dart, not as an optimized use of React)

- Implented 6 different variations of React component hierarchies that produce identical resulting HTML markup:
  - `JS-1`: JavaScript implementation of the markup as a single React component (1 render function)
  - `JS-2`: JavaScript implementation that uses a hierarchy of 2 different React components to achieve the same result
  - `JS-3`: JavaScript implementation that uses a hierarchy of 3 different React components to achieve the same result
  - `Dart-1`: JS-1 as implemented with React-Dart
  - `Dart-2`: JS-2 as implemented with React-Dart
  - `Dart-3`: JS-3 as implemented with React-Dart

- Implemented matching UIX components as a performance comparison (`UIX-1`, `UIX-2`, `UIX-3`)

## Basic Performance Results

Animation of 250 'Dots' in Chrome (fps)

Hierarchy Complexity | React (JavaScript) | React-Dart | UIX | Tiles
-------------------- | ------------------ | ---------- | --- | -----
1                    | 42                 | 23         | 50  | 36
2                    | 41                 | 11         | 43  | 33
3                    | 40                 | 8          | 40  | 30

- In JS, performance degrades slightly as React component hierarchy increases in complexity
- In React-Dart, performance degrades significantly faster as React component hierarchy increases in complexity
- Overall React-Dart performance is significantly slower (likely mostly due to Dart-JS interop overhead)

## Timeline Comparisons

### Render loop of `JS-1`
- Note: 3ms component `render`

![JS-1 Render Loop](/pics/1_component_JS.png?raw=true)

### Render loop of `Dart-1`
- Note: 20ms component `render` with significant Dart-JS interop overhead

![Dart-1 Render Loop](/pics/1_component_dart.png?raw=true)

### Render loop of `Dart-2`
- Note: increased Dart-JS interop overhead sprinkled throughout the render cycle

![Dart-2 Render Loop](/pics/2_components_dart.png?raw=true)

### Render loop of `Dart-3`
- Note: increased Dart-JS interop overhead sprinkled throughout the render cycle

![Dart-3 Render Loop](/pics/3_components_dart.png?raw=true)
