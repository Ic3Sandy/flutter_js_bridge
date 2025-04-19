#!/bin/bash

# Exit on error
set -e

echo "Running pre-push checks..."

# Format code
echo "Formatting code..."
dart format .

# Run static analysis
echo "Running static analysis..."
flutter analyze

# Run tests
echo "Running tests..."
flutter test

echo "All checks passed! You can now push your changes."
