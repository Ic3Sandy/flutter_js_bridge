import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

import 'mocks/mock_webview.dart';

/// Tests for the [JSBridgeController] class.
void main() {
  // Initialize Flutter test binding
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('JSBridgeController', () {
    // Test fixtures
    late MockWebViewController mockWebViewController;
    late JSBridgeController controller;
    const testChannelName = 'TestChannel';

    setUp(() {
      // Create a fresh mock for each test
      mockWebViewController = MockWebViewController();

      // Initialize the controller with the mock
      controller = JSBridgeController(
        webViewController: mockWebViewController,
        javaScriptChannelName: testChannelName,
      );
    });

    group('initialization', () {
      test('constructor - should set up JavaScript channel and inject bridge code', () {
        // Assert
        expect(mockWebViewController.jsCode.isNotEmpty, true);
        expect(controller.javaScriptChannelName, testChannelName);
        
        // Verify bridge code was injected
        final injectedCode = mockWebViewController.jsCode.first;
        expect(injectedCode.contains('window.FlutterJSBridge'), true);
        expect(injectedCode.contains('registerHandler'), true);
        expect(injectedCode.contains('callFlutter'), true);
      });
    });
    
    group('sending messages', () {
      test('sendToJavaScript - should format and send message correctly', () {
        // Arrange
        const action = 'test-send';
        final data = {'param': 'value'};
        mockWebViewController.jsCode.clear(); // Clear initialization code

        // Act
        controller.sendToJavaScript(action, data: data);

        // Assert
        expect(mockWebViewController.jsCode.isNotEmpty, true);
        final jsCode = mockWebViewController.jsCode.last;

        // Verify the JavaScript contains the expected parts
        expect(jsCode.contains('FlutterJSBridge.receiveMessage'), true);
        expect(jsCode.contains('"action":"$action"'), true);
        expect(jsCode.contains('"data":{"param":"value"}'), true);
      });
      
      test('callJavaScript - should send message with expectsResponse=true', () {
        // Arrange
        const action = 'test-call';
        final data = {'param': 'value'};
        mockWebViewController.jsCode.clear(); // Clear initialization code

        // Act
        controller.callJavaScript(action, data: data);

        // Assert
        expect(mockWebViewController.jsCode.isNotEmpty, true);
        final jsCode = mockWebViewController.jsCode.last;

        // Verify the JavaScript contains the expected parts
        expect(jsCode.contains('FlutterJSBridge.receiveMessage'), true);
        expect(jsCode.contains('"action":"$action"'), true);
        expect(jsCode.contains('"expectsResponse":true'), true);
      });
    });

    group('handlers', () {
      test('registerHandler - should register a handler that can be called', () {
        // Arrange
        final testData = {'test': 'data'};
        const testAction = 'test-action';
        var handlerCalled = false;
        
        // Act - Register a handler
        controller.registerHandler(testAction, (args) {
          handlerCalled = true;
          expect(args, [testData]);
          return 'handler-response';
        });

        // Simulate JavaScript sending a message
        final message = JSMessage(
          id: 'test-id',
          action: testAction,
          data: testData,
          expectsResponse: true,
        );
        
        // Manually invoke the handler through the private method
        // This is a workaround since we can't directly trigger the JavaScript channel
        // In a real scenario, this would be called when JavaScript sends a message
        final jsMessage = MockJavaScriptMessage(message.toJsonString());
        controller.handleIncomingMessage(jsMessage);
        
        // Assert
        expect(handlerCalled, true);
        // Check that a response was sent back
        expect(mockWebViewController.jsCode.last.contains('response'), true);
      });
      
      test('unregisterHandler - should remove a registered handler', () {
        // Arrange
        const testAction = 'test-action';
        var handlerCalled = false;
        
        controller.registerHandler(testAction, (args) {
          handlerCalled = true;
          return null;
        });
        
        // Act - Unregister the handler
        controller.unregisterHandler(testAction);
        
        // Simulate JavaScript sending a message
        final message = JSMessage(
          id: 'test-id',
          action: testAction,
          data: null,
          expectsResponse: false,
        );
        
        // Clear previous JavaScript code
        mockWebViewController.jsCode.clear();
        
        // Manually invoke the handler
        final jsMessage = MockJavaScriptMessage(message.toJsonString());
        controller.handleIncomingMessage(jsMessage);
        
        // Assert
        expect(handlerCalled, false);
        // No JavaScript should be executed since the handler was unregistered
        expect(mockWebViewController.jsCode.isEmpty, true);
      });
    });
    
    test('generateMessageId - should create unique IDs', () {
      // Act
      final id1 = controller.generateMessageId();
      final id2 = controller.generateMessageId();
      
      // Assert
      expect(id1.isNotEmpty, true);
      expect(id2.isNotEmpty, true);
      expect(id1, isNot(equals(id2))); // IDs should be unique
      expect(id1.length, equals(16)); // Default length is 16 characters
    });
  });
}
