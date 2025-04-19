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

## Running Test Scripts

The CLI tester comes with test scripts to verify its functionality. These scripts run a series of commands to test different features of the CLI tester.

### Bash Script (Unix/Linux/macOS/WSL)

To run the bash test script:

1. Make the script executable:
   ```bash
   chmod +x test_cli.sh
   ```

2. Run the script:
   ```bash
   ./test_cli.sh
   ```

The script will run various commands and display whether each test passed or failed with color-coded output.

### PowerShell Script (Windows)

To run the PowerShell test script:

```powershell
.\test_cli.ps1
```

For a more comprehensive test suite that includes error handling tests:

```powershell
.\run_tests.ps1
```

### Test Script Features

- Tests basic commands (help, register-handler, send-event)
- Tests JavaScript interaction (call-js, simulate-js-message)
- Tests with different data formats (simple key:value, complex data)
- Color-coded output for easy readability
- Summary of all test results

### JSON Data Format

When using the CLI tester or test scripts, you can provide JSON data in several formats:

1. Standard JSON format: `'{"key": "value"}'`
2. Simple key-value format: `'key:value'`
3. Multiple key-value pairs: `'key1:value1,key2:value2'`

The CLI tester will automatically parse these formats appropriately.
