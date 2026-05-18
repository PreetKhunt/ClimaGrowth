@echo off
echo ============================================================
echo   ClimaGrowth – Setup Script (Windows)
echo ============================================================

echo.
echo [1/6] Checking Flutter installation...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found. Install from https://flutter.dev
    pause
    exit /b 1
)

echo.
echo [2/6] Installing Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed.
    pause
    exit /b 1
)

echo.
echo [3/6] Generating localization files...
flutter gen-l10n
if errorlevel 1 (
    echo WARNING: Localization generation failed. Check l10n.yaml.
)

echo.
echo [4/6] Checking Firebase CLI...
firebase --version
if errorlevel 1 (
    echo Firebase CLI not found. Installing...
    npm install -g firebase-tools
)

echo.
echo [5/6] Checking FlutterFire CLI...
dart pub global activate flutterfire_cli
echo.
echo IMPORTANT: Run the following command to connect your Firebase project:
echo   flutterfire configure
echo.
echo This will generate lib/firebase_options.dart automatically.

echo.
echo [6/6] Reminder – API keys to set in lib/utils/constants.dart:
echo   kGeminiApiKey      = your Gemini API key
echo   kGoogleMapsApiKey  = your Google Maps API key
echo.
echo Also set kGoogleMapsApiKey in:
echo   android/app/src/main/AndroidManifest.xml  (meta-data value)
echo   ios/Runner/AppDelegate.swift               (GMSServices.provideAPIKey)

echo.
echo ============================================================
echo   Setup complete! Run: flutter run
echo ============================================================
pause
