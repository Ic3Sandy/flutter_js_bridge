import 'dart:async';

/// A simple mock for JavaScript channel messages
class JavaScriptMessage {
  final String message;
  JavaScriptMessage(this.message);
}

/// Callback type for JavaScript channel messages
typedef JavaScriptChannelCallback = void Function(JavaScriptMessage message);

/// A simple mock implementation of a WebViewController for testing in CLI
class MockWebViewController {
  final Map<String, JavaScriptChannelCallback> _channels = {};
  final Map<String, dynamic> _mockJavaScriptResults = {};
  
  /// Callback for when JavaScript is run
  void Function(String code)? onJavaScriptRun;
  
  /// Simulates a message from JavaScript
  void simulateMessageFromJavaScript(String message) {
    // Find the channel that should receive this message
    if (_channels.containsKey('FlutterJSBridge')) {
      final callback = _channels['FlutterJSBridge']!;
      callback(JavaScriptMessage(message));
    }
  }
  
  /// Set a mock result for a JavaScript call
  void setMockJavaScriptResult(String code, dynamic result) {
    _mockJavaScriptResults[code] = result;
  }

  /// Add a JavaScript channel
  Future<void> addJavaScriptChannel(
    String name, {
    required JavaScriptChannelCallback onMessageReceived,
  }) async {
    _channels[name] = onMessageReceived;
  }

  /// Remove a JavaScript channel
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    _channels.remove(javaScriptChannelName);
  }

  /// Run JavaScript code and return a result
  Future<String?> runJavaScriptReturningResult(String javaScript) {
    onJavaScriptRun?.call(javaScript);
    
    // Check if we have a mock result for this code
    if (_mockJavaScriptResults.containsKey(javaScript)) {
      return Future.value(_mockJavaScriptResults[javaScript].toString());
    }
    
    // Default mock implementation for the bridge
    if (javaScript.contains('FlutterJSBridge.receiveMessage')) {
      return Future.value('null');
    }
    
    return Future.value('null');
  }

  /// Run JavaScript code without returning a result
  Future<void> runJavaScript(String javaScript) {
    onJavaScriptRun?.call(javaScript);
    return Future.value();
  }
}
