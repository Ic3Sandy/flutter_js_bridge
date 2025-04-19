import 'dart:async';
import 'dart:math';
import 'js_message.dart';
import 'mock_webview_controller.dart';

/// Controller for managing JavaScript-Dart communication in CLI
class JSBridgeController {
  /// The MockWebViewController to interact with JavaScript
  final MockWebViewController webViewController;

  /// Map of pending callbacks for JavaScript responses
  final Map<String, Completer<dynamic>> _pendingCallbacks = {};

  /// Map of action handlers
  final Map<String, JSCallbackHandler> _actionHandlers = {};

  /// Random generator for message IDs
  final Random _random = Random();

  /// Name of the JavaScript channel for communication
  final String javaScriptChannelName;
  
  /// Default length for generated message IDs
  static const int _messageIdLength = 16;
  
  /// Character set for generating message IDs
  static const String _messageIdChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Creates a new JSBridgeController with the provided WebViewController
  /// 
  /// [webViewController] The WebViewController to interact with JavaScript
  /// [javaScriptChannelName] Name of the JavaScript channel for communication, defaults to 'FlutterJSBridge'
  JSBridgeController({
    required this.webViewController, 
    this.javaScriptChannelName = 'FlutterJSBridge'
  }) {
    _setupJavaScriptChannel();
  }

  /// Sets up the JavaScript channel for communication
  void _setupJavaScriptChannel() {
    // Add the JavaScript channel to the WebViewController
    webViewController.addJavaScriptChannel(
      javaScriptChannelName, 
      onMessageReceived: handleIncomingMessage
    );

    // In a real implementation, we would inject JavaScript bridge code here
    // For CLI testing, we'll simulate this
  }

  /// Handles messages coming from JavaScript
  /// 
  /// This method processes incoming messages from JavaScript, handling responses
  /// to pending requests and dispatching new actions to registered handlers.
  /// 
  /// [message] The JavaScriptMessage received from the WebView
  void handleIncomingMessage(JavaScriptMessage message) {
    try {
      final JSMessage jsMessage = JSMessage.fromJsonString(message.message);

      // Check if this is a response to a pending callback
      if (_pendingCallbacks.containsKey(jsMessage.id)) {
        final completer = _pendingCallbacks.remove(jsMessage.id)!;
        completer.complete(jsMessage.data);
        return;
      }

      // Process as a new action if a handler exists
      if (_actionHandlers.containsKey(jsMessage.action)) {
        final handler = _actionHandlers[jsMessage.action]!;
        // Execute the handler with the data as list of arguments
        final result = handler(jsMessage.data is List ? jsMessage.data : [jsMessage.data]);

        // If a response is expected, send it back
        if (jsMessage.expectsResponse) {
          _sendResponse(jsMessage.id, result);
        }
      } else {
        print('No handler registered for action: ${jsMessage.action}');
      }
    } catch (e) {
      print('Error handling JavaScript message: $e');
    }
  }

  /// Registers a handler for a specific JavaScript action
  /// 
  /// [action] The action name to register the handler for
  /// [handler] The callback function to execute when the action is received
  void registerHandler(String action, JSCallbackHandler handler) {
    if (action.isEmpty) {
      throw ArgumentError('Action name cannot be empty');
    }
    _actionHandlers[action] = handler;
  }

  /// Unregisters a handler for a specific JavaScript action
  /// 
  /// [action] The action name to unregister the handler for
  void unregisterHandler(String action) {
    _actionHandlers.remove(action);
  }

  /// Calls a JavaScript method with optional data and waits for a response
  /// 
  /// [action] The action name to call in JavaScript
  /// [data] Optional data to pass to the JavaScript method
  /// 
  /// Returns a Future that completes with the response from JavaScript
  Future<dynamic> callJavaScript(String action, {dynamic data}) {
    if (action.isEmpty) {
      throw ArgumentError('Action name cannot be empty');
    }
    
    final messageId = generateMessageId();
    final completer = Completer<dynamic>();

    // Store the callback for later resolution
    _pendingCallbacks[messageId] = completer;

    // Create message
    final message = JSMessage(id: messageId, action: action, data: data, expectsResponse: true);

    // Send message to JavaScript
    _sendMessageToJavaScript(message);

    return completer.future;
  }

  /// Sends a message to JavaScript without expecting a response
  /// 
  /// [action] The action name to call in JavaScript
  /// [data] Optional data to pass to the JavaScript method
  void sendToJavaScript(String action, {dynamic data}) {
    if (action.isEmpty) {
      throw ArgumentError('Action name cannot be empty');
    }
    
    // Create message
    final message = JSMessage(id: generateMessageId(), action: action, data: data, expectsResponse: false);

    // Send message to JavaScript
    _sendMessageToJavaScript(message);
  }

  /// Sends a response back for a specific message ID
  /// 
  /// [messageId] The ID of the message to respond to
  /// [result] The result data to send back
  void _sendResponse(String messageId, dynamic result) {
    final message = JSMessage(id: messageId, action: 'response', data: result, expectsResponse: false);
    _sendMessageToJavaScript(message);
  }

  /// Sends a message to JavaScript
  /// 
  /// [message] The JSMessage to send to JavaScript
  void _sendMessageToJavaScript(JSMessage message) {
    final jsonString = message.toJsonString().replaceAll("'", "\\'");
    final jsCode = "window.FlutterJSBridge.receiveMessage('$jsonString')";
    webViewController.runJavaScript(jsCode);
  }

  /// Generates a unique message ID
  /// 
  /// Returns a randomly generated string of characters to use as a message ID
  String generateMessageId() {
    return List.generate(_messageIdLength, 
      (index) => _messageIdChars[_random.nextInt(_messageIdChars.length)])
      .join();
  }
}

/// Callback function type for JavaScript interactions with return values
typedef JSCallbackHandler = dynamic Function(List<dynamic> arguments);
