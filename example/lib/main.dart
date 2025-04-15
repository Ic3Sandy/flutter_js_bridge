import 'package:flutter/material.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _webViewController;
  String _receivedMessage = 'No message received yet';
  bool _isBridgeReady = false;

  // A minimal HTML page for testing
  final String _minimalHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Basic Bridge Test</title>
      <style>
        body { font-family: sans-serif; margin: 20px; }
        button { padding: 10px; margin: 5px; }
        input { padding: 8px; width: 80%; }
        .box { padding: 10px; margin-top: 10px; border: 1px solid #ddd; }
      </style>
    </head>
    <body>
      <h2>Simple JS Bridge Test</h2>
      
      <input type="text" id="messageInput" placeholder="Message to Flutter">
      <button onclick="sendBasicMessage()">Send Message</button>
      
      <div class="box" id="status">Status: Initializing</div>
      
      <script>
        // Simple function to send a message to Flutter
        function sendBasicMessage() {
          var message = document.getElementById('messageInput').value || 'empty';
          document.getElementById('status').textContent = 'Sending: ' + message;
          
          try {
            // Direct method call through JavaScript channel
            FlutterChannel.postMessage(message);
            document.getElementById('status').textContent = 'Message sent: ' + message;
          } catch (e) {
            document.getElementById('status').textContent = 'Error: ' + e.message;
            console.error('Error sending message:', e);
          }
        }
        
        // Flag when page is ready
        window.onload = function() {
          document.getElementById('status').textContent = 'Page loaded, ready to send messages';
        };
      </script>
    </body>
    </html>
  ''';

  @override
  void initState() {
    super.initState();
    debugPrint('MyHomePageState initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple JS Bridge Test')),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _createWebViewController())),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Received message:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(_receivedMessage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _executeJavaScript, child: const Text('Run JS Test')),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _receivedMessage = 'Message cleared';
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                  child: const Text('Clear Message', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Create and configure the WebViewController
  WebViewController _createWebViewController() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterChannel',
            onMessageReceived: (JavaScriptMessage message) {
              debugPrint('Received message from JS: ${message.message}');
              setState(() {
                _receivedMessage = message.message;
              });
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (url) {
                debugPrint('Page finished loading: $url');
              },
              onWebResourceError: (error) {
                debugPrint('Web resource error: ${error.description}');
              },
            ),
          )
          ..loadHtmlString(_minimalHtml);

    return _webViewController;
  }

  // Test JavaScript execution
  void _executeJavaScript() {
    const js = '''
      document.getElementById('status').textContent = 'JavaScript test executed';
      FlutterChannel.postMessage('Message from JavaScript test button');
    ''';

    _webViewController
        .runJavaScript(js)
        .then((_) {
          debugPrint('JavaScript executed successfully');
        })
        .catchError((error) {
          debugPrint('Error executing JavaScript: $error');
        });
  }
}
