import 'dart:io';
import 'package:flutter_js_bridge_cli_tester/typescript/ts_definitions_cli_command.dart';
import 'package:flutter_js_bridge_cli_tester/typescript/ts_definitions_generator.dart';
import 'package:flutter_js_bridge_cli_tester/typescript/ts_definitions_models.dart';

/// A simple demo script to show how to use the TypeScript Definitions Generator
void main() async {
  // Demo header information is not printed during tests
  // Flutter JS Bridge - TypeScript Definitions Generator Demo
  // --------------------------------------------------------
  
  // Create a generator
  final generator = TSDefinitionsGenerator();
  
  // Define some interfaces
  final interfaces = [
    TSInterfaceDefinition(
      name: 'UserData',
      properties: [
        TSPropertyDefinition(name: 'id', type: 'string', required: true, description: 'User ID'),
        TSPropertyDefinition(name: 'name', type: 'string', required: true, description: 'User name'),
        TSPropertyDefinition(name: 'email', type: 'string', required: true, description: 'User email'),
        TSPropertyDefinition(name: 'age', type: 'number', required: false, description: 'User age (optional)'),
      ],
      description: 'Represents user data',
    ),
    TSInterfaceDefinition(
      name: 'Settings',
      properties: [
        TSPropertyDefinition(name: 'theme', type: 'string', required: true, description: 'UI theme (light/dark)'),
        TSPropertyDefinition(name: 'notifications', type: 'boolean', required: true, description: 'Whether notifications are enabled'),
      ],
      description: 'User settings configuration',
    ),
  ];
  
  // Define some actions
  final actions = [
    TSActionDefinition(
      name: 'getUserData',
      parameters: [
        TSParameterDefinition(name: 'userId', type: 'string', required: true, description: 'The ID of the user to fetch'),
      ],
      returnType: 'Promise<UserData>',
      description: 'Fetches user data from Flutter',
    ),
    TSActionDefinition(
      name: 'saveSettings',
      parameters: [
        TSParameterDefinition(name: 'settings', type: 'Settings', required: true, description: 'The settings to save'),
      ],
      returnType: 'Promise<boolean>',
      description: 'Saves user settings to Flutter',
    ),
  ];
  
  // Generate TypeScript definitions
  final definitions = generator.generateDefinitionFile(
    interfaces: interfaces,
    actions: actions,
  );
  
  // Generated definitions are not printed during tests
  // Instead, they are written directly to the output file
  
  // Save the definitions to a file
  final outputPath = 'typescript_demo_output.d.ts';
  final outputFile = File(outputPath);
  await outputFile.writeAsString(definitions);
  
  // TypeScript definitions written to file
  
  // Try loading from config file
  
  final configPath = 'sample_ts_config.json';
  if (await File(configPath).exists()) {
    final cliCommand = TSDefinitionsCliCommand(generator: generator);
    
    try {
      await cliCommand.execute(
        configPath: configPath,
        outputPath: 'typescript_demo_config_output.d.ts',
        verbose: true,
      );
    } catch (e) {
      // Error handling is silent during tests
    }
  } else {
    // Config file not found handling is silent during tests
  }
}
