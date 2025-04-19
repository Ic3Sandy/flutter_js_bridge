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

# Check code formatting
echo "Checking code formatting..."
dart format . --set-exit-if-changed

# Run static analysis
echo "Running static analysis..."
flutter analyze

# Run tests
echo "Running tests..."
flutter test

echo "All checks passed! You can now push your changes."
