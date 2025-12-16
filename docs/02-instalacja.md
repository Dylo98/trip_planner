# Instalacja i uruchomienie

## Wymagania systemowe

### Minimalne wymagania

| Komponent | Wymaganie |
|-----------|-----------|
| System operacyjny | Windows 10+, macOS 10.14+, Linux |
| RAM | 8 GB (zalecane 16 GB) |
| Miejsce na dysku | 5 GB wolnego miejsca |
| Flutter SDK | >= 3.6.0 |
| Dart SDK | >= 3.6.0 < 4.0.0 |

### Dla rozwoju na Android

| Komponent | Wymaganie |
|-----------|-----------|
| Android Studio | Arctic Fox (2020.3.1) lub nowszy |
| Android SDK | API Level 21+ (Android 5.0) |
| Java JDK | 11 lub nowszy |

### Dla rozwoju na iOS (tylko macOS)

| Komponent | Wymaganie |
|-----------|-----------|
| Xcode | 14.0 lub nowszy |
| CocoaPods | Najnowsza wersja |
| iOS Deployment Target | 12.0+ |

## Krok 1: Instalacja Flutter

### Windows

```powershell
# Pobierz Flutter SDK z https://flutter.dev/docs/get-started/install/windows
# Rozpakuj do C:\flutter

# Dodaj do PATH
$env:PATH += ";C:\flutter\bin"

# Lub na stałe w zmiennych środowiskowych systemu
```

### macOS

```bash
# Przez Homebrew
brew install flutter

# Lub ręcznie
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

### Linux

```bash
# Przez snap
sudo snap install flutter --classic

# Lub ręcznie
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

### Weryfikacja instalacji

```bash
flutter doctor
```

Upewnij się, że wszystkie checkmarki są zielone (✓) dla platform, na których chcesz rozwijać.

## Krok 2: Klonowanie repozytorium

```bash
# HTTPS
git clone https://github.com/Dylo98/trip_planner.git

# SSH
git clone git@github.com:Dylo98/trip_planner.git

# Przejdź do katalogu projektu
cd trip_planner
```

## Krok 3: Instalacja zależności

```bash
# Pobierz wszystkie pakiety
flutter pub get
```

### Rozwiązywanie problemów z zależnościami

```bash
# Wyczyść cache i pobierz ponownie
flutter clean
flutter pub cache repair
flutter pub get

# Zaktualizuj zależności do najnowszych wersji
flutter pub upgrade
```

## Krok 4: Konfiguracja Firebase

Szczegółowa instrukcja w [03-konfiguracja.md](03-konfiguracja.md).

```bash
# Zainstaluj FlutterFire CLI
dart pub global activate flutterfire_cli

# Skonfiguruj Firebase
flutterfire configure
```

## Krok 5: Konfiguracja zmiennych środowiskowych

Utwórz plik `.env` w głównym katalogu:

```bash
touch .env
```

Dodaj wymagane klucze:

```env
GOOGLE_MAPS_API_KEY=your_api_key_here
```

## Krok 6: Uruchomienie aplikacji

### Tryb debug

```bash
# Uruchom na domyślnym urządzeniu
flutter run

# Uruchom na konkretnym urządzeniu
flutter devices                    # Lista dostępnych urządzeń
flutter run -d <device_id>        # Uruchom na wybranym

# Przykłady
flutter run -d chrome              # Web
flutter run -d emulator-5554       # Android Emulator
flutter run -d iPhone              # iOS Simulator
```

### Tryb release

```bash
flutter run --release
```

### Tryb profile (do analizy wydajności)

```bash
flutter run --profile
```

## Hot Reload i Hot Restart

Podczas działania aplikacji w trybie debug:

| Klawisz | Akcja |
|---------|-------|
| `r` | Hot Reload - odświeża UI zachowując stan |
| `R` | Hot Restart - restartuje aplikację |
| `q` | Zamyka aplikację |
| `p` | Włącza/wyłącza siatę debugowania |
| `o` | Przełącza między Android/iOS stylem |

## Uruchamianie na emulatorach

### Android Emulator

```bash
# Lista dostępnych AVD
emulator -list-avds

# Uruchom emulator
emulator -avd <avd_name>

# Lub przez Android Studio: Tools > AVD Manager
```

### iOS Simulator (tylko macOS)

```bash
# Uruchom domyślny simulator
open -a Simulator

# Lista dostępnych simulatorów
xcrun simctl list devices
```

## Uruchamianie na fizycznym urządzeniu

### Android

1. Włącz **Developer Options** na telefonie:
   - Ustawienia > O telefonie > Numer kompilacji (dotknij 7 razy)

2. Włącz **USB Debugging**:
   - Ustawienia > Opcje programistyczne > Debugowanie USB

3. Podłącz telefon przez USB

4. Potwierdź połączenie na telefonie

5. Sprawdź czy urządzenie jest widoczne:
   ```bash
   flutter devices
   ```

6. Uruchom:
   ```bash
   flutter run
   ```

### iOS (tylko macOS)

1. Podłącz iPhone przez USB

2. Zaufaj komputerowi na telefonie

3. Otwórz projekt w Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

4. Skonfiguruj **Signing & Capabilities**:
   - Wybierz Team (Apple Developer Account)
   - Ustaw Bundle Identifier

5. Uruchom przez Flutter:
   ```bash
   flutter run
   ```

## Struktura po instalacji

```
trip_planner/
├── .dart_tool/           # Cache narzędzi Dart
├── .idea/                # Ustawienia IDE
├── android/              # Projekt Android
├── ios/                  # Projekt iOS
├── lib/                  # Kod źródłowy Dart
├── linux/                # Projekt Linux
├── macos/                # Projekt macOS
├── web/                  # Projekt Web
├── windows/              # Projekt Windows
├── test/                 # Testy
├── assets/               # Zasoby (obrazy, fonty, animacje)
├── .env                  # Zmienne środowiskowe (utworzony ręcznie)
├── pubspec.yaml          # Manifest projektu
├── pubspec.lock          # Zablokowane wersje zależności
└── firebase_options.dart # Konfiguracja Firebase (wygenerowany)
```

## Najczęstsze problemy

### "Flutter SDK not found"

```bash
# Sprawdź czy Flutter jest w PATH
echo $PATH | grep flutter

# Dodaj do ~/.bashrc lub ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"
source ~/.bashrc
```

### "Gradle build failed" (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### "Unable to locate Android SDK"

```bash
# Ustaw ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Problemy z Firebase

```bash
# Przebuduj konfigurację
flutterfire configure --force
```
