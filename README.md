# ClimaGrowth – AI-Powered Farming Assistant

> **Smart Farming with AI** | Pilot Region: Padra, Gujarat, India | v1.0.0

ClimaGrowth is a production-ready Flutter mobile application that helps farmers in the Padra region of Gujarat make better agricultural decisions using real-time weather data, soil insights, satellite maps, disaster alerts, and an AI-powered chatbot (ClimaVOICE).

---

## Features

| Feature | Description |
|---|---|
| Authentication | Mobile OTP + Email/Password login via Firebase |
| Weather Module | Real-time data from Open-Meteo API with 7-day forecast |
| Soil Health | Moisture gauge, health badge, irrigation advice |
| AI Chatbot | ClimaVOICE powered by Gemini API with voice input |
| Farm Map | Google Maps with satellite view and farm pin |
| Disaster Alerts | FCM push notifications for floods, storms, heatwaves |
| Crop Recommendations | AI-generated cards for crop, water, fertilizer, market |
| Market Prices | Mandi prices with 7-day trend charts |
| Government Schemes | Scheme cards with eligibility and apply links |
| Offline Mode | Hive caching for weather, recommendations, and chat |
| Multi-language | English, Gujarati, Hindi support |
| Dark/Light Theme | User-selectable with dynamic weather-responsive gradients |

---

## Tech Stack

- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Firebase (Auth, Firestore, FCM, Storage)
- **Weather API**: Open-Meteo (free, no key required)
- **Maps**: Google Maps Flutter SDK
- **AI**: Gemini API (Google)
- **State Management**: Provider
- **Offline Cache**: Hive
- **Charts**: fl_chart

---

## Project Structure

```
climagrowth/
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # MaterialApp + routing + providers
│   ├── screens/               # 18 screens
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── weather_screen.dart
│   │   ├── soil_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── map_screen.dart
│   │   ├── alerts_screen.dart
│   │   ├── crop_form_screen.dart
│   │   ├── recommendations_screen.dart
│   │   ├── recommendation_detail_screen.dart
│   │   ├── market_prices_screen.dart
│   │   ├── govt_schemes_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── help_support_screen.dart
│   │   └── auth/
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── widgets/               # Reusable widgets
│   ├── services/              # API & Firebase services
│   ├── models/                # Data models
│   ├── providers/             # State management
│   ├── utils/                 # Constants, themes, validators
│   └── l10n/                  # ARB localization files
├── android/
├── ios/
├── assets/
└── pubspec.yaml
```

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio or VS Code
- Firebase CLI (`npm install -g firebase-tools`)

### 1. Clone & Install

```bash
git clone <your-repo>
cd climagrowth
flutter pub get
```

### 2. Firebase Setup

```bash
firebase login
flutterfire configure
```

This generates `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

Enable these Firebase services:
- Authentication (Email/Password + Phone)
- Firestore Database
- Cloud Messaging (FCM)

### 3. API Keys

Edit `lib/utils/constants.dart`:

```dart
const String kGeminiApiKey = 'YOUR_GEMINI_API_KEY';
const String kGoogleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

Get keys from:
- Gemini: https://makersuite.google.com/app/apikey
- Google Maps: https://console.cloud.google.com (enable Maps SDK for Android/iOS)

Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`.

### 4. Google Maps for iOS

In `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Generate Localization

```bash
flutter gen-l10n
```

### 6. Run

```bash
# Debug mode
flutter run

# Release APK
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release
```

---

## Environment Configuration

| Variable | Location | Description |
|---|---|---|
| `kGeminiApiKey` | `constants.dart` | Google Gemini AI key |
| `kGoogleMapsApiKey` | `constants.dart` + `AndroidManifest.xml` | Google Maps key |
| `google-services.json` | `android/app/` | Firebase Android config |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase iOS config |

---

## Firestore Security Rules (recommended)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /soilData/{doc} {
      allow read, write: if request.auth != null && resource.data.uid == request.auth.uid;
    }
    match /chatHistory/{doc} {
      allow read, write: if request.auth != null;
    }
    match /alerts/{doc} {
      allow read: if request.auth != null;
      allow write: if false; // admin only
    }
    match /marketPrices/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /schemes/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## Offline Support

The app caches the following locally (Hive):
- Last fetched weather data
- Latest AI recommendations
- Chat history (last 50 messages)
- User settings (language, theme, notification preferences)

An orange banner appears when the app detects no internet connection.

---

## Contact

**Project**: ClimaGrowth  
**Made by**: Preet 😊
**Version**: 1.0.0 | May 2026
