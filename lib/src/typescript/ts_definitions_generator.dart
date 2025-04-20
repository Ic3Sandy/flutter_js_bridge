
import 'ts_definitions_models.dart';

/// Generator for TypeScript definition files for the Flutter JS Bridge
class TSDefinitionsGenerator {
  /// Creates a new TypeScript definitions generator
  TSDefinitionsGenerator();

  /// Generates the base interface for the FlutterJSBridge
  String generateBaseInterface() {
    return '''
interface FlutterJSBridge {
  /**
   * Registers a handler for a specific action from Flutter
   * @param action The action name to register the handler for
   * @param handler The callback function to execute when the action is received
   */
  registerHandler(action: string, handler: (data: any) => any): void;

  /**
   * Unregisters a handler for a specific action
   * @param action The action name to unregister the handler for
   */
  unregisterHandler(action: string): void;

  /**
   * Calls a Flutter method with optional data and waits for a response
   * @param action The action name to call in Flutter
   * @param data Optional data to pass to the Flutter method
   * @returns A Promise that resolves with the response from Flutter
   */
  callFlutter(action: string, data?: any): Promise<any>;

  /**
   * Sends data to Flutter without expecting a response
   * @param action The action name to call in Flutter
   * @param data Optional data to pass to the Flutter method
   */
  sendToFlutter(action: string, data?: any): void;
''';
  }

  /// Generates TypeScript definitions for custom actions
  /// 
  /// [actions] List of action definitions to generate
  String generateActionsDefinitions(List<TSActionDefinition> actions) {
    final buffer = StringBuffer();

    for (final action in actions) {
      // Add JSDoc comment if description is provided
      if (action.description != null) {
        buffer.writeln('  /** ${action.description} */');
      }

      // Generate method signature
      buffer.write('  ${action.name}(');
      
      // Add parameters
      final params = action.parameters.map((param) => param.toTypeScriptString()).join(', ');
      buffer.write(params);
      
      // Add return type
      buffer.writeln('): ${action.returnType};');
      
      // Add empty line between methods for readability
      if (actions.last != action) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Generates TypeScript interface definitions
  /// 
  /// [interfaces] List of interface definitions to generate
  String generateInterfaceDefinitions(List<TSInterfaceDefinition> interfaces) {
    final buffer = StringBuffer();

    for (final interface in interfaces) {
      // Add JSDoc comment if description is provided
      if (interface.description != null) {
        buffer.writeln('/** ${interface.description} */');
      }

      // Start interface definition
      buffer.writeln('interface ${interface.name} {');
      
      // Add properties
      for (final property in interface.properties) {
        // Add property JSDoc if description is provided
        if (property.description != null) {
          buffer.writeln('  /** ${property.description} */');
        }
        
        buffer.writeln('  ${property.toTypeScriptString()}');
      }
      
      // Close interface
      buffer.writeln('}');
      
      // Add empty line between interfaces for readability
      if (interfaces.last != interface) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Generates a complete TypeScript definition file
  /// 
  /// [interfaces] List of interface definitions to include
  /// [actions] List of action definitions to include
  String generateDefinitionFile({
    List<TSInterfaceDefinition> interfaces = const [],
    List<TSActionDefinition> actions = const [],
  }) {
    final buffer = StringBuffer();

    // Add file header
    buffer.writeln('// Type definitions for Flutter JS Bridge');
    buffer.writeln('// Generated on ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    
    // Add global namespace
    buffer.writeln('declare global {');
    buffer.writeln('  interface Window {');
    buffer.writeln('    FlutterJSBridge: FlutterJSBridge;');
    buffer.writeln('  }');
    buffer.writeln();
    
    // Add FlutterJSBridge interface
    buffer.writeln('  ${generateBaseInterface()}');
    
    // Add custom actions
    if (actions.isNotEmpty) {
      buffer.writeln(generateActionsDefinitions(actions));
    }
    
    // Close FlutterJSBridge interface
    buffer.writeln('  }');
    buffer.writeln();
    
    // Add custom interfaces
    if (interfaces.isNotEmpty) {
      for (final interface in interfaces) {
        // Add JSDoc comment if description is provided
        if (interface.description != null) {
          buffer.writeln('  /** ${interface.description} */');
        }
        
        // Start interface definition
        buffer.writeln('  interface ${interface.name} {');
        
        // Add properties
        for (final property in interface.properties) {
          // Add property JSDoc if description is provided
          if (property.description != null) {
            buffer.writeln('    /** ${property.description} */');
          }
          
          buffer.writeln('    ${property.toTypeScriptString()}');
        }
        
        // Close interface
        buffer.writeln('  }');
        
        // Add empty line between interfaces for readability
        if (interfaces.last != interface) {
          buffer.writeln();
        }
      }
    }
    
    // Close global namespace
    buffer.writeln('}');
    buffer.writeln();
    
    // Add export statement
    buffer.writeln('export {};');
    
    return buffer.toString();
  }

  /// Generates TypeScript definitions from registered handlers
  /// 
  /// [registeredHandlers] Map of registered handlers with their metadata
  String generateFromRegisteredHandlers(Map<String, dynamic> registeredHandlers) {
    final actions = <TSActionDefinition>[];
    
    registeredHandlers.forEach((actionName, metadata) {
      final parameters = <TSParameterDefinition>[];
      
      if (metadata['parameters'] != null) {
        for (final param in metadata['parameters'] as List) {
          parameters.add(TSParameterDefinition.fromJson(param as Map<String, dynamic>));
        }
      }
      
      actions.add(TSActionDefinition(
        name: actionName,
        parameters: parameters,
        returnType: 'Promise<${metadata['returnType'] ?? 'any'}>',
        description: metadata['description'] as String?,
      ));
    });
    
    return generateActionsDefinitions(actions);
  }

  /// Writes TypeScript definitions to a file
  /// 
  /// [path] Path to write the file to
  /// [interfaces] List of interface definitions to include
  /// [actions] List of action definitions to include
  Future<void> writeDefinitionFile(
    String path, {
    List<TSInterfaceDefinition> interfaces = const [],
    List<TSActionDefinition> actions = const [],
  }) async {
    // This method is implemented in TSDefinitionsService
    // which handles file I/O operations
    throw UnimplementedError('Use TSDefinitionsService to write definition files');
  }
}
