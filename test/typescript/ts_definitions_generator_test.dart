import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_models.dart';

void main() {
  group('TSDefinitionsGenerator', () {
    late TSDefinitionsGenerator generator;

    setUp(() {
      generator = TSDefinitionsGenerator();
    });

    test('should generate basic interface for FlutterJSBridge', () {
      final definitions = generator.generateBaseInterface();
      
      expect(definitions, contains('interface FlutterJSBridge {'));
      expect(definitions, contains('registerHandler(action: string, handler: (data: any) => any): void;'));
      expect(definitions, contains('unregisterHandler(action: string): void;'));
      expect(definitions, contains('callFlutter(action: string, data?: any): Promise<any>;'));
      expect(definitions, contains('sendToFlutter(action: string, data?: any): void;'));
    });

    test('should generate TypeScript definitions for custom actions', () {
      final actions = [
        const TSActionDefinition(
          name: 'getUserData',
          parameters: [
            TSParameterDefinition(name: 'userId', type: 'string', required: true),
          ],
          returnType: 'Promise<UserData>',
          description: 'Fetches user data from Flutter',
        ),
        const TSActionDefinition(
          name: 'saveSettings',
          parameters: [
            TSParameterDefinition(name: 'settings', type: 'Settings', required: true),
          ],
          returnType: 'Promise<boolean>',
          description: 'Saves user settings to Flutter',
        ),
      ];

      final definitions = generator.generateActionsDefinitions(actions);
      
      expect(definitions, contains('getUserData(userId: string): Promise<UserData>;'));
      expect(definitions, contains('saveSettings(settings: Settings): Promise<boolean>;'));
      expect(definitions, contains('/** Fetches user data from Flutter */'));
      expect(definitions, contains('/** Saves user settings to Flutter */'));
    });

    test('should generate TypeScript interface definitions', () {
      final interfaces = [
        const TSInterfaceDefinition(
          name: 'UserData',
          properties: [
            TSPropertyDefinition(name: 'id', type: 'string', required: true),
            TSPropertyDefinition(name: 'name', type: 'string', required: true),
            TSPropertyDefinition(name: 'email', type: 'string', required: true),
            TSPropertyDefinition(name: 'age', type: 'number', required: false),
          ],
          description: 'Represents user data',
        ),
        const TSInterfaceDefinition(
          name: 'Settings',
          properties: [
            TSPropertyDefinition(name: 'theme', type: 'string', required: true),
            TSPropertyDefinition(name: 'notifications', type: 'boolean', required: true),
          ],
          description: 'User settings configuration',
        ),
      ];

      final definitions = generator.generateInterfaceDefinitions(interfaces);
      
      expect(definitions, contains('interface UserData {'));
      expect(definitions, contains('id: string;'));
      expect(definitions, contains('name: string;'));
      expect(definitions, contains('email: string;'));
      expect(definitions, contains('age?: number;'));
      expect(definitions, contains('interface Settings {'));
      expect(definitions, contains('theme: string;'));
      expect(definitions, contains('notifications: boolean;'));
      expect(definitions, contains('/** Represents user data */'));
      expect(definitions, contains('/** User settings configuration */'));
    });

    test('should generate complete TypeScript definition file', () {
      final interfaces = [
        const TSInterfaceDefinition(
          name: 'UserData',
          properties: [
            TSPropertyDefinition(name: 'id', type: 'string', required: true),
            TSPropertyDefinition(name: 'name', type: 'string', required: true),
          ],
        ),
      ];

      final actions = [
        const TSActionDefinition(
          name: 'getUserData',
          parameters: [
            TSParameterDefinition(name: 'userId', type: 'string', required: true),
          ],
          returnType: 'Promise<UserData>',
        ),
      ];

      final definitions = generator.generateDefinitionFile(
        interfaces: interfaces,
        actions: actions,
      );
      
      expect(definitions, contains('// Type definitions for Flutter JS Bridge'));
      expect(definitions, contains('declare global {'));
      expect(definitions, contains('interface Window {'));
      expect(definitions, contains('FlutterJSBridge: FlutterJSBridge;'));
      expect(definitions, contains('interface FlutterJSBridge {'));
      expect(definitions, contains('interface UserData {'));
      expect(definitions, contains('getUserData(userId: string): Promise<UserData>;'));
    });

    test('should generate TypeScript definitions from registered handlers', () {
      // Mock registered handlers data that would come from the bridge
      final registeredHandlers = {
        'getUserData': {
          'parameters': [
            {'name': 'userId', 'type': 'string', 'required': true}
          ],
          'returnType': 'UserData',
        },
        'saveSettings': {
          'parameters': [
            {'name': 'settings', 'type': 'Settings', 'required': true}
          ],
          'returnType': 'boolean',
        }
      };
      
      final definitions = generator.generateFromRegisteredHandlers(registeredHandlers);
      
      expect(definitions, contains('getUserData(userId: string): Promise<UserData>;'));
      expect(definitions, contains('saveSettings(settings: Settings): Promise<boolean>;'));
    });
  });
}
