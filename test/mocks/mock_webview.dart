import 'package:webview_flutter/webview_flutter.dart';

/// A mock implementation of [WebViewController] for testing purposes.
/// 
/// This mock captures JavaScript code that would be executed and provides
/// methods to verify the expected behavior in tests without requiring
/// an actual WebView instance.
class MockWebViewController implements WebViewController {
  /// Stores JavaScript code strings that have been executed.
  final List<String> jsCode = [];

  /// Records JavaScript code instead of executing it in a real WebView.
  /// 
  /// @param javaScriptString The JavaScript code that would be executed
  @override
  Future<void> runJavaScript(String javaScriptString) async {
    jsCode.add(javaScriptString);
    return Future.value();
  }

  /// Simulates adding a JavaScript channel to the WebView.
  /// 
  /// @param name The name of the JavaScript channel
  /// @param onMessageReceived Callback for when messages are received
  @override
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage) onMessageReceived,
  }) async {
    return Future.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

/// A mock implementation of [JavaScriptMessage] for testing purposes.
/// 
/// This class simulates messages that would be received from JavaScript
/// in a real WebView implementation.
class MockJavaScriptMessage implements JavaScriptMessage {
  /// The message content
  final String _message;

  /// Creates a mock JavaScript message with the specified content.
  /// 
  /// @param message The message content
  MockJavaScriptMessage(this._message);

  /// Returns the message content.
  @override
  String get message => _message;
}
