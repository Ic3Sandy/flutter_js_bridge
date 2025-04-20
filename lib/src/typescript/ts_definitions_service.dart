import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_js_bridge/src/js_bridge_controller.dart';
import 'package:flutter_js_bridge/src/js_event.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_models.dart';

/// Service for generating TypeScript definitions for the Flutter JS Bridge
class TSDefinitionsService {
  /// The JS Bridge controller
  final JSBridgeController _controller;
  
  /// The TypeScript definitions generator
  final TSDefinitionsGenerator _generator;
  
  /// Map of registered action metadata
  final Map<String, Map<String, dynamic>> _actionMetadata = {};
  
  /// Map of registered interface definitions
  final Map<String, TSInterfaceDefinition> _interfaceDefinitions = {};

  /// Creates a new TypeScript definitions service
  /// 
  /// [controller] The JS Bridge controller to generate definitions for
  TSDefinitionsService({
    required JSBridgeController controller,
    TSDefinitionsGenerator? generator,
  }) : 
    _controller = controller,
    _generator = generator ?? TSDefinitionsGenerator();

  /// Registers metadata for an action
  /// 
  /// [actionName] The name of the action
  /// [returnType] The TypeScript return type of the action
  /// [parameters] List of parameter definitions for the action
  /// [description] Optional description of the action
  void registerActionMetadata({
    required String actionName,
    required String returnType,
    List<TSParameterDefinition> parameters = const [],
    String? description,
  }) {
    _actionMetadata[actionName] = {
      'returnType': returnType,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }

  /// Registers an interface definition
  /// 
  /// [interfaceDefinition] The interface definition to register
  void registerInterface(TSInterfaceDefinition interfaceDefinition) {
    _interfaceDefinitions[interfaceDefinition.name] = interfaceDefinition;
  }

  /// Registers a handler with TypeScript metadata
  /// 
  /// [actionName] The name of the action
  /// [handler] The callback function to execute when the action is received
  /// [returnType] The TypeScript return type of the action
  /// [parameters] List of parameter definitions for the action
  /// [description] Optional description of the action
  void registerHandlerWithMetadata({
    required String actionName,
    required JSCallbackHandler handler,
    required String returnType,
    List<TSParameterDefinition> parameters = const [],
    String? description,
  }) {
    // Register the handler with the controller
    _controller.registerHandler(actionName, handler);
    
    // Register the metadata for TypeScript generation
    registerActionMetadata(
      actionName: actionName,
      returnType: returnType,
      parameters: parameters,
      description: description,
    );
  }

  /// Generates TypeScript definitions based on registered metadata
  /// 
  /// Returns the generated TypeScript definitions as a string
  String generateDefinitions() {
    final actions = _actionMetadata.entries.map((entry) {
      return TSActionDefinition(
        name: entry.key,
        parameters: (entry.value['parameters'] as List?)
                ?.map((param) => TSParameterDefinition.fromJson(param as Map<String, dynamic>))
                .toList() ??
            [],
        returnType: 'Promise<${entry.value['returnType'] ?? 'any'}>',
        description: entry.value['description'] as String?,
      );
    }).toList();
    
    final interfaces = _interfaceDefinitions.values.toList();
    
    return _generator.generateDefinitionFile(
      interfaces: interfaces,
      actions: actions,
    );
  }

  /// Writes TypeScript definitions to a file
  /// 
  /// [path] Path to write the file to
  Future<void> writeDefinitionsToFile(String path) async {
    try {
      final content = generateDefinitions();
      final file = File(path);
      await file.writeAsString(content);
      debugPrint('TypeScript definitions written to $path');
    } catch (e) {
      debugPrint('Error writing TypeScript definitions: $e');
      rethrow;
    }
  }

  /// Injects TypeScript definitions into the WebView
  /// 
  /// This method injects the generated TypeScript definitions into the WebView
  /// as a script tag, making them available for TypeScript projects that use
  /// the bridge.
  Future<void> injectDefinitionsIntoWebView() async {
    try {
      final definitions = generateDefinitions();
      
      // Escape the definitions for JavaScript
      final escapedDefinitions = definitions
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', '\\n');
      
      // Create a script that adds the definitions to the page
      final script = '''
      (function() {
        // Create a script element for the TypeScript definitions
        const script = document.createElement('script');
        script.type = 'text/typescript';
        script.id = 'flutter-js-bridge-definitions';
        script.textContent = '$escapedDefinitions';
        
        // Add the script to the document head
        document.head.appendChild(script);
        
        console.log('Flutter JS Bridge TypeScript definitions injected');
      })();
      ''';
      
      // Run the script in the WebView
      await _controller.webViewController.runJavaScript(script);
      
      debugPrint('TypeScript definitions injected into WebView');
    } catch (e) {
      debugPrint('Error injecting TypeScript definitions: $e');
      rethrow;
    }
  }
}
