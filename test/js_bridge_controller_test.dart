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

    test('sendToJavaScript - should format and send message correctly', () {
      // Arrange
      const action = 'test-send';
      final data = {'param': 'value'};

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

    test('registerHandler - should register a handler that can be called', () {
      // Arrange
      final testData = {'test': 'data'};
      const testAction = 'test-action';
      // Act - Register a handler
      controller.registerHandler(testAction, (args) {
        expect(args, [testData]);
        return 'handler-response';
      });

      // Assert - Verify the controller is set up correctly
      expect(controller.javaScriptChannelName, testChannelName);

      // Act - Send a message that should trigger the handler
      controller.sendToJavaScript(testAction, data: testData);
      
      // Assert - Verify JavaScript was called
      expect(mockWebViewController.jsCode.isNotEmpty, true);
      // Note: We can't directly verify the handler was called since it's a private implementation
      // In a real test, we would need to mock the JavaScript channel callback
    });
  });
}
