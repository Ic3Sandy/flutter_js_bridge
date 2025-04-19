@echo off
echo Running pre-push checks...

echo Checking Flutter version...
flutter --version
if %ERRORLEVEL% neq 0 (
    echo Error checking Flutter version
    exit /b %ERRORLEVEL%
)

echo Checking for outdated dependencies...
flutter pub outdated
if %ERRORLEVEL% neq 0 (
    echo Error checking dependencies
    exit /b %ERRORLEVEL%
)

echo Checking code formatting...
dart format . --set-exit-if-changed
if %ERRORLEVEL% neq 0 (
    echo Error formatting code
    exit /b %ERRORLEVEL%
)

echo Running static analysis...
flutter analyze
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

echo Running CLI tester tests...
cd cli_tester
if %ERRORLEVEL% neq 0 (
    echo Error changing to cli_tester directory
    exit /b %ERRORLEVEL%
)
powershell -ExecutionPolicy Bypass -File .\test_cli.ps1
if %ERRORLEVEL% neq 0 (
    echo Error running CLI tester tests
    exit /b %ERRORLEVEL%
)
cd ..

echo All checks passed! You can now push your changes.
