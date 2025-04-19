import 'dart:async';
import 'dart:convert';

import 'lib/js_event.dart';
import 'lib/js_message.dart';
import 'lib/js_bridge_controller.dart';
import 'lib/js_event_bus.dart';
import 'lib/mock_webview_controller.dart';

void main() async {
  print('Flutter JS Bridge CLI Example');
  print('----------------------------');

  // Create mock controller and bridge
  final mockController = MockWebViewController();
  final bridgeController = JSBridgeController(
    webViewController: mockController,
  );
  final eventBus = JSEventBus(bridgeController);

  // Register a handler for form submissions
  print('\n1. Registering a handler for "formSubmit" action');
  bridgeController.registerHandler('formSubmit', (args) {
    print('  → Handler called with data: ${jsonEncode(args)}');
    return {'status': 'success', 'message': 'Form submitted successfully'};
  });

  // Subscribe to button click events
  print('\n2. Subscribing to "buttonClick" events');
  eventBus.on('buttonClick', (event) {
    print(
      '  → Event received: ${event.name} with data: ${jsonEncode(event.data)}',
    );
  });

  // Send an event to JavaScript
  print('\n3. Sending a "buttonClick" event to JavaScript');
  final buttonEvent = JSEvent(
    name: 'buttonClick',
    data: {'id': 'submit-btn', 'value': 'Submit'},
  );
  eventBus.publish(buttonEvent);

  // Simulate a message from JavaScript
  print('\n4. Simulating a message from JavaScript');
  final formMessage = JSMessage(
    id: bridgeController.generateMessageId(),
    action: 'formSubmit',
    data: [
      {'name': 'John Doe', 'email': 'john@example.com'},
    ],
    expectsResponse: true,
  );

  print('  → Simulating message: ${formMessage.toJsonString()}');
  mockController.simulateMessageFromJavaScript(formMessage.toJsonString());

  // Wait for all async operations to complete
  await Future.delayed(Duration(seconds: 1));

  print('\nExample completed');
}
