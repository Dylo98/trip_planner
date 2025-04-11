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
