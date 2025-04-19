# Comprehensive test script for Flutter JS Bridge CLI Tester
# This script runs a series of tests to verify all functionality

# Clear the console for better readability
Clear-Host

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   Flutter JS Bridge CLI Tester - Comprehensive Test   " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Function to run a test and display the result
function Test-Command {
    param (
        [string]$TestName,
        [string]$Command,
        [string]$ExpectedOutput = $null
    )
    
    Write-Host "Test: $TestName" -ForegroundColor Yellow
    Write-Host "Command: $Command" -ForegroundColor Gray
    
    try {
        $output = Invoke-Expression $Command
        
        if ($LASTEXITCODE -eq 0) {
            if ($ExpectedOutput -and -not ($output -match $ExpectedOutput)) {
                Write-Host "✗ Test failed - Output doesn't match expected pattern" -ForegroundColor Red
                Write-Host "Expected to contain: $ExpectedOutput" -ForegroundColor Red
                Write-Host "Actual output: $output" -ForegroundColor Red
            } else {
                Write-Host "✓ Test passed" -ForegroundColor Green
            }
        } else {
            Write-Host "✗ Test failed with exit code $LASTEXITCODE" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Test failed with error: $_" -ForegroundColor Red
    }
    
    Write-Host "--------------------------" -ForegroundColor Gray
}

Write-Host "SECTION 1: Basic Commands" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

# Test 1: Show help
Test-Command -TestName "Show help" -Command "dart run bin/flutter_js_bridge_cli.dart --help" -ExpectedOutput "Flutter JS Bridge CLI Tester"

# Test 2: Register a handler
Test-Command -TestName "Register handler" -Command "dart run bin/flutter_js_bridge_cli.dart register-handler --action testAction" -ExpectedOutput "Registered handler for action: testAction"

# Test 3: Send an event with simple data
Test-Command -TestName "Send event with simple data" -Command "dart run bin/flutter_js_bridge_cli.dart send-event --name testEvent --data 'key:value'" -ExpectedOutput "Event sent: testEvent"

# Test 4: Send an event with complex data
Test-Command -TestName "Send event with complex data" -Command "dart run bin/flutter_js_bridge_cli.dart send-event --name complexEvent --data 'key1:value1,key2:value2'" -ExpectedOutput "Event sent: complexEvent"

Write-Host "SECTION 2: JavaScript Interaction" -ForegroundColor Cyan
Write-Host "-------------------------------" -ForegroundColor Cyan

# Test 5: Call JavaScript action
Test-Command -TestName "Call JavaScript action" -Command "dart run bin/flutter_js_bridge_cli.dart call-js --action testAction --data 'key:value'" -ExpectedOutput "Calling JavaScript action: testAction"

# Test 6: Simulate JavaScript message
Test-Command -TestName "Simulate JavaScript message" -Command "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data 'key:value'" -ExpectedOutput "Simulating message from JavaScript"

# Test 7: Simulate JavaScript message with expects-response flag
Test-Command -TestName "Simulate JavaScript message with expects-response" -Command "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data 'key:value' --expects-response" -ExpectedOutput "Simulating message from JavaScript"

Write-Host "SECTION 3: Error Handling" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

# Test 8: Invalid command
Test-Command -TestName "Invalid command" -Command "dart run bin/flutter_js_bridge_cli.dart invalid-command 2>&1" -ExpectedOutput "Could not find a command named"

# Test 9: Missing required parameter
Test-Command -TestName "Missing required parameter" -Command "dart run bin/flutter_js_bridge_cli.dart register-handler 2>&1" -ExpectedOutput "Missing option"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "                 All Tests Completed                  " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test interactive mode, run:" -ForegroundColor Yellow
Write-Host "dart run bin/flutter_js_bridge_cli.dart start-interactive" -ForegroundColor White
Write-Host ""
Write-Host "In interactive mode, try these commands:" -ForegroundColor Yellow
Write-Host "help" -ForegroundColor White
Write-Host "register-handler testAction" -ForegroundColor White
Write-Host "send-event testEvent key:value" -ForegroundColor White
Write-Host "call-js testAction key:value" -ForegroundColor White
Write-Host "simulate-js testAction key:value" -ForegroundColor White
Write-Host "exit" -ForegroundColor White
