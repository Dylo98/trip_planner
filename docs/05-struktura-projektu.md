# Struktura projektu

## Drzewko katalogów

```
trip_planner/
│
├── android/                          # Konfiguracja Android
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml   # Uprawnienia i konfiguracja
│   │   │   └── kotlin/               # Kod natywny Kotlin
│   │   └── build.gradle              # Zależności Android
│   └── build.gradle                  # Konfiguracja Gradle
│
├── ios/                              # Konfiguracja iOS
│   ├── Runner/
│   │   ├── AppDelegate.swift         # Punkt wejścia iOS
│   │   ├── Info.plist                # Uprawnienia i konfiguracja
│   │   └── Assets.xcassets/          # Ikony i obrazy
│   └── Runner.xcworkspace            # Projekt Xcode
│
├── web/                              # Konfiguracja Web
│   ├── index.html                    # Strona HTML
│   └── manifest.json                 # PWA manifest
│
├── linux/                            # Konfiguracja Linux
├── macos/                            # Konfiguracja macOS
├── windows/                          # Konfiguracja Windows
│
├── assets/                           # Zasoby statyczne
│   ├── images/                       # Obrazy
│   │   ├── background_image1.jpg
│   │   ├── logo.png
│   │   ├── image_home.jpg
│   │   └── no_profile.jpg
│   ├── fonts/                        # Czcionki
│   │   └── oswald/
│   │       ├── Oswald-Regular.ttf
│   │       ├── Oswald-Bold.ttf
│   │       └── ...
│   └── lottie/                       # Animacje Lottie
│       └── LottieAnimation.json
│
├── lib/                              # KOD ŹRÓDŁOWY DART
│   ├── main.dart                     # Punkt wejścia aplikacji
│   ├── firebase_options.dart         # Konfiguracja Firebase
│   │
│   ├── core/                         # Moduł współdzielony
│   │   ├── navigation/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   └── features/                     # Moduły funkcjonalne
│       ├── auth/
│       ├── home/
│       ├── trip/
│       ├── budget/
│       ├── schedule/
│       ├── friends/
│       ├── profile/
│       ├── statistics/
│       ├── timeline/
│       └── splash/
│
├── test/                             # Testy jednostkowe i widgetów
│
├── .env                              # Zmienne środowiskowe (NIE COMMITOWAĆ)
├── .gitignore                        # Ignorowane pliki
├── pubspec.yaml                      # Manifest projektu i zależności
├── pubspec.lock                      # Zablokowane wersje zależności
├── analysis_options.yaml             # Reguły lintowania
├── firebase.json                     # Konfiguracja Firebase Hosting
└── README.md                         # Dokumentacja główna
```

## Szczegółowa struktura lib/

### Punkt wejścia - main.dart

```
lib/
├── main.dart                         # Inicjalizacja aplikacji
└── firebase_options.dart             # Wygenerowana konfiguracja Firebase
```

**main.dart:**
- Inicjalizacja Firebase
- Ładowanie zmiennych środowiskowych (.env)
- Inicjalizacja lokalizacji (pl_PL)
- Uruchomienie aplikacji z ProviderScope (Riverpod)

### Moduł Core

```
lib/core/
│
├── navigation/
│   └── app_router.dart               # Konfiguracja GoRouter
│                                      # Wszystkie ścieżki nawigacji
│                                      # Przekierowania auth
│
├── theme/
│   ├── app_theme.dart                # Główny ThemeData
│   ├── colors.dart                   # AppColors - paleta kolorów
│   ├── text_style.dart               # AppTextStyles
│   ├── button_style.dart             # AppButtonStyles
│   └── input_style.dart              # AppInputStyles
│
├── utils/
│   ├── validators.dart               # Walidacja email, hasła, itp.
│   ├── debouncer.dart                # Debouncing dla wyszukiwania
│   ├── text_utils.dart               # Formatowanie tekstu
│   ├── location_name.dart            # Pomocnicze funkcje lokalizacji
│   ├── user_utils.dart               # Pomocnicze funkcje użytkownika
│   └── action_lock.dart              # Zapobieganie wielokrotnym kliknięciom
│
└── widgets/
    ├── buttons/
    │   ├── form_auth_btn.dart        # Przycisk formularza auth
    │   └── gradient_button.dart      # Przycisk z gradientem
    │
    ├── dialog/
    │   ├── dialog_header.dart        # Nagłówek dialogu
    │   ├── dialog_actions_bar.dart   # Pasek akcji dialogu
    │   └── dialog_confirmation.dart  # Dialog potwierdzenia
    │
    ├── drawer/
    │   ├── app_drawer.dart           # Główna szuflada nawigacyjna
    │   ├── drawer_menu_item.dart     # Element menu
    │   └── drawer_logout_item.dart   # Element wylogowania
    │
    ├── error_display.dart            # Wyświetlanie błędów
    ├── empty_state.dart              # Widok pustego stanu
    ├── loading_indicator.dart        # Wskaźnik ładowania
    ├── user_avatar.dart              # Avatar użytkownika
    └── app_notifications.dart        # Powiadomienia (flushbar)
```

### Feature: Auth

```
lib/features/auth/
│
├── screens/
│   └── auth.dart                     # Ekran logowania/rejestracji
│
├── services/
│   ├── auth_service.dart             # Logika autoryzacji Firebase
│   └── user_repository.dart          # Operacje na użytkownikach
│
├── model/
│   └── app_user.dart                 # Model użytkownika
│
├── constants/
│   └── auth_messages.dart            # Komunikaty błędów auth
│
├── providers/
│   └── auth_provider.dart            # Provider stanu auth
│
└── widgets/
    ├── bottomsheets/                 # Dolne panele logowania/rejestracji
    └── buttons/                      # Przyciski auth
```

### Feature: Trip (główny moduł)

```
lib/features/trip/
│
├── screens/
│   ├── trip_list/
│   │   └── trips_list_screen.dart    # Lista wszystkich podróży
│   │
│   ├── trip_details/
│   │   ├── trip_details_screen.dart  # Szczegóły podróży (kontener)
│   │   ├── trip_details_main_screen.dart  # Zakładka szczegółów
│   │   └── trip_details_map_screen.dart   # Zakładka mapy
│   │
│   ├── new_trip/
│   │   ├── new_trip_screen.dart      # Tworzenie nowej podróży
│   │   └── new_trip_map_screen.dart  # Wybór lokalizacji na mapie
│   │
│   └── fullscreen_image_screen.dart  # Podgląd zdjęcia pełnoekranowy
│
├── services/
│   ├── trip_service.dart             # FACADE - główny serwis
│   ├── base_trip_service.dart        # Klasa bazowa serwisów
│   │
│   ├── trip/                         # Serwisy podróży
│   │   ├── trip_crud_service.dart    # CRUD podróży
│   │   ├── trip_image_service.dart   # Zdjęcia podróży
│   │   └── trip_deletion_service.dart # Usuwanie podróży
│   │
│   └── marker/                       # Serwisy markerów
│       ├── marker_crud_service.dart  # CRUD markerów
│       ├── marker_update_service.dart # Aktualizacja markerów
│       └── marker_image_service.dart # Zdjęcia markerów
│
├── providers/
│   ├── all_trips_provider.dart       # StreamProvider wszystkich podróży
│   ├── get_trip_provider.dart        # FutureProvider pojedynczej podróży
│   ├── watch_trip_provider.dart      # StreamProvider obserwacji podróży
│   ├── trip_form_provider.dart       # Stan formularza nowej podróży
│   ├── trip_markers_provider.dart    # Stan markerów na mapie
│   └── trip_photo_provider.dart      # Stan zdjęcia podróży
│
├── model/
│   ├── trip_model.dart               # Model Trip
│   └── marker_point_model.dart       # Model MarkerPoint
│
├── controllers/
│   └── map/
│       └── polyline_controller.dart  # Kontroler linii na mapie
│
├── utils/
│   ├── trip_status_helper.dart       # Pomocnik statusów podróży
│   ├── trip_sorting_helper.dart      # Sortowanie podróży
│   ├── transport_helper.dart         # Pomocnik środków transportu
│   └── confirmation_dialog_helper.dart
│
└── widgets/
    ├── trip_card/                    # Karta podróży
    │   ├── trip_card.dart
    │   ├── trip_card_content.dart
    │   ├── trip_card_overlay.dart
    │   └── trip_status_badge.dart
    │
    ├── trip_details/                 # Szczegóły podróży
    │   ├── trip_header_image.dart
    │   ├── trip_date_range.dart
    │   ├── trip_status_chip.dart
    │   └── trip_photo_grid.dart
    │
    ├── trip_list/                    # Lista podróży
    │   ├── my_trip.dart
    │   └── trip_toolbar.dart
    │
    ├── new_trip/                     # Formularz nowej podróży
    │   └── trip_form.dart
    │
    ├── marker_details_sheet/         # Panel szczegółów markera
    │   ├── marker_details_sheet.dart
    │   ├── marker_details_content.dart
    │   ├── marker_details_state.dart
    │   ├── marker_description_section.dart
    │   ├── marker_images_section.dart
    │   ├── marker_image_carousel.dart
    │   ├── marker_image_picker.dart
    │   ├── marker_add_image_button.dart
    │   ├── marker_transport_section.dart
    │   └── marker_nearby_places_section.dart
    │
    ├── nearby_places/                # Pobliskie miejsca
    │   ├── nearby_places_list_widget.dart
    │   ├── google_nearby_places_section.dart
    │   ├── providers/
    │   │   └── nearby_places_provider.dart
    │   ├── models/
    │   │   └── place_category.dart
    │   └── widgets/
    │       ├── places_grid/
    │       ├── place_card/
    │       ├── place_details/
    │       ├── category_filter_chips.dart/
    │       └── state_widgets/
    │
    └── shared/                       # Współdzielone widgety trip
        ├── map_location_fab.dart
        ├── starting_location_dialog.dart
        ├── starting_location_banner.dart
        ├── delete_trip_dialog.dart
        ├── date_change_dialog.dart
        ├── trip_name_edit_dialog.dart
        └── search_location.dart
```

### Feature: Budget

```
lib/features/budget/
│
├── screens/
│   └── trip_budget_screen.dart       # Ekran budżetu podróży
│
├── services/
│   ├── trip_expense_service.dart     # Operacje na wydatkach
│   ├── budget_calculator_service.dart # Obliczenia budżetowe
│   └── settlement_calculator_service.dart # Rozliczenia
│
└── model/
    ├── expense_item_model.dart       # Model wydatku
    ├── budget_statistics_model.dart  # Statystyki budżetowe
    ├── settlement_transaction_model.dart # Transakcja rozliczenia
    ├── budget_payer_selection_model.dart
    └── payer_summary_model.dart      # Podsumowanie płatnika
```

### Feature: Schedule

```
lib/features/schedule/
│
├── screens/
│   ├── days_schedule_screen.dart     # Harmonogram dni
│   └── activity_screen.dart          # Szczegóły aktywności
│
├── services/
│   └── day_plan_service.dart         # Zarządzanie planami dni
│
└── model/
    ├── day_plan_model.dart           # Model planu dnia
    └── day_plan_item_model.dart      # Model elementu planu
```

### Feature: Friends

```
lib/features/friends/
│
├── screens/
│   └── friends_screen.dart           # Ekran znajomych
│
└── model/
    ├── friend_model.dart             # Model znajomego
    ├── friend_request_model.dart     # Model zaproszenia
    └── shared_trip_member_model.dart # Model członka wspólnej podróży
```

### Feature: Profile

```
lib/features/profile/
│
├── screens/
│   ├── profile.dart                  # Główny ekran profilu
│   ├── edit_profile.dart             # Edycja danych profilu
│   └── change_password.dart          # Zmiana hasła
│
└── services/
    ├── profile_image_service.dart    # Zarządzanie zdjęciem profilowym
    └── password_service.dart         # Zmiana hasła
```

### Pozostałe features

```
lib/features/
│
├── home/
│   └── screens/
│       └── home.dart                 # Ekran główny (dashboard)
│
├── statistics/
│   ├── screens/
│   │   └── statistics_screen.dart    # Ekran statystyk
│   └── model/
│       └── traveler_statistics.dart  # Model statystyk
│
├── timeline/
│   └── screens/
│       └── timeline_screen.dart      # Oś czasu podróży
│
└── splash/
    └── screens/
        └── splash.dart               # Ekran ładowania
```

## Konwencje nazewnictwa

| Typ | Konwencja | Przykład |
|-----|-----------|----------|
| Pliki | snake_case | `trip_service.dart` |
| Klasy | PascalCase | `TripService` |
| Zmienne | camelCase | `tripList` |
| Stałe | camelCase lub SCREAMING_SNAKE | `maxTripDays` |
| Foldery | snake_case | `nearby_places` |
| Widgety | PascalCase | `TripCard` |
| Providery | camelCase + Provider | `tripServiceProvider` |

## Organizacja importów

Zalecana kolejność importów:

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Pakiety zewnętrzne
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 4. Lokalne - core
import 'package:trip_planner/core/theme/colors.dart';

// 5. Lokalne - features
import 'package:trip_planner/features/trip/model/trip_model.dart';

// 6. Lokalne - relatywne (w tym samym module)
import '../services/trip_service.dart';
import './trip_card.dart';
```
