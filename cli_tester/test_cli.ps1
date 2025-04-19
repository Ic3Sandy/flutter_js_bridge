# PowerShell Test script for Flutter JS Bridge CLI Tester
# This script runs various commands to verify that the CLI tester is working correctly

# Set colors for better readability
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Blue "=== Flutter JS Bridge CLI Tester - Test Script ==="
Write-Output ""

# Function to run a test and check if it succeeded
function Run-Test {
    param (
        [string]$TestName,
        [string]$Command
    )
    
    Write-ColorOutput Yellow "Testing: $TestName"
    Write-Output "Command: $Command"
    
    # Run the command
    try {
        Invoke-Expression $Command
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput Green "✓ Test passed"
        } else {
            Write-ColorOutput Red "✗ Test failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-ColorOutput Red "✗ Test failed with error: $_"
    }
    
    Write-Output ""
}

# Test 1: Show help
Run-Test -TestName "Show help" -Command "dart run bin/flutter_js_bridge_cli.dart --help"

# Test 2: Register a handler
Run-Test -TestName "Register handler" -Command "dart run bin/flutter_js_bridge_cli.dart register-handler --action testAction"

# Test 3: Send an event with simple data
Run-Test -TestName "Send event with simple data" -Command "dart run bin/flutter_js_bridge_cli.dart send-event --name testEvent --data 'key:value'"

# Test 4: Send an event with complex data
Run-Test -TestName "Send event with complex data" -Command "dart run bin/flutter_js_bridge_cli.dart send-event --name complexEvent --data 'key1:value1,key2:value2'"

# Test 5: Call JavaScript action
Run-Test -TestName "Call JavaScript action" -Command "dart run bin/flutter_js_bridge_cli.dart call-js --action testAction --data 'key:value'"

# Test 6: Simulate JavaScript message
Run-Test -TestName "Simulate JavaScript message" -Command "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data 'key:value'"

# Test 7: Simulate JavaScript message with expects-response flag
Run-Test -TestName "Simulate JavaScript message with expects-response" -Command "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data 'key:value' --expects-response"

Write-ColorOutput Blue "=== All tests completed ==="
Write-ColorOutput Yellow "Note: To test interactive mode, run:"
Write-Output "dart run bin/flutter_js_bridge_cli.dart start-interactive"
