import 'dart:async';
import 'dart:convert';

import 'lib/js_event.dart';
import 'lib/js_message.dart';
import 'lib/js_bridge_controller.dart';
import 'lib/js_event_bus.dart';
import 'lib/mock_webview_controller.dart';

void main() async {
  print('🚀 Starting Flutter JS Bridge CLI Example');
  print('----------------------------------------\n');
  
  // Create mock controller and bridge
  final mockController = MockWebViewController();
  final bridgeController = JSBridgeController(webViewController: mockController);
  final eventBus = JSEventBus(bridgeController);
  
  // Setup logging for the mock controller
  mockController.onJavaScriptRun = (code) {
    print('📜 JavaScript code executed: $code');
  };
  
  // 1. Register event handlers
  print('1️⃣ Registering handlers...');
  
  // Register a handler for form submissions
  bridgeController.registerHandler('formSubmit', (args) {
    print('📥 Form submitted with data: ${jsonEncode(args)}');
    return {'status': 'success', 'message': 'Form submitted successfully'};
  });
  
  // Register a handler for data requests
  bridgeController.registerHandler('getData', (args) {
    print('📥 Data requested with args: ${jsonEncode(args)}');
    return {'userId': 123, 'name': 'John Doe', 'email': 'john@example.com'};
  });
  
  print('✅ Handlers registered successfully\n');
  
  // 2. Subscribe to events
  print('2️⃣ Setting up event subscriptions...');
  
  // Subscribe to button click events
  final buttonSubscription = eventBus.on('buttonClick', (event) {
    print('📥 Button clicked: ${jsonEncode(event.data)}');
  });
  
  // Subscribe to all events
  final allEventsSubscription = eventBus.onAny((event) {
    print('📥 Any event received: ${event.name} with data: ${jsonEncode(event.data)}');
  });
  
  // Subscribe to form events with a filter
  final formSubscription = eventBus.onWhere(
    'formEvent', 
    (event) => event.data['type'] == 'submit',
    (event) {
      print('📥 Form submitted via event: ${jsonEncode(event.data)}');
    }
  );
  
  print('✅ Event subscriptions set up successfully\n');
  
  // 3. Send events to JavaScript
  print('3️⃣ Sending events to JavaScript...');
  
  // Send a button click event
  final buttonEvent = JSEvent(
    name: 'buttonClick',
    data: {'id': 'submit-btn', 'value': 'Submit'},
  );
  
  eventBus.publish(buttonEvent);
  print('📤 Button click event sent\n');
  
  // 4. Call JavaScript methods
  print('4️⃣ Calling JavaScript methods...');
  
  // Call a JavaScript method
  print('📤 Calling updateUI method...');
  bridgeController.sendToJavaScript('updateUI', data: {'visible': true, 'color': 'blue'});
  
  // Call a JavaScript method with a response
  print('📤 Calling getUserData method with response...');
  
  // Setup a mock response for the JavaScript call
  final messageId = bridgeController.generateMessageId();
  Timer(Duration(milliseconds: 500), () {
    final responseMessage = JSMessage(
      id: messageId,
      action: 'response',
      data: {'name': 'John Doe', 'age': 30},
      expectsResponse: false,
    );
    
    mockController.simulateMessageFromJavaScript(responseMessage.toJsonString());
  });
  
  try {
    final result = await bridgeController.callJavaScript('getUserData', data: {'userId': 123});
    print('📥 Received response from getUserData: ${jsonEncode(result)}');
  } catch (e) {
    print('❌ Error calling JavaScript: $e');
  }
  
  // 5. Simulate messages from JavaScript
  print('\n5️⃣ Simulating messages from JavaScript...');
  
  // Simulate a form submission from JavaScript
  final formMessage = JSMessage(
    id: bridgeController.generateMessageId(),
    action: 'formSubmit',
    data: [{'name': 'John Doe', 'email': 'john@example.com', 'message': 'Hello, world!'}],
    expectsResponse: true,
  );
  
  print('📤 Simulating form submission from JavaScript...');
  mockController.simulateMessageFromJavaScript(formMessage.toJsonString());
  
  // Simulate an event from JavaScript
  final eventMessage = JSMessage(
    id: bridgeController.generateMessageId(),
    action: 'event',
    data: {
      'name': 'formEvent',
      'data': {'type': 'submit', 'formId': 'contact-form'},
      'isMainFrame': true,
    },
    expectsResponse: false,
  );
  
  print('📤 Simulating event from JavaScript...');
  mockController.simulateMessageFromJavaScript(eventMessage.toJsonString());
  
  // Wait for all async operations to complete
  await Future.delayed(Duration(seconds: 1));
  
  // Clean up
  buttonSubscription.cancel();
  allEventsSubscription.cancel();
  formSubscription.cancel();
  
  print('\n✅ Example completed successfully');
}
