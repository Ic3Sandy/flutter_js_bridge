import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge/src/typescript/ts_definitions_cli.dart';

@GenerateMocks([TSDefinitionsGenerator])
import 'ts_definitions_cli_test.mocks.dart';

void main() {
  group('TSDefinitionsCLI', () {
    late MockTSDefinitionsGenerator mockGenerator;
    late TSDefinitionsCLI cli;
    late Directory tempDir;

    setUp(() async {
      mockGenerator = MockTSDefinitionsGenerator();
      cli = TSDefinitionsCLI(generator: mockGenerator);
      
      // Create a temporary directory for test files
      tempDir = await Directory.systemTemp.createTemp('ts_definitions_test_');
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should generate TypeScript definitions from config file', () async {
      // Arrange
      final configPath = '${tempDir.path}/config.json';
      final outputPath = '${tempDir.path}/output.d.ts';
      
      // Create a sample config file
      final configFile = File(configPath);
      await configFile.writeAsString(jsonEncode({
        'interfaces': [
          {
            'name': 'UserData',
            'properties': [
              {
                'name': 'id',
                'type': 'string',
                'required': true
              }
            ]
          }
        ],
        'actions': [
          {
            'name': 'getUserData',
            'parameters': [
              {
                'name': 'userId',
                'type': 'string',
                'required': true
              }
            ],
            'returnType': 'UserData'
          }
        ]
      }));
      
      // Mock the generator
      when(mockGenerator.generateDefinitionFile(
        interfaces: anyNamed('interfaces'),
        actions: anyNamed('actions'),
      )).thenReturn('// Generated TypeScript definitions');
      
      // Act
      await cli.run(['generate', '--config', configPath, '--output', outputPath]);
      
      // Assert
      verify(mockGenerator.generateDefinitionFile(
        interfaces: anyNamed('interfaces'),
        actions: anyNamed('actions'),
      )).called(1);
      
      // Check that the output file was created
      final outputFile = File(outputPath);
      expect(await outputFile.exists(), isTrue);
      expect(await outputFile.readAsString(), '// Generated TypeScript definitions');
    });

    test('should handle missing config file', () async {
      // Arrange
      final configPath = '${tempDir.path}/non_existent_config.json';
      final outputPath = '${tempDir.path}/output.d.ts';
      
      // Act & Assert
      expect(
        () => cli.run(['generate', '--config', configPath, '--output', outputPath]),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('should handle invalid config file', () async {
      // Arrange
      final configPath = '${tempDir.path}/invalid_config.json';
      final outputPath = '${tempDir.path}/output.d.ts';
      
      // Create an invalid config file
      final configFile = File(configPath);
      await configFile.writeAsString('invalid json');
      
      // Act & Assert
      expect(
        () => cli.run(['generate', '--config', configPath, '--output', outputPath]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
