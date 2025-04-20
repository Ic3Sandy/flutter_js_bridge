import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_js_bridge/src/js_bridge_controller.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_service.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_models.dart';

@GenerateMocks([WebViewController, JSBridgeController, TSDefinitionsGenerator])
import 'ts_definitions_service_test.mocks.dart';

void main() {
  group('TSDefinitionsService', () {
    late MockJSBridgeController mockController;
    late MockTSDefinitionsGenerator mockGenerator;
    late TSDefinitionsService service;

    setUp(() {
      mockController = MockJSBridgeController();
      mockGenerator = MockTSDefinitionsGenerator();
      service = TSDefinitionsService(
        controller: mockController,
        generator: mockGenerator,
      );
    });

    test('should register action metadata', () {
      // Arrange
      const actionName = 'getUserData';
      const returnType = 'UserData';
      final parameters = [
        TSParameterDefinition(
          name: 'userId',
          type: 'string',
          required: true,
        ),
      ];
      const description = 'Gets user data by ID';

      // Act
      service.registerActionMetadata(
        actionName: actionName,
        returnType: returnType,
        parameters: parameters,
        description: description,
      );

      // Assert
      expect(
        service.generateDefinitions(),
        isNotEmpty,
      );
    });

    test('should register interface definition', () {
      // Arrange
      final interface = TSInterfaceDefinition(
        name: 'UserData',
        properties: [
          TSPropertyDefinition(
            name: 'id',
            type: 'string',
            required: true,
          ),
          TSPropertyDefinition(
            name: 'name',
            type: 'string',
            required: true,
          ),
        ],
      );

      // Act
      service.registerInterface(interface);

      // Assert
      expect(
        service.generateDefinitions(),
        isNotEmpty,
      );
    });

    test('should register handler with metadata', () {
      // Arrange
      const actionName = 'getUserData';
      final handler = (List<dynamic> args) => {'id': '123', 'name': 'Test User'};
      const returnType = 'UserData';
      final parameters = [
        TSParameterDefinition(
          name: 'userId',
          type: 'string',
          required: true,
        ),
      ];

      // Act
      service.registerHandlerWithMetadata(
        actionName: actionName,
        handler: handler,
        returnType: returnType,
        parameters: parameters,
      );

      // Assert
      verify(mockController.registerHandler(actionName, handler)).called(1);
      expect(
        service.generateDefinitions(),
        isNotEmpty,
      );
    });

    test('should generate definitions based on registered metadata', () {
      // Arrange
      when(mockGenerator.generateDefinitionFile(
        interfaces: anyNamed('interfaces'),
        actions: anyNamed('actions'),
      )).thenReturn('// TypeScript definitions');

      // Register some metadata
      service.registerActionMetadata(
        actionName: 'getUserData',
        returnType: 'UserData',
        parameters: [
          TSParameterDefinition(
            name: 'userId',
            type: 'string',
            required: true,
          ),
        ],
      );

      service.registerInterface(
        TSInterfaceDefinition(
          name: 'UserData',
          properties: [
            TSPropertyDefinition(
              name: 'id',
              type: 'string',
              required: true,
            ),
          ],
        ),
      );

      // Act
      final definitions = service.generateDefinitions();

      // Assert
      expect(definitions, '// TypeScript definitions');
      verify(mockGenerator.generateDefinitionFile(
        interfaces: anyNamed('interfaces'),
        actions: anyNamed('actions'),
      )).called(1);
    });
  });
}
