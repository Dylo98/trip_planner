# Baza danych (Firestore)

## Przegląd

TripPlanner wykorzystuje **Cloud Firestore** - bazę danych NoSQL typu dokumentowego od Firebase. Firestore oferuje synchronizację w czasie rzeczywistym, offline persistence i automatyczne skalowanie.

---

## Struktura bazy danych

### Schemat główny

```
firestore/
│
├── users/                              # Kolekcja użytkowników
│   └── {userId}/                       # Dokument użytkownika
│       ├── email: string
│       ├── name: string
│       ├── avatar: string
│       ├── createdAt: timestamp
│       │
│       ├── trips/                      # Podkolekcja podróży
│       │   └── {tripId}/               # Dokument podróży
│       │       ├── name: string
│       │       ├── startDate: timestamp
│       │       ├── endDate: timestamp
│       │       ├── description: string
│       │       ├── tripPhotoUrl: string
│       │       ├── tripType: string
│       │       ├── imageUrl: array<string>
│       │       ├── markerPoints: array<object>
│       │       └── tripExpenses: array<object>
│       │
│       ├── shared_trips/               # Podróże udostępnione użytkownikowi
│       │   └── {tripId}/
│       │       └── ownerId: string     # ID właściciela podróży
│       │
│       ├── friends/                    # Znajomi użytkownika
│       │   └── {friendId}/
│       │       ├── name: string
│       │       ├── email: string
│       │       └── avatar: string
│       │
│       └── friend_requests/            # Zaproszenia do znajomych
│           └── {requestId}/
│               ├── fromUserId: string
│               ├── toUserId: string
│               ├── fromUserName: string
│               ├── status: string
│               └── createdAt: timestamp
```

---

## Dokumenty szczegółowo

### User Document

**Ścieżka:** `users/{userId}`

```json
{
  "email": "jan.kowalski@example.com",
  "name": "Jan Kowalski",
  "avatar": "https://storage.googleapis.com/.../avatar.jpg",
  "createdAt": "Timestamp(2024-01-15T10:30:00Z)"
}
```

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| email | string | ✅ | Adres email (z Firebase Auth) |
| name | string | ✅ | Imię użytkownika |
| avatar | string | ❌ | URL zdjęcia profilowego |
| createdAt | timestamp | ✅ | Data rejestracji |

### Trip Document

**Ścieżka:** `users/{userId}/trips/{tripId}`

```json
{
  "name": "Wakacje w Grecji",
  "startDate": "Timestamp(2024-07-01T00:00:00Z)",
  "endDate": "Timestamp(2024-07-14T00:00:00Z)",
  "description": "Dwutygodniowa podróż po greckich wyspach",
  "tripPhotoUrl": "https://storage.googleapis.com/.../trip.jpg",
  "tripType": "planned",
  "imageUrl": [
    "https://storage.googleapis.com/.../photo1.jpg",
    "https://storage.googleapis.com/.../photo2.jpg"
  ],
  "markerPoints": [
    {
      "id": "marker-uuid-1",
      "position": {
        "latitude": 37.9838,
        "longitude": 23.7275
      },
      "name": "Ateny",
      "description": "Stolica Grecji",
      "imageUrl": ["https://..."],
      "transportMode": "plane",
      "expenses": [
        {
          "id": "expense-uuid-1",
          "title": "Hotel",
          "amount": 500.00,
          "payerName": "Jan",
          "category": "accommodation",
          "createdAt": "2024-07-01T15:00:00Z"
        }
      ]
    }
  ],
  "tripExpenses": [
    {
      "id": "expense-uuid-2",
      "title": "Bilety lotnicze",
      "amount": 1200.00,
      "payerName": "Jan",
      "category": "transport",
      "createdAt": "2024-06-15T10:00:00Z"
    }
  ]
}
```

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| name | string | ✅ | Nazwa podróży |
| startDate | timestamp | ❌ | Data rozpoczęcia |
| endDate | timestamp | ❌ | Data zakończenia |
| description | string | ❌ | Opis podróży |
| tripPhotoUrl | string | ❌ | URL głównego zdjęcia |
| tripType | string | ✅ | "planned" lub "ongoing" |
| imageUrl | array | ❌ | Lista URL zdjęć |
| markerPoints | array | ✅ | Lista punktów na mapie |
| tripExpenses | array | ❌ | Lista ogólnych wydatków |

### MarkerPoint (embedded)

```json
{
  "id": "uuid-string",
  "position": {
    "latitude": 52.2297,
    "longitude": 21.0122
  },
  "name": "Warszawa",
  "description": "Stolica Polski",
  "imageUrl": ["https://..."],
  "transportMode": "car",
  "expenses": []
}
```

### ExpenseItem (embedded)

```json
{
  "id": "uuid-string",
  "title": "Obiad",
  "amount": 85.50,
  "payerName": "Anna",
  "payerUserId": "user-uid",
  "category": "food",
  "createdAt": "2024-07-02T13:00:00Z"
}
```

### Shared Trip Reference

**Ścieżka:** `users/{userId}/shared_trips/{tripId}`

```json
{
  "ownerId": "original-owner-uid"
}
```

Ten dokument wskazuje na oryginalną podróż w kolekcji właściciela.

### Friend Document

**Ścieżka:** `users/{userId}/friends/{friendId}`

```json
{
  "name": "Anna Nowak",
  "email": "anna.nowak@example.com",
  "avatar": "https://storage.googleapis.com/.../avatar.jpg"
}
```

### Friend Request Document

**Ścieżka:** `users/{userId}/friend_requests/{requestId}`

```json
{
  "fromUserId": "sender-uid",
  "toUserId": "receiver-uid",
  "fromUserName": "Jan Kowalski",
  "fromUserAvatar": "https://...",
  "status": "pending",
  "createdAt": "Timestamp(2024-01-20T14:00:00Z)"
}
```

| Status | Opis |
|--------|------|
| pending | Oczekuje na odpowiedź |
| accepted | Zaakceptowane |
| rejected | Odrzucone |

---

## Operacje CRUD

### Tworzenie dokumentu

```dart
// Dodanie nowej podróży
await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .doc(tripId)
    .set(trip.toJson());

// Z automatycznym ID
final docRef = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .add(trip.toJson());
final newId = docRef.id;
```

### Odczyt dokumentu

```dart
// Pojedynczy dokument
final doc = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .doc(tripId)
    .get();

if (doc.exists) {
  final trip = Trip.fromFirestore({...doc.data()!, 'id': doc.id});
}

// Stream pojedynczego dokumentu
firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .doc(tripId)
    .snapshots()
    .listen((doc) {
      final trip = Trip.fromFirestore({...doc.data()!, 'id': doc.id});
    });
```

### Odczyt kolekcji

```dart
// Wszystkie dokumenty
final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .get();

final trips = snapshot.docs
    .map((doc) => Trip.fromFirestore({...doc.data(), 'id': doc.id}))
    .toList();

// Stream kolekcji
firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => Trip.fromFirestore({...doc.data(), 'id': doc.id}))
        .toList());
```

### Aktualizacja dokumentu

```dart
// Aktualizacja konkretnych pól
await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .doc(tripId)
    .update({
      'name': 'Nowa nazwa',
      'endDate': Timestamp.fromDate(newEndDate),
    });

// Aktualizacja zagnieżdżonego pola
await docRef.update({
  'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
});
```

### Usuwanie dokumentu

```dart
await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .doc(tripId)
    .delete();
```

---

## Operacje na tablicach

### Dodanie elementu do tablicy

```dart
await docRef.update({
  'markerPoints': FieldValue.arrayUnion([newMarker.toJson()]),
});
```

### Usunięcie elementu z tablicy

```dart
await docRef.update({
  'markerPoints': FieldValue.arrayRemove([markerToRemove.toJson()]),
});
```

### Aktualizacja elementu w tablicy

Firestore nie wspiera bezpośredniej aktualizacji elementu tablicy. Należy:
1. Pobrać cały dokument
2. Zmodyfikować tablicę lokalnie
3. Zapisać całą tablicę z powrotem

```dart
final doc = await docRef.get();
final trip = Trip.fromFirestore(doc.data()!);

final updatedMarkers = trip.markerPoints.map((marker) {
  if (marker.id == targetId) {
    return marker.copyWith(name: 'Nowa nazwa');
  }
  return marker;
}).toList();

await docRef.update({
  'markerPoints': updatedMarkers.map((m) => m.toJson()).toList(),
});
```

---

## Zapytania (Queries)

### Filtrowanie

```dart
// Podróże z określonym statusem
final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .where('tripType', isEqualTo: 'planned')
    .get();

// Podróże po określonej dacie
final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .where('startDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
    .get();
```

### Sortowanie

```dart
// Sortowanie po dacie (najnowsze najpierw)
final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .orderBy('startDate', descending: true)
    .get();
```

### Limitowanie

```dart
// Tylko 10 pierwszych podróży
final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .orderBy('startDate', descending: true)
    .limit(10)
    .get();
```

---

## Reguły bezpieczeństwa

**Lokalizacja:** Firebase Console > Firestore > Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Funkcja pomocnicza - sprawdza czy zalogowany
    function isAuthenticated() {
      return request.auth != null;
    }

    // Funkcja pomocnicza - sprawdza czy to właściciel
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Użytkownicy
    match /users/{userId} {
      // Tylko właściciel może czytać i pisać swój dokument
      allow read, write: if isOwner(userId);

      // Podróże użytkownika
      match /trips/{tripId} {
        allow read, write: if isOwner(userId);
      }

      // Udostępnione podróże
      match /shared_trips/{tripId} {
        // Może czytać swoje shared_trips
        allow read: if isOwner(userId);
        // Każdy zalogowany może dodać (udostępnić)
        allow write: if isAuthenticated();
      }

      // Znajomi
      match /friends/{friendId} {
        allow read, write: if isOwner(userId);
      }

      // Zaproszenia
      match /friend_requests/{requestId} {
        allow read: if isOwner(userId);
        allow create: if isAuthenticated();
        allow update, delete: if isOwner(userId);
      }
    }
  }
}
```

---

## Indeksy

Dla złożonych zapytań Firestore wymaga indeksów. Tworzone automatycznie lub przez konsolę.

### Przykładowe indeksy

| Kolekcja | Pola | Typ zapytania |
|----------|------|---------------|
| trips | startDate (DESC) | Sortowanie po dacie |
| trips | tripType, startDate (DESC) | Filtrowanie + sortowanie |
| friend_requests | toUserId, status | Filtrowanie zaproszeń |

---

## Offline Persistence

Firestore automatycznie cache'uje dane lokalnie.

### Konfiguracja

```dart
// Włączone domyślnie dla mobile
// Dla web wymaga jawnej konfiguracji:
await FirebaseFirestore.instance.enablePersistence();
```

### Obsługa stanu offline

```dart
firestore
    .collection('users')
    .doc(userId)
    .collection('trips')
    .snapshots()
    .listen((snapshot) {
      // Sprawdzenie czy dane z cache
      final isFromCache = snapshot.metadata.isFromCache;

      if (isFromCache) {
        // Dane z lokalnego cache (offline)
      } else {
        // Dane z serwera (online)
      }
    });
```

---

## Firebase Storage

### Struktura Storage

```
storage/
├── trips/
│   └── {userId}/
│       └── {tripId}/
│           ├── main.jpg              # Główne zdjęcie podróży
│           └── markers/
│               └── {markerId}/
│                   ├── photo1.jpg
│                   └── photo2.jpg
│
└── avatars/
    └── {userId}/
        └── avatar.jpg
```

### Reguły Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Zdjęcia podróży
    match /trips/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Awatary
    match /avatars/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Migracje i wersjonowanie

### Dodawanie nowego pola

```dart
// Nowe pole z domyślną wartością
factory Trip.fromFirestore(Map<String, dynamic> data) {
  return Trip(
    // ...
    newField: data['newField'] ?? 'default_value',  // Obsługa braku pola
  );
}
```

### Batch updates

```dart
final batch = firestore.batch();

for (final tripDoc in tripsToUpdate.docs) {
  batch.update(tripDoc.reference, {'newField': 'value'});
}

await batch.commit();
```
