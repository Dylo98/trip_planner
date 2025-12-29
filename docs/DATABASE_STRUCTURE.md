# Struktura Bazy Danych - Aplikacja Trip Planner

## Informacje Ogólne

Aplikacja wykorzystuje **Firebase Cloud Firestore** - nierelacyjną bazę danych typu NoSQL, która przechowuje dane w formie dokumentów zgrupowanych w kolekcjach. Struktura bazy została zaprojektowana z uwzględnieniem hierarchicznej organizacji danych oraz optymalizacji pod kątem operacji odczytu i zapisu w czasie rzeczywistym.

**Identyfikator projektu Firebase**: `trip-planner-3bc06`

---

## Diagram Struktury Bazy Danych

```
users (KOLEKCJA)
├── {uid} (DOKUMENT)
│   ├── avatar: String
│   ├── coverImage: String
│   ├── createdAt: Timestamp
│   ├── email: String
│   ├── name: String
│   └── updatedAt: Timestamp
│
├── friends (PODKOLEKCJA)
│   └── {friendUid} (DOKUMENT)
│       ├── avatar: String
│       ├── createdAt: Timestamp
│       ├── email: String
│       ├── name: String
│       └── status: String
│
├── friend_requests (PODKOLEKCJA)
│   └── {requestId} (DOKUMENT)
│       ├── createdAt: Timestamp
│       ├── fromAvatar: String
│       ├── fromEmail: String
│       ├── fromName: String
│       ├── fromUid: String
│       ├── status: String
│       └── toUid: String
│
├── shared_trips (PODKOLEKCJA)
│   └── {tripId} (DOKUMENT)
│       ├── ownerId: String
│       ├── role: String
│       ├── sharedAt: Timestamp
│       └── tripId: String
│
└── trips (PODKOLEKCJA)
    └── {tripId} (DOKUMENT)
        ├── description: String
        ├── endDate: String (ISO8601)
        ├── id: String
        ├── markerPoints: Array<MarkerPoint>
        ├── name: String
        ├── startDate: String (ISO8601)
        ├── tripExpenses: Array<ExpenseItem>
        ├── tripPhotoUrl: String
        └── tripType: String
        │
        ├── shared_members (PODKOLEKCJA)
        │   └── {memberUid} (DOKUMENT)
        │       ├── addedAt: Timestamp
        │       ├── avatar: String
        │       ├── email: String
        │       ├── name: String
        │       └── role: String
        │
        └── day_plans (PODKOLEKCJA)
            └── {date} (DOKUMENT)
                ├── date: String (ISO8601)
                └── items: Array<DayPlanItem>
```

---

## 1. Kolekcja `users`

Główna kolekcja przechowująca dane wszystkich zarejestrowanych użytkowników aplikacji.

### Ścieżka w bazie danych
```
/users/{uid}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `email` | String | Adres email użytkownika | Tak |
| `name` | String | Nazwa wyświetlana użytkownika | Tak |
| `avatar` | String | URL do zdjęcia profilowego | Nie |
| `coverImage` | String | URL do zdjęcia w tle profilu | Nie |
| `createdAt` | Timestamp | Data utworzenia konta | Tak |
| `updatedAt` | Timestamp | Data ostatniej aktualizacji profilu | Tak |

### Identyfikator dokumentu
Identyfikator dokumentu użytkownika odpowiada identyfikatorowi UID z Firebase Authentication, co zapewnia spójność między systemem uwierzytelniania a bazą danych.

### Przykład dokumentu
```json
{
  "email": "jan.kowalski@example.com",
  "name": "Jan Kowalski",
  "avatar": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "coverImage": "https://firebasestorage.googleapis.com/.../cover.jpg",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-20T14:45:00Z"
}
```

---

## 2. Podkolekcja `trips`

Przechowuje wszystkie podróże należące do danego użytkownika.

### Ścieżka w bazie danych
```
/users/{uid}/trips/{tripId}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `id` | String | Unikalny identyfikator podróży | Tak |
| `name` | String | Nazwa podróży | Tak |
| `description` | String | Opis podróży | Nie |
| `startDate` | String (ISO8601) | Data rozpoczęcia podróży | Tak |
| `endDate` | String (ISO8601) | Data zakończenia podróży | Nie |
| `tripType` | String (Enum) | Typ podróży: "planned" lub "ongoing" | Tak |
| `tripPhotoUrl` | String | URL głównego zdjęcia podróży | Nie |
| `markerPoints` | Array\<MarkerPoint\> | Lista punktów na mapie | Nie |
| `tripExpenses` | Array\<ExpenseItem\> | Lista wydatków podróży | Nie |

### Struktura obiektu `MarkerPoint` (zagnieżdżona)

| Pole | Typ danych | Opis |
|------|------------|------|
| `id` | String | Unikalny identyfikator markera |
| `name` | String | Nazwa lokalizacji |
| `description` | String | Opis miejsca |
| `position` | Object | Obiekt z koordynatami geograficznymi |
| `position.latitude` | Number | Szerokość geograficzna |
| `position.longitude` | Number | Długość geograficzna |
| `imageUrl` | Array\<String\> | Lista URL zdjęć miejsca |
| `transportMode` | String | Środek transportu do miejsca |
| `expenses` | Array\<ExpenseItem\> | Wydatki w danej lokalizacji |

### Struktura obiektu `ExpenseItem` (zagnieżdżona)

| Pole | Typ danych | Opis |
|------|------------|------|
| `id` | String | Unikalny identyfikator wydatku |
| `title` | String | Tytuł/opis wydatku |
| `amount` | Number (Double) | Kwota wydatku |
| `category` | String | Kategoria wydatku |
| `payerName` | String | Imię osoby płacącej |
| `payerUserId` | String | UID osoby płacącej |
| `createdAt` | String (ISO8601) | Data utworzenia wydatku |

### Wartości typu wyliczeniowego `tripType`

| Wartość | Opis |
|---------|------|
| `planned` | Podróż zaplanowana z określoną datą końcową |
| `ongoing` | Podróż w trakcie bez określonej daty końcowej |

### Przykład dokumentu
```json
{
  "id": "trip_abc123",
  "name": "Wakacje we Włoszech",
  "description": "Rodzinny wyjazd do Rzymu i Florencji",
  "startDate": "2025-07-01T00:00:00Z",
  "endDate": "2025-07-14T00:00:00Z",
  "tripType": "planned",
  "tripPhotoUrl": "https://firebasestorage.googleapis.com/.../trip.jpg",
  "markerPoints": [
    {
      "id": "marker_001",
      "name": "Koloseum",
      "description": "Zwiedzanie Koloseum",
      "position": {
        "latitude": 41.8902,
        "longitude": 12.4922
      },
      "imageUrl": ["https://..."],
      "transportMode": "metro",
      "expenses": []
    }
  ],
  "tripExpenses": [
    {
      "id": "exp_001",
      "title": "Bilety lotnicze",
      "amount": 1200.00,
      "category": "transport",
      "payerName": "Jan Kowalski",
      "payerUserId": "uid_123",
      "createdAt": "2025-06-15T10:00:00Z"
    }
  ]
}
```

---

## 3. Podkolekcja `shared_trips`

Przechowuje referencje do podróży udostępnionych użytkownikowi przez innych użytkowników.

### Ścieżka w bazie danych
```
/users/{uid}/shared_trips/{tripId}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `tripId` | String | Identyfikator udostępnionej podróży | Tak |
| `ownerId` | String | UID właściciela podróży | Tak |
| `role` | String (Enum) | Rola użytkownika w podróży | Tak |
| `sharedAt` | Timestamp | Data udostępnienia | Tak |

### Wartości typu wyliczeniowego `role`

| Wartość | Opis | Uprawnienia |
|---------|------|-------------|
| `owner` | Właściciel | Pełna kontrola nad podróżą |
| `editor` | Edytor | Możliwość edycji szczegółów podróży |
| `viewer` | Obserwator | Tylko odczyt danych podróży |

### Przykład dokumentu
```json
{
  "tripId": "trip_xyz789",
  "ownerId": "uid_friend_456",
  "role": "editor",
  "sharedAt": "2025-06-20T15:30:00Z"
}
```

---

## 4. Podkolekcja `shared_members`

Przechowuje listę użytkowników, którym udostępniono daną podróż.

### Ścieżka w bazie danych
```
/users/{uid}/trips/{tripId}/shared_members/{memberUid}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `email` | String | Adres email członka | Tak |
| `name` | String | Nazwa wyświetlana członka | Tak |
| `avatar` | String | URL zdjęcia profilowego | Nie |
| `role` | String (Enum) | Rola w podróży | Tak |
| `addedAt` | Timestamp | Data dodania do podróży | Tak |

### Przykład dokumentu
```json
{
  "email": "anna.nowak@example.com",
  "name": "Anna Nowak",
  "avatar": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "role": "viewer",
  "addedAt": "2025-06-21T09:15:00Z"
}
```

---

## 5. Podkolekcja `friends`

Przechowuje listę znajomych użytkownika.

### Ścieżka w bazie danych
```
/users/{uid}/friends/{friendUid}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `email` | String | Adres email znajomego | Tak |
| `name` | String | Nazwa wyświetlana znajomego | Tak |
| `avatar` | String | URL zdjęcia profilowego | Nie |
| `status` | String (Enum) | Status znajomości | Tak |
| `createdAt` | Timestamp | Data nawiązania znajomości | Tak |

### Wartości typu wyliczeniowego `status`

| Wartość | Opis |
|---------|------|
| `pending` | Oczekujące na akceptację |
| `accepted` | Zaakceptowana znajomość |
| `rejected` | Odrzucone zaproszenie |
| `blocked` | Zablokowany użytkownik |

### Przykład dokumentu
```json
{
  "email": "piotr.wisniewski@example.com",
  "name": "Piotr Wiśniewski",
  "avatar": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "status": "accepted",
  "createdAt": "2025-03-10T12:00:00Z"
}
```

---

## 6. Podkolekcja `friend_requests`

Przechowuje przychodzące zaproszenia do znajomych.

### Ścieżka w bazie danych
```
/users/{uid}/friend_requests/{requestId}
```

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `fromUid` | String | UID nadawcy zaproszenia | Tak |
| `toUid` | String | UID odbiorcy zaproszenia | Tak |
| `fromEmail` | String | Email nadawcy | Tak |
| `fromName` | String | Nazwa nadawcy | Tak |
| `fromAvatar` | String | URL zdjęcia nadawcy | Nie |
| `status` | String (Enum) | Status zaproszenia | Tak |
| `createdAt` | Timestamp | Data wysłania zaproszenia | Tak |

### Wartości typu wyliczeniowego `status`

| Wartość | Opis |
|---------|------|
| `pending` | Oczekujące na odpowiedź |
| `accepted` | Zaakceptowane |
| `rejected` | Odrzucone |

### Przykład dokumentu
```json
{
  "fromUid": "uid_sender_789",
  "toUid": "uid_receiver_123",
  "fromEmail": "maria.kowalska@example.com",
  "fromName": "Maria Kowalska",
  "fromAvatar": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "status": "pending",
  "createdAt": "2025-06-25T16:45:00Z"
}
```

---

## 7. Podkolekcja `day_plans`

Przechowuje dzienne plany dla każdego dnia podróży.

### Ścieżka w bazie danych
```
/users/{uid}/trips/{tripId}/day_plans/{date}
```

### Identyfikator dokumentu
Identyfikatorem dokumentu jest data w formacie `YYYY-MM-DD` (np. "2025-07-05").

### Pola dokumentu

| Pole | Typ danych | Opis | Wymagane |
|------|------------|------|----------|
| `date` | String (ISO8601) | Data planu dziennego | Tak |
| `items` | Array\<DayPlanItem\> | Lista aktywności na dany dzień | Tak |

### Struktura obiektu `DayPlanItem` (zagnieżdżona)

| Pole | Typ danych | Opis |
|------|------------|------|
| `id` | String | Unikalny identyfikator aktywności |
| `type` | String (Enum) | Typ aktywności |
| `title` | String | Tytuł aktywności |
| `startTime` | String (ISO8601) | Godzina rozpoczęcia |
| `endTime` | String (ISO8601) | Godzina zakończenia |
| `icon` | String | Identyfikator ikony |
| `isCompleted` | Boolean | Czy aktywność została wykonana |
| `location` | Object | Lokalizacja geograficzna |
| `location.latitude` | Number | Szerokość geograficzna |
| `location.longitude` | Number | Długość geograficzna |
| `markerId` | String | ID powiązanego markera (jeśli type="marker") |
| `expenses` | Array\<ExpenseItem\> | Wydatki związane z aktywnością |

### Wartości typu wyliczeniowego `type`

| Wartość | Opis |
|---------|------|
| `marker` | Aktywność powiązana z punktem na mapie |
| `custom` | Niestandardowa aktywność |
| `checklist` | Element listy kontrolnej |

### Przykład dokumentu
```json
{
  "date": "2025-07-05",
  "items": [
    {
      "id": "item_001",
      "type": "marker",
      "title": "Zwiedzanie Koloseum",
      "startTime": "2025-07-05T09:00:00Z",
      "endTime": "2025-07-05T12:00:00Z",
      "icon": "museum",
      "isCompleted": false,
      "location": {
        "latitude": 41.8902,
        "longitude": 12.4922
      },
      "markerId": "marker_001",
      "expenses": [
        {
          "id": "exp_002",
          "title": "Bilety wstępu",
          "amount": 32.00,
          "category": "atrakcje",
          "payerName": "Jan Kowalski",
          "payerUserId": "uid_123",
          "createdAt": "2025-07-05T08:30:00Z"
        }
      ]
    },
    {
      "id": "item_002",
      "type": "custom",
      "title": "Lunch w restauracji",
      "startTime": "2025-07-05T13:00:00Z",
      "endTime": "2025-07-05T14:30:00Z",
      "icon": "restaurant",
      "isCompleted": false,
      "location": null,
      "markerId": null,
      "expenses": []
    }
  ]
}
```

---

## Relacje Między Kolekcjami

### 1. Model Udostępniania Podróży

Udostępnianie podróży wykorzystuje dwukierunkową relację:

```
Właściciel podróży:
/users/{ownerId}/trips/{tripId}
/users/{ownerId}/trips/{tripId}/shared_members/{memberUid}

Odbiorca udostępnienia:
/users/{memberUid}/shared_trips/{tripId} → wskazuje na ownerId
```

Taka struktura umożliwia:
- Właścicielowi zarządzanie listą osób z dostępem do podróży
- Użytkownikom szybki dostęp do listy udostępnionych im podróży

### 2. Model Znajomości

Znajomość wymaga dwóch wpisów (relacja dwukierunkowa):

```
Użytkownik A:
/users/{uidA}/friends/{uidB}

Użytkownik B:
/users/{uidB}/friends/{uidA}
```

### 3. Śledzenie Wydatków

Wydatki mogą być zapisywane na trzech poziomach:

```
Poziom podróży:     /users/{uid}/trips/{tripId} → tripExpenses[]
Poziom markera:     /users/{uid}/trips/{tripId} → markerPoints[].expenses[]
Poziom aktywności:  /users/{uid}/trips/{tripId}/day_plans/{date} → items[].expenses[]
```

---

## Typy Danych

| Typ w Firestore | Opis | Przykład |
|-----------------|------|----------|
| String | Tekst | "Jan Kowalski" |
| Number | Liczba (całkowita lub zmiennoprzecinkowa) | 41.8902, 150 |
| Boolean | Wartość logiczna | true, false |
| Timestamp | Znacznik czasu serwera | Timestamp(seconds=1234567890) |
| Array | Lista wartości | ["url1", "url2"] |
| Map/Object | Obiekt zagnieżdżony | { "latitude": 41.89, "longitude": 12.49 } |

---

## Indeksy Bazy Danych

Firestore automatycznie tworzy indeksy dla pojedynczych pól. Dla złożonych zapytań wymagane są indeksy złożone:

| Kolekcja | Pola | Typ zapytania |
|----------|------|---------------|
| `friends` | status, createdAt | Filtrowanie aktywnych znajomych |
| `friend_requests` | status, createdAt | Filtrowanie oczekujących zaproszeń |
| `trips` | tripType, startDate | Sortowanie podróży według typu i daty |

---

## Struktura Firebase Storage

Pliki multimedialne są przechowywane w Firebase Storage z następującą strukturą katalogów:

```
users/
└── {userId}/
    ├── profile/
    │   ├── avatar_{timestamp}.jpg
    │   └── cover_{timestamp}.jpg
    ├── trips/
    │   └── {tripId}/
    │       └── {nazwa_zdjęcia}.jpg
    └── markers/
        └── {tripId}/
            └── {markerId}/
                └── {nazwa_zdjęcia}.jpg
```

---

## Bezpieczeństwo i Reguły Dostępu

Firestore Security Rules kontrolują dostęp do danych:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Użytkownicy mogą czytać/zapisywać tylko swoje dane
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Podkolekcje dziedziczą reguły
      match /{subcollection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## Podsumowanie

Struktura bazy danych aplikacji Trip Planner została zaprojektowana zgodnie z najlepszymi praktykami Firebase Firestore:

1. **Hierarchiczna organizacja** - dane użytkownika i jego podróże są logicznie pogrupowane
2. **Denormalizacja** - kluczowe dane (np. imię, email znajomego) są duplikowane dla szybszego dostępu
3. **Zagnieżdżone struktury** - wydatki i markery są przechowywane jako tablice w dokumentach podróży
4. **Dwukierunkowe relacje** - znajomości i udostępnienia wymagają wpisów w obu kolekcjach
5. **Identyfikatory semantyczne** - daty jako ID dokumentów day_plans ułatwiają zapytania

Ta architektura zapewnia:
- Szybki odczyt danych dla pojedynczego użytkownika
- Efektywne nasłuchiwanie zmian w czasie rzeczywistym
- Skalowalność wraz ze wzrostem liczby użytkowników
- Prostą implementację uprawnień dostępu
