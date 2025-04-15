import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'js_message.dart';
import 'js_event.dart';

/// Controller for managing JavaScript-Flutter communication
class JSBridgeController {
  /// The WebViewController to interact with JavaScript
  final WebViewController webViewController;

  /// Map of pending callbacks for JavaScript responses
  final Map<String, Completer<dynamic>> _pendingCallbacks = {};

  /// Map of action handlers
  final Map<String, JSCallbackHandler> _actionHandlers = {};

  /// Random generator for message IDs
  final Random _random = Random();

  /// Name of the JavaScript channel for communication
  final String javaScriptChannelName;

  /// Creates a new JSBridgeController with the provided WebViewController
  JSBridgeController({required this.webViewController, this.javaScriptChannelName = 'FlutterJSBridge'}) {
    _setupJavaScriptChannel();
  }

  /// Sets up the JavaScript channel for communication
  void _setupJavaScriptChannel() {
    // Add the JavaScript channel to the WebViewController
    webViewController.addJavaScriptChannel(javaScriptChannelName, onMessageReceived: _handleIncomingMessage);

    // Inject the JavaScript bridge code
    webViewController.runJavaScript(_bridgeJavaScriptCode);
  }

  /// Handles messages coming from JavaScript
  void _handleIncomingMessage(JavaScriptMessage message) {
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
      }
    } catch (e) {
      debugPrint('Error handling JavaScript message: $e');
    }
  }

  /// Registers a handler for a specific JavaScript action
  void registerHandler(String action, JSCallbackHandler handler) {
    _actionHandlers[action] = handler;
  }

  /// Unregisters a handler for a specific JavaScript action
  void unregisterHandler(String action) {
    _actionHandlers.remove(action);
  }

  /// Calls a JavaScript method with optional data and waits for a response
  Future<dynamic> callJavaScript(String action, {dynamic data}) {
    final messageId = _generateMessageId();
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
  void sendToJavaScript(String action, {dynamic data}) {
    // Create message
    final message = JSMessage(id: _generateMessageId(), action: action, data: data, expectsResponse: false);

    // Send message to JavaScript
    _sendMessageToJavaScript(message);
  }

  /// Sends a response back for a specific message ID
  void _sendResponse(String messageId, dynamic result) {
    final message = JSMessage(id: messageId, action: 'response', data: result, expectsResponse: false);

    _sendMessageToJavaScript(message);
  }

  /// Sends a message to JavaScript
  void _sendMessageToJavaScript(JSMessage message) {
    final jsonString = message.toJsonString().replaceAll("'", "\\'");
    final jsCode = "window.FlutterJSBridge.receiveMessage('$jsonString')";
    webViewController.runJavaScript(jsCode);
  }

  /// Generates a unique message ID
  String _generateMessageId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(16, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// The JavaScript code that will be injected to enable the bridge
  String get _bridgeJavaScriptCode => '''
  (function() {
    if (window.FlutterJSBridge) return;
    
    window.FlutterJSBridge = {
      // Store callbacks for Flutter responses
      _callbacks: {},
      
      // Store handlers for Flutter actions
      _handlers: {},
      
      // Register a handler for Flutter actions
      registerHandler: function(action, handler) {
        this._handlers[action] = handler;
      },
      
      // Unregister a handler
      unregisterHandler: function(action) {
        delete this._handlers[action];
      },
      
      // Call a Flutter method with optional data
      callFlutter: function(action, data) {
        return new Promise((resolve, reject) => {
          const messageId = this._generateMessageId();
          
          // Store the callback
          this._callbacks[messageId] = resolve;
          
          // Prepare the message
          const message = {
            id: messageId,
            action: action,
            data: data,
            expectsResponse: true
          };
          
          // Send to Flutter
          $javaScriptChannelName.postMessage(JSON.stringify(message));
        });
      },
      
      // Send data to Flutter without expecting a response
      sendToFlutter: function(action, data) {
        const messageId = this._generateMessageId();
        
        // Prepare the message
        const message = {
          id: messageId,
          action: action,
          data: data,
          expectsResponse: false
        };
        
        // Send to Flutter
        $javaScriptChannelName.postMessage(JSON.stringify(message));
      },
      
      // Receive message from Flutter
      receiveMessage: function(messageJson) {
        const message = JSON.parse(messageJson);
        
        // Check if this is a response to a pending request
        if (this._callbacks[message.id]) {
          const callback = this._callbacks[message.id];
          delete this._callbacks[message.id];
          callback(message.data);
          return;
        }
        
        // Otherwise, process as a new action
        if (this._handlers[message.action]) {
          const handler = this._handlers[message.action];
          const result = handler(message.data);
          
          // If response is expected, send it back
          if (message.expectsResponse) {
            this.sendToFlutter('response:' + message.id, result);
          }
        }
      },
      
      // Generate a unique message ID
      _generateMessageId: function() {
        const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let id = '';
        for (let i = 0; i < 16; i++) {
          id += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return id;
      }
    };
    
    // Dispatch event to indicate the bridge is ready
    document.dispatchEvent(new Event('FlutterJSBridgeReady'));
  })();
  ''';
}
