# 2.3. Wzorce projektowe

W aplikacji TripPlanner wykorzystano kilka kluczowych wzorców projektowych, które wspierają architekturę Feature-First i zapewniają wysoki poziom separacji odpowiedzialności oraz łatwość utrzymania kodu.

## 2.3.1. Repository Pattern (Wzorzec repozytorium)

Wzorzec Repository stanowi warstwę abstrakcji między logiką biznesową a źródłem danych. W projekcie każda główna funkcjonalność posiada dedykowany serwis działający jako repozytorium. Dodatkowo, dla zachowania zasady DRY (Don't Repeat Yourself), utworzono abstrakcyjną klasę bazową `BaseTripService`, która zawiera wspólne zależności i metody pomocnicze dla wszystkich serwisów związanych z podróżami.

### Klasa bazowa serwisów

```dart
abstract class BaseTripService {
  BaseTripService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;

  String requireUserId() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }
    return uid;
  }

  DocumentReference<Map<String, dynamic>> getTripRef(String tripId) {
    final uid = requireUserId();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId);
  }
}
```

### Implementacja repozytorium podróży

```dart
class TripCrudService extends BaseTripService {
  TripCrudService({
    required super.firestore,
    required super.auth,
    required super.storage,
  });

  Future<void> saveTrip(Trip trip) async {
    final uid = requireUserId();
    await firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(trip.id)
        .set(trip.toJson());
  }

  Future<Trip?> getTrip(String tripId) async {
    final ownerId = await getTripOwnerId(tripId);
    final tripRef = getTripRefWithOwner(tripId, ownerId);
    final doc = await tripRef.get();

    if (!doc.exists || doc.data() == null) return null;

    final tripData = doc.data()!;
    tripData['id'] = doc.id;
    return Trip.fromFirestore(tripData);
  }

  Stream<List<Trip>> getTrips(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final tripData = doc.data();
            tripData['id'] = doc.id;
            return Trip.fromFirestore(tripData);
          }).toList();
        });
  }
}
```

### Zalety zastosowania

- **Separacja odpowiedzialności** – logika dostępu do danych oddzielona od logiki biznesowej
- **Dziedziczenie** – wspólna funkcjonalność wydzielona do klasy bazowej `BaseTripService`
- **Łatwość testowania** – możliwość wstrzykiwania zależności Firebase przez konstruktor
- **Elastyczność** – łatwa zmiana źródła danych bez wpływu na resztę aplikacji
- **Centralizacja** – wszystkie operacje na danych w jednym miejscu

---

## 2.3.2. Provider Pattern (Wzorzec dostawcy stanu)

Wykorzystany przez bibliotekę Riverpod, wzorzec Provider umożliwia reaktywne zarządzanie stanem aplikacji. Każda funkcjonalność posiada dedykowane providery, które obsługują strumienie danych oraz logikę biznesową. Zastosowano modyfikator `autoDispose`, który automatycznie zwalnia zasoby gdy provider nie jest już używany.

### Provider listy podróży

```dart
final getTripProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final userAsync = ref.watch(authStateProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      final tripService = ref.watch(tripServiceProvider);
      return tripService.getTrips(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
```

### Provider wszystkich podróży (własnych i udostępnionych)

```dart
final allTripsProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final ownTripsAsync = ref.watch(getTripProvider);
  final sharedTripsAsync = ref.watch(sharedTripsProvider);

  return Stream.value([
    ...ownTripsAsync.value ?? [],
    ...sharedTripsAsync.value ?? [],
  ]);
});
```

### Zalety zastosowania

- **Reaktywność** – automatyczna aktualizacja interfejsu przy zmianach danych
- **Dependency Injection** – wstrzykiwanie zależności przez `ref.watch()` bez używania singletonów
- **Kompozycja** – łączenie wielu providerów w jeden (np. `allTripsProvider`)
- **Automatyczne zarządzanie zasobami** – `autoDispose` zwalnia zasoby gdy nie są potrzebne
- **Testability** – łatwe testowanie poprzez nadpisywanie providerów

---

## 2.3.3. Observer Pattern (Wzorzec obserwatora)

Zaimplementowany natywnie w `StreamProvider` z Riverpod oraz wykorzystany w nasłuchiwaniu zmian w bazie Firebase Firestore. Dzięki temu aplikacja automatycznie reaguje na zmiany danych w czasie rzeczywistym, co jest kluczowe dla funkcji współdzielenia podróży między użytkownikami.

### Obserwowanie zmian w pojedynczej podróży

```dart
Stream<Trip> watchTrip(String tripId) async* {
  final uid = auth.currentUser?.uid;
  if (uid == null) {
    throw Exception('Użytkownik niezalogowany');
  }

  final ownerId = await getTripOwnerId(tripId);

  yield* firestore
      .collection('users')
      .doc(ownerId)
      .collection('trips')
      .doc(tripId)
      .snapshots()
      .map((doc) {
        if (!doc.exists || doc.data() == null) {
          throw Exception('Podróż nie istnieje');
        }
        final tripData = doc.data()!;
        tripData['id'] = doc.id;
        return Trip.fromFirestore(tripData);
      });
}
```

### Obserwowanie listy znajomych

```dart
Stream<List<Friend>> watchFriends() {
  final currentUid = _currentUserId;

  return _firestore
      .collection('users')
      .doc(currentUid)
      .collection('friends')
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Friend.fromJson(doc.id, doc.data()))
            .toList();
      });
}
```

### Zalety zastosowania

- **Real-time updates** – natychmiastowa aktualizacja danych bez ręcznego odświeżania
- **Loose coupling** – luźne powiązanie między źródłem danych a interfejsem użytkownika
- **Automatyczna synchronizacja** – wieloużytkownikowa współpraca bez konfliktów
- **Filtrowanie na poziomie bazy** – zapytania `where()` wykonywane po stronie serwera

---

## 2.3.4. Factory Pattern (Wzorzec fabryki)

Zastosowany w modelach danych do tworzenia obiektów z różnych źródeł (Firestore, JSON). Każdy model posiada konstruktory fabryczne (`factory`) umożliwiające elastyczne tworzenie instancji oraz metodę `toJson()` do serializacji.

### Model podróży z konstruktorami fabrycznymi

```dart
class Trip {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<MarkerPoint> markerPoints;
  final List<ExpenseItem>? tripExpenses;
  final TripType tripType;

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.description,
    required this.markerPoints,
    this.tripExpenses,
    TripType? tripType,
  }) : tripType = tripType ??
         (endDate == null ? TripType.ongoing : TripType.planned);

  factory Trip.fromFirestore(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return Trip(
      id: data['id'],
      name: data['name'],
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      description: data['description'] as String?,
      markerPoints: data['markerPoints'] != null
          ? (data['markerPoints'] as List)
              .map((m) => MarkerPoint.fromJson(m))
              .toList()
          : [],
      tripExpenses: data['tripExpenses'] != null
          ? (data['tripExpenses'] as List)
              .map((e) => ExpenseItem.fromJson(e))
              .toList()
          : null,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      description: json['description'] as String?,
      markerPoints: json['markerPoints'] != null
          ? (json['markerPoints'] as List)
              .map((m) => MarkerPoint.fromJson(m))
              .toList()
          : [],
      tripExpenses: json['tripExpenses'] != null
          ? (json['tripExpenses'] as List)
              .map((e) => ExpenseItem.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'markerPoints': markerPoints.map((m) => m.toJson()).toList(),
      'tripExpenses': tripExpenses?.map((e) => e.toJson()).toList(),
      'tripType': tripType.name,
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    // ... pozostałe parametry
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      // ... pozostałe przypisania
    );
  }
}
```

### Zalety zastosowania

- **Elastyczność tworzenia obiektów** – różne źródła danych (Firestore z `Timestamp`, JSON ze `String`)
- **Enkapsulacja logiki parsowania** – szczegóły konwersji typów ukryte wewnątrz konstruktorów
- **Obsługa różnic w formacie** – `fromFirestore` obsługuje `Timestamp`, `fromJson` obsługuje `String`
- **Immutability** – metoda `copyWith()` umożliwia tworzenie zmodyfikowanych kopii bez mutacji oryginału

---

## 2.3.5. Singleton Pattern z Dependency Injection

Instancje Firebase są wykorzystywane jako singletony, jednak w przeciwieństwie do klasycznej implementacji wzorca Singleton, zastosowano wzorzec Dependency Injection. Pozwala to na wstrzykiwanie alternatywnych implementacji (np. mocków) podczas testowania, zachowując jednocześnie efektywność współdzielenia połączeń.

### Implementacja z opcjonalnym wstrzykiwaniem zależności

```dart
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw _handleAuthException(error);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
```

### Implementacja w serwisie znajomych

```dart
class FriendService {
  FriendService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ... metody serwisu
}
```

### Zalety zastosowania

- **Jedna instancja połączenia** – oszczędność zasobów dzięki `FirebaseAuth.instance`
- **Testability** – możliwość wstrzyknięcia mocków przez konstruktor
- **Globalna dostępność** – łatwy dostęp do usług Firebase w całej aplikacji
- **Spójność stanu** – wszyscy korzystają z tego samego połączenia
- **Elastyczność** – domyślne wartości dla produkcji, wstrzykiwanie dla testów

---

## 2.3.6. Template Method Pattern (Wzorzec metody szablonowej)

Zastosowany w klasie bazowej `BaseTripService`, która definiuje szkielet algorytmu dostępu do danych podróży, pozostawiając implementację szczegółowych operacji klasom pochodnym.

### Klasa bazowa z metodami szablonowymi

```dart
abstract class BaseTripService {
  BaseTripService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  });

  // Metoda szablonowa - wspólna logika walidacji użytkownika
  String requireUserId() {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Użytkownik niezalogowany');
    }
    return uid;
  }

  // Metoda szablonowa - budowanie referencji do podróży
  DocumentReference<Map<String, dynamic>> getTripRef(String tripId) {
    final uid = requireUserId();
    return firestore
        .collection('users')
        .doc(uid)
        .collection('trips')
        .doc(tripId);
  }

  // Metoda szablonowa - określanie właściciela podróży
  Future<String> getTripOwnerId(String tripId) async {
    final currentUid = requireUserId();

    // Sprawdź własne podróże
    final ownTripDoc = await firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (ownTripDoc.exists) return currentUid;

    // Sprawdź udostępnione podróże
    final sharedTripDoc = await firestore
        .collection('users')
        .doc(currentUid)
        .collection('shared_trips')
        .doc(tripId)
        .get();

    if (sharedTripDoc.exists) {
      return sharedTripDoc.data()!['ownerId'] as String;
    }

    throw Exception('Nie znaleziono podróży');
  }
}
```

### Klasy pochodne wykorzystujące metody szablonowe

```dart
class TripCrudService extends BaseTripService {
  // Wykorzystuje getTripRef() i requireUserId()
}

class MarkerCrudService extends BaseTripService {
  // Wykorzystuje getTripRef() i getTripOwnerId()
}

class TripImageService extends BaseTripService {
  // Wykorzystuje storage i getTripRef()
}
```

### Zalety zastosowania

- **Eliminacja duplikacji** – wspólna logika w jednym miejscu
- **Spójność** – wszystkie serwisy używają tych samych metod dostępu
- **Rozszerzalność** – łatwe dodawanie nowych serwisów przez dziedziczenie
- **Enkapsulacja** – szczegóły implementacji ukryte w klasie bazowej

---

## 2.3.7. Batch Operations Pattern (Wzorzec operacji wsadowych)

Zastosowany przy operacjach wymagających atomowej modyfikacji wielu dokumentów w bazie danych. Firebase Firestore wspiera transakcje wsadowe (`WriteBatch`), które gwarantują, że wszystkie operacje zostaną wykonane lub żadna z nich.

### Akceptacja zaproszenia do znajomych

```dart
Future<void> acceptFriendRequest(String requestId, String fromUid) async {
  final currentUid = _currentUserId;

  final currentUserDoc = await _firestore.collection('users').doc(currentUid).get();
  final friendUserDoc = await _firestore.collection('users').doc(fromUid).get();

  final currentUserData = currentUserDoc.data()!;
  final friendUserData = friendUserDoc.data()!;

  // Utworzenie operacji wsadowej
  final batch = _firestore.batch();

  // Operacja 1: Aktualizacja statusu zaproszenia
  batch.update(
    _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .doc(requestId),
    {'status': 'accepted'},
  );

  // Operacja 2: Dodanie znajomego do listy bieżącego użytkownika
  batch.set(
    _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(fromUid),
    Friend(
      uid: fromUid,
      email: friendUserData['email'],
      name: friendUserData['name'],
      avatar: friendUserData['avatar'],
      status: FriendshipStatus.accepted,
      createdAt: DateTime.now(),
    ).toJson(),
  );

  // Operacja 3: Dodanie znajomego do listy drugiego użytkownika
  batch.set(
    _firestore
        .collection('users')
        .doc(fromUid)
        .collection('friends')
        .doc(currentUid),
    Friend(
      uid: currentUid,
      email: currentUserData['email'],
      name: currentUserData['name'],
      avatar: currentUserData['avatar'],
      status: FriendshipStatus.accepted,
      createdAt: DateTime.now(),
    ).toJson(),
  );

  // Atomowe wykonanie wszystkich operacji
  await batch.commit();
}
```

### Usuwanie znajomego

```dart
Future<void> removeFriend(String friendUid) async {
  final currentUid = _currentUserId;
  final batch = _firestore.batch();

  // Usunięcie z obu stron relacji
  batch.delete(
    _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendUid),
  );

  batch.delete(
    _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUid),
  );

  await batch.commit();
}
```

### Zalety zastosowania

- **Atomowość** – wszystkie operacje wykonują się lub żadna
- **Spójność danych** – relacje dwukierunkowe zawsze zsynchronizowane
- **Wydajność** – jedna transakcja zamiast wielu osobnych zapytań
- **Obsługa błędów** – automatyczne wycofanie przy niepowodzeniu

---

## Podsumowanie

Zastosowane wzorce projektowe tworzą spójną architekturę aplikacji:

| Wzorzec | Zastosowanie | Korzyść |
|---------|--------------|---------|
| Repository | Serwisy dostępu do danych | Separacja warstw |
| Provider (Riverpod) | Zarządzanie stanem | Reaktywność UI |
| Observer | Strumienie Firebase | Real-time updates |
| Factory | Modele danych | Elastyczna serializacja |
| Singleton + DI | Instancje Firebase | Testowalność |
| Template Method | BaseTripService | Eliminacja duplikacji |
| Batch Operations | Operacje wielodokumentowe | Atomowość transakcji |

Kombinacja tych wzorców zapewnia:
- **Wysoką testowalność** – dzięki Dependency Injection
- **Skalowalność** – dzięki separacji odpowiedzialności
- **Responsywność** – dzięki reaktywnemu zarządzaniu stanem
- **Niezawodność** – dzięki atomowym operacjom wsadowym
