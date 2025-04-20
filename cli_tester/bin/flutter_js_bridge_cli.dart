import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_js_bridge_cli_tester/js_event.dart';
import 'package:flutter_js_bridge_cli_tester/js_message.dart';
import 'package:flutter_js_bridge_cli_tester/js_bridge_controller.dart';
import 'package:flutter_js_bridge_cli_tester/js_event_bus.dart';
import 'package:flutter_js_bridge_cli_tester/mock_webview_controller.dart';
// Import all debug modules
import 'package:flutter_js_bridge_cli_tester/debug.dart';
// Import TypeScript definitions modules
import 'package:flutter_js_bridge_cli_tester/typescript.dart';

void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addCommand(
          'send-event',
          ArgParser()
            ..addOption('name', abbr: 'n', help: 'Event name', mandatory: true)
            ..addOption('data', abbr: 'd', help: 'Event data as JSON string')
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addCommand(
          'register-handler',
          ArgParser()
            ..addOption(
              'action',
              abbr: 'a',
              help: 'Action name to register handler for',
              mandatory: true,
            )
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addCommand(
          'call-js',
          ArgParser()
            ..addOption(
              'action',
              abbr: 'a',
              help: 'JavaScript action to call',
              mandatory: true,
            )
            ..addOption('data', abbr: 'd', help: 'Data to send as JSON string')
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addCommand(
          'simulate-js-message',
          ArgParser()
            ..addOption(
              'action',
              abbr: 'a',
              help: 'Action name from JavaScript',
              mandatory: true,
            )
            ..addOption('data', abbr: 'd', help: 'Data as JSON string')
            ..addFlag(
              'expects-response',
              abbr: 'r',
              help: 'Whether response is expected',
              defaultsTo: false,
            )
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addCommand(
          'start-interactive',
          ArgParser()
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addCommand(
          'generate-ts-defs',
          ArgParser()
            ..addOption(
              'config',
              abbr: 'c',
              help: 'Path to the config file (JSON)',
              mandatory: false,
            )
            ..addOption(
              'output',
              abbr: 'o',
              help: 'Path to the output file (.d.ts)',
              mandatory: true,
            )
            ..addFlag(
              'extract',
              abbr: 'e',
              help: 'Extract definitions from controller',
              negatable: false,
            )
            ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false),
        )
        ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false)
        ..addFlag(
          'verbose',
          abbr: 'v',
          help: 'Show verbose output',
          negatable: false,
        )
        ..addFlag(
          'debug',
          abbr: 'd',
          help: 'Enable debugging tools',
          negatable: false,
        );

  try {
    final results = parser.parse(arguments);

    if (results['help'] == true || arguments.isEmpty) {
      printUsage(parser);
      return;
    }

    final verbose = results['verbose'] as bool;
    final debug = results['debug'] as bool;

    // Create mock controller and bridge
    final mockController = MockWebViewController();
    final bridgeController = JSBridgeController(
      webViewController: mockController,
    );
    final eventBus = JSEventBus(bridgeController);

    // Create debug manager if debug flag is enabled
    JSDebugManager? debugManager;
    if (debug) {
      debugManager = JSDebugManager(
        config: JSDebugConfig(
          isLoggingEnabled: true,
          logLevel: JSLogLevel.debug,
          isMessageInspectionEnabled: true,
          isPerformanceMonitoringEnabled: true,
        ),
        onLog: (record) {
          if (verbose) {
            print('📝 [${record.level.name.toUpperCase()}] ${record.message}');
          }
        },
        onMessageInspected: (record) {
          if (verbose) {
            final direction = record.direction == JSMessageDirection.outgoing
                ? 'OUTGOING'
                : 'INCOMING';
            print('🔍 [$direction] ${record.message.action}: ${record.message.data}');
          }
        },
      );
    }

    // Setup logging for the mock controller
    mockController.onJavaScriptRun = (code) {
      if (verbose) {
        print('JavaScript code executed: $code');
      }
    };

    // Setup default handler for all events
    bridgeController.registerHandler('event', (args) {
      final event = args[0] as Map<String, dynamic>;
      print('📥 Received event: ${event['name']} with data: ${event['data']}');
      return null;
    });

    if (results.command == null) {
      printUsage(parser);
      return;
    }

    final commandName = results.command!.name;
    final commandResults = results.command!;

    if (commandResults['help'] == true) {
      printCommandHelp(parser, commandName);
      return;
    }

    // Create TypeScript definitions CLI command handler
    final tsDefinitionsCliCommand = TSDefinitionsCliCommand();

    switch (commandName) {
      case 'generate-ts-defs':
        final outputPath = commandResults['output'] as String;
        final configPath = commandResults['config'] as String?;
        final extract = commandResults['extract'] as bool;
        
        try {
          if (extract) {
            // Extract TypeScript definitions from controller
            await tsDefinitionsCliCommand.extractFromController(
              controller: bridgeController,
              outputPath: outputPath,
              verbose: verbose,
            );
          } else if (configPath != null) {
            // Generate TypeScript definitions from config file
            await tsDefinitionsCliCommand.execute(
              configPath: configPath,
              outputPath: outputPath,
              verbose: verbose,
            );
          } else {
            print('Error: Either --config or --extract must be specified');
            printCommandHelp(parser, commandName);
            return;
          }
        } catch (e) {
          print('Error: $e');
          return;
        }
        break;
        
      case 'send-event':
        final eventName = commandResults['name'] as String;
        final eventDataStr = commandResults['data'] as String?;
        dynamic eventData;

        if (eventDataStr != null) {
          try {
            eventData = jsonDecode(eventDataStr);
          } catch (e) {
            print('Error parsing event data: $e');
            return;
          }
        }

        final event = JSEvent(name: eventName, data: eventData);
        eventBus.fire(event);

        if (verbose) {
          print('Event sent: $eventName');
          if (eventData != null) {
            print('Event data: $eventData');
          }
        }
        break;

      case 'register-handler':
        final action = commandResults['action'] as String;

        bridgeController.registerHandler(action, (args) {
          print('📥 Handler called for action: $action with args: $args');
          return {'status': 'success', 'message': 'Handled by CLI'};
        });

        print('🔌 Registered handler for action: $action');
        break;

      case 'call-js':
        final action = commandResults['action'] as String;
        final data = commandResults['data'] as String?;

        print('📤 Calling JavaScript action: $action with data: $data');
        if (debug && debugManager != null) {
          final result = await debugManager.trackOperation('call-js-$action',
              () => bridgeController.callJavaScript(action, data: data));
          print('✅ JavaScript action called successfully');
          print('📤 Result: $result');
        } else {
          final result = await bridgeController.callJavaScript(action, data: data);
          print('✅ JavaScript action called successfully');
          print('📤 Result: $result');
        }
        break;

      case 'simulate-js-message':
        final action = commandResults['action'] as String;
        final expectsResponse = commandResults['expects-response'] as bool;
        final data = commandResults['data'] as String?;
                for (final pair in pairs) {
                  if (pair.contains(':')) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      String key = parts[0].trim();
                      String value = parts[1].trim();
                      // Remove quotes if they exist
                      key = key.replaceAll('"', '').replaceAll('\'', '');
                      if (value.startsWith('"') && value.endsWith('"') ||
                          value.startsWith('\'') && value.endsWith('\'')) {
                        value = value.substring(1, value.length - 1);
                      }
                      map[key] = value;
                    }
                  }
                }
                data = map;
              }
            }
          } catch (e) {
            print('Error parsing JSON data: $e');
            print(
              'Try using a simple format like: --data "key:value" or --data "key1:value1,key2:value2"',
            );
            return;
          }
        }

        final message = JSMessage(
          id: bridgeController.generateMessageId(),
          action: action,
          data: data,
          expectsResponse: expectsResponse,
        );

        print(
          '🔄 Simulating message from JavaScript: ${message.toJsonString()}',
        );
        mockController.simulateMessageFromJavaScript(message.toJsonString());

      case 'start-interactive':
        if (command['help'] == true) {
          printCommandHelp(parser, 'start-interactive');
          return;
        }

        await startInteractiveMode(bridgeController, eventBus, verbose, debug, debugManager);

      default:
        printUsage(parser);
    }
  } catch (e) {
    print('Error: $e');
    printUsage(parser);
  }
}

Future<void> startInteractiveMode(
  JSBridgeController bridgeController,
  JSEventBus eventBus,
  bool verbose,
  bool debug,
  JSDebugManager? debugManager,
) async {
  print('\n🚀 Starting interactive mode. Type "help" for available commands.');
  print('Press Ctrl+C to exit.\n');

  // Setup subscription to all events
  final subscription = eventBus.onAny((event) {
    print('📥 Event received: ${event.name} with data: ${event.data}');
  });

  final commandHelp = '''
Available commands:
  send-event <name> [data]           - Send an event with optional JSON data
  register-handler <action>          - Register a handler for an action
  call-js <action> [data]            - Call a JavaScript action with optional JSON data
  simulate-js <action> [data]        - Simulate a message from JavaScript
  debug-log <level> <message>        - Log a message with specified level (debug/info/warning/error)
  debug-inspect-messages             - Show recent messages that passed through the bridge
  debug-performance                  - Show performance statistics
  debug-config <option> <value>      - Configure debugging options
  help                               - Show this help
  exit                               - Exit interactive mode
''';

  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync();

    if (input == null || input.trim().toLowerCase() == 'exit') {
      break;
    }

    final parts = input.trim().split(' ');
    final command = parts.isNotEmpty ? parts[0].toLowerCase() : '';

    switch (command) {
      case 'help':
        print(commandHelp);

      case 'debug-log':
        if (!debug || debugManager == null) {
          print('Debugging is not enabled. Start with --debug flag.');
          continue;
        }
        if (parts.length < 3) {
          print('Usage: debug-log <level> <message>');
          print('Levels: debug, info, warning, error');
          continue;
        }

        final level = parts[1].toLowerCase();
        final message = parts.sublist(2).join(' ');

        switch (level) {
          case 'debug':
            debugManager.debug(message);
            print('📝 Debug message logged: $message');
          case 'info':
            debugManager.info(message);
            print('📝 Info message logged: $message');
          case 'warning':
            debugManager.warning(message);
            print('📝 Warning message logged: $message');
          case 'error':
            debugManager.error(message);
            print('📝 Error message logged: $message');
          default:
            print('Invalid log level. Use debug, info, warning, or error.');
        }

      case 'debug-inspect-messages':
        if (!debug || debugManager == null) {
          print('Debugging is not enabled. Start with --debug flag.');
          continue;
        }

        final messages = debugManager.messageInspector.getRecentMessages(10);
        if (messages.isEmpty) {
          print('No messages recorded yet.');
        } else {
          print('\n📊 Recent Messages (${messages.length}):');
          for (final record in messages) {
            final direction = record.direction == JSMessageDirection.outgoing
                ? '➡️ OUT'
                : '⬅️ IN';
            print('$direction | ${record.timestamp.toIso8601String()} | ${record.message.action}: ${record.message.data}');
          }
        }

      case 'debug-performance':
        if (!debug || debugManager == null) {
          print('Debugging is not enabled. Start with --debug flag.');
          continue;
        }

        final stats = debugManager.performanceMonitor.getAllOperationStats();
        if (stats.isEmpty) {
          print('No performance data recorded yet.');
        } else {
          print('\n⏱️ Performance Statistics:');
          for (final entry in stats.entries) {
            final stat = entry.value;
            print('${stat.operationName}: ${stat.count} calls, avg: ${stat.averageDuration.inMicroseconds}μs, ' +
                'min: ${stat.minDuration.inMicroseconds}μs, max: ${stat.maxDuration.inMicroseconds}μs');
          }
        }

      case 'debug-config':
        if (!debug || debugManager == null) {
          print('Debugging is not enabled. Start with --debug flag.');
          continue;
        }

        if (parts.length < 3) {
          print('Usage: debug-config <option> <value>');
          print('Options: logging, inspection, performance, errors');
          print('Values: on, off');
          print('Current config: ${debugManager.config}');
          continue;
        }

        final option = parts[1].toLowerCase();
        final value = parts[2].toLowerCase() == 'on';

        var newConfig = debugManager.config;
        switch (option) {
          case 'logging':
            newConfig = newConfig.copyWith(isLoggingEnabled: value);
          case 'inspection':
            newConfig = newConfig.copyWith(isMessageInspectionEnabled: value);
          case 'performance':
            newConfig = newConfig.copyWith(isPerformanceMonitoringEnabled: value);
          case 'errors':
            newConfig = newConfig.copyWith(isErrorTrackingEnabled: value);
          default:
            print('Invalid option. Use logging, inspection, performance, or errors.');
            continue;
        }

        debugManager.updateConfig(newConfig);
        print('Debug configuration updated: ${debugManager.config}');

      case 'send-event':
        if (parts.length < 2) {
          print('Usage: send-event <name> [data]');
          continue;
        }

        final name = parts[1];
        dynamic data;

        if (parts.length > 2) {
          final dataStr = parts.sublist(2).join(' ');
          try {
            // Try to parse it directly first
            try {
              data = jsonDecode(dataStr);
            } catch (_) {
              // If direct parsing fails, try a simpler approach - create a Map manually
              if (dataStr.contains(':')) {
                // Simple key-value parsing for basic JSON objects
                final map = <String, dynamic>{};
                // Remove braces if they exist
                var cleanStr = dataStr.replaceAll('{', '').replaceAll('}', '');
                // Split by commas for multiple key-value pairs
                final pairs = cleanStr.split(',');
                for (final pair in pairs) {
                  if (pair.contains(':')) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      String key = parts[0].trim();
                      String value = parts[1].trim();
                      // Remove quotes if they exist
                      key = key.replaceAll('"', '').replaceAll('\'', '');
                      if (value.startsWith('"') && value.endsWith('"') ||
                          value.startsWith('\'') && value.endsWith('\'')) {
                        value = value.substring(1, value.length - 1);
                      }
                      map[key] = value;
                    }
                  }
                }
                data = map;
              }
            }
          } catch (e) {
            print('Error parsing JSON data: $e');
            print(
              'Try using a simple format like: key:value or key1:value1,key2:value2',
            );
            continue;
          }
        }

        final event = JSEvent(name: name, data: data);
        eventBus.publish(event);
        print('📤 Event sent: $name with data: $data');

      case 'register-handler':
        if (parts.length < 2) {
          print('Usage: register-handler <action>');
          continue;
        }

        final action = parts[1];

        bridgeController.registerHandler(action, (args) {
          print('📥 Handler called for action: $action with args: $args');
          return {'status': 'success', 'message': 'Handled by CLI'};
        });

        print('🔌 Registered handler for action: $action');

      case 'call-js':
        if (parts.length < 2) {
          print('Usage: call-js <action> [data]');
          continue;
        }

        final action = parts[1];
        dynamic data;

        if (parts.length > 2) {
          final dataStr = parts.sublist(2).join(' ');
          try {
            // Try to parse it directly first
            try {
              data = jsonDecode(dataStr);
            } catch (_) {
              // If direct parsing fails, try a simpler approach - create a Map manually
              if (dataStr.contains(':')) {
                // Simple key-value parsing for basic JSON objects
                final map = <String, dynamic>{};
                // Remove braces if they exist
                var cleanStr = dataStr.replaceAll('{', '').replaceAll('}', '');
                // Split by commas for multiple key-value pairs
                final pairs = cleanStr.split(',');
                for (final pair in pairs) {
                  if (pair.contains(':')) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      String key = parts[0].trim();
                      String value = parts[1].trim();
                      // Remove quotes if they exist
                      key = key.replaceAll('"', '').replaceAll('\'', '');
                      if (value.startsWith('"') && value.endsWith('"') ||
                          value.startsWith('\'') && value.endsWith('\'')) {
                        value = value.substring(1, value.length - 1);
                      }
                      map[key] = value;
                    }
                  }
                }
                data = map;
              }
            }
          } catch (e) {
            print('Error parsing JSON data: $e');
            print(
              'Try using a simple format like: key:value or key1:value1,key2:value2',
            );
            continue;
          }
        }

        print('📤 Calling JavaScript action: $action with data: $data');
        if (debug && debugManager != null) {
          final result = await debugManager.trackOperation('call-js-$action',
              () => bridgeController.callJavaScript(action, data: data));
          print('✅ JavaScript action called successfully');
          print('📤 Result: $result');
        } else {
          final result = await bridgeController.callJavaScript(action, data: data);
          print('✅ JavaScript action called successfully');
          print('📤 Result: $result');
        }

      case 'simulate-js':
        if (parts.length < 2) {
          print('Usage: simulate-js <action> [data]');
          continue;
        }

        final action = parts[1];
        dynamic data;

        if (parts.length > 2) {
          final dataStr = parts.sublist(2).join(' ');
          try {
            // Try to parse it directly first
            try {
              data = jsonDecode(dataStr);
            } catch (_) {
              // If direct parsing fails, try a simpler approach - create a Map manually
              if (dataStr.contains(':')) {
                // Simple key-value parsing for basic JSON objects
                final map = <String, dynamic>{};
                // Remove braces if they exist
                var cleanStr = dataStr.replaceAll('{', '').replaceAll('}', '');
                // Split by commas for multiple key-value pairs
                final pairs = cleanStr.split(',');
                for (final pair in pairs) {
                  if (pair.contains(':')) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      String key = parts[0].trim();
                      String value = parts[1].trim();
                      // Remove quotes if they exist
                      key = key.replaceAll('"', '').replaceAll('\'', '');
                      if (value.startsWith('"') && value.endsWith('"') ||
                          value.startsWith('\'') && value.endsWith('\'')) {
                        value = value.substring(1, value.length - 1);
                      }
                      map[key] = value;
                    }
                  }
                }
                data = map;
              }
            }
          } catch (e) {
            print('Error parsing JSON data: $e');
            print(
              'Try using a simple format like: key:value or key1:value1,key2:value2',
            );
            continue;
          }
        }

        final message = JSMessage(
          id: bridgeController.generateMessageId(),
          action: action,
          data: data,
          expectsResponse: true,
        );

        print(
          '🔄 Simulating message from JavaScript: ${message.toJsonString()}',
        );
        bridgeController.webViewController.simulateMessageFromJavaScript(
          message.toJsonString(),
        );

      default:
        if (command.isNotEmpty) {
          print(
            'Unknown command: $command. Type "help" for available commands.',
          );
        }
    }
  }

  subscription.cancel();
  print('👋 Exiting interactive mode.');
}

void printUsage(ArgParser parser) {
  print('Flutter JS Bridge CLI Tester');
  print('A command-line tool to test the Flutter JS Bridge library');
  print('');
  print('Usage:');
  print('  flutter_js_bridge_cli <command> [arguments]');
  print('');
  print('Global options:');
  print(parser.usage);
  print('');
  print('Available commands:');
  print('  send-event          Send an event to JavaScript');
  print('  register-handler    Register a handler for JavaScript actions');
  print('  call-js             Call a JavaScript action');
  print('  simulate-js-message Simulate a message from JavaScript');
  print('  start-interactive   Start interactive mode');
  print('');
  print(
    'Run "flutter_js_bridge_cli <command> --help" for more information about a command.',
  );
}

void printCommandHelp(ArgParser parser, String commandName) {
  final command = parser.commands[commandName]!;
  print('flutter_js_bridge_cli $commandName');
  print('');
  print('Usage:');
  print('  flutter_js_bridge_cli $commandName [options]');
  print('');
  print('Options:');
  print(command.usage);
}
