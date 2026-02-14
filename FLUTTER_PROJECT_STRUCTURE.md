# Struktura projektu Flutter - omówienie na przykładzie TripPlanner

## 1. Czym jest Flutter?

Flutter to framework od Google do tworzenia aplikacji wieloplatformowych (Android, iOS, Web, Desktop) z jednej bazy kodu napisanej w języku **Dart**. Projekt Flutter ma ściśle określoną strukturę katalogów, z których każdy pełni konkretną rolę.

---

## 2. Struktura katalogów głównych (root)

Po utworzeniu nowego projektu (`flutter create trip_planner`) otrzymujemy następujący układ:

```
trip_planner/
├── lib/                        # Główny kod aplikacji (Dart)
├── test/                       # Testy jednostkowe i widgetowe
├── assets/                     # Zasoby statyczne (obrazy, czcionki, animacje)
│
├── android/                    # Kod natywny Android (Kotlin/Java, Gradle)
├── ios/                        # Kod natywny iOS (Swift/Obj-C, Xcode)
├── web/                        # Konfiguracja platformy webowej
├── linux/                      # Kod natywny Linux (CMake, C++)
├── macos/                      # Kod natywny macOS (Swift, Xcode)
├── windows/                    # Kod natywny Windows (CMake, C++)
│
├── pubspec.yaml                # Manifest projektu - zależności, zasoby, metadane
├── pubspec.lock                # Zablokowane wersje zależności
├── analysis_options.yaml       # Konfiguracja analizatora Dart (reguły lintingu)
├── .gitignore                  # Pliki ignorowane przez Git
├── .metadata                   # Metadane Flutter (wersja, typ projektu)
└── README.md                   # Dokumentacja projektu
```

### Co robi każdy element?

| Element | Rola |
|---------|------|
| **`lib/`** | Cały kod Dart aplikacji — tu programista spędza 95% czasu |
| **`test/`** | Testy — jednostkowe, widgetowe, integracyjne |
| **`assets/`** | Pliki statyczne: obrazy, czcionki, animacje Lottie, pliki JSON |
| **`android/`** | Natywny projekt Android — konfiguracja Gradle, manifesty, ikony |
| **`ios/`** | Natywny projekt iOS — konfiguracja Xcode, Info.plist, ikony |
| **`web/`** | Pliki HTML/JS dla wersji webowej |
| **`pubspec.yaml`** | "Serce" projektu — definiuje nazwę, wersję, zależności, zasoby |

---

## 3. Plik `pubspec.yaml` — manifest projektu

To najważniejszy plik konfiguracyjny. Definiuje:

```yaml
name: trip_planner              # Nazwa pakietu
version: 1.0.0+1                # Wersja aplikacji + numer buildu

environment:
  sdk: '>=3.6.0 <4.0.0'        # Wymagana wersja Dart SDK

dependencies:                    # Zależności produkcyjne
  flutter:
    sdk: flutter
  firebase_core: ^3.13.0        # Firebase
  flutter_riverpod: ^2.6.1      # Zarządzanie stanem
  go_router: ^17.0.0            # Nawigacja/Routing
  google_maps_flutter: ^2.12.1  # Mapy Google

dev_dependencies:                # Zależności deweloperskie (testy, lint)
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true     # Włącza ikony Material Design
  assets:                        # Deklaracja zasobów statycznych
    - assets/images/logo.png
    - assets/lottie/LottieAnimation.json
  fonts:                         # Deklaracja niestandardowych czcionek
    - family: Oswald
      fonts:
        - asset: assets/fonts/oswald/Oswald-Regular.ttf
        - asset: assets/fonts/oswald/Oswald-Bold.ttf
          weight: 700
```

**Kluczowe sekcje:**
- **`dependencies`** — paczki pobierane z [pub.dev](https://pub.dev)
- **`assets`** — każdy plik statyczny musi być tu zadeklarowany
- **`fonts`** — niestandardowe czcionki z wagami (weight)

---

## 4. Punkt wejścia — `lib/main.dart`

Każda aplikacja Flutter zaczyna się od funkcji `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Inicjalizacja silnika Flutter
  await dotenv.load(fileName: ".env");         // Załadowanie zmiennych środowiskowych
  await Firebase.initializeApp(                // Inicjalizacja Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp())); // Uruchomienie aplikacji
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,   // Motyw wizualny
      routerConfig: appRouter,      // Konfiguracja nawigacji
    );
  }
}
```

**Co tu widać:**
1. `WidgetsFlutterBinding.ensureInitialized()` — wymagane przed operacjami async w `main()`
2. Inicjalizacja usług zewnętrznych (Firebase, .env)
3. `ProviderScope` — opakowanie dla Riverpod (zarządzanie stanem)
4. `MaterialApp.router` — korzeń drzewa widgetów z Material Design i routingiem

---

## 5. Struktura katalogu `lib/` — Feature-First Architecture

Projekt TripPlanner stosuje architekturę **Feature-First** (modularną), gdzie kod jest podzielony wg funkcjonalności, a nie wg warstw technicznych:

```
lib/
├── main.dart                    # Punkt wejścia
├── firebase_options.dart        # Konfiguracja Firebase (auto-generowany)
│
├── core/                        # Współdzielone komponenty bazowe
│   ├── navigation/              # Routing (GoRouter)
│   │   └── app_router.dart
│   ├── theme/                   # Motyw wizualny
│   │   ├── app_theme.dart       # Konfiguracja ThemeData
│   │   ├── colors.dart          # Paleta kolorów
│   │   ├── text_style.dart      # Style typografii
│   │   ├── button_style.dart    # Style przycisków
│   │   └── input_style.dart     # Style pól formularza
│   ├── utils/                   # Narzędzia pomocnicze
│   │   ├── validators.dart      # Walidatory formularzy
│   │   ├── debouncer.dart       # Ogranicznik częstotliwości wywołań
│   │   └── text_utils.dart      # Formatowanie tekstu
│   └── widgets/                 # Widgety wielokrotnego użytku
│       ├── app_notifications.dart
│       ├── loading_indicator.dart
│       ├── empty_state.dart
│       ├── buttons/
│       ├── dialog/
│       └── drawer/
│
└── features/                    # Moduły funkcjonalne
    ├── auth/                    # Autoryzacja
    ├── trip/                    # Zarządzanie wycieczkami
    ├── budget/                  # Budżet i wydatki
    ├── schedule/                # Harmonogram dnia
    ├── friends/                 # Znajomi i udostępnianie
    ├── home/                    # Ekran główny
    ├── profile/                 # Profil użytkownika
    ├── statistics/              # Statystyki podróży
    ├── timeline/                # Oś czasu
    └── splash/                  # Ekran powitalny
```

---

## 6. Anatomia modułu funkcjonalnego (Feature)

Każdy moduł w `features/` ma spójną, powtarzalną strukturę wewnętrzną:

```
features/trip/
├── model/                       # Modele danych (klasy Dart)
│   ├── trip_model.dart          # Model wycieczki
│   ├── marker_point_model.dart  # Model znacznika na mapie
│   └── place_category.dart      # Enum kategorii miejsc
│
├── services/                    # Logika biznesowa i komunikacja z backendem
│   ├── trip_service.dart        # Fasada — główny punkt dostępu
│   ├── trip/
│   │   ├── trip_crud_service.dart
│   │   └── trip_image_service.dart
│   ├── marker/
│   │   └── marker_crud_service.dart
│   └── google_places/
│       └── google_places_service.dart
│
├── providers/                   # Zarządzanie stanem (Riverpod)
│   ├── get_trip_provider.dart   # Stream wycieczek użytkownika
│   ├── all_trips_provider.dart  # Wszystkie wycieczki (własne + shared)
│   └── trip_form_provider.dart  # Stan formularza
│
├── controllers/                 # Kontrolery logiki UI
│   ├── trip_details_edit_controller.dart
│   └── map/
│       └── trip_map_controller.dart
│
├── screens/                     # Widoki/ekrany (pełne strony)
│   ├── new_trip/
│   │   └── new_trip_screen.dart
│   ├── trip_details/
│   │   └── trip_details_screen.dart
│   └── trip_list/
│       └── trips_list_screen.dart
│
├── widgets/                     # Komponenty UI (fragmenty ekranów)
│   ├── trip_card/
│   │   ├── trip_card.dart
│   │   └── trip_card_content.dart
│   ├── marker_details_sheet/
│   └── nearby_places/
│
└── utils/                       # Narzędzia specyficzne dla tego modułu
    ├── trip_sorting_helper.dart
    └── trip_status_helper.dart
```

### Rola każdej warstwy:

| Warstwa | Odpowiedzialność | Przykład |
|---------|-----------------|----------|
| **`model/`** | Klasy danych — definiują kształt danych, serializacja JSON | `TripModel` z polami: id, name, dates |
| **`services/`** | Logika biznesowa, komunikacja z Firebase/API | Zapis/odczyt wycieczek z Firestore |
| **`providers/`** | Zarządzanie stanem — łączą serwisy z UI | `getTripProvider` — stream wycieczek |
| **`controllers/`** | Złożona logika stanu UI (StateNotifier) | Kontroler mapy, edycji formularza |
| **`screens/`** | Pełne ekrany/strony aplikacji | Ekran listy wycieczek |
| **`widgets/`** | Mniejsze, wielokrotnego użytku elementy UI | Karta wycieczki, bottom sheet |
| **`utils/`** | Funkcje pomocnicze specyficzne dla modułu | Sortowanie wycieczek, helper statusów |

---

## 7. Warstwa `core/` — współdzielona baza

### 7.1 Nawigacja (`core/navigation/`)

Flutter używa deklaratywnego routingu. W tym projekcie zastosowano **GoRouter**:

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    // Przekierowanie na /auth jeśli użytkownik niezalogowany
  },
  routes: [
    GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/',     builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/my-trips', ...),
    GoRoute(path: '/friends', ...),
    GoRoute(path: '/profile', ...),
  ],
);
```

### 7.2 Motyw (`core/theme/`)

System wizualny zdefiniowany centralnie:

- **`colors.dart`** — paleta kolorów (`AppColors.primary`, `AppColors.error`)
- **`text_style.dart`** — style tekstu (`AppTextStyles.heading`, `AppTextStyles.body`)
- **`app_theme.dart`** — kompletny `ThemeData` dla Material Design
- **`button_style.dart`** — style przycisków z gradientami
- **`input_style.dart`** — style pól formularza

### 7.3 Narzędzia (`core/utils/`)

Współdzielone funkcje pomocnicze:
- **`validators.dart`** — walidacja formularzy (email, hasło, daty)
- **`debouncer.dart`** — ograniczenie częstotliwości np. wyszukiwania
- **`action_lock.dart`** — zapobieganie podwójnemu kliknięciu

### 7.4 Widgety współdzielone (`core/widgets/`)

Komponenty UI używane w wielu modułach:
- `loading_indicator.dart` — spinner ładowania
- `empty_state.dart` — ekran pustego stanu
- `error_display.dart` — wyświetlanie błędów
- `app_notifications.dart` — powiadomienia snackbar
- `dialog/` — współdzielone okna dialogowe
- `drawer/` — szuflada nawigacyjna

---

## 8. Zasoby statyczne (`assets/`)

```
assets/
├── images/                      # Obrazy rastrowe (JPG, PNG)
│   ├── logo.png
│   ├── background_image1.jpg
│   ├── image_home.jpg
│   └── no_profile.jpg
├── fonts/                       # Niestandardowe czcionki
│   └── oswald/
│       ├── Oswald-Regular.ttf
│       ├── Oswald-Bold.ttf
│       └── ... (6 wariantów)
└── lottie/                      # Animacje Lottie (JSON)
    └── LottieAnimation.json
```

Każdy zasób musi być zadeklarowany w `pubspec.yaml` w sekcji `flutter.assets` lub `flutter.fonts`.

---

## 9. Katalogi platform natywnych

### `android/`
```
android/
├── app/
│   ├── build.gradle.kts         # Konfiguracja buildu (min SDK, zależności)
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml  # Manifest Android (uprawnienia, activity)
│       │   └── kotlin/              # Kod natywny Kotlin (jeśli potrzeba)
│       ├── debug/                   # Konfiguracja debug
│       └── profile/                 # Konfiguracja profilowania
├── build.gradle.kts             # Konfiguracja Gradle na poziomie projektu
└── gradle/                      # Wrapper Gradle
```

### `ios/`
```
ios/
├── Runner/
│   ├── AppDelegate.swift        # Punkt wejścia iOS
│   ├── Info.plist               # Konfiguracja iOS (uprawnienia, orientacja)
│   ├── Assets.xcassets/         # Ikony i obrazy iOS
│   └── Base.lproj/             # Storyboardy
├── Runner.xcodeproj/           # Projekt Xcode
└── Runner.xcworkspace/         # Workspace Xcode (z CocoaPods)
```

Flutter generuje te katalogi automatycznie. Programista modyfikuje je tylko gdy:
- Trzeba dodać uprawnienia natywne (kamera, lokalizacja, internet)
- Trzeba zintegrować natywny SDK
- Trzeba zmienić ikonę lub splash screen

---

## 10. Testy (`test/`)

```
test/
└── widget_test.dart             # Testy widgetów
```

Flutter obsługuje trzy rodzaje testów:

| Typ | Lokalizacja | Cel |
|-----|-------------|-----|
| **Jednostkowe** | `test/` | Testowanie logiki (serwisy, modele) |
| **Widgetowe** | `test/` | Testowanie komponentów UI w izolacji |
| **Integracyjne** | `integration_test/` | Testowanie pełnych scenariuszy użytkownika |

---

## 11. Pliki konfiguracyjne

### `analysis_options.yaml`
```yaml
include: package:flutter_lints/flutter.yaml  # Rekomendowane reguły lintera
```
Definiuje reguły statycznej analizy kodu — ostrzeżenia, błędy stylu, najlepsze praktyki.

### `.gitignore`
Wyklucza z repozytorium:
- Artefakty budowania (`build/`, `.dart_tool/`)
- Pliki IDE (`.idea/`, `.vscode/`)
- Sekrety (`.env`)
- Zależności natywne (`Pods/`, `*.apk`)

### `.metadata`
Metadane projektu Flutter — wersja frameworka, typ projektu, migracje platform.

---

## 12. Wzorce architektoniczne zastosowane w projekcie

### 12.1 Feature-First Architecture
Kod pogrupowany wg funkcjonalności (auth, trip, budget), nie wg warstw technicznych (models, views, controllers). Ułatwia skalowanie — nowa funkcjonalność = nowy folder.

### 12.2 Wzorzec Fasady (Facade)
`TripService` pełni rolę fasady — deleguje operacje do wyspecjalizowanych serwisów:
```
TripService (fasada)
  ├── TripCrudService       — CRUD wycieczek
  ├── TripImageService      — zarządzanie zdjęciami
  ├── TripDeletionService   — usuwanie z czyszczeniem
  ├── MarkerCrudService     — operacje na znacznikach
  └── GooglePlacesService   — pobliskie miejsca
```

### 12.3 Provider Pattern (Riverpod)
Zarządzanie stanem przez providery — reaktywne strumienie danych:
```dart
final getTripProvider = StreamProvider((ref) {
  return ref.watch(tripServiceProvider).getUserTrips();
});
```

### 12.4 Wzorzec Repository/Service
Serwisy abstrahują komunikację z Firebase/API — widgety nie wiedzą skąd pochodzą dane.

---

## 13. Przepływ danych w aplikacji

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│   Firebase   │◄──►│   Services   │◄──►│  Providers  │◄──►│  Widgets │
│  (Firestore, │    │  (logika     │    │  (Riverpod  │    │  (UI —   │
│   Auth,      │    │   biznesowa) │    │   stan)     │    │  ekrany, │
│   Storage)   │    │              │    │             │    │  karty)  │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────┘
       ▲                                                        │
       └────────────────────────────────────────────────────────┘
                         (cykl reaktywny)
```

1. **Firebase** — baza danych, autoryzacja, storage
2. **Services** — odczyt/zapis danych, logika biznesowa
3. **Providers** — zarządzanie stanem, cache, reaktywne strumienie
4. **Widgets** — renderowanie UI na podstawie stanu z providerów

---

## 14. Podsumowanie — co trzeba zapamiętać

| Zasada | Opis |
|--------|------|
| **Jeden `lib/`** | Cały kod Dart w jednym katalogu |
| **`pubspec.yaml` to manifest** | Zależności, zasoby, czcionki — wszystko tu zadeklarowane |
| **`main.dart` to start** | Funkcja `main()` → `runApp()` |
| **Feature-First** | Każda funkcjonalność w osobnym katalogu z pełną strukturą warstw |
| **`core/` to współdzielone** | Motyw, nawigacja, widgety bazowe, narzędzia |
| **Platformy natywne** | Katalogi `android/`, `ios/` itd. — modyfikowane rzadko |
| **Deklaracja zasobów** | Obrazy i czcionki muszą być zadeklarowane w `pubspec.yaml` |
| **Stan przez Riverpod** | Providery łączą logikę biznesową z widgetami reaktywnie |
