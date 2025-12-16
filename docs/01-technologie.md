# Technologie

## Przegląd stosu technologicznego

TripPlanner to aplikacja mobilna zbudowana w oparciu o nowoczesny stos technologiczny, łączący Flutter jako framework UI z Firebase jako kompleksowym rozwiązaniem backendowym.

## Framework i język

| Technologia | Wersja | Opis |
|-------------|--------|------|
| **Flutter** | SDK >=3.6.0 | Cross-platformowy framework UI od Google |
| **Dart** | >=3.6.0 <4.0.0 | Język programowania zoptymalizowany pod UI |

### Dlaczego Flutter?

- **Jeden codebase** - aplikacja działa na Android, iOS, Web, Windows, macOS, Linux
- **Hot Reload** - natychmiastowe odświeżanie zmian podczas developmentu
- **Wydajność** - kompilacja do natywnego kodu maszynowego
- **Bogaty ekosystem** - tysiące gotowych pakietów na pub.dev

## Backend - Firebase

| Usługa | Wersja pakietu | Zastosowanie |
|--------|----------------|--------------|
| **Firebase Core** | 3.13.0 | Inicjalizacja Firebase |
| **Firebase Auth** | 5.5.2 | Autoryzacja użytkowników |
| **Cloud Firestore** | 5.6.7 | Baza danych NoSQL w czasie rzeczywistym |
| **Firebase Storage** | 12.4.6 | Przechowywanie plików (zdjęcia) |

### Firebase Authentication

Obsługiwane metody logowania:
- Email + hasło
- Reset hasła przez email

### Cloud Firestore

- Baza danych dokumentowa NoSQL
- Synchronizacja w czasie rzeczywistym
- Offline persistence
- Skalowalna bez konfiguracji serwera

### Firebase Storage

- Przechowywanie zdjęć podróży
- Zdjęcia profilowe użytkowników
- Zdjęcia markerów na mapie

## State Management

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **flutter_riverpod** | 2.6.1 | Reaktywne zarządzanie stanem |

### Dlaczego Riverpod?

- Compile-time safety - błędy wykrywane podczas kompilacji
- Testability - łatwe mockowanie providerów
- Brak BuildContext - providery dostępne wszędzie
- Automatyczne dispose - zarządzanie cyklem życia

## Nawigacja

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **go_router** | 17.0.0 | Deklaratywny routing |

### Funkcje GoRouter

- URL-based routing
- Deep linking
- Nested routes
- Redirecty na podstawie stanu auth

## Mapy i lokalizacja

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **google_maps_flutter** | 2.12.1 | Widżet Google Maps |
| **geocoding** | 3.0.0 | Konwersja adres ↔ współrzędne |
| **geolocator** | 14.0.0 | Lokalizacja urządzenia |

### Możliwości

- Interaktywne mapy z markerami
- Geokodowanie adresów
- Odwrotne geokodowanie (współrzędne → adres)
- Pobieranie aktualnej lokalizacji użytkownika

## UI/UX

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **google_fonts** | 6.2.1 | Fonty Google (Oswald) |
| **cupertino_icons** | 1.0.8 | Ikony iOS |
| **lottie** | 3.0.0 | Animacje Lottie |
| **animated_text_kit** | 4.2.3 | Animowane teksty |
| **animations** | 2.0.11 | Animacje Material |

## Komponenty UI

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **carousel_slider** | 5.0.0 | Karuzele zdjęć |
| **flutter_staggered_grid_view** | 0.7.0 | Siatki o zmiennej wielkości |
| **timeline_tile** | 2.0.0 | Komponenty osi czasu |
| **modal_bottom_sheet** | 3.0.0 | Zaawansowane bottom sheets |
| **another_flushbar** | 1.10.24 | Powiadomienia snackbar |
| **cached_network_image** | 3.4.1 | Cache'owanie obrazów z sieci |

## Narzędzia pomocnicze

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **flutter_dotenv** | 5.1.0 | Zmienne środowiskowe z .env |
| **http** | 1.4.0 | Requesty HTTP |
| **uuid** | 4.5.1 | Generowanie unikalnych ID |
| **intl** | 0.20.2 | Internacjonalizacja, formatowanie dat |
| **image_picker** | 1.1.2 | Wybieranie zdjęć z galerii/kamery |
| **url_launcher** | 6.3.2 | Otwieranie URL-i zewnętrznych |
| **shared_preferences** | 2.5.3 | Lokalne przechowywanie preferencji |

## Dev Dependencies

| Pakiet | Wersja | Opis |
|--------|--------|------|
| **flutter_test** | SDK | Framework testowy Flutter |
| **flutter_lints** | 5.0.0 | Reguły lintowania kodu |

## Czcionki

Aplikacja używa rodziny fontów **Oswald**:

| Wariant | Waga |
|---------|------|
| ExtraLight | 200 |
| Light | 300 |
| Regular | 400 |
| Medium | 500 |
| SemiBold | 600 |
| Bold | 700 |

## Wspierane platformy

| Platforma | Status | Uwagi |
|-----------|--------|-------|
| Android | ✅ Wspierana | Główna platforma |
| iOS | ✅ Wspierana | Wymaga Mac do budowania |
| Web | ✅ Wspierana | Ograniczona funkcjonalność map |
| Windows | ⚠️ Eksperymentalna | Folder projektu obecny |
| macOS | ⚠️ Eksperymentalna | Folder projektu obecny |
| Linux | ⚠️ Eksperymentalna | Folder projektu obecny |

## Diagram zależności

```
┌─────────────────────────────────────────────────────────┐
│                      TripPlanner                        │
├─────────────────────────────────────────────────────────┤
│  UI Layer                                               │
│  ├── Flutter Framework                                  │
│  ├── Google Fonts, Lottie, Animations                  │
│  └── Custom Widgets                                     │
├─────────────────────────────────────────────────────────┤
│  State Management                                       │
│  └── Riverpod (Providers)                              │
├─────────────────────────────────────────────────────────┤
│  Navigation                                             │
│  └── GoRouter                                          │
├─────────────────────────────────────────────────────────┤
│  Services Layer                                         │
│  ├── AuthService                                        │
│  ├── TripService (Facade)                              │
│  └── Other Feature Services                            │
├─────────────────────────────────────────────────────────┤
│  External APIs                                          │
│  ├── Firebase (Auth, Firestore, Storage)               │
│  └── Google Maps API                                    │
└─────────────────────────────────────────────────────────┘
```
