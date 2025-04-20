import 'dart:convert';
import 'dart:io';

import 'package:flutter_js_bridge_cli_tester/js_bridge_controller.dart';
import 'package:flutter_js_bridge_cli_tester/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge_cli_tester/typescript/ts_definitions_models.dart';

/// Command handler for TypeScript definitions generation in the CLI tester
class TSDefinitionsCliCommand {
  /// The TypeScript definitions generator
  final TSDefinitionsGenerator _generator;

  /// Creates a new TypeScript definitions CLI command
  TSDefinitionsCliCommand({
    TSDefinitionsGenerator? generator,
  }) : _generator = generator ?? TSDefinitionsGenerator();

  /// Executes the command with the given arguments
  /// 
  /// [configPath] Path to the configuration file
  /// [outputPath] Path to the output file
  /// [verbose] Whether to show verbose output
  Future<void> execute({
    required String configPath,
    required String outputPath,
    bool verbose = false,
  }) async {
    try {
      if (verbose) {
        print('Reading config from: $configPath');
      }

      final configFile = File(configPath);
      if (!await configFile.exists()) {
        throw FileSystemException('Config file not found', configPath);
      }

      final configJson = jsonDecode(await configFile.readAsString());
      
      final interfaces = <TSInterfaceDefinition>[];
      final actions = <TSActionDefinition>[];

      // Parse interfaces
      if (configJson['interfaces'] != null) {
        for (final interfaceJson in configJson['interfaces']) {
          interfaces.add(TSInterfaceDefinition.fromJson(interfaceJson));
        }
        
        if (verbose) {
          print('Parsed ${interfaces.length} interface definitions');
        }
      }

      // Parse actions
      if (configJson['actions'] != null) {
        for (final actionJson in configJson['actions']) {
          actions.add(TSActionDefinition.fromJson(actionJson));
        }
        
        if (verbose) {
          print('Parsed ${actions.length} action definitions');
        }
      }

      // Generate definitions
      final definitions = _generator.generateDefinitionFile(
        interfaces: interfaces,
        actions: actions,
      );

      // Write to output file
      final outputFile = File(outputPath);
      await outputFile.writeAsString(definitions);

      print('TypeScript definitions generated successfully: $outputPath');
    } catch (e) {
      print('Error generating TypeScript definitions: $e');
      rethrow;
    }
  }

  /// Extracts TypeScript definitions from a JSBridgeController
  /// 
  /// [controller] The JSBridgeController to extract definitions from
  /// [outputPath] Path to the output file
  /// [verbose] Whether to show verbose output
  Future<void> extractFromController({
    required JSBridgeController controller,
    required String outputPath,
    bool verbose = false,
  }) async {
    try {
      if (verbose) {
        print('Extracting TypeScript definitions from controller');
      }

      // In a real implementation, this would extract metadata from the controller
      // For this example, we'll create some sample definitions
      final interfaces = <TSInterfaceDefinition>[
        TSInterfaceDefinition(
          name: 'UserData',
          properties: [
            TSPropertyDefinition(
              name: 'id',
              type: 'string',
              required: true,
              description: 'User ID',
            ),
            TSPropertyDefinition(
              name: 'name',
              type: 'string',
              required: true,
              description: 'User name',
            ),
          ],
          description: 'Represents user data',
        ),
      ];

      final actions = <TSActionDefinition>[
        TSActionDefinition(
          name: 'getUserData',
          parameters: [
            TSParameterDefinition(
              name: 'userId',
              type: 'string',
              required: true,
              description: 'The ID of the user to fetch',
            ),
          ],
          returnType: 'Promise<UserData>',
          description: 'Fetches user data from Flutter',
        ),
      ];

      // Generate definitions
      final definitions = _generator.generateDefinitionFile(
        interfaces: interfaces,
        actions: actions,
      );

      // Write to output file
      final outputFile = File(outputPath);
      await outputFile.writeAsString(definitions);

      print('TypeScript definitions generated successfully: $outputPath');
      
      if (verbose) {
        print('Generated definitions:');
        print('-------------------');
        print(definitions);
        print('-------------------');
      }
    } catch (e) {
      print('Error generating TypeScript definitions: $e');
      rethrow;
    }
  }
}
