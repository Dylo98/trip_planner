# Architektura

## Przegląd

Projekt TripPlanner wykorzystuje architekturę **Feature-First** (nazywaną też Feature-Driven lub Modular Architecture) w połączeniu ze sprawdzonymi wzorcami projektowymi.

## Architektura Feature-First

### Koncepcja

Zamiast tradycyjnego podziału według typu (wszystkie modele w jednym folderze, wszystkie widoki w innym), kod jest organizowany według funkcjonalności biznesowych.

### Porównanie

#### Tradycyjna architektura (Type-First)
```
lib/
├── models/
│   ├── user.dart
│   ├── trip.dart
│   └── expense.dart
├── services/
│   ├── auth_service.dart
│   ├── trip_service.dart
│   └── expense_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── trip_screen.dart
│   └── expense_screen.dart
└── widgets/
    └── ...
```

#### Architektura Feature-First (TripPlanner)
```
lib/
├── core/                    # Współdzielone zasoby
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
└── features/
    ├── auth/                # Feature: Autoryzacja
    │   ├── model/
    │   ├── services/
    │   ├── screens/
    │   └── widgets/
    │
    ├── trip/                # Feature: Podróże
    │   ├── model/
    │   ├── services/
    │   ├── providers/
    │   ├── screens/
    │   └── widgets/
    │
    └── budget/              # Feature: Budżet
        ├── model/
        ├── services/
        └── screens/
```

### Zalety Feature-First

| Zaleta | Opis |
|--------|------|
| **Modularność** | Każdy feature jest samodzielną jednostką |
| **Skalowalność** | Łatwe dodawanie nowych funkcjonalności |
| **Czytelność** | Kod powiązany logicznie jest w jednym miejscu |
| **Niezależność** | Zespoły mogą pracować nad różnymi features równolegle |
| **Testowalność** | Każdy moduł można testować izolowanie |
| **Usuwalność** | Łatwo usunąć cały feature bez wpływu na resztę |

## Wzorce projektowe

### 1. Facade Pattern

**Lokalizacja:** `lib/features/trip/services/trip_service.dart`

**Problem:** Wiele małych, wyspecjalizowanych serwisów tworzy skomplikowane API.

**Rozwiązanie:** Jeden główny serwis (fasada) deleguje operacje do serwisów szczegółowych.

```dart
/// TripService jako Facade
class TripService {
  late final TripCrudService _tripCrudService;
  late final TripImageService _tripImageService;
  late final TripDeletionService _tripDeletionService;
  late final MarkerCrudService _markerCrudService;
  late final MarkerUpdateService _markerUpdateService;
  late final MarkerImageService _markerImageService;
  late final TripExpenseService _tripExpenseService;

  // Publiczne API - proste i spójne
  Future<void> saveTrip(Trip trip) => _tripCrudService.saveTrip(trip);
  Future<Trip?> getTrip(String tripId) => _tripCrudService.getTrip(tripId);
  Future<void> deleteTrip(String tripId) => _tripDeletionService.deleteTrip(tripId);
  // ...
}
```

**Diagram:**
```
┌─────────────────────────────────────────────────────────┐
│                    TripService                          │
│                     (Facade)                            │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ TripCrudSvc   │ │ TripImageSvc  │ │ MarkerCrudSvc │
└───────────────┘ └───────────────┘ └───────────────┘
        │                 │                 │
        └─────────────────┴─────────────────┘
                          │
                          ▼
                   ┌─────────────┐
                   │  Firebase   │
                   └─────────────┘
```

### 2. Repository Pattern

**Problem:** Bezpośredni dostęp do Firebase z widoków tworzy silne powiązania.

**Rozwiązanie:** Warstwa abstrakcji między logiką biznesową a źródłem danych.

```dart
/// Repository abstrahuje źródło danych
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<AppUser?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromFirestore(doc.data()!) : null;
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }
}
```

**Zalety:**
- Łatwa zamiana źródła danych (Firebase → REST API → lokalna baza)
- Centralizacja logiki dostępu do danych
- Uproszczone testowanie (mockowanie)

### 3. Provider Pattern (Riverpod)

**Problem:** Przekazywanie zależności przez konstruktory w całym drzewie widżetów.

**Rozwiązanie:** Globalne repozytorium zależności dostępne z dowolnego miejsca.

```dart
// Definicja providera
final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// Użycie w widżecie
class TripListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripService = ref.watch(tripServiceProvider);
    // ...
  }
}
```

### 4. Singleton Pattern (przez Riverpod)

Firebase SDK używa wewnętrznie wzorca Singleton. Riverpod zapewnia podobne zachowanie:

```dart
// Provider jest tworzony raz i cache'owany
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance; // Singleton
});
```

## Warstwy aplikacji

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Screens   │  │   Widgets   │  │  Dialogs    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                   State Management                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │              Riverpod Providers                  │   │
│  │  (StateNotifier, FutureProvider, StreamProvider) │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                   Business Logic Layer                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Services   │  │ Repositories│  │   Utils     │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                      Data Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Models    │  │   DTOs      │  │  Mappers    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                   External Services                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Firebase   │  │ Google Maps │  │  Google AI  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

## Przepływ danych

### Przykład: Pobieranie listy podróży

```
User Interface          Provider              Service            Firebase
     │                     │                    │                   │
     │  watch(provider)    │                    │                   │
     │────────────────────>│                    │                   │
     │                     │    getTrips()      │                   │
     │                     │───────────────────>│                   │
     │                     │                    │   query()         │
     │                     │                    │──────────────────>│
     │                     │                    │                   │
     │                     │                    │   Stream<Data>    │
     │                     │                    │<──────────────────│
     │                     │   Stream<Trip>     │                   │
     │                     │<───────────────────│                   │
     │   List<Trip>        │                    │                   │
     │<────────────────────│                    │                   │
     │                     │                    │                   │
```

### Przykład: Zapisanie nowej podróży

```
UI → Provider → TripService (Facade) → TripCrudService → Firestore
                                    ↘
                                      TripImageService → Storage
```

## Moduł Core

Współdzielone zasoby używane przez wszystkie features:

```
core/
├── navigation/
│   └── app_router.dart      # Centralny router GoRouter
│
├── theme/
│   ├── app_theme.dart       # ThemeData
│   ├── colors.dart          # Paleta kolorów
│   ├── text_style.dart      # Style tekstów
│   ├── button_style.dart    # Style przycisków
│   └── input_style.dart     # Style input fields
│
├── utils/
│   ├── validators.dart      # Walidacja formularzy
│   ├── debouncer.dart       # Debouncing akcji
│   ├── text_utils.dart      # Formatowanie tekstów
│   └── action_lock.dart     # Zapobieganie podwójnym kliknięciom
│
└── widgets/
    ├── buttons/             # Przyciski wielokrotnego użytku
    ├── dialogs/             # Dialogi
    ├── drawer/              # Szuflada nawigacyjna
    ├── error_display.dart   # Wyświetlanie błędów
    ├── empty_state.dart     # Pusty stan
    └── loading_indicator.dart
```

## Zależności między modułami

```
                    ┌──────────┐
                    │   Core   │
                    └────┬─────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    ┌────────┐      ┌────────┐      ┌────────┐
    │  Auth  │      │  Trip  │◄─────│ Budget │
    └────────┘      └────────┘      └────────┘
         │               │               │
         │               │               │
         ▼               ▼               ▼
    ┌────────┐      ┌────────┐      ┌────────┐
    │Profile │      │Schedule│      │Friends │
    └────────┘      └────────┘      └────────┘
```

**Zasady:**
- Core nie zależy od żadnego feature
- Features mogą zależeć od Core
- Features mogą zależeć od innych features (np. Budget od Trip)
- Unikać cyklicznych zależności

## Zasady SOLID w projekcie

### Single Responsibility
Każdy serwis ma jedną odpowiedzialność:
- `TripCrudService` - tylko CRUD
- `TripImageService` - tylko zdjęcia
- `TripDeletionService` - tylko usuwanie

### Open/Closed
Nowe features dodajemy bez modyfikacji istniejących:
- Dodanie `Timeline` nie wymaga zmian w `Trip`

### Liskov Substitution
Modele używają `copyWith` do immutable updates:
```dart
final updated = trip.copyWith(name: 'New Name');
```

### Interface Segregation
Facade (`TripService`) eksponuje tylko potrzebne metody.

### Dependency Inversion
Serwisy przyjmują zależności przez konstruktor:
```dart
class TripService {
  TripService(
    FirebaseFirestore firestore,  // Abstrakcja, nie konkret
    FirebaseAuth auth,
  );
}
```
