# Konfiguracja

## Przegląd konfiguracji

Aplikacja TripPlanner wymaga skonfigurowania następujących elementów:

1. **Firebase** - backend (auth, baza danych, storage)
2. **Google Maps API** - mapy i geolokalizacja
3. **Google AI API** - funkcje AI (opcjonalnie)
4. **Zmienne środowiskowe** - klucze API

## Konfiguracja Firebase

### Krok 1: Utwórz projekt Firebase

1. Przejdź do [Firebase Console](https://console.firebase.google.com/)
2. Kliknij **Add project**
3. Podaj nazwę projektu (np. "trip-planner")
4. Opcjonalnie włącz Google Analytics
5. Kliknij **Create project**

### Krok 2: Włącz wymagane usługi

#### Authentication

1. W konsoli Firebase: **Build > Authentication**
2. Kliknij **Get started**
3. W zakładce **Sign-in method** włącz:
   - **Email/Password** - podstawowa metoda

#### Cloud Firestore

1. W konsoli Firebase: **Build > Firestore Database**
2. Kliknij **Create database**
3. Wybierz tryb:
   - **Production mode** - dla produkcji (wymaga reguł bezpieczeństwa)
   - **Test mode** - dla developmentu (otwarte przez 30 dni)
4. Wybierz lokalizację (np. europe-west1)

#### Firebase Storage

1. W konsoli Firebase: **Build > Storage**
2. Kliknij **Get started**
3. Wybierz tryb (Production/Test)
4. Wybierz lokalizację

### Krok 3: Zainstaluj FlutterFire CLI

```bash
# Zainstaluj globalnie
dart pub global activate flutterfire_cli

# Sprawdź instalację
flutterfire --version
```

### Krok 4: Skonfiguruj Firebase w projekcie

```bash
# Zaloguj się do Firebase
firebase login

# Skonfiguruj projekt
flutterfire configure
```

Podczas konfiguracji:
1. Wybierz swój projekt Firebase
2. Wybierz platformy (Android, iOS, Web)
3. CLI automatycznie wygeneruje `firebase_options.dart`

### Krok 5: Zweryfikuj konfigurację

Plik `lib/firebase_options.dart` powinien zostać wygenerowany:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Konfiguracja dla każdej platformy
  }
}
```

## Reguły bezpieczeństwa Firestore

W konsoli Firebase > Firestore > Rules, ustaw reguły:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Użytkownicy mogą czytać/pisać tylko swoje dane
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Podróże użytkownika
      match /trips/{tripId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Udostępnione podróże
      match /shared_trips/{tripId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if request.auth != null;
      }
    }
  }
}
```

## Reguły bezpieczeństwa Storage

W konsoli Firebase > Storage > Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Zdjęcia podróży
    match /trips/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Zdjęcia profilowe
    match /avatars/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Konfiguracja Google Maps API

### Krok 1: Włącz API w Google Cloud Console

1. Przejdź do [Google Cloud Console](https://console.cloud.google.com/)
2. Wybierz projekt Firebase (są połączone)
3. **APIs & Services > Library**
4. Wyszukaj i włącz:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Maps JavaScript API** (dla web)
   - **Places API**
   - **Geocoding API**

### Krok 2: Utwórz klucz API

1. **APIs & Services > Credentials**
2. **Create Credentials > API key**
3. Kliknij na utworzony klucz aby go skonfigurować
4. **Restrict key**:
   - Dla produkcji: ogranicz do konkretnych aplikacji
   - Dla developmentu: możesz zostawić bez ograniczeń

### Krok 3: Skonfiguruj klucz w projekcie

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/AppDelegate.swift`)

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Web (`web/index.html`)

```html
<head>
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
</head>
```

## Plik .env

Utwórz plik `.env` w głównym katalogu projektu:

```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIza...your_key_here

# Opcjonalne - dodatkowe konfiguracje
# DEBUG_MODE=true
# API_BASE_URL=https://api.example.com
```

### Bezpieczeństwo

**WAŻNE:** Plik `.env` zawiera wrażliwe dane!

1. Upewnij się, że `.env` jest w `.gitignore`:
   ```gitignore
   # Zmienne środowiskowe
   .env
   .env.local
   .env.*.local
   ```

2. Nigdy nie commituj kluczy API do repozytorium

3. Dla produkcji używaj:
   - Zmiennych środowiskowych CI/CD
   - Secret management (np. Google Secret Manager)

## Konfiguracja Android

### `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.trip_planner"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### Uprawnienia (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest ...>
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- Lokalizacja -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <!-- Kamera i zdjęcia -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

    <application ...>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${GOOGLE_MAPS_API_KEY}"/>
    </application>
</manifest>
```

## Konfiguracja iOS

### `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Lokalizacja -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Ta aplikacja potrzebuje dostępu do lokalizacji, aby pokazać Twoją pozycję na mapie.</string>

    <key>NSLocationAlwaysUsageDescription</key>
    <string>Ta aplikacja potrzebuje dostępu do lokalizacji w tle.</string>

    <!-- Kamera -->
    <key>NSCameraUsageDescription</key>
    <string>Ta aplikacja potrzebuje dostępu do kamery, aby robić zdjęcia.</string>

    <!-- Galeria -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Ta aplikacja potrzebuje dostępu do galerii, aby wybierać zdjęcia.</string>
</dict>
```

## Weryfikacja konfiguracji

### Sprawdź Firebase

```bash
# W konsoli Flutter
flutter run
# Aplikacja powinna się uruchomić bez błędów Firebase
```

### Sprawdź Google Maps

```dart
// W aplikacji powinny się wyświetlać mapy bez błędów
// Sprawdź konsolę na błędy API key
```

### Sprawdź zmienne środowiskowe

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  print('Maps API: ${dotenv.env['GOOGLE_MAPS_API_KEY']}');
}
```

## Środowiska (Development/Production)

Dla różnych środowisk możesz utworzyć:

```
.env.development
.env.staging
.env.production
```

I ładować odpowiedni plik:

```dart
void main() async {
  const environment = String.fromEnvironment('ENV', defaultValue: 'development');
  await dotenv.load(fileName: '.env.$environment');
  // ...
}
```

Uruchomienie z konkretnym środowiskiem:

```bash
flutter run --dart-define=ENV=production
```
