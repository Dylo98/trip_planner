# Modele danych

## Przegląd

Modele danych w TripPlanner reprezentują struktury używane do przechowywania i manipulowania danymi. Wszystkie modele są immutable i używają wzorca `copyWith` do aktualizacji.

---

## Trip (Podróż)

**Lokalizacja:** `lib/features/trip/model/trip_model.dart`

### Struktura

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
  final TripType tripType;
}
```

### Pola

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `id` | String | ✅ | Unikalny identyfikator (UUID) |
| `name` | String | ✅ | Nazwa podróży |
| `startDate` | DateTime? | ❌ | Data rozpoczęcia |
| `endDate` | DateTime? | ❌ | Data zakończenia |
| `description` | String? | ❌ | Opis podróży |
| `imageUrl` | List<String>? | ❌ | Lista URL zdjęć |
| `tripPhotoUrl` | String? | ❌ | URL głównego zdjęcia |
| `markerPoints` | List<MarkerPoint> | ✅ | Lista punktów na mapie |
| `tripExpenses` | List<ExpenseItem>? | ❌ | Lista wydatków |
| `tripType` | TripType | ✅ | Typ podróży |

### Enumy

```dart
enum TripType {
  planned,   // Podróż zaplanowana z datą końcową
  ongoing,   // Podróż spontaniczna bez daty końcowej
}

enum TripStatus {
  upcoming,   // Nadchodząca (startDate > now)
  ongoing,    // W trakcie (startDate <= now <= endDate)
  completed,  // Zakończona (endDate < now)
}
```

### Właściwości obliczane

```dart
// Status podróży (getter)
TripStatus get status {
  if (startDate == null) return TripStatus.upcoming;
  final now = DateTime.now();

  if (endDate != null && now.isAfter(endDate!)) {
    return TripStatus.completed;
  }
  if (now.isBefore(startDate!)) {
    return TripStatus.upcoming;
  }
  return TripStatus.ongoing;
}

// Czas trwania w dniach
int get durationInDays {
  if (startDate == null) return 0;
  if (endDate == null) return 1;
  return endDate!.difference(startDate!).inDays + 1;
}
```

### Serializacja

```dart
// Do JSON (dla Firestore)
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'description': description,
    'imageUrl': imageUrl,
    'tripPhotoUrl': tripPhotoUrl,
    'markerPoints': markerPoints.map((m) => m.toJson()).toList(),
    'tripExpenses': tripExpenses?.map((e) => e.toJson()).toList(),
    'tripType': tripType.name,
  };
}

// Z Firestore (obsługuje Timestamp)
factory Trip.fromFirestore(Map<String, dynamic> data) { ... }

// Z JSON (obsługuje ISO 8601 strings)
factory Trip.fromJson(Map<String, dynamic> json) { ... }
```

### copyWith

```dart
Trip copyWith({
  String? id,
  String? name,
  DateTime? startDate,
  DateTime? endDate,
  String? description,
  List<String>? imageUrl,
  String? tripPhotoUrl,
  List<MarkerPoint>? markerPoints,
  List<ExpenseItem>? tripExpenses,
  TripType? tripType,
}) {
  return Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    // ... reszta pól
  );
}
```

---

## MarkerPoint (Punkt na mapie)

**Lokalizacja:** `lib/features/trip/model/marker_point_model.dart`

### Struktura

```dart
class MarkerPoint {
  final String id;
  final LatLng position;
  final String? name;
  final String? description;
  final List<String>? imageUrl;
  final String? transportMode;
  final List<ExpenseItem>? expenses;
}
```

### Pola

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `id` | String | ✅ | Unikalny identyfikator (UUID) |
| `position` | LatLng | ✅ | Współrzędne geograficzne |
| `name` | String? | ❌ | Nazwa miejsca |
| `description` | String? | ❌ | Opis miejsca |
| `imageUrl` | List<String>? | ❌ | Lista URL zdjęć |
| `transportMode` | String? | ❌ | Środek transportu |
| `expenses` | List<ExpenseItem>? | ❌ | Wydatki w tym miejscu |

### LatLng (Google Maps)

```dart
// Z pakietu google_maps_flutter
class LatLng {
  final double latitude;
  final double longitude;
}
```

### Właściwości obliczane

```dart
// Suma wydatków dla markera
double get totalExpense {
  if (expenses == null || expenses!.isEmpty) return 0.0;
  return expenses!.fold(0.0, (sum, item) => sum + item.amount);
}

// Czy marker ma wydatki
bool get hasExpenses {
  return expenses != null && expenses!.isNotEmpty;
}
```

### Serializacja

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'position': {
      'latitude': position.latitude,
      'longitude': position.longitude,
    },
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'transportMode': transportMode,
    'expenses': expenses?.map((e) => e.toJson()).toList(),
  };
}

factory MarkerPoint.fromJson(Map<String, dynamic> json) {
  final pos = json['position'] as Map<String, dynamic>;
  return MarkerPoint(
    id: json['id'],
    position: LatLng(
      (pos['latitude'] as num).toDouble(),
      (pos['longitude'] as num).toDouble(),
    ),
    // ... reszta pól
  );
}
```

---

## ExpenseItem (Wydatek)

**Lokalizacja:** `lib/features/budget/model/expense_item_model.dart`

### Struktura

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

### Pola

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `id` | String | ✅ | Unikalny identyfikator |
| `title` | String | ✅ | Nazwa wydatku |
| `amount` | double | ✅ | Kwota |
| `payerName` | String? | ❌ | Imię płatnika |
| `payerUserId` | String? | ❌ | ID użytkownika płatnika |
| `createdAt` | DateTime | ✅ | Data utworzenia |
| `category` | String? | ❌ | Kategoria wydatku |

### Właściwości

```dart
// Wyświetlana nazwa płatnika
String get displayPayerName {
  if (payerName != null && payerName!.isNotEmpty) {
    return payerName!;
  }
  return 'Nie określono';
}

// Czy ma przypisanego płatnika
bool get hasAssignedPayer => payerName != null && payerName!.isNotEmpty;
```

---

## AppUser (Użytkownik)

**Lokalizacja:** `lib/features/auth/model/app_user.dart`

### Struktura

```dart
class AppUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? createdAt;
}
```

### Pola

| Pole | Typ | Wymagane | Opis |
|------|-----|----------|------|
| `id` | String | ✅ | UID z Firebase Auth |
| `email` | String | ✅ | Adres email |
| `name` | String | ✅ | Imię użytkownika |
| `avatar` | String? | ❌ | URL zdjęcia profilowego |
| `createdAt` | DateTime? | ❌ | Data rejestracji |

---

## Friend (Znajomy)

**Lokalizacja:** `lib/features/friends/model/friend_model.dart`

### Struktura

```dart
class Friend {
  final String id;
  final String name;
  final String email;
  final String? avatar;
}
```

---

## FriendRequest (Zaproszenie)

**Lokalizacja:** `lib/features/friends/model/friend_request_model.dart`

### Struktura

```dart
class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String? fromUserAvatar;
  final DateTime createdAt;
  final RequestStatus status;
}

enum RequestStatus {
  pending,
  accepted,
  rejected,
}
```

---

## DayPlan (Plan dnia)

**Lokalizacja:** `lib/features/schedule/model/day_plan_model.dart`

### Struktura

```dart
class DayPlan {
  final String id;
  final DateTime date;
  final List<DayPlanItem> items;
}
```

---

## DayPlanItem (Element planu)

**Lokalizacja:** `lib/features/schedule/model/day_plan_item_model.dart`

### Struktura

```dart
class DayPlanItem {
  final String id;
  final String title;
  final String? description;
  final DateTime time;
  final String? location;
  final bool isCompleted;
}
```

---

## TravelerStatistics (Statystyki)

**Lokalizacja:** `lib/features/statistics/model/traveler_statistics.dart`

### Struktura

```dart
class TravelerStatistics {
  final int totalTrips;
  final int completedTrips;
  final int ongoingTrips;
  final int upcomingTrips;
  final int totalPlaces;
  final double totalExpenses;
  final int totalFriends;
}
```

---

## SettlementTransaction (Rozliczenie)

**Lokalizacja:** `lib/features/budget/model/settlement_transaction_model.dart`

### Struktura

```dart
class SettlementTransaction {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;
}
```

---

## PlaceCategory (Kategoria miejsca)

**Lokalizacja:** `lib/features/trip/widgets/nearby_places/models/place_category.dart`

### Struktura

```dart
class PlaceCategory {
  final String id;
  final String name;
  final String icon;
  final String googleType; // Typ dla Google Places API
}
```

---

## Diagram relacji

```
┌─────────────────┐
│     AppUser     │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐       1:N      ┌─────────────────┐
│      Trip       │───────────────►│   MarkerPoint   │
└────────┬────────┘                └────────┬────────┘
         │                                  │
         │ 1:N                              │ 1:N
         ▼                                  ▼
┌─────────────────┐                ┌─────────────────┐
│   ExpenseItem   │                │   ExpenseItem   │
│ (trip expenses) │                │(marker expenses)│
└─────────────────┘                └─────────────────┘

┌─────────────────┐       1:N      ┌─────────────────┐
│      Trip       │───────────────►│     DayPlan     │
└─────────────────┘                └────────┬────────┘
                                            │
                                            │ 1:N
                                            ▼
                                   ┌─────────────────┐
                                   │   DayPlanItem   │
                                   └─────────────────┘

┌─────────────────┐       N:N      ┌─────────────────┐
│     AppUser     │◄──────────────►│     Friend      │
└─────────────────┘                └─────────────────┘
         │
         │
         ▼
┌─────────────────┐
│  FriendRequest  │
└─────────────────┘
```

---

## Konwersja typów Firestore

### Timestamp → DateTime

```dart
DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();  // Firestore
  if (value is String) return DateTime.parse(value); // JSON
  return null;
}
```

### DateTime → Timestamp

```dart
// Przy zapisie do Firestore
'startDate': Timestamp.fromDate(startDate),
```

### Obsługa list

```dart
// Z Firestore (lista może być null)
markerPoints: data['markerPoints'] != null
    ? (data['markerPoints'] as List)
        .map((m) => MarkerPoint.fromJson(m))
        .toList()
    : [],
```
