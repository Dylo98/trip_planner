# TripPlanner

Aplikacja mobilna do planowania i zarządzania podróżami, napisana w Flutter z wykorzystaniem Firebase jako backendu.

## Pełna dokumentacja

Szczegółowa dokumentacja techniczna znajduje się w folderze **[docs/](docs/README.md)**:

| Dokument | Opis |
|----------|------|
| [Technologie](docs/01-technologie.md) | Stos technologiczny, biblioteki |
| [Instalacja](docs/02-instalacja.md) | Wymagania, instalacja |
| [Konfiguracja](docs/03-konfiguracja.md) | Firebase, API keys |
| [Architektura](docs/04-architektura.md) | Wzorce projektowe |
| [Struktura projektu](docs/05-struktura-projektu.md) | Organizacja kodu |
| [Funkcjonalności](docs/06-funkcjonalnosci.md) | Features aplikacji |
| [Modele danych](docs/07-modele-danych.md) | Trip, MarkerPoint, etc. |
| [Serwisy](docs/08-serwisy.md) | Logika biznesowa |
| [State Management](docs/09-state-management.md) | Riverpod |
| [Nawigacja](docs/10-nawigacja.md) | GoRouter |
| [Baza danych](docs/11-baza-danych.md) | Firestore |
| [Budowanie](docs/12-budowanie.md) | Build & Deploy |

---

## Spis treści

- [Technologie](#technologie)
- [Wymagania](#wymagania)
- [Instalacja](#instalacja)
- [Konfiguracja](#konfiguracja)
- [Architektura](#architektura)
- [Struktura projektu](#struktura-projektu)
- [Funkcjonalności](#funkcjonalności)
- [Modele danych](#modele-danych)
- [Serwisy](#serwisy)
- [State Management](#state-management)
- [Nawigacja](#nawigacja)

## Technologie

| Technologia | Wersja | Opis |
|-------------|--------|------|
| Flutter | SDK >=3.6.0 | Framework UI |
| Dart | >=3.6.0 <4.0.0 | Język programowania |
| Firebase Auth | 5.5.2 | Autoryzacja użytkowników |
| Cloud Firestore | 5.6.7 | Baza danych NoSQL |
| Firebase Storage | 12.4.6 | Przechowywanie plików |
| Riverpod | 2.6.1 | State management |
| GoRouter | 17.0.0 | Nawigacja |
| Google Maps Flutter | 2.12.1 | Mapy i geolokalizacja |

## Wymagania

- Flutter SDK >= 3.6.0
- Dart >= 3.6.0
- Konto Firebase z aktywowanymi usługami:
  - Authentication
  - Cloud Firestore
  - Storage
- Klucz API Google Maps

## Instalacja

```bash
# Klonowanie repozytorium
git clone <repository-url>
cd trip_planner

# Instalacja zależności
flutter pub get

# Uruchomienie aplikacji
flutter run
```

## Konfiguracja

### Plik .env

Utwórz plik `.env` w głównym katalogu projektu:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### Firebase

Projekt wymaga konfiguracji Firebase. Plik `firebase_options.dart` powinien być wygenerowany przez FlutterFire CLI:

```bash
flutterfire configure
```

## Architektura

Projekt wykorzystuje architekturę **Feature-First** z podziałem na moduły funkcjonalne. Każdy moduł zawiera własne:
- Ekrany (screens)
- Widgety (widgets)
- Serwisy (services)
- Providery (providers)
- Modele (model)

### Wzorce projektowe

- **Facade Pattern** - `TripService` jako główna fasada delegująca do wyspecjalizowanych serwisów
- **Repository Pattern** - separacja logiki dostępu do danych
- **Provider Pattern** - zarządzanie stanem z Riverpod

## Struktura projektu

```
lib/
├── main.dart                    # Punkt wejścia aplikacji
├── firebase_options.dart        # Konfiguracja Firebase
│
├── core/                        # Moduł współdzielony
│   ├── navigation/
│   │   └── app_router.dart      # Konfiguracja GoRouter
│   ├── theme/
│   │   ├── app_theme.dart       # Główny motyw aplikacji
│   │   ├── colors.dart          # Paleta kolorów
│   │   ├── text_style.dart      # Style tekstów
│   │   ├── button_style.dart    # Style przycisków
│   │   └── input_style.dart     # Style pól formularzy
│   ├── utils/
│   │   ├── validators.dart      # Walidatory formularzy
│   │   ├── debouncer.dart       # Debouncing akcji
│   │   ├── text_utils.dart      # Pomocnicze funkcje tekstowe
│   │   ├── location_name.dart   # Nazwy lokalizacji
│   │   └── action_lock.dart     # Blokada równoczesnych akcji
│   └── widgets/
│       ├── buttons/             # Przyciski wielokrotnego użytku
│       ├── dialog/              # Komponenty dialogów
│       ├── drawer/              # Szuflada nawigacyjna
│       ├── error_display.dart   # Wyświetlanie błędów
│       ├── empty_state.dart     # Stan pusty
│       ├── loading_indicator.dart
│       └── user_avatar.dart
│
└── features/                    # Moduły funkcjonalne
    ├── auth/                    # Autoryzacja
    │   ├── screens/
    │   │   └── auth.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   └── user_repository.dart
    │   └── model/
    │       └── app_user.dart
    │
    ├── home/                    # Ekran główny
    │   └── screens/
    │       └── home.dart
    │
    ├── trip/                    # Zarządzanie podróżami
    │   ├── screens/
    │   │   ├── trip_list/
    │   │   ├── trip_details/
    │   │   └── new_trip/
    │   ├── widgets/
    │   │   ├── trip_card/
    │   │   ├── trip_details/
    │   │   ├── marker_details_sheet/
    │   │   ├── nearby_places/
    │   │   └── shared/
    │   ├── services/
    │   │   ├── trip_service.dart      # Fasada główna
    │   │   ├── trip/                  # Serwisy podróży
    │   │   └── marker/                # Serwisy markerów
    │   ├── providers/
    │   │   ├── all_trips_provider.dart
    │   │   ├── trip_markers_provider.dart
    │   │   └── trip_form_provider.dart
    │   ├── model/
    │   │   ├── trip_model.dart
    │   │   └── marker_point_model.dart
    │   └── utils/
    │
    ├── budget/                  # Budżet i wydatki
    │   ├── screens/
    │   │   └── trip_budget_screen.dart
    │   ├── services/
    │   │   ├── budget_calculator_service.dart
    │   │   ├── settlement_calculator_service.dart
    │   │   └── trip_expense_service.dart
    │   └── model/
    │       ├── expense_item_model.dart
    │       ├── budget_statistics_model.dart
    │       └── settlement_transaction_model.dart
    │
    ├── schedule/                # Harmonogram dnia
    │   ├── screens/
    │   │   ├── days_schedule_screen.dart
    │   │   └── activity_screen.dart
    │   ├── services/
    │   │   └── day_plan_service.dart
    │   └── model/
    │       ├── day_plan_model.dart
    │       └── day_plan_item_model.dart
    │
    ├── friends/                 # Znajomi i współdzielenie
    │   ├── screens/
    │   │   └── friends_screen.dart
    │   └── model/
    │       ├── friend_model.dart
    │       ├── friend_request_model.dart
    │       └── shared_trip_member_model.dart
    │
    ├── profile/                 # Profil użytkownika
    │   ├── screens/
    │   │   ├── profile.dart
    │   │   ├── edit_profile.dart
    │   │   └── change_password.dart
    │   └── services/
    │       ├── profile_image_service.dart
    │       └── password_service.dart
    │
    ├── statistics/              # Statystyki
    │   ├── screens/
    │   │   └── statistics_screen.dart
    │   └── model/
    │       └── traveler_statistics.dart
    │
    ├── timeline/                # Oś czasu
    │   └── screens/
    │       └── timeline_screen.dart
    │
    └── splash/                  # Ekran ładowania
        └── screens/
            └── splash.dart
```

## Funkcjonalności

### Autoryzacja
- Rejestracja nowego użytkownika (email + hasło)
- Logowanie
- Resetowanie hasła
- Wylogowanie

### Zarządzanie podróżami
- Tworzenie nowej podróży z datami i lokalizacją
- Lista wszystkich podróży użytkownika
- Szczegóły podróży z mapą
- Statusy podróży: nadchodząca, w trakcie, zakończona
- Typy podróży: planowana, spontaniczna
- Usuwanie podróży

### Mapa i markery
- Interaktywna mapa Google Maps
- Dodawanie punktów na mapie (markerów)
- Szczegóły markera: nazwa, opis, zdjęcia
- Wybór środka transportu między punktami
- Wyszukiwanie pobliskich miejsc (Google Places API)

### Budżet
- Dodawanie wydatków do podróży
- Wydatki przypisane do markerów
- Kategorie wydatków
- Przypisywanie płatnika
- Rozliczenia między uczestnikami
- Statystyki budżetowe

### Harmonogram
- Plan dnia dla każdego dnia podróży
- Dodawanie aktywności z godziną
- Zarządzanie harmonogramem

### Znajomi i współdzielenie
- Lista znajomych
- Zaproszenia do znajomych
- Współdzielenie podróży z innymi użytkownikami

### Profil użytkownika
- Edycja danych profilu
- Zmiana zdjęcia profilowego
- Zmiana hasła

### Statystyki
- Podsumowanie podróży użytkownika
- Statystyki wydatków

## Modele danych

### Trip
```dart
class Trip {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String>? imageUrl;
  final String? tripPhotoUrl;
  final List<MarkerPoint> markerPoints;
  final List<ExpenseItem>? tripExpenses;
  final TripType tripType;  // planned, ongoing

  TripStatus get status;    // upcoming, ongoing, completed
  int get durationInDays;
}
```

### MarkerPoint
```dart
class MarkerPoint {
  final String id;
  final LatLng position;
  final String? name;
  final String? description;
  final List<String>? imageUrl;
  final String? transportMode;
  final List<ExpenseItem>? expenses;

  double get totalExpense;
  bool get hasExpenses;
}
```

### ExpenseItem
```dart
class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String? payerName;
  final String? payerUserId;
  final DateTime createdAt;
  final String? category;
}
```

## Serwisy

### TripService (Facade)
Główny serwis zarządzający podróżami. Wykorzystuje wzorzec Facade do delegowania operacji:

| Serwis | Odpowiedzialność |
|--------|------------------|
| `TripCrudService` | Podstawowe operacje CRUD na podróżach |
| `TripImageService` | Zarządzanie zdjęciami podróży |
| `TripDeletionService` | Usuwanie podróży z zasobami |
| `MarkerCrudService` | Operacje CRUD na markerach |
| `MarkerUpdateService` | Aktualizacja danych markerów |
| `MarkerImageService` | Zarządzanie zdjęciami markerów |
| `TripExpenseService` | Zarządzanie wydatkami |

### AuthService
Obsługuje autoryzację użytkowników przez Firebase Auth:
- `login()` - logowanie
- `signup()` - rejestracja
- `logout()` - wylogowanie
- `resetPassword()` - reset hasła

## State Management

Projekt wykorzystuje **Riverpod** do zarządzania stanem aplikacji.

### Główne providery

```dart
// Serwis podróży
final tripServiceProvider = Provider<TripService>((ref) => ...);

// Wszystkie podróże użytkownika
final allTripsProvider = StreamProvider<List<Trip>>((ref) => ...);

// Pojedyncza podróż
final getTripProvider = FutureProvider.family<Trip?, String>((ref, tripId) => ...);

// Obserwowanie podróży w czasie rzeczywistym
final watchTripProvider = StreamProvider.family<Trip, String>((ref, tripId) => ...);
```

## Nawigacja

Aplikacja wykorzystuje **GoRouter** z automatycznym przekierowaniem na podstawie stanu autoryzacji.

### Ścieżki

| Ścieżka | Ekran | Opis |
|---------|-------|------|
| `/auth` | AuthScreen | Logowanie/rejestracja |
| `/` | HomeScreen | Ekran główny |
| `/add-trip` | NewTripScreen | Tworzenie podróży |
| `/my-trips` | MyTripsScreen | Lista podróży |
| `/friends` | FriendsScreen | Znajomi |
| `/statistics` | StatisticsScreen | Statystyki |
| `/profile` | ProfileScreen | Profil |
| `/profile/edit` | EditProfileScreen | Edycja profilu |
| `/profile/change-password` | ChangePasswordScreen | Zmiana hasła |

### Automatyczne przekierowania

- Niezalogowany użytkownik → `/auth`
- Zalogowany użytkownik na `/auth` → `/`

## Struktura bazy danych (Firestore)

```
users/
└── {userId}/
    ├── email: string
    ├── name: string
    ├── avatar: string
    ├── createdAt: timestamp
    │
    ├── trips/
    │   └── {tripId}/
    │       ├── name: string
    │       ├── startDate: timestamp
    │       ├── endDate: timestamp
    │       ├── description: string
    │       ├── tripPhotoUrl: string
    │       ├── tripType: string
    │       ├── markerPoints: array
    │       └── tripExpenses: array
    │
    └── shared_trips/
        └── {tripId}/
            └── ownerId: string
```

## Uruchamianie testów

```bash
flutter test
```

## Budowanie aplikacji

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Licencja

Projekt prywatny - wszystkie prawa zastrzeżone.
