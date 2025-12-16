# Budowanie aplikacji

## Przegląd

Ten dokument opisuje proces budowania aplikacji TripPlanner na różne platformy: Android, iOS i Web.

---

## Przygotowanie do budowania

### Sprawdzenie środowiska

```bash
# Sprawdź konfigurację Flutter
flutter doctor

# Sprawdź podłączone urządzenia
flutter devices

# Wyczyść poprzednie buildy
flutter clean

# Pobierz zależności
flutter pub get
```

### Wersjonowanie

**Lokalizacja:** `pubspec.yaml`

```yaml
version: 1.0.0+1
#        │     │
#        │     └── Build number (dla store'ów)
#        └── Version name (wyświetlana użytkownikom)
```

Zwiększanie wersji:
```yaml
# Przed release
version: 1.0.0+1

# Po release
version: 1.0.1+2   # Bug fix
version: 1.1.0+3   # Nowa funkcja
version: 2.0.0+4   # Major release
```

---

## Android

### Konfiguracja podpisywania

#### Krok 1: Utwórz keystore

```bash
keytool -genkey -v -keystore ~/trip-planner-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias trip-planner
```

#### Krok 2: Utwórz `android/key.properties`

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=trip-planner
storeFile=/Users/username/trip-planner-key.jks
```

**WAŻNE:** Dodaj do `.gitignore`:
```gitignore
android/key.properties
*.jks
```

#### Krok 3: Skonfiguruj `android/app/build.gradle`

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Budowanie APK

```bash
# APK release
flutter build apk --release

# APK dla konkretnej architektury (mniejszy rozmiar)
flutter build apk --release --split-per-abi

# Lokalizacja outputu:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Budowanie App Bundle (Google Play)

```bash
flutter build appbundle --release

# Lokalizacja outputu:
# build/app/outputs/bundle/release/app-release.aab
```

### Konfiguracja ProGuard

**Lokalizacja:** `android/app/proguard-rules.pro`

```proguard
# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
```

---

## iOS

### Wymagania

- macOS z zainstalowanym Xcode 14+
- Apple Developer Account (dla dystrybucji)
- Konfiguracja Signing & Capabilities w Xcode

### Konfiguracja w Xcode

```bash
# Otwórz projekt w Xcode
open ios/Runner.xcworkspace
```

W Xcode:
1. Wybierz **Runner** w nawigatorze projektu
2. Zakładka **Signing & Capabilities**
3. Wybierz **Team** (konto Apple Developer)
4. Ustaw **Bundle Identifier**: `com.yourcompany.tripplanner`

### Budowanie dla iOS

```bash
# Build bez podpisywania (do testów)
flutter build ios --release --no-codesign

# Build z podpisywaniem (wymaga konfiguracji w Xcode)
flutter build ios --release

# Lokalizacja outputu:
# build/ios/iphoneos/Runner.app
```

### Archiwizacja dla App Store

```bash
# 1. Zbuduj aplikację
flutter build ios --release

# 2. Otwórz Xcode
open ios/Runner.xcworkspace

# 3. W Xcode: Product > Archive
# 4. W Organizer: Distribute App > App Store Connect
```

### Budowanie IPA

```bash
# Wymaga odpowiedniego provisioning profile
flutter build ipa --release

# Lokalizacja:
# build/ios/ipa/trip_planner.ipa
```

---

## Web

### Budowanie dla Web

```bash
flutter build web --release

# Lokalizacja outputu:
# build/web/
```

### Optymalizacje

```bash
# Z tree-shaking ikon Material
flutter build web --release --tree-shake-icons

# Z konkretnym rendererem
flutter build web --release --web-renderer html      # Mniejszy rozmiar
flutter build web --release --web-renderer canvaskit # Lepsza jakość
flutter build web --release --web-renderer auto      # Automatyczny wybór
```

### Konfiguracja `web/index.html`

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TripPlanner</title>

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <!-- Google Maps API -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>

  <!-- Flutter loading -->
  <script src="flutter_bootstrap.js" async></script>
</head>
<body>
  <!-- Loading indicator -->
  <div id="loading">
    <img src="icons/Icon-192.png" alt="Loading...">
  </div>
</body>
</html>
```

### PWA Configuration

**Lokalizacja:** `web/manifest.json`

```json
{
  "name": "TripPlanner",
  "short_name": "TripPlanner",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Aplikacja do planowania podróży",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

---

## Deployment

### Firebase Hosting (Web)

```bash
# Zainstaluj Firebase CLI
npm install -g firebase-tools

# Zaloguj się
firebase login

# Inicjalizacja (jednorazowo)
firebase init hosting

# Build i deploy
flutter build web --release
firebase deploy --only hosting
```

**Konfiguracja:** `firebase.json`

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Google Play Store (Android)

1. **Utwórz konto** Google Play Developer ($25 jednorazowo)
2. **Utwórz aplikację** w Google Play Console
3. **Upload App Bundle** (.aab)
4. **Wypełnij listing**:
   - Tytuł i opis
   - Screenshots
   - Ikona
   - Kategoria
5. **Konfiguruj release**:
   - Internal testing (szybkie testy)
   - Closed testing (beta testerzy)
   - Open testing (publiczna beta)
   - Production (pełny release)

### Apple App Store (iOS)

1. **Utwórz konto** Apple Developer ($99/rok)
2. **Utwórz App ID** w Apple Developer Portal
3. **Utwórz aplikację** w App Store Connect
4. **Upload przez Xcode** (Archive > Distribute)
5. **Wypełnij metadane**:
   - Nazwa i opis
   - Screenshots dla różnych urządzeń
   - Ikona
   - Kategoria
   - Privacy policy URL
6. **Submit for Review**

---

## Zmienne środowiskowe w build

### Różne konfiguracje

```bash
# Development
flutter run --dart-define=ENV=development

# Staging
flutter build apk --dart-define=ENV=staging

# Production
flutter build apk --dart-define=ENV=production
```

### Odczyt w kodzie

```dart
const environment = String.fromEnvironment('ENV', defaultValue: 'development');

void main() async {
  await dotenv.load(fileName: '.env.$environment');
  // ...
}
```

---

## CI/CD

### GitHub Actions przykład

**Lokalizacja:** `.github/workflows/build.yml`

```yaml
name: Build & Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-firebase-project
```

---

## Debugowanie buildów

### Analiza rozmiaru APK

```bash
flutter build apk --analyze-size

# Otwiera interaktywny raport w przeglądarce
```

### Sprawdzenie podpisu APK

```bash
# Weryfikacja podpisu
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Informacje o certyfikacie
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

### Logi budowania

```bash
# Verbose output
flutter build apk --release -v

# Bardzo verbose
flutter build apk --release -vv
```

---

## Checklist przed release

### Android
- [ ] Zaktualizuj `version` w `pubspec.yaml`
- [ ] Skonfiguruj keystore i podpisywanie
- [ ] Zbuduj w trybie release
- [ ] Przetestuj na fizycznym urządzeniu
- [ ] Sprawdź rozmiar APK/AAB
- [ ] Przygotuj screenshots i opisy

### iOS
- [ ] Zaktualizuj `version` w `pubspec.yaml`
- [ ] Skonfiguruj Signing w Xcode
- [ ] Zarchiwizuj i prześlij do App Store Connect
- [ ] Przetestuj przez TestFlight
- [ ] Przygotuj screenshots dla wszystkich rozmiarów
- [ ] Dodaj Privacy Policy URL

### Web
- [ ] Zbuduj z optymalizacjami
- [ ] Skonfiguruj Firebase Hosting
- [ ] Przetestuj PWA
- [ ] Sprawdź performance w Lighthouse
- [ ] Skonfiguruj domenę (opcjonalnie)
