# State Management

## Przegląd

TripPlanner wykorzystuje **Riverpod** jako rozwiązanie do zarządzania stanem aplikacji. Riverpod to reaktywny framework, który zapewnia compile-time safety i lepszą testowalność niż tradycyjny Provider.

---

## Dlaczego Riverpod?

| Cecha | Provider | Riverpod |
|-------|----------|----------|
| Compile-time safety | ❌ Runtime errors | ✅ Compile-time errors |
| Testability | ⚠️ Wymaga mockowania context | ✅ Łatwe mockowanie |
| BuildContext dependency | ✅ Wymagany | ❌ Nie wymagany |
| Multiple providers same type | ❌ Nie możliwe | ✅ Możliwe |
| Auto-dispose | ⚠️ Manualne | ✅ Automatyczne |
| DevTools | ⚠️ Ograniczone | ✅ Pełne wsparcie |

---

## Konfiguracja

### Owijanie aplikacji ProviderScope

```dart
// lib/main.dart
void main() async {
  // ... inicjalizacja

  runApp(
    const ProviderScope(  // Wymagane dla Riverpod
      child: MyApp(),
    ),
  );
}
```

### ConsumerWidget vs StatelessWidget

```dart
// Standardowy widget - nie ma dostępu do providerów
class MyWidget extends StatelessWidget { ... }

// Consumer widget - ma dostęp do providerów
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(myProvider);
    return Text(value);
  }
}

// Consumer stateful widget
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  Widget build(BuildContext context) {
    final value = ref.watch(myProvider);
    return Text(value);
  }
}
```

---

## Typy providerów

### 1. Provider (podstawowy)

Dla obiektów które nie zmieniają się w czasie (serwisy, konfiguracja).

```dart
// Definicja
final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// Użycie
final tripService = ref.watch(tripServiceProvider);
```

### 2. StateProvider

Dla prostych stanów (liczniki, flagi, wybory).

```dart
// Definicja
final selectedSortingProvider = StateProvider<TripSorting>((ref) {
  return TripSorting.byDateDesc;
});

// Użycie - odczyt
final sorting = ref.watch(selectedSortingProvider);

// Użycie - zapis
ref.read(selectedSortingProvider.notifier).state = TripSorting.byName;
```

### 3. FutureProvider

Dla asynchronicznych danych jednorazowych.

```dart
// Definicja
final getTripProvider = FutureProvider.family<Trip?, String>((ref, tripId) async {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTrip(tripId);
});

// Użycie
final tripAsync = ref.watch(getTripProvider(tripId));

return tripAsync.when(
  data: (trip) => TripDetails(trip: trip),
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorDisplay(error: error),
);
```

### 4. StreamProvider

Dla danych w czasie rzeczywistym (Firestore streams).

```dart
// Definicja
final allTripsProvider = StreamProvider<List<Trip>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTrips(user.uid);
});

// Użycie
final tripsAsync = ref.watch(allTripsProvider);

return tripsAsync.when(
  data: (trips) => TripList(trips: trips),
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorDisplay(error: error),
);
```

### 5. StateNotifierProvider

Dla złożonej logiki stanu z wieloma akcjami.

```dart
// StateNotifier
class TripFormNotifier extends StateNotifier<TripFormState> {
  TripFormNotifier() : super(TripFormState.initial());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void reset() {
    state = TripFormState.initial();
  }

  bool get isValid => state.name.isNotEmpty && state.startDate != null;
}

// Provider
final tripFormProvider = StateNotifierProvider<TripFormNotifier, TripFormState>((ref) {
  return TripFormNotifier();
});

// Użycie - odczyt stanu
final formState = ref.watch(tripFormProvider);

// Użycie - wywołanie akcji
ref.read(tripFormProvider.notifier).setName('Moja podróż');
```

---

## Providery w TripPlanner

### Trip Providers

```dart
// lib/features/trip/providers/

// Serwis podróży
final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// Wszystkie podróże (stream z Firestore)
final allTripsProvider = StreamProvider<List<Trip>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTrips(user.uid);
});

// Pojedyncza podróż (jednorazowe pobranie)
final getTripProvider = FutureProvider.family<Trip?, String>((ref, tripId) async {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTrip(tripId);
});

// Obserwowanie podróży w czasie rzeczywistym
final watchTripProvider = StreamProvider.family<Trip, String>((ref, tripId) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.watchTrip(tripId);
});
```

### Form Provider

```dart
// lib/features/trip/providers/trip_form_provider.dart

class TripFormState {
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final File? image;
  final bool isSubmitting;
  final String? error;

  const TripFormState({
    this.name = '',
    this.startDate,
    this.endDate,
    this.image,
    this.isSubmitting = false,
    this.error,
  });

  factory TripFormState.initial() => const TripFormState();

  TripFormState copyWith({...}) => TripFormState(...);
}

class TripFormNotifier extends StateNotifier<TripFormState> {
  TripFormNotifier(this._tripService) : super(TripFormState.initial());

  final TripService _tripService;

  void setName(String name) => state = state.copyWith(name: name);
  void setStartDate(DateTime date) => state = state.copyWith(startDate: date);
  void setEndDate(DateTime? date) => state = state.copyWith(endDate: date);
  void setImage(File? image) => state = state.copyWith(image: image);

  Future<bool> submit() async {
    if (!isValid) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Logika zapisu...
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  bool get isValid => state.name.trim().isNotEmpty;

  void reset() => state = TripFormState.initial();
}

final tripFormProvider = StateNotifierProvider<TripFormNotifier, TripFormState>((ref) {
  final tripService = ref.watch(tripServiceProvider);
  return TripFormNotifier(tripService);
});
```

### Markers Provider

```dart
// lib/features/trip/providers/trip_markers_provider.dart

class MarkersState {
  final List<MarkerPoint> markers;
  final String? selectedMarkerId;
  final bool isLoading;

  const MarkersState({
    this.markers = const [],
    this.selectedMarkerId,
    this.isLoading = false,
  });
}

class MarkersNotifier extends StateNotifier<MarkersState> {
  MarkersNotifier() : super(const MarkersState());

  void setMarkers(List<MarkerPoint> markers) {
    state = MarkersState(markers: markers);
  }

  void selectMarker(String? markerId) {
    state = MarkersState(
      markers: state.markers,
      selectedMarkerId: markerId,
    );
  }

  MarkerPoint? get selectedMarker {
    if (state.selectedMarkerId == null) return null;
    return state.markers.firstWhere(
      (m) => m.id == state.selectedMarkerId,
      orElse: () => null,
    );
  }
}

final tripMarkersProvider = StateNotifierProvider<MarkersNotifier, MarkersState>((ref) {
  return MarkersNotifier();
});
```

### Nearby Places Provider

```dart
// lib/features/trip/widgets/nearby_places/providers/nearby_places_provider.dart

final nearbyPlacesProvider = FutureProvider.family<List<Place>, LatLng>((ref, location) async {
  final response = await http.get(Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=${location.latitude},${location.longitude}'
    '&radius=1500'
    '&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}'
  ));

  final data = json.decode(response.body);
  return (data['results'] as List)
      .map((json) => Place.fromJson(json))
      .toList();
});
```

---

## Użycie ref

### ref.watch

Nasłuchuje zmian i automatycznie przebudowuje widget.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Przebudowuje widget gdy trips się zmieni
  final trips = ref.watch(allTripsProvider);
  return TripList(trips: trips);
}
```

### ref.read

Jednorazowy odczyt bez nasłuchiwania (dla event handlerów).

```dart
void _onSubmit() {
  // Nie nasłuchuj - tylko wywołaj akcję
  ref.read(tripFormProvider.notifier).submit();
}
```

### ref.listen

Nasłuchuje zmian i wykonuje side effects (nawigacja, snackbary).

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen<TripFormState>(tripFormProvider, (previous, next) {
    if (next.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error!)),
      );
    }
  });

  // ...
}
```

---

## AsyncValue handling

```dart
final tripsAsync = ref.watch(allTripsProvider);

// Metoda 1: when
return tripsAsync.when(
  data: (trips) => TripList(trips: trips),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// Metoda 2: pattern matching
return switch (tripsAsync) {
  AsyncData(:final value) => TripList(trips: value),
  AsyncLoading() => const CircularProgressIndicator(),
  AsyncError(:final error) => Text('Error: $error'),
};

// Metoda 3: valueOrNull (dla conditional rendering)
final trips = tripsAsync.valueOrNull ?? [];
if (tripsAsync.isLoading) {
  return LoadingIndicator();
}
return TripList(trips: trips);
```

---

## Family modifiers

Providery parametryzowane - różne instancje dla różnych argumentów.

```dart
// Definicja z .family
final watchTripProvider = StreamProvider.family<Trip, String>((ref, tripId) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.watchTrip(tripId);
});

// Użycie - przekazanie argumentu
final tripAsync = ref.watch(watchTripProvider(tripId));
```

---

## Auto-dispose

Automatyczne czyszczenie gdy provider nie jest używany.

```dart
// Provider z auto-dispose
final searchResultsProvider = FutureProvider.autoDispose.family<List<Place>, String>((ref, query) async {
  // Anulowanie gdy widget jest dispose
  ref.onDispose(() {
    // Cleanup logic
  });

  return searchPlaces(query);
});
```

---

## Testowanie

```dart
void main() {
  test('TripFormNotifier sets name correctly', () {
    final notifier = TripFormNotifier(MockTripService());

    notifier.setName('Test Trip');

    expect(notifier.state.name, 'Test Trip');
  });

  testWidgets('TripList shows trips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mock provider
          allTripsProvider.overrideWith((ref) => Stream.value([
            Trip(id: '1', name: 'Test', ...),
          ])),
        ],
        child: MaterialApp(home: TripListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## Best Practices

### 1. Granularne providery

```dart
// ❌ Źle - jeden duży provider
final appStateProvider = StateNotifierProvider<AppNotifier, AppState>(...);

// ✅ Dobrze - małe, wyspecjalizowane providery
final userProvider = StreamProvider<User?>(...);
final tripsProvider = StreamProvider<List<Trip>>(...);
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(...);
```

### 2. Nie używaj ref.watch w event handlerach

```dart
// ❌ Źle
void onPressed() {
  final trips = ref.watch(allTripsProvider); // Nie używaj watch w handlerze!
}

// ✅ Dobrze
void onPressed() {
  final tripService = ref.read(tripServiceProvider);
  tripService.deleteTrip(tripId);
}
```

### 3. Używaj select dla optymalizacji

```dart
// ❌ Źle - przebudowuje przy każdej zmianie stanu
final state = ref.watch(tripFormProvider);

// ✅ Dobrze - przebudowuje tylko gdy name się zmieni
final name = ref.watch(tripFormProvider.select((state) => state.name));
```

### 4. Organizacja providerów

```
lib/features/trip/providers/
├── trip_service_provider.dart    # Provider serwisu
├── all_trips_provider.dart       # StreamProvider list
├── watch_trip_provider.dart      # StreamProvider pojedynczej
├── trip_form_provider.dart       # StateNotifierProvider formularza
└── trip_markers_provider.dart    # StateNotifierProvider markerów
```
