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
  String _receivedMessage = 'No message received yet';

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
      
      <div class="result" id="result">Result will appear here</div>
      
      <script>
        // Global variable to track if bridge is ready
        let bridgeReady = false;
        
        // Listen for the bridge ready event
        document.addEventListener('FlutterJSBridgeReady', function() {
          bridgeReady = true;
          document.getElementById('result').innerText = 'Bridge is ready!';
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
                ElevatedButton(onPressed: _callJavaScript, child: const Text('Call JavaScript Method')),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _sendDataToJavaScript, child: const Text('Send Data to JavaScript')),
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
}
