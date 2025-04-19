#!/bin/bash

# Exit on error
set -e

echo "Running pre-push checks..."

# Check Flutter version
echo "Checking Flutter version..."
flutter --version

# Check for outdated dependencies
echo "Checking for outdated dependencies..."
flutter pub outdated

# Format code
echo "Formatting code..."
dart format .

# Run static analysis
echo "Running static analysis..."
flutter analyze --exclude=cli_tester

# Run tests
echo "Running tests..."
flutter test

echo "All checks passed! You can now push your changes."
