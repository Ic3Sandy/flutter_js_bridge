<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Flutter JS Bridge

A Flutter library for seamless communication between JavaScript (WebView) and Flutter. This library provides a simple and robust API for bidirectional communication between your Flutter application and JavaScript code running in a WebView.

## Features

- ✅ Two-way communication between Flutter and JavaScript
- ✅ Send data from Flutter to JavaScript
- ✅ Receive data from JavaScript in Flutter
- ✅ Call JavaScript functions from Flutter
- ✅ Call Flutter methods from JavaScript
- ✅ Support for asynchronous calls with Promise-based responses
- ✅ Easy-to-use API for both Flutter and JavaScript sides

## TODO / Planned Features

- [ ] Type safety & serialization: Support for custom serialization/deserialization of complex Dart and JS objects, and safe type-checking utilities.
- [ ] Event broadcasting: System for broadcasting events between JS and Flutter with multiple listeners.
- [ ] Plugin/extension system: Allow registration of plugins/extensions on either side for reusable communication patterns.
- [ ] Debugging tools: Logging and debugging utilities for inspecting messages and errors.
- [ ] Security features: Message validation, origin checks, and permission controls.
- [ ] Queue & retry mechanism: Message queuing and retry logic for unreliable states.
- [ ] Batch messaging: Support for batching multiple messages/commands for performance.
- [ ] Lifecycle integration: Hooks for Flutter app lifecycle events to notify JS or manage bridge state.
- [ ] Testing utilities: Mock/test tools for simulating JS–Flutter communication in tests.
- [ ] Documentation & example expansion: More advanced examples, error handling, and best practices.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_js_bridge: ^0.0.1
```

### Development Version

To use the development version from the Git repository:

```yaml
dependencies:
  flutter_js_bridge:
    git:
      url: https://github.com/YOUR_USERNAME/flutter_js_bridge.git
      ref: main
```

Replace `YOUR_USERNAME` with your GitHub username after pushing to GitHub.

## Usage

### Basic Setup

1. Import the package:

```dart
import 'package:flutter_js_bridge/flutter_js_bridge.dart';
```

2. Create a JSBridgeWebView:

```dart
JSBridgeWebView(
  initialUrl: 'https://example.com',
  onWebViewCreated: (controller) {
    // Store the controller for later use
    _controller = controller;
    
    // Register handlers to receive calls from JavaScript
    _controller.registerHandler('myHandler', (args) {
      print('Received from JavaScript: $args');
      return 'Response from Flutter';
    });
  },
  onPageFinished: (controller, url) {
    print('Page finished loading: $url');
  },
)
```

### Communication from Flutter to JavaScript

#### Call JavaScript and get a response:

```dart
try {
  final result = await _controller.callJavaScript('myJsFunction', data: {
    'message': 'Hello from Flutter!',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
  
  print('JavaScript response: $result');
} catch (e) {
  print('Error calling JavaScript: $e');
}
```

#### Send data to JavaScript without expecting a response:

```dart
_controller.sendToJavaScript('updateData', data: {
  'count': 42,
  'items': ['Apple', 'Banana', 'Orange'],
});
```

### Communication from JavaScript to Flutter

In your HTML/JavaScript code, you need to:

1. Wait for the bridge to be ready:

```javascript
document.addEventListener('FlutterJSBridgeReady', function() {
  // Bridge is ready, you can now call Flutter
  console.log('Bridge is ready!');
});
```

2. Call Flutter methods and get responses:

```javascript
// Call a Flutter method with Promise-based response
window.FlutterJSBridge.callFlutter('myHandler', { data: 'some data' })
  .then(function(response) {
    console.log('Response from Flutter:', response);
  })
  .catch(function(error) {
    console.error('Error:', error);
  });
```

3. Send data to Flutter without expecting a response:

```javascript
window.FlutterJSBridge.sendToFlutter('eventName', {
  message: 'Data from JavaScript',
  time: new Date().toISOString()
});
```

4. Register handlers for Flutter to call:

```javascript
window.FlutterJSBridge.registerHandler('callFromFlutter', function(data) {
  console.log('Called from Flutter with:', data);
  return 'Response to Flutter';
});
```

## Advanced Usage

### Customizing JavaScript Channel Name

You can customize the name of the JavaScript channel (default is `FlutterJSBridge`):

```dart
JSBridgeWebView(
  javascriptChannelName: 'MyCustomBridge',
  // ... other parameters
)
```

Then in JavaScript, use:

```javascript
window.MyCustomBridge.callFlutter('myHandler', data);
```

### Initializing with HTML Content

You can initialize the WebView with custom HTML content:

```dart
JSBridgeWebView(
  initialHtml: '''
    <!DOCTYPE html>
    <html>
    <head>
      <title>My WebView</title>
    </head>
    <body>
      <h1>Hello from Flutter JS Bridge</h1>
      <script>
        document.addEventListener('FlutterJSBridgeReady', function() {
          console.log('Bridge is ready!');
        });
      </script>
    </body>
    </html>
  ''',
  // ... other parameters
)
```

### Loading Content from Flutter Assets

You can also load HTML content from Flutter assets:

```dart
JSBridgeWebView(
  initialAsset: 'assets/index.html',
  // ... other parameters
)
```

## Complete Example

Check the `example` directory for a complete example of the library in action.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
