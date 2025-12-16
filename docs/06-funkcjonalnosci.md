# Funkcjonalności

## Przegląd funkcjonalności

TripPlanner to kompleksowa aplikacja do planowania i zarządzania podróżami. Poniżej znajduje się szczegółowy opis każdej funkcjonalności.

---

## 1. Autoryzacja (Auth)

### Rejestracja

**Lokalizacja:** `lib/features/auth/`

Użytkownik może utworzyć nowe konto podając:
- Imię (minimum 2 znaki)
- Adres email (walidowany format)
- Hasło (minimum 6 znaków)

**Przepływ:**
1. Użytkownik wypełnia formularz rejestracji
2. Walidacja po stronie klienta (validators.dart)
3. Utworzenie konta w Firebase Auth
4. Utworzenie dokumentu użytkownika w Firestore
5. Automatyczne zalogowanie
6. Przekierowanie do ekranu głównego

**Dane zapisywane w Firestore:**
```json
{
  "email": "user@example.com",
  "name": "Jan Kowalski",
  "avatar": "",
  "createdAt": "timestamp"
}
```

### Logowanie

- Logowanie przez email i hasło
- Automatyczne przekierowanie zalogowanych użytkowników
- Sesja utrzymywana przez Firebase Auth

### Resetowanie hasła

- Wysłanie emaila z linkiem do resetu
- Obsługa przez Firebase Auth

### Wylogowanie

- Czyszczenie sesji Firebase Auth
- Przekierowanie do ekranu autoryzacji

### Obsługa błędów

| Kod błędu | Komunikat |
|-----------|-----------|
| invalid-email | Nieprawidłowy format adresu email |
| user-not-found | Nie znaleziono użytkownika |
| wrong-password | Nieprawidłowe hasło |
| email-already-in-use | Email jest już zajęty |
| weak-password | Hasło jest za słabe |
| too-many-requests | Zbyt wiele prób, spróbuj później |

---

## 2. Zarządzanie podróżami (Trip)

### Tworzenie podróży

**Lokalizacja:** `lib/features/trip/screens/new_trip/`

**Wymagane dane:**
- Nazwa podróży
- Data rozpoczęcia
- Data zakończenia (opcjonalna - dla podróży spontanicznych)
- Zdjęcie główne (opcjonalne)

**Typy podróży:**
| Typ | Opis |
|-----|------|
| `planned` | Podróż z określoną datą końcową |
| `ongoing` | Podróż spontaniczna bez daty końcowej |

**Przepływ tworzenia:**
1. Użytkownik wypełnia formularz
2. Opcjonalnie wybiera zdjęcie z galerii/kamery
3. Zdjęcie uploadowane do Firebase Storage
4. Dokument podróży zapisywany w Firestore
5. Przekierowanie do listy podróży

### Lista podróży

**Lokalizacja:** `lib/features/trip/screens/trip_list/`

**Funkcje:**
- Wyświetlanie wszystkich podróży użytkownika
- Sortowanie po dacie (najnowsze/najstarsze)
- Filtrowanie po statusie
- Wizualne rozróżnienie statusów

**Statusy podróży:**
| Status | Warunek | Ikona/Kolor |
|--------|---------|-------------|
| `upcoming` | Data start > teraz | Niebieski |
| `ongoing` | Data start <= teraz <= Data end | Zielony |
| `completed` | Data end < teraz | Szary |

### Szczegóły podróży

**Lokalizacja:** `lib/features/trip/screens/trip_details/`

**Dwie główne zakładki:**

1. **Szczegóły** - informacje o podróży
   - Zdjęcie nagłówkowe
   - Nazwa i daty
   - Status podróży
   - Galeria zdjęć
   - Lista markerów

2. **Mapa** - interaktywna mapa
   - Widok Google Maps
   - Markery punktów podróży
   - Linie łączące punkty (polylines)
   - Dodawanie nowych punktów

### Edycja podróży

**Możliwe edycje:**
- Zmiana nazwy podróży
- Zmiana dat
- Zmiana zdjęcia głównego
- Dodawanie/usuwanie markerów

### Usuwanie podróży

**Proces:**
1. Potwierdzenie przez dialog
2. Usunięcie wszystkich zdjęć z Storage
3. Usunięcie dokumentu z Firestore
4. Usunięcie z list współdzielonych (jeśli dotyczy)

---

## 3. Mapa i markery

### Interaktywna mapa

**Lokalizacja:** `lib/features/trip/screens/trip_details/trip_details_map_screen.dart`

**Funkcje:**
- Google Maps z pełną interakcją
- Zoom, przesuwanie, obracanie
- Lokalizacja użytkownika
- Różne typy mapy (normalna, satelita, teren)

### Markery (punkty podróży)

**Dodawanie markera:**
1. Długie naciśnięcie na mapie
2. Automatyczne pobranie nazwy lokalizacji (geocoding)
3. Zapisanie do Firestore

**Dane markera:**
```dart
class MarkerPoint {
  String id;
  LatLng position;        // Współrzędne
  String? name;           // Nazwa miejsca
  String? description;    // Opis
  List<String>? imageUrl; // Zdjęcia
  String? transportMode;  // Środek transportu
  List<ExpenseItem>? expenses; // Wydatki
}
```

### Szczegóły markera (Bottom Sheet)

**Lokalizacja:** `lib/features/trip/widgets/marker_details_sheet/`

**Sekcje:**
1. **Nagłówek** - nazwa i przycisk zamknięcia
2. **Opis** - edytowalny opis miejsca
3. **Zdjęcia** - galeria ze zdjęciami, możliwość dodawania
4. **Transport** - wybór środka transportu do tego punktu
5. **Wydatki** - lista wydatków związanych z miejscem
6. **Pobliskie miejsca** - sugestie z Google Places

### Środki transportu

| Środek | Ikona |
|--------|-------|
| Samochód | 🚗 |
| Pociąg | 🚂 |
| Autobus | 🚌 |
| Samolot | ✈️ |
| Rower | 🚲 |
| Pieszo | 🚶 |
| Statek | ⛵ |

### Pobliskie miejsca (Google Places)

**Lokalizacja:** `lib/features/trip/widgets/nearby_places/`

**Funkcje:**
- Wyszukiwanie miejsc w pobliżu markera
- Filtrowanie po kategorii
- Szczegóły miejsca (godziny otwarcia, recenzje)
- Otwieranie w Google Maps

**Kategorie:**
- Restauracje
- Hotele
- Atrakcje turystyczne
- Muzea
- Parki
- Kawiarnie
- Sklepy

---

## 4. Budżet i wydatki

### Zarządzanie wydatkami

**Lokalizacja:** `lib/features/budget/`

**Typy wydatków:**
1. **Wydatki podróży** - ogólne wydatki całej podróży
2. **Wydatki markera** - wydatki przypisane do konkretnego miejsca

### Dodawanie wydatku

**Wymagane dane:**
- Tytuł wydatku
- Kwota
- Płatnik (opcjonalnie)
- Kategoria (opcjonalnie)

**Kategorie wydatków:**
- Transport
- Zakwaterowanie
- Jedzenie
- Rozrywka
- Zakupy
- Inne

### Rozliczenia między uczestnikami

**Lokalizacja:** `lib/features/budget/services/settlement_calculator_service.dart`

**Algorytm:**
1. Sumowanie wydatków każdego uczestnika
2. Obliczanie średniego kosztu na osobę
3. Generowanie transakcji wyrównujących

**Przykład:**
```
Uczestnicy: Adam, Bartek, Celina
Wydatki: Adam: 300 PLN, Bartek: 150 PLN, Celina: 150 PLN
Średnia: 200 PLN

Rozliczenie:
- Bartek → Adam: 50 PLN
- Celina → Adam: 50 PLN
```

### Statystyki budżetowe

- Suma wszystkich wydatków
- Wydatki na osobę
- Wydatki według kategorii
- Wydatki według dnia

---

## 5. Harmonogram (Schedule)

### Plan dnia

**Lokalizacja:** `lib/features/schedule/`

**Funkcje:**
- Tworzenie planu dla każdego dnia podróży
- Dodawanie aktywności z godziną
- Edycja i usuwanie aktywności
- Widok timeline

### Aktywność

**Dane aktywności:**
```dart
class DayPlanItem {
  String id;
  String title;        // Nazwa aktywności
  String? description; // Opis
  DateTime time;       // Godzina rozpoczęcia
  String? location;    // Miejsce
}
```

---

## 6. Znajomi i współdzielenie

### Lista znajomych

**Lokalizacja:** `lib/features/friends/`

**Funkcje:**
- Wyświetlanie listy znajomych
- Wyszukiwanie użytkowników
- Wysyłanie zaproszeń
- Akceptowanie/odrzucanie zaproszeń

### Zaproszenia

**Stany zaproszenia:**
| Stan | Opis |
|------|------|
| pending | Oczekuje na odpowiedź |
| accepted | Zaakceptowane |
| rejected | Odrzucone |

### Współdzielenie podróży

**Funkcje:**
- Udostępnianie podróży znajomym
- Wspólna edycja markerów
- Wspólne wydatki

**Przepływ:**
1. Właściciel wybiera "Udostępnij"
2. Wybiera znajomych z listy
3. Znajomi otrzymują dostęp w kolekcji `shared_trips`
4. Mogą przeglądać i edytować podróż

---

## 7. Profil użytkownika

### Wyświetlanie profilu

**Lokalizacja:** `lib/features/profile/screens/profile.dart`

**Wyświetlane dane:**
- Zdjęcie profilowe (avatar)
- Imię
- Email
- Statystyki (liczba podróży, znajomych)

### Edycja profilu

**Lokalizacja:** `lib/features/profile/screens/edit_profile.dart`

**Możliwe edycje:**
- Zmiana imienia
- Zmiana zdjęcia profilowego

### Zmiana hasła

**Lokalizacja:** `lib/features/profile/screens/change_password.dart`

**Wymagania:**
- Aktualne hasło (weryfikacja)
- Nowe hasło (min. 6 znaków)
- Potwierdzenie nowego hasła

---

## 8. Statystyki

### Statystyki użytkownika

**Lokalizacja:** `lib/features/statistics/`

**Dostępne metryki:**
- Łączna liczba podróży
- Podróże zakończone
- Podróże w trakcie
- Podróże zaplanowane
- Łączna liczba odwiedzonych miejsc
- Łączne wydatki

### Wizualizacja

- Wykresy wydatków
- Mapa odwiedzonych miejsc
- Timeline podróży

---

## 9. Oś czasu (Timeline)

### Widok timeline

**Lokalizacja:** `lib/features/timeline/`

**Funkcje:**
- Chronologiczny widok wszystkich podróży
- Wizualizacja na osi czasu
- Podgląd najważniejszych wydarzeń
- Animowane przejścia

---

## 10. Ekran główny (Home)

### Dashboard

**Lokalizacja:** `lib/features/home/screens/home.dart`

**Elementy:**
- Szybki dostęp do ostatnich podróży
- Nadchodzące podróże
- Statystyki podsumowujące
- Nawigacja do głównych sekcji

### Szuflada nawigacyjna (Drawer)

**Elementy menu:**
- Strona główna
- Moje podróże
- Znajomi
- Statystyki
- Profil
- Wyloguj

---

## 11. Splash Screen

### Ekran ładowania

**Lokalizacja:** `lib/features/splash/`

**Funkcje:**
- Animacja Lottie podczas ładowania
- Sprawdzanie stanu autoryzacji
- Przekierowanie do odpowiedniego ekranu

---

## Diagram przepływu użytkownika

```
                    ┌─────────────┐
                    │   Start     │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Splash    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
       ┌─────────────┐           ┌─────────────┐
       │    Auth     │           │    Home     │
       │  (niezalog) │           │  (zalog)    │
       └──────┬──────┘           └──────┬──────┘
              │                         │
              ▼                         ▼
       ┌─────────────┐           ┌─────────────┐
       │   Login/    │           │   Drawer    │
       │  Register   │           │    Menu     │
       └──────┬──────┘           └──────┬──────┘
              │                         │
              └──────────┬──────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
  │   Trips     │ │  Friends    │ │   Profile   │
  └──────┬──────┘ └─────────────┘ └─────────────┘
         │
         ▼
  ┌─────────────┐
  │Trip Details │
  │  (Map/Info) │
  └──────┬──────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌───────┐
│Budget │ │Schedule│
└───────┘ └───────┘
```
