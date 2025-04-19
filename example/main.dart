import 'package:flutter/material.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JS Bridge Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late JSBridgeController _controller;
  late JSEventBus _eventBus;
  String _receivedMessage = 'No message received yet';
  final List<String> _eventLog = [];
  JSEventSubscription? _loginSubscription;
  JSEventSubscription? _allEventsSubscription;
  bool _isFilteringAdminEvents = false;

  final String _initialHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>JS Bridge Demo</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          line-height: 1.6;
        }
        button {
          padding: 10px 15px;
          background-color: #4285f4;
          color: white;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          margin: 5px;
        }
        input {
          padding: 8px;
          border: 1px solid #ddd;
          border-radius: 4px;
          margin: 5px;
          width: 80%;
        }
        .result {
          margin-top: 20px;
          padding: 10px;
          background-color: #f1f1f1;
          border-radius: 4px;
        }
      </style>
    </head>
    <body>
      <h2>Flutter JS Bridge Demo</h2>
      
      <div>
        <input type="text" id="messageInput" placeholder="Enter a message">
        <button onclick="sendMessageToFlutter()">Send to Flutter</button>
      </div>
      
      <div>
        <button onclick="requestDataFromFlutter()">Request Data from Flutter</button>
      </div>
      
      <div style="margin-top: 20px; padding: 10px; background-color: #f8f9fa; border-radius: 4px;">
        <h3 style="color: #d32f2f;">Event Bus Testing</h3>
        <button style="background-color: #d32f2f;" onclick="sendLoginEvent('user')">Send User Login Event</button>
        <button style="background-color: #d32f2f;" onclick="sendLoginEvent('admin')">Send Admin Login Event</button>
        <button style="background-color: #d32f2f;" onclick="sendCustomEvent()">Send Custom Event</button>
      </div>
      
      <div class="result" id="result">Result will appear here</div>
      
      <script>
        // Global variable to track if bridge is ready
        let bridgeReady = false;
        
        // Listen for the bridge ready event
        document.addEventListener('FlutterJSBridgeReady', function() {
          bridgeReady = true;
          document.getElementById('result').innerText = 'Bridge is ready!';
          
          // Dispatch a custom event to test the event bus
          setTimeout(function() {
            window.FlutterJSBridge.sendToFlutter('event', {
              name: 'appReady',
              data: { timestamp: Date.now() }
            });
          }, 1000);
        });
        
        // Function to send a message to Flutter
        function sendMessageToFlutter() {
          if (!bridgeReady) {
            document.getElementById('result').innerText = 'Bridge not ready yet!';
            return;
          }
          
          const message = document.getElementById('messageInput').value;
          if (!message) {
            alert('Please enter a message');
            return;
          }
          
          window.FlutterJSBridge.sendToFlutter('messageFromJS', message);
          document.getElementById('result').innerText = 'Message sent to Flutter: ' + message;
        }
        
        // Function to request data from Flutter
        function requestDataFromFlutter() {
          if (!bridgeReady) {
            document.getElementById('result').innerText = 'Bridge not ready yet!';
            return;
          }
          
          window.FlutterJSBridge.callFlutter('getDataFromFlutter')
            .then(function(response) {
              document.getElementById('result').innerText = 'Received from Flutter: ' + JSON.stringify(response);
            })
            .catch(function(error) {
              document.getElementById('result').innerText = 'Error: ' + error;
            });
        }
        
        // Function to be called from Flutter
        window.FlutterJSBridge.registerHandler('callFromFlutter', function(data) {
          document.getElementById('result').innerText = 'Called from Flutter with: ' + JSON.stringify(data);
          return 'Response from JavaScript!';
        });
        
        // Function to send login events
        function sendLoginEvent(role) {
          if (!bridgeReady) {
            document.getElementById('result').innerText = 'Bridge not ready yet!';
            return;
          }
          
          const userId = Math.floor(Math.random() * 1000);
          window.FlutterJSBridge.sendToFlutter('event', {
            name: 'userLogin',
            data: { userId: userId, role: role, timestamp: Date.now() }
          });
          
          document.getElementById('result').innerText = role + ' login event sent with userId: ' + userId;
        }
        
        // Function to send custom event
        function sendCustomEvent() {
          if (!bridgeReady) {
            document.getElementById('result').innerText = 'Bridge not ready yet!';
            return;
          }
          
          const eventName = document.getElementById('messageInput').value || 'customEvent';
          
          window.FlutterJSBridge.sendToFlutter('event', {
            name: eventName,
            data: { message: 'This is a custom event', timestamp: Date.now() }
          });
          
          document.getElementById('result').innerText = 'Custom event "' + eventName + '" sent';
        }
      </script>
    </body>
    </html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter JS Bridge Example')),
      body: Column(
        children: [
          Expanded(
            child: JSBridgeWebView(
              initialHtml: _initialHtml,
              javascriptEnabled: true,
              onWebViewCreated: (controller) {
                _controller = controller;
                _eventBus = JSEventBus(_controller);
                
                // Set up event subscriptions
                _setupEventSubscriptions();

                // Register handler to receive messages from JavaScript
                _controller.registerHandler('messageFromJS', (args) {
                  final message = args.isNotEmpty ? args[0] : 'No data';
                  setState(() {
                    _receivedMessage = message.toString();
                  });
                  return 'Message received!';
                });

                // Register handler to provide data to JavaScript
                _controller.registerHandler('getDataFromFlutter', (args) {
                  return {
                    'time': DateTime.now().toString(),
                    'message': 'Hello from Flutter!',
                    'data': [1, 2, 3, 4, 5],
                  };
                });
              },
              onPageFinished: (controller, url) {
                print('Page finished loading: $url');
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Message from JavaScript: $_receivedMessage', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(onPressed: _callJavaScript, child: const Text('Call JavaScript Method')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(onPressed: _sendDataToJavaScript, child: const Text('Send Data to JS')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('EVENT BUS DEMO', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _toggleLoginSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _loginSubscription != null ? Colors.green : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _loginSubscription != null ? 'UNSUBSCRIBE FROM LOGIN' : 'SUBSCRIBE TO LOGIN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _toggleAllEventsSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _allEventsSubscription != null ? Colors.green : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _allEventsSubscription != null ? 'UNSUBSCRIBE FROM ALL' : 'SUBSCRIBE TO ALL',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _toggleAdminFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFilteringAdminEvents ? Colors.green : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _isFilteringAdminEvents ? 'REMOVE ADMIN FILTER' : 'FILTER ADMIN EVENTS',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _publishCustomEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'PUBLISH CUSTOM EVENT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('EVENT LOG:', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  child: _eventLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No events yet. Try subscribing and sending events!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _eventLog.length,
                        itemBuilder: (context, index) {
                          final log = _eventLog[_eventLog.length - 1 - index];
                          Color textColor = Colors.black;
                          if (log.contains('ADMIN ALERT')) {
                            textColor = Colors.red;
                          } else if (log.contains('Subscribed')) {
                            textColor = Colors.green.shade800;
                          } else if (log.contains('Unsubscribed')) {
                            textColor = Colors.orange.shade800;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: TextStyle(fontSize: 13, color: textColor),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _callJavaScript() async {
    try {
      final result = await _controller.callJavaScript('callFromFlutter', data: 'Called from Flutter button!');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Response: $result')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _sendDataToJavaScript() {
    _controller.sendToJavaScript(
      'updateFromFlutter',
      data: {'timestamp': DateTime.now().millisecondsSinceEpoch, 'message': 'Data sent from Flutter'},
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data sent to JavaScript')));
  }
  
  // Set up event subscriptions
  void _setupEventSubscriptions() {
    // Listen for the stream of all events
    _eventBus.eventStream.listen((event) {
      _addToEventLog('Stream: ${event.name} event received');
    });
  }
  
  // Toggle subscription to login events
  void _toggleLoginSubscription() {
    setState(() {
      if (_loginSubscription != null) {
        // Unsubscribe
        _loginSubscription!.cancel();
        _loginSubscription = null;
        _addToEventLog('Unsubscribed from login events');
      } else {
        // Subscribe to login events
        _loginSubscription = _eventBus.on('userLogin', (event) {
          final userData = event.data as Map;
          _addToEventLog('Login: User ${userData['userId']} with role ${userData['role']}');
        });
        _addToEventLog('Subscribed to login events');
      }
    });
  }
  
  // Toggle subscription to all events
  void _toggleAllEventsSubscription() {
    setState(() {
      if (_allEventsSubscription != null) {
        // Unsubscribe
        _allEventsSubscription!.cancel();
        _allEventsSubscription = null;
        _addToEventLog('Unsubscribed from all events');
      } else {
        // Subscribe to all events
        _allEventsSubscription = _eventBus.onAny((event) {
          _addToEventLog('Any: ${event.name} event received');
        });
        _addToEventLog('Subscribed to all events');
      }
    });
  }
  
  // Toggle admin event filtering
  void _toggleAdminFilter() {
    setState(() {
      _isFilteringAdminEvents = !_isFilteringAdminEvents;
      
      if (_isFilteringAdminEvents) {
        // Subscribe with filter for admin events
        _eventBus.onWhere(
          'userLogin',
          (event) => event.data is Map && (event.data as Map)['role'] == 'admin',
          (event) {
            final userData = event.data as Map;
            _addToEventLog('ADMIN ALERT: Admin ${userData['userId']} logged in!');
          },
        );
        _addToEventLog('Admin event filter enabled');
      } else {
        _addToEventLog('Admin event filter disabled');
        // Note: We don't have a reference to cancel this specific subscription
        // In a real app, you would keep the reference to cancel it
      }
    });
  }
  
  // Publish a custom event from Flutter to JavaScript
  void _publishCustomEvent() {
    final event = JSEvent(
      name: 'flutterEvent',
      data: {
        'message': 'Hello from Flutter!',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    _eventBus.publish(event);
    _addToEventLog('Published flutterEvent to JavaScript');
  }
  
  // Add a message to the event log
  void _addToEventLog(String message) {
    setState(() {
      _eventLog.add('${DateTime.now().toString().split('.').first}: $message');
      // Keep the log to a reasonable size
      if (_eventLog.length > 100) {
        _eventLog.removeAt(0);
      }
    });
  }
  
  @override
  void dispose() {
    // Clean up resources
    _eventBus.dispose();
    super.dispose();
  }
}
