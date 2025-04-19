#!/bin/bash
# Test script for Flutter JS Bridge CLI Tester
# This script runs various commands to verify that the CLI tester is working correctly

# Set colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Flutter JS Bridge CLI Tester - Test Script ===${NC}\n"

# Function to run a test and check if it succeeded
run_test() {
  local test_name="$1"
  local command="$2"
  
  echo -e "${YELLOW}Testing: ${test_name}${NC}"
  echo -e "Command: ${command}"
  
  # Run the command
  eval "$command"
  
  # Check the exit code
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Test passed${NC}\n"
  else
    echo -e "${RED}✗ Test failed${NC}\n"
  fi
}

# Test 1: Show help
run_test "Show help" "dart run bin/flutter_js_bridge_cli.dart --help"

# Test 2: Register a handler
run_test "Register handler" "dart run bin/flutter_js_bridge_cli.dart register-handler --action testAction"

# Test 3: Send an event with simple data
run_test "Send event with simple data" "dart run bin/flutter_js_bridge_cli.dart send-event --name testEvent --data \"key:value\""

# Test 4: Send an event with complex data
run_test "Send event with complex data" "dart run bin/flutter_js_bridge_cli.dart send-event --name complexEvent --data \"key1:value1,key2:value2\""

# Test 5: Call JavaScript action
run_test "Call JavaScript action" "dart run bin/flutter_js_bridge_cli.dart call-js --action testAction --data \"key:value\""

# Test 6: Simulate JavaScript message
run_test "Simulate JavaScript message" "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data \"key:value\""

# Test 7: Simulate JavaScript message with expects-response flag
run_test "Simulate JavaScript message with expects-response" "dart run bin/flutter_js_bridge_cli.dart simulate-js-message --action testAction --data \"key:value\" --expects-response"

echo -e "${BLUE}=== All tests completed ===${NC}"
echo -e "${YELLOW}Note: To test interactive mode, run:${NC}"
echo -e "dart run bin/flutter_js_bridge_cli.dart start-interactive"
