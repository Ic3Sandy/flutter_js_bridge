# Flutter JS Bridge CLI Tester

A command-line application to test the Flutter JS Bridge library without requiring a Flutter application or WebView.

## Overview

This CLI tester provides a way to test the functionality of the Flutter JS Bridge library through command-line arguments. It uses a mock implementation of the WebViewController to simulate JavaScript interactions.

## Features

- Send events to JavaScript
- Register handlers for JavaScript actions
- Call JavaScript actions
- Simulate messages from JavaScript
- Interactive mode for continuous testing

## Getting Started

1. Make sure you have Dart SDK installed (version ^3.7.2)
2. Navigate to the `cli_tester` directory
3. Run `dart pub get` to install dependencies
4. Run the CLI tester with `dart run bin/flutter_js_bridge_cli.dart`

## Usage

```bash
# Show help
dart run bin/flutter_js_bridge_cli.dart --help

# Send an event to JavaScript
dart run bin/flutter_js_bridge_cli.dart send-event --name "myEvent" --data '{"key": "value"}'

# Register a handler for JavaScript actions
dart run bin/flutter_js_bridge_cli.dart register-handler --action "myAction"

# Call a JavaScript action
dart run bin/flutter_js_bridge_cli.dart call-js --action "myAction" --data '{"key": "value"}'

# Simulate a message from JavaScript
dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action "myAction" --data '{"key": "value"}' --expects-response

# Start interactive mode
dart run bin/flutter_js_bridge_cli.dart start-interactive
```

## Interactive Mode

Interactive mode allows you to continuously test the library without restarting the CLI. Available commands in interactive mode:

- `send-event <name> [data]` - Send an event with optional JSON data
- `register-handler <action>` - Register a handler for an action
- `call-js <action> [data]` - Call a JavaScript action with optional JSON data
- `simulate-js <action> [data]` - Simulate a message from JavaScript
- `help` - Show help
- `exit` - Exit interactive mode

Example:
```
> send-event buttonClick {"id":"submit-btn"}
> register-handler formSubmit
> simulate-js getData {"userId":123}
```

## Testing Scenarios

### Event Bus Testing

Test the event bus functionality by sending events and subscribing to them:

```bash
# Start interactive mode
dart run bin/flutter_js_bridge_cli.dart start-interactive

# Register a handler for events
> register-handler event

# Send an event
> send-event buttonClick {"id":"submit-btn"}

# Simulate an event from JavaScript
> simulate-js event {"name":"serverResponse","data":{"status":"success"}}
```

### JavaScript Communication Testing

Test direct communication with JavaScript:

```bash
# Call a JavaScript method
> call-js getUserData {"userId":123}

# Simulate a response from JavaScript
> simulate-js response {"name":"John","age":30}
```
