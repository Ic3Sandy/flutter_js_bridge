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

echo Formatting code...
dart format .
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

echo All checks passed! You can now push your changes.
