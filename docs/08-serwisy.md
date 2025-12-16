# Serwisy

## Przegląd

Serwisy w TripPlanner odpowiadają za logikę biznesową i komunikację z zewnętrznymi usługami (Firebase). Wykorzystują wzorzec Facade do uproszczenia API.

---

## Architektura serwisów Trip

```
                    ┌─────────────────────────────────┐
                    │         TripService             │
                    │           (Facade)              │
                    └─────────────┬───────────────────┘
                                  │
        ┌────────────┬────────────┼────────────┬────────────┐
        │            │            │            │            │
        ▼            ▼            ▼            ▼            ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│TripCrudSvc  │ │TripImageSvc │ │TripDeletion │ │MarkerCrud   │ │MarkerUpdate │
│             │ │             │ │    Svc      │ │    Svc      │ │    Svc      │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
                                                      │
                                                      ▼
                                               ┌─────────────┐
                                               │MarkerImage  │
                                               │    Svc      │
                                               └─────────────┘
```

---

## TripService (Facade)

**Lokalizacja:** `lib/features/trip/services/trip_service.dart`

Główny serwis zarządzający podróżami. Implementuje wzorzec Facade, delegując operacje do wyspecjalizowanych serwisów.

### Inicjalizacja

```dart
class TripService {
  TripService(
    FirebaseFirestore firestore,
    FirebaseAuth auth, [
    FirebaseStorage? storage,
  ]) {
    _tripCrudService = TripCrudService(...);
    _tripImageService = TripImageService(...);
    _tripDeletionService = TripDeletionService(...);
    _markerCrudService = MarkerCrudService(...);
    _markerUpdateService = MarkerUpdateService(...);
    _markerImageService = MarkerImageService(...);
    _tripExpenseService = TripExpenseService(...);
  }
}
```

### API - Operacje na podróżach

```dart
// Zapisanie podróży
Future<void> saveTrip(Trip trip);

// Pobranie pojedynczej podróży
Future<Trip?> getTrip(String tripId);

// Obserwowanie podróży w czasie rzeczywistym
Stream<Trip> watchTrip(String tripId);

// Pobranie wszystkich podróży użytkownika
Stream<List<Trip>> getTrips(String uid);

// Usunięcie podróży wraz z zasobami
Future<void> deleteTrip(String tripId);
```

### API - Zdjęcia podróży

```dart
// Upload zdjęcia głównego
Future<String> uploadTripImage(File imageFile, String tripId);

// Usunięcie zdjęcia
Future<void> deleteTripImage(String imageUrl);

// Aktualizacja zdjęcia głównego
Future<void> updateTripPhoto(String tripId, String? photoUrl);
```

### API - Markery

```dart
// Dodanie markera
Future<void> addMarkerToTrip(String tripId, MarkerPoint marker);

// Usunięcie markera
Future<void> deleteMarkerFromTrip(String tripId, String markerId);

// Aktualizacja środka transportu
Future<void> updateMarkerTransportMode({
  required String tripId,
  required String markerId,
  required String transportMode,
});

// Aktualizacja opisu
Future<void> updateMarkerDescription({
  required String tripId,
  required String markerId,
  required String description,
});

// Aktualizacja nazwy
Future<void> updateMarkerName({
  required String tripId,
  required String markerId,
  required String name,
});
```

### API - Zdjęcia markerów

```dart
// Dodanie zdjęcia do markera
Future<void> addImageToMarker({
  required String tripId,
  required String markerId,
  required File image,
});

// Usunięcie zdjęcia markera
Future<void> deleteMarkerImage(String imageUrl);
```

### API - Wydatki

```dart
// Aktualizacja wydatków markera
Future<void> updateMarkerExpenses({
  required String tripId,
  required String markerId,
  required List<ExpenseItem> expenses,
});

// Wydatki ogólne podróży
Future<void> addTripExpense({required String tripId, required ExpenseItem expense});
Future<void> deleteTripExpense({required String tripId, required String expenseId});
Future<void> updateTripExpense({required String tripId, required ExpenseItem expense});
Future<List<ExpenseItem>> getTripExpenses(String tripId);
```

### API - Metadane podróży

```dart
// Aktualizacja dat
Future<void> updateTripDates(String tripId, DateTime startDate, DateTime? endDate);

// Aktualizacja nazwy
Future<void> updateTripName(String tripId, String name);
```

### Provider

```dart
final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
```

---

## BaseTripService

**Lokalizacja:** `lib/features/trip/services/base_trip_service.dart`

Klasa bazowa dla wszystkich serwisów Trip, zawierająca wspólne metody.

```dart
abstract class BaseTripService {
  BaseTripService({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  // Sprawdzenie czy użytkownik jest zalogowany
  String requireUserId() {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');
    return uid;
  }

  // Pobranie właściciela podróży (obsługa shared_trips)
  Future<String> getTripOwnerId(String tripId);

  // Referencja do dokumentu podróży
  DocumentReference<Map<String, dynamic>> getTripRefWithOwner(
    String tripId,
    String ownerId,
  );
}
```

---

## TripCrudService

**Lokalizacja:** `lib/features/trip/services/trip/trip_crud_service.dart`

Podstawowe operacje CRUD na podróżach.

### Metody

```dart
// Zapisanie nowej lub aktualizacja istniejącej podróży
Future<void> saveTrip(Trip trip) async {
  final uid = requireUserId();
  await firestore
      .collection('users')
      .doc(uid)
      .collection('trips')
      .doc(trip.id)
      .set(trip.toJson());
}

// Pobranie podróży po ID
Future<Trip?> getTrip(String tripId) async {
  final uid = requireUserId();
  final doc = await firestore
      .collection('users')
      .doc(uid)
      .collection('trips')
      .doc(tripId)
      .get();

  if (!doc.exists) return null;
  return Trip.fromFirestore({...doc.data()!, 'id': tripId});
}

// Stream pojedynczej podróży
Stream<Trip> watchTrip(String tripId) {
  final uid = requireUserId();
  return firestore
      .collection('users')
      .doc(uid)
      .collection('trips')
      .doc(tripId)
      .snapshots()
      .map((doc) => Trip.fromFirestore({...doc.data()!, 'id': tripId}));
}

// Stream wszystkich podróży
Stream<List<Trip>> getTrips(String uid) {
  return firestore
      .collection('users')
      .doc(uid)
      .collection('trips')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Trip.fromFirestore({...doc.data(), 'id': doc.id}))
          .toList());
}
```

---

## TripImageService

**Lokalizacja:** `lib/features/trip/services/trip/trip_image_service.dart`

Zarządzanie zdjęciami podróży.

### Metody

```dart
// Upload zdjęcia do Storage
Future<String> uploadTripImage(File imageFile, String tripId) async {
  final uid = requireUserId();
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final ref = storage.ref('trips/$uid/$tripId/$fileName');

  await ref.putFile(imageFile);
  return await ref.getDownloadURL();
}

// Usunięcie zdjęcia ze Storage
Future<void> deleteTripImage(String imageUrl) async {
  try {
    final ref = storage.refFromURL(imageUrl);
    await ref.delete();
  } catch (e) {
    // Ignoruj błędy jeśli plik nie istnieje
  }
}
```

---

## TripDeletionService

**Lokalizacja:** `lib/features/trip/services/trip/trip_deletion_service.dart`

Kompleksowe usuwanie podróży wraz z zasobami.

### Metody

```dart
Future<void> deleteTrip(String tripId) async {
  final uid = requireUserId();

  // 1. Pobierz podróż aby uzyskać listę zdjęć
  final trip = await _getTripForDeletion(tripId);

  // 2. Usuń główne zdjęcie podróży
  if (trip?.tripPhotoUrl != null) {
    await _deleteImage(trip!.tripPhotoUrl!);
  }

  // 3. Usuń zdjęcia markerów
  for (final marker in trip?.markerPoints ?? []) {
    for (final imageUrl in marker.imageUrl ?? []) {
      await _deleteImage(imageUrl);
    }
  }

  // 4. Usuń dokument podróży
  await firestore
      .collection('users')
      .doc(uid)
      .collection('trips')
      .doc(tripId)
      .delete();
}
```

---

## MarkerCrudService

**Lokalizacja:** `lib/features/trip/services/marker/marker_crud_service.dart`

Operacje dodawania i usuwania markerów.

### Metody

```dart
// Dodanie markera do podróży
Future<void> addMarkerToTrip(String tripId, MarkerPoint marker) async {
  final ownerId = await getTripOwnerId(tripId);
  final tripRef = getTripRefWithOwner(tripId, ownerId);

  await tripRef.update({
    'markerPoints': FieldValue.arrayUnion([marker.toJson()]),
  });
}

// Usunięcie markera (wraz ze zdjęciami)
Future<void> deleteMarkerFromTrip(String tripId, String markerId) async {
  final ownerId = await getTripOwnerId(tripId);
  final tripRef = getTripRefWithOwner(tripId, ownerId);

  // Pobierz aktualną podróż
  final doc = await tripRef.get();
  final trip = Trip.fromFirestore({...doc.data()!, 'id': tripId});

  // Znajdź marker do usunięcia
  final markerToDelete = trip.markerPoints.firstWhere((m) => m.id == markerId);

  // Usuń zdjęcia markera ze Storage
  for (final imageUrl in markerToDelete.imageUrl ?? []) {
    await _markerImageService.deleteMarkerImage(imageUrl);
  }

  // Usuń marker z listy
  final updatedMarkers = trip.markerPoints
      .where((m) => m.id != markerId)
      .toList();

  await tripRef.update({
    'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
  });
}
```

---

## MarkerUpdateService

**Lokalizacja:** `lib/features/trip/services/marker/marker_update_service.dart`

Aktualizacja danych markerów.

### Metody

```dart
Future<void> updateMarkerTransportMode({
  required String tripId,
  required String markerId,
  required String transportMode,
}) async {
  await _updateMarkerField(
    tripId: tripId,
    markerId: markerId,
    fieldName: 'transportMode',
    value: transportMode,
  );
}

Future<void> updateMarkerDescription({...}) async { ... }
Future<void> updateMarkerName({...}) async { ... }
Future<void> updateMarkerExpenses({...}) async { ... }

// Wspólna metoda do aktualizacji pola markera
Future<void> _updateMarkerField({
  required String tripId,
  required String markerId,
  required String fieldName,
  required dynamic value,
}) async {
  final ownerId = await getTripOwnerId(tripId);
  final tripRef = getTripRefWithOwner(tripId, ownerId);

  final doc = await tripRef.get();
  final trip = Trip.fromFirestore({...doc.data()!, 'id': tripId});

  final updatedMarkers = trip.markerPoints.map((marker) {
    if (marker.id == markerId) {
      // Aktualizuj konkretne pole
      return marker.copyWith(/* odpowiednie pole */);
    }
    return marker;
  }).toList();

  await tripRef.update({
    'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
  });
}
```

---

## MarkerImageService

**Lokalizacja:** `lib/features/trip/services/marker/marker_image_service.dart`

Zarządzanie zdjęciami markerów.

### Metody

```dart
Future<void> addImageToMarker({
  required String tripId,
  required String markerId,
  required File image,
}) async {
  final uid = requireUserId();

  // 1. Upload do Storage
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final ref = storage.ref('trips/$uid/$tripId/markers/$markerId/$fileName');
  await ref.putFile(image);
  final imageUrl = await ref.getDownloadURL();

  // 2. Dodaj URL do markera
  final ownerId = await getTripOwnerId(tripId);
  final tripRef = getTripRefWithOwner(tripId, ownerId);

  final doc = await tripRef.get();
  final trip = Trip.fromFirestore({...doc.data()!, 'id': tripId});

  final updatedMarkers = trip.markerPoints.map((marker) {
    if (marker.id == markerId) {
      return marker.copyWith(
        imageUrl: [...?marker.imageUrl, imageUrl],
      );
    }
    return marker;
  }).toList();

  await tripRef.update({
    'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
  });
}

Future<void> deleteMarkerImage(String imageUrl) async {
  try {
    final ref = storage.refFromURL(imageUrl);
    await ref.delete();
  } catch (e) {
    // Ignoruj błędy
  }
}
```

---

## AuthService

**Lokalizacja:** `lib/features/auth/services/auth_service.dart`

Obsługa autoryzacji użytkowników przez Firebase Auth.

### Struktura

```dart
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  });

  User? get currentUser;
  Stream<User?> get authStateChanges;
}
```

### Metody

```dart
// Logowanie
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

// Rejestracja
Future<UserCredential> signup({
  required String email,
  required String password,
  required String name,
}) async {
  // 1. Walidacja
  if (name.trim().isEmpty) throw AuthException('Imię jest wymagane');

  // 2. Utworzenie konta w Auth
  final credential = await _auth.createUserWithEmailAndPassword(...);

  // 3. Utworzenie dokumentu w Firestore
  await _firestore.collection('users').doc(user.uid).set({
    'email': email.trim(),
    'name': name.trim(),
    'avatar': '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 4. Ustawienie displayName
  await user.updateDisplayName(name.trim());

  return credential;
}

// Wylogowanie
Future<void> logout() async {
  await _auth.signOut();
}

// Reset hasła
Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email.trim());
}
```

### Obsługa błędów

```dart
AuthException _handleAuthException(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return AuthException('Nieprawidłowy format email');
    case 'user-not-found':
      return AuthException('Nie znaleziono użytkownika');
    case 'wrong-password':
      return AuthException('Nieprawidłowe hasło');
    case 'email-already-in-use':
      return AuthException('Email jest już zajęty');
    // ... więcej przypadków
  }
}
```

---

## TripExpenseService

**Lokalizacja:** `lib/features/budget/services/trip_expense_service.dart`

Zarządzanie wydatkami podróży.

### Metody

```dart
// Dodanie wydatku
Future<void> addTripExpense({
  required String tripId,
  required ExpenseItem expense,
}) async {
  final tripRef = getTripRefWithOwner(tripId, await getTripOwnerId(tripId));
  final trip = Trip.fromFirestore((await tripRef.get()).data()!);

  final updatedExpenses = [...?trip.tripExpenses, expense];

  await tripRef.update({
    'tripExpenses': updatedExpenses.map((e) => e.toJson()).toList(),
  });
}

// Usunięcie wydatku
Future<void> deleteTripExpense({
  required String tripId,
  required String expenseId,
}) async { ... }

// Aktualizacja wydatku
Future<void> updateTripExpense({
  required String tripId,
  required ExpenseItem expense,
}) async { ... }

// Pobranie wszystkich wydatków
Future<List<ExpenseItem>> getTripExpenses(String tripId) async { ... }
```

---

## PasswordService

**Lokalizacja:** `lib/features/profile/services/password_service.dart`

Zmiana hasła użytkownika.

```dart
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('User not logged in');

  // Ponowna autoryzacja
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
  );
  await user.reauthenticateWithCredential(credential);

  // Zmiana hasła
  await user.updatePassword(newPassword);
}
```

---

## ProfileImageService

**Lokalizacja:** `lib/features/profile/services/profile_image_service.dart`

Zarządzanie zdjęciem profilowym.

```dart
Future<String> uploadAvatar(File imageFile) async {
  final uid = _auth.currentUser!.uid;
  final ref = _storage.ref('avatars/$uid/avatar.jpg');

  await ref.putFile(imageFile);
  final url = await ref.getDownloadURL();

  // Zaktualizuj w Firestore
  await _firestore.collection('users').doc(uid).update({'avatar': url});

  return url;
}
```
