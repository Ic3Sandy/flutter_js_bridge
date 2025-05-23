#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Running pre-pipeline validation..."

echo "Checking Flutter and Dart versions..."
flutter --version

echo "Validating pubspec.yaml..."
flutter pub get

echo "Checking for outdated dependencies..."
flutter pub outdated

echo "Formatting code..."
# Use --set-exit-if-changed to fail if formatting is needed
if ! dart format . --set-exit-if-changed; then
  echo "Error: Code formatting issues found"
  echo "Please run 'dart format .' to fix formatting issues"
  exit 1
fi

echo "Running static analysis..."
flutter analyze

echo "Running tests..."
flutter test

# Run CLI tester tests
echo "Running CLI tester tests..."
cd cli_tester
chmod +x test_cli.sh
./test_cli.sh
cd ..

echo "All validation checks passed! Your code is ready for the pipeline."
