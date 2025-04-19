@echo off
echo Running pre-pipeline validation...

echo Checking Flutter and Dart versions...
flutter --version
if %ERRORLEVEL% neq 0 (
    echo Error checking Flutter version
    exit /b %ERRORLEVEL%
)

echo Validating pubspec.yaml...
flutter pub get
if %ERRORLEVEL% neq 0 (
    echo Error validating dependencies
    exit /b %ERRORLEVEL%
)

echo Checking for outdated dependencies...
flutter pub outdated
if %ERRORLEVEL% neq 0 (
    echo Error checking dependencies
    exit /b %ERRORLEVEL%
)

echo Formatting code...
dart format . --set-exit-if-changed
if %ERRORLEVEL% neq 0 (
    echo Error: Code formatting issues found
    echo Please run 'dart format .' to fix formatting issues
    exit /b %ERRORLEVEL%
)

echo Running static analysis...
flutter analyze --exclude=cli_tester
if %ERRORLEVEL% neq 0 (
    echo Error during static analysis
    exit /b %ERRORLEVEL%
)

echo Running tests...
flutter test
if %ERRORLEVEL% neq 0 (
    echo Error during tests
    exit /b %ERRORLEVEL%
)

echo All validation checks passed! Your code is ready for the pipeline.
