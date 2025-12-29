# TripPlanner - Aplikacja mobilna Flutter

## Technologie

    Projekt został wykonany przy użyciu:
    - Flutter
    - Dart
    - Firebase
    - Riverpod
    - Google Maps API
    - Flutter Packages:
        - flutter_dotenv
        - flutter_riverpod
        - firebase_auth
        - flushbar

## Funkcjonalności aplikacji

    - Rejestracja i logowanie użytkownika

## Struktura folderów

    lib/
        main.dart - Główny plik uruchamiający aplikację

        services/ - Pliki z logiką i komunikacją z Firebase

            auth_service.dart - Plik zawiera klasę AuthService, która odpowiedzialna jest za obsługę autoryzacji
                                użytkownika przy pomocy FireBase Authentication
                Funkcjonalności:
                    - logowanie użytkownika na podstawie adresu e-mail i hasła
                    - rejestracja nowego użytkownika za pomocą adresu e-mail i hasła
                Plik zawiera również klasę AuthException która służy do przekazywania własnych komunikatów błędów do widoków

        theme/ - Globalne style aplikacji

        utils/ - Funkcje pomocnicze

            validators.dart - Plik zawiera klasę Validators, która służy do walidacji
                Zawiera dwie statyczne metody:
                    - validateEmail
                    - validatePassword

        widgets/
            authflashbars/ - komponenty wyświetlające komunikaty błędów i sukcesów
            bottomsheets/ - dolne panele do logowania i rejestracji
            buttons/ - przyciski wielokrotnego użytku
            triggers/ - odpowiada za wywołanie różnych elementów UI
                login_bottom_sheet_trigger - wywołuje BottomSheet dla logowania
                signup_bottom_sheet_trigger - wywołuje BottomSheet dla rejestracji

        screens/ - widoki aplikacji
            auth.dart - główny widok aplikacji zanim użytkownik się zarejestruje lub zaloguje
            home.dart - główny widok dla zalogowanego użytkownika
            splash.dart - przejściowy widok pomiędzy auth.dart, a home.dart na wypadek gdyby oczekiwanie na dane z firebase się wydłużyło

## Możliwości dalszego rozwoju

Aplikacja TripPlanner posiada solidne podstawy architektoniczne, które umożliwiają rozbudowę w następujących kierunkach:

### Integracje zewnętrzne
- **Integracja z API rezerwacyjnymi** - połączenie z Booking.com, Airbnb, Skyscanner w celu rezerwacji noclegów i lotów bezpośrednio z aplikacji
- **Synchronizacja z kalendarzem** - eksport planów podróży do Google Calendar, Apple Calendar
- **Integracja z mediami społecznościowymi** - udostępnianie podróży na Instagram, Facebook
- **Połączenie z aplikacjami bankowymi** - automatyczne importowanie wydatków z kart płatniczych

### Rozszerzenia funkcjonalne
- **Tryb offline** - pełna funkcjonalność bez połączenia z internetem z późniejszą synchronizacją
- **Rekomendacje AI** - wykorzystanie Google Generative AI do sugerowania atrakcji, restauracji i optymalnych tras
- **Gamifikacja** - odznaki i osiągnięcia za odwiedzone miejsca, kraje, przebyte kilometry
- **Widgety na ekran główny** - szybki podgląd nadchodzących podróży i aktywności

### Aspekty społecznościowe
- **Publiczne profile podróżników** - możliwość przeglądania i śledzenia innych użytkowników
- **Komentarze i recenzje miejsc** - społecznościowa baza ocen atrakcji
- **Wspólne planowanie w czasie rzeczywistym** - edycja współbieżna z widocznymi kursorami użytkowników

### Monetyzacja
- **Wersja premium** - rozszerzone funkcje dla płatnych użytkowników
- **Współpraca z lokalnymi przewodnikami** - rezerwacje wycieczek z prowizją
- **Reklamy kontekstowe** - rekomendacje sponsorowanych miejsc

## Funkcje planowane

### Priorytet wysoki (planowane w najbliższych iteracjach)
1. **Powiadomienia push** - przypomnienia o nadchodzących podróżach, aktywnościach i terminach płatności
2. **Eksport do PDF** - generowanie kompletnego itinerarium podróży do wydruku
3. **Wsparcie dla wielu walut** - automatyczne przeliczanie wydatków z różnych walut
4. **Wyszukiwanie głosowe** - dodawanie punktów i notatek za pomocą poleceń głosowych

### Priorytet średni
5. **Szablony podróży** - gotowe plany na popularne destynacje do wykorzystania jako baza
6. **Historia cen** - śledzenie zmian cen lotów i noclegów
7. **Pogoda** - integracja z API pogodowym dla planowanych destynacji
8. **Przypomnienia o dokumentach** - alerty o kończącej się ważności paszportu, wiz

### Priorytet niski (rozważane)
9. **Tłumaczenia offline** - wbudowany tłumacz podstawowych zwrotów
10. **Tryb ciemny** - alternatywna kolorystyka interfejsu
11. **Wsparcie dla Apple Watch/Wear OS** - podgląd planu dnia na zegarku
12. **AR (Rozszerzona rzeczywistość)** - nawigacja i informacje o zabytkach przez kamerę

## Ograniczenia obecnej wersji

### Ograniczenia techniczne
- **Brak trybu offline** - aplikacja wymaga stałego połączenia z internetem do pełnej funkcjonalności
- **Limity API Google Places** - ograniczona liczba zapytań dziennie do wyszukiwania miejsc w pobliżu
- **Rozmiar zdjęć** - brak automatycznej kompresji obrazów przed wysłaniem do Firebase Storage
- **Brak synchronizacji konfliktów** - przy jednoczesnej edycji przez wielu użytkowników mogą wystąpić nadpisania danych

### Ograniczenia funkcjonalne
- **Jedna waluta** - wszystkie wydatki są zapisywane bez informacji o walucie oryginalnej
- **Brak integracji z kalendarzem** - plany nie synchronizują się z zewnętrznymi kalendarzami
- **Ograniczone powiadomienia** - brak powiadomień push o nadchodzących aktywnościach
- **Brak eksportu danych** - użytkownik nie może wyeksportować swoich podróży do pliku

### Ograniczenia platformowe
- **Wymagana konfiguracja API** - użytkownik musi skonfigurować własne klucze Google Maps i Places API
- **Tylko język polski** - interfejs nie obsługuje innych języków
- **Brak wersji webowej produkcyjnej** - aplikacja webowa wymaga dodatkowej konfiguracji CORS i hostingu

### Ograniczenia bezpieczeństwa
- **Brak szyfrowania end-to-end** - dane są chronione przez Firebase, ale nie są szyfrowane po stronie klienta
- **Pojedyncza metoda logowania** - tylko email/hasło, brak logowania przez Google, Facebook, Apple
- **Brak uwierzytelniania dwuskładnikowego (2FA)** - konto chronione tylko hasłem

### Ograniczenia wydajnościowe
- **Ładowanie wszystkich podróży** - przy dużej liczbie podróży może wystąpić opóźnienie ładowania
- **Brak paginacji** - listy markerów i wydatków ładowane są w całości
- **Cache zdjęć** - ograniczone cachowanie obrazów może powodować ponowne pobieranie
