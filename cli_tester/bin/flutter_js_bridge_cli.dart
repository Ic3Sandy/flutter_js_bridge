import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import '../lib/js_event.dart';
import '../lib/js_message.dart';
import '../lib/js_bridge_controller.dart';
import '../lib/js_event_bus.dart';
import '../lib/mock_webview_controller.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('send-event', ArgParser()
      ..addOption('name', abbr: 'n', help: 'Event name', mandatory: true)
      ..addOption('data', abbr: 'd', help: 'Event data as JSON string')
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false))
    ..addCommand('register-handler', ArgParser()
      ..addOption('action', abbr: 'a', help: 'Action name to register handler for', mandatory: true)
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false))
    ..addCommand('call-js', ArgParser()
      ..addOption('action', abbr: 'a', help: 'JavaScript action to call', mandatory: true)
      ..addOption('data', abbr: 'd', help: 'Data to send as JSON string')
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false))
    ..addCommand('simulate-js-message', ArgParser()
      ..addOption('action', abbr: 'a', help: 'Action name from JavaScript', mandatory: true)
      ..addOption('data', abbr: 'd', help: 'Data as JSON string')
      ..addFlag('expects-response', abbr: 'r', help: 'Whether response is expected', defaultsTo: false)
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false))
    ..addCommand('start-interactive', ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false))
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false)
    ..addFlag('verbose', abbr: 'v', help: 'Show verbose output', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] == true || arguments.isEmpty) {
      printUsage(parser);
      return;
    }

    final verbose = results['verbose'] as bool;
    
    // Create mock controller and bridge
    final mockController = MockWebViewController();
    final bridgeController = JSBridgeController(webViewController: mockController);
    final eventBus = JSEventBus(bridgeController);

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

    final command = results.command!;
    
    switch (command.name) {
      case 'send-event':
        if (command['help'] == true) {
          printCommandHelp(parser, 'send-event');
          return;
        }
        
        final name = command['name'] as String;
        dynamic data;
        
        if (command['data'] != null) {
          try {
            data = jsonDecode(command['data'] as String);
          } catch (e) {
            print('Error parsing JSON data: $e');
            return;
          }
        }
        
        final event = JSEvent(name: name, data: data);
        eventBus.publish(event);
        print('📤 Event sent: $name with data: $data');
        
      case 'register-handler':
        if (command['help'] == true) {
          printCommandHelp(parser, 'register-handler');
          return;
        }
        
        final action = command['action'] as String;
        
        bridgeController.registerHandler(action, (args) {
          print('📥 Handler called for action: $action with args: $args');
          return {'status': 'success', 'message': 'Handled by CLI'};
        });
        
        print('🔌 Registered handler for action: $action');
        
      case 'call-js':
        if (command['help'] == true) {
          printCommandHelp(parser, 'call-js');
          return;
        }
        
        final action = command['action'] as String;
        dynamic data;
        
        if (command['data'] != null) {
          try {
            data = jsonDecode(command['data'] as String);
          } catch (e) {
            print('Error parsing JSON data: $e');
            return;
          }
        }
        
        print('📤 Calling JavaScript action: $action with data: $data');
        final result = await bridgeController.callJavaScript(action, data: data);
        print('📥 Received response: $result');
        
      case 'simulate-js-message':
        if (command['help'] == true) {
          printCommandHelp(parser, 'simulate-js-message');
          return;
        }
        
        final action = command['action'] as String;
        final expectsResponse = command['expects-response'] as bool;
        dynamic data;
        
        if (command['data'] != null) {
          try {
            data = jsonDecode(command['data'] as String);
          } catch (e) {
            print('Error parsing JSON data: $e');
            return;
          }
        }
        
        final message = JSMessage(
          id: bridgeController.generateMessageId(),
          action: action,
          data: data,
          expectsResponse: expectsResponse,
        );
        
        print('🔄 Simulating message from JavaScript: ${message.toJsonString()}');
        mockController.simulateMessageFromJavaScript(message.toJsonString());
        
      case 'start-interactive':
        if (command['help'] == true) {
          printCommandHelp(parser, 'start-interactive');
          return;
        }
        
        await startInteractiveMode(bridgeController, eventBus, verbose);
        
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
  bool verbose
) async {
  print('\n🚀 Starting interactive mode. Type "help" for available commands.');
  print('Press Ctrl+C to exit.\n');
  
  // Setup subscription to all events
  final subscription = eventBus.onAny((event) {
    print('📥 Event received: ${event.name} with data: ${event.data}');
  });
  
  final commandHelp = '''
Available commands:
  send-event <name> [data]       - Send an event with optional JSON data
  register-handler <action>      - Register a handler for an action
  call-js <action> [data]        - Call a JavaScript action with optional JSON data
  simulate-js <action> [data]    - Simulate a message from JavaScript
  help                           - Show this help
  exit                           - Exit interactive mode
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
            data = jsonDecode(dataStr);
          } catch (e) {
            print('Error parsing JSON data: $e');
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
            data = jsonDecode(dataStr);
          } catch (e) {
            print('Error parsing JSON data: $e');
            continue;
          }
        }
        
        print('📤 Calling JavaScript action: $action with data: $data');
        try {
          final result = await bridgeController.callJavaScript(action, data: data);
          print('📥 Received response: $result');
        } catch (e) {
          print('Error calling JavaScript: $e');
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
            data = jsonDecode(dataStr);
          } catch (e) {
            print('Error parsing JSON data: $e');
            continue;
          }
        }
        
        final message = JSMessage(
          id: bridgeController.generateMessageId(),
          action: action,
          data: data,
          expectsResponse: true,
        );
        
        print('🔄 Simulating message from JavaScript: ${message.toJsonString()}');
        bridgeController.webViewController
            .simulateMessageFromJavaScript(message.toJsonString());
        
      default:
        if (command.isNotEmpty) {
          print('Unknown command: $command. Type "help" for available commands.');
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
  print('Run "flutter_js_bridge_cli <command> --help" for more information about a command.');
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
