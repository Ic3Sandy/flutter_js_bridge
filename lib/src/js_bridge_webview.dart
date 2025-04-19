import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'js_bridge_controller.dart';
import 'js_event.dart';

/// A WebView widget with built-in JavaScript-Flutter bridge functionality
class JSBridgeWebView extends StatefulWidget {
  /// Initial URL to load
  final String? initialUrl;

  /// Initial HTML content to load
  final String? initialHtml;

  /// Initial URL for loading HTML content from an asset
  final String? initialAsset;

  /// Callback when the WebView is created
  final Function(JSBridgeController controller)? onWebViewCreated;

  /// Callback when a page starts loading
  final Function(JSBridgeController controller, String url)? onPageStarted;

  /// Callback when a page finishes loading
  final Function(JSBridgeController controller, String url)? onPageFinished;

  /// Whether JavaScript execution is allowed
  final bool javascriptEnabled;

  /// Name of the JavaScript channel for communication
  final String javascriptChannelName;

  /// JavaScript handlers to register on creation
  final Map<String, JSCallbackHandler>? javascriptHandlers;

  /// Background color for the WebView
  final Color? backgroundColor;

  /// User agent string for the WebView
  final String? userAgent;

  /// Whether zoom is enabled in the WebView
  final bool? zoomEnabled;

  /// Creates a JSBridgeWebView
  const JSBridgeWebView({
    super.key,
    this.initialUrl,
    this.initialHtml,
    this.initialAsset,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.javascriptEnabled = true,
    this.javascriptChannelName = 'FlutterJSBridge',
    this.javascriptHandlers,
    this.backgroundColor,
    this.userAgent,
    this.zoomEnabled,
  });

  @override
  State<JSBridgeWebView> createState() => _JSBridgeWebViewState();
}

class _JSBridgeWebViewState extends State<JSBridgeWebView> {
  late final WebViewController _webViewController;
  late final JSBridgeController _jsBridgeController;
  final Completer<void> _initialLoad = Completer<void>();

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Create WebViewController
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(
            widget.javascriptEnabled
                ? JavaScriptMode.unrestricted
                : JavaScriptMode.disabled,
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (widget.onPageStarted != null) {
                  widget.onPageStarted!(_jsBridgeController, url);
                }
              },
              onPageFinished: (String url) {
                if (!_initialLoad.isCompleted) {
                  _initialLoad.complete();
                }
                if (widget.onPageFinished != null) {
                  widget.onPageFinished!(_jsBridgeController, url);
                }
              },
            ),
          );

    // Apply additional settings if provided
    if (widget.backgroundColor != null) {
      _webViewController.setBackgroundColor(widget.backgroundColor!);
    }

    if (widget.userAgent != null) {
      _webViewController.setUserAgent(widget.userAgent);
    }

    if (widget.zoomEnabled != null) {
      _webViewController.enableZoom(widget.zoomEnabled!);
    }

    // Create the JavaScript bridge controller
    _jsBridgeController = JSBridgeController(
      webViewController: _webViewController,
      javaScriptChannelName: widget.javascriptChannelName,
    );

    // Register JavaScript handlers if provided
    if (widget.javascriptHandlers != null) {
      widget.javascriptHandlers!.forEach((name, handler) {
        _jsBridgeController.registerHandler(name, handler);
      });
    }

    // Load initial content
    if (widget.initialUrl != null) {
      _webViewController.loadRequest(Uri.parse(widget.initialUrl!));
    } else if (widget.initialHtml != null) {
      _webViewController.loadHtmlString(widget.initialHtml!);
    } else if (widget.initialAsset != null) {
      _webViewController.loadFlutterAsset(widget.initialAsset!);
    }

    // Invoke onWebViewCreated callback
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_jsBridgeController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }
}
