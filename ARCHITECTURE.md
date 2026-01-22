# Architektura Trip Planner

## Przegląd

Aplikacja mobilna Flutter (cross-platform) do planowania podróży z backendem Firebase.

## Stack technologiczny

- **Framework**: Flutter & Dart (SDK >=3.6.0)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Mapy**: Google Maps, Google Places API, Nominatim
- **Nawigacja**: Go Router

## Struktura katalogów

```
lib/
├── main.dart                 # Punkt wejścia
├── core/                     # Współdzielone narzędzia (25 plików)
│   ├── navigation/           # Konfiguracja routera
│   ├── theme/                # Motyw, kolory, style
│   ├── utils/                # Walidatory, helpery
│   └── widgets/              # Wspólne widgety
└── features/                 # Moduły funkcjonalne (227 plików)
    ├── auth/                 # Uwierzytelnianie
    ├── trip/                 # Główna funkcjonalność - wycieczki
    ├── budget/               # Zarządzanie budżetem
    ├── friends/              # Funkcje społecznościowe
    ├── profile/              # Profil użytkownika
    ├── schedule/             # Harmonogram aktywności
    ├── statistics/           # Statystyki podróży
    └── ...
```

## Wzorce architektoniczne

### 1. Modułowa architektura Feature-First

Każda funkcjonalność jest samodzielna:
```
feature/
├── model/       # Modele danych
├── services/    # Logika biznesowa
├── providers/   # Stan Riverpod
├── screens/     # Ekrany
└── widgets/     # Komponenty UI
```

### 2. Wzorzec Fasady (Facade)

`TripService` deleguje do wyspecjalizowanych serwisów:
- `TripCrudService` - operacje CRUD
- `TripImageService` - obsługa zdjęć
- `MarkerCrudService` - znaczniki na mapie

### 3. Riverpod dla zarządzania stanem

- **Provider** - dependency injection serwisów
- **StreamProvider** - real-time dane z Firestore
- **StateNotifierProvider** - mutowalny stan formularzy

## Przepływ danych

```
UI (Screen)
  → ref.watch(provider)
    → Service Layer
      → Firebase/API
        → Model parsing
          → Stream do UI
```

## Kluczowe metryki

| Metryka | Wartość |
|---------|---------|
| Pliki Dart | ~252 |
| Providery Riverpod | 24+ |
| Moduły funkcjonalne | 11 |
| Serwisy | 19 |
