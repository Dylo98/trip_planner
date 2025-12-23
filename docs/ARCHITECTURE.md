# Architektura

Architektura aplikacji TripPlanner została zaprojektowana z myślą o skalowalności oraz łatwości utrzymania. Projekt wykorzystuje podejście Feature-First (nazywane również architekturą modularną) w połączeniu ze sprawdzonymi wzorcami projektowymi, które zapewniają separację odpowiedzialności i luźne powiązania między komponentami.

## Architektura Feature-First

### Koncepcja

Architektura Feature-First to podejście do organizacji kodu, w którym struktura projektu odzwierciedla funkcjonalności biznesowe aplikacji, a nie typy plików. W przeciwieństwie do tradycyjnego podejścia, gdzie wszystkie modele znajdują się w jednym folderze, wszystkie serwisy w innym, a widoki w kolejnym, w architekturze Feature-First kod związany z konkretną funkcjonalnością jest zgrupowany w jednym miejscu.

### Porównanie z architekturą tradycyjną

W tradycyjnym podejściu struktura projektu wygląda następująco: istnieje folder models zawierający wszystkie modele danych, folder services ze wszystkimi serwisami, folder screens ze wszystkimi ekranami oraz folder widgets ze wszystkimi widżetami. Przy rozbudowie aplikacji taka struktura prowadzi do sytuacji, gdzie pliki powiązane logicznie są rozproszone po całym projekcie.

W architekturze Feature-First zastosowanej w TripPlanner struktura jest odmienna. Projekt dzieli się na dwa główne obszary: moduł core zawierający zasoby współdzielone przez całą aplikację oraz folder features, w którym każda funkcjonalność biznesowa stanowi oddzielny, samowystarczalny moduł. Każdy taki moduł zawiera własne ekrany, widżety, serwisy, providery i modele danych.

Aplikacja zawiera następujące moduły funkcjonalne:
- **auth** - autoryzacja i zarządzanie użytkownikami
- **trip** - zarządzanie podróżami i markerami na mapie
- **budget** - śledzenie wydatków i rozliczenia
- **schedule** - harmonogram podróży
- **friends** - zarządzanie znajomymi i udostępnianie podróży
- **profile** - profil użytkownika i ustawienia
- **statistics** - statystyki podróży
- **home** - ekran główny aplikacji
- **timeline** - oś czasu podróży
- **splash** - ekran powitalny

### Zalety i wady zastosowania podejścia Feature-First

| Zalety | Wady |
|--------|------|
| Wysoka spójność | Ryzyko duplikacji kodu |
| Lepsza skalowalność | Trudniejsza decyzja przy wyborze elementów wspólnych |
| Łatwiejsze debugowanie i rozwój | Zależności między feature'ami mogą się skomplikować |
| Lepsza praca równoległa | Więcej folderów i plików na starcie |
| Łatwiejsza izolacja testów | |

## Moduł Core

Moduł core zawiera zasoby współdzielone przez wszystkie funkcjonalności aplikacji. Jest to jedyna część kodu, od której mogą zależeć pozostałe moduły.

### Nawigacja

Folder navigation zawiera centralną konfigurację routera GoRouter. Wszystkie ścieżki nawigacyjne aplikacji są zdefiniowane w jednym miejscu, co zapewnia spójność i ułatwia zarządzanie przepływem użytkownika między ekranami. Tutaj również znajduje się logika automatycznych przekierowań na podstawie stanu autoryzacji.

### Motyw wizualny

Folder theme zawiera definicje wyglądu aplikacji podzielone na logiczne jednostki. Plik app_theme definiuje główny obiekt ThemeData używany przez całą aplikację. Plik colors zawiera paletę kolorów jako stałe, co umożliwia łatwą zmianę schematu kolorystycznego w jednym miejscu. Pliki text_style, button_style oraz input_style definiują odpowiednio style tekstów, przycisków i pól formularzy.

### Narzędzia pomocnicze

Folder utils zawiera funkcje i klasy pomocnicze używane w wielu miejscach aplikacji. Znajdują się tu:
- **validators** - walidatory formularzy sprawdzające poprawność adresów e-mail, haseł, nazw użytkowników, nazw podróży, dat, tytułów wydatków oraz kwot
- **debouncer** - mechanizm zapobiegający zbyt częstemu wywoływaniu operacji (przydatny przy wyszukiwaniu)
- **text_utils** - funkcje formatujące tekst
- **action_lock** - mechanizm zapobiegający wielokrotnemu kliknięciu przycisku przed zakończeniem poprzedniej operacji

### Współdzielone widżety

Folder widgets zawiera komponenty interfejsu użytkownika wykorzystywane w wielu miejscach aplikacji. Są to między innymi przyciski o spójnym wyglądzie, komponenty dialogów, panel nawigacyjny, widżet wyświetlania błędów, widżet pustego stanu, wskaźnik ładowania oraz widżet awatara użytkownika.

## Wzorce projektowe

### Wzorzec Fasady (Facade Pattern)

Wzorzec Fasady jest kluczowym elementem architektury modułu podróży. Główny serwis TripService pełni rolę fasady, która udostępnia uproszczone API do zarządzania podróżami, ukrywając złożoność wewnętrznej implementacji.

Za fasadą kryje się siedem wyspecjalizowanych serwisów:
- **TripCrudService** - podstawowe operacje tworzenia, odczytu, aktualizacji i usuwania podróży
- **TripImageService** - zarządzanie zdjęciami przypisanymi do podróży
- **TripDeletionService** - kompleksowe usuwanie podróży wraz ze wszystkimi powiązanymi zasobami
- **TripExpenseService** - zarządzanie ogólnymi wydatkami podróży
- **MarkerCrudService** - operacje na punktach zaznaczonych na mapie
- **MarkerUpdateService** - aktualizacja danych markerów
- **MarkerImageService** - zarządzanie zdjęciami przypisanymi do markerów

Dzięki zastosowaniu wzorca Fasady kod korzystający z funkcjonalności podróży nie musi wiedzieć, który konkretny serwis jest odpowiedzialny za daną operację. Wystarczy wywołać odpowiednią metodę na obiekcie TripService, a fasada przekieruje żądanie do właściwego serwisu wewnętrznego.

Fasada została wprowadzona tylko w tym module ponieważ występuje tutaj większa złożoność i wiele wyspecjalizowanych serwisów. Dla prostszych funkcjonalności stosowane są bezpośrednie serwisy, aby uniknąć nadmiarowych warstw abstrakcji.

### Wzorzec Repozytorium (Repository Pattern)

Wzorzec Repozytorium wprowadza warstwę abstrakcji między logiką biznesową a źródłem danych. W aplikacji TripPlanner wzorzec ten jest stosowany wybiórczo - głównie w module autoryzacji (UserRepository), gdzie zapewnia czystą separację między logiką zarządzania użytkownikami a Firebase Firestore.

W pozostałych modułach serwisy komunikują się bezpośrednio z Firebase, co jest świadomym kompromisem między czystością architektury a pragmatyzmem. Dla aplikacji tej skali pełna warstwa repozytoriów we wszystkich modułach wprowadzałaby nadmiarową złożoność.

Korzyści z zastosowania tego wzorca tam, gdzie został użyty, są znaczące. Zmiana źródła danych wymaga jedynie modyfikacji implementacji repozytorium, bez zmian w pozostałej części aplikacji. Testowanie logiki biznesowej jest prostsze, ponieważ repozytoria można łatwo zastąpić wersjami testowymi (mock) zwracającymi predefiniowane dane.

### Wzorzec Provider (realizowany przez Riverpod)

Riverpod realizuje wzorzec Provider, umożliwiając centralne zarządzanie zależnościami i stanem aplikacji. Zamiast przekazywać zależności przez konstruktory kolejnych klas w drzewie widżetów, komponenty pobierają je bezpośrednio z systemu providerów.

Każdy provider definiuje sposób tworzenia i zarządzania cyklem życia konkretnego obiektu. Providery mogą zależeć od innych providerów, tworząc graf zależności, który Riverpod automatycznie rozwiązuje i zarządza.

## Warstwy aplikacji

Aplikacja jest podzielona na pięć warstw, z których każda ma określoną odpowiedzialność.

### Warstwa prezentacji

Warstwa prezentacji obejmuje wszystkie elementy interfejsu użytkownika: ekrany (screens), widżety (widgets) oraz dialogi. Komponenty tej warstwy są odpowiedzialne wyłącznie za wyświetlanie danych i reagowanie na interakcje użytkownika. Nie zawierają logiki biznesowej ani nie komunikują się bezpośrednio ze źródłami danych.

### Warstwa zarządzania stanem

Warstwa ta składa się z providerów Riverpod, które zarządzają stanem aplikacji. Providery pobierają dane z warstwy logiki biznesowej i udostępniają je warstwie prezentacji w reaktywny sposób. Gdy dane się zmieniają, widżety subskrybujące dany provider są automatycznie odświeżane.

### Warstwa logiki biznesowej

W tej warstwie znajdują się serwisy implementujące reguły biznesowe aplikacji oraz klasy pomocnicze. Serwisy koordynują operacje, walidują dane i implementują złożoną logikę, która nie powinna znajdować się w warstwie prezentacji.

### Warstwa danych

Warstwa danych zawiera modele reprezentujące struktury danych używane w aplikacji, obiekty transferu danych (DTO) oraz mappery konwertujące dane między różnymi reprezentacjami. Modele są niemodyfikowalne (immutable) i zawierają metody do serializacji oraz deserializacji.

### Warstwa usług zewnętrznych

Najniższa warstwa obejmuje integrację z zewnętrznymi usługami: Firebase Authentication, Cloud Firestore, Firebase Storage oraz Google Maps API. Komunikacja z tymi usługami jest enkapsulowana w serwisach, dzięki czemu pozostałe warstwy nie są bezpośrednio zależne od konkretnych technologii zewnętrznych.

## Przepływ danych

Dane w aplikacji przepływają w określony sposób. Użytkownik wchodzi w interakcję z warstwą prezentacji, która wywołuje akcje na providerach. Providery delegują operacje do serwisów w warstwie logiki biznesowej. Serwisy komunikują się z zewnętrznymi usługami (bezpośrednio lub przez repozytoria). Odpowiedź wraca tą samą ścieżką: usługi zewnętrzne przekazują dane do serwisów, serwisy aktualizują stan w providerach, a providery powiadamiają warstwę prezentacji o zmianach.

W przypadku danych pobieranych w czasie rzeczywistym (strumienie z Firestore) przepływ jest ciągły. Zmiany w bazie danych automatycznie propagują się przez wszystkie warstwy aż do interfejsu użytkownika.

## Zasady SOLID

Architektura aplikacji respektuje zasady SOLID, które są fundamentem dobrego projektowania obiektowego.

### Zasada pojedynczej odpowiedzialności (Single Responsibility Principle)

Każda klasa ma jedną, jasno określoną odpowiedzialność. Na przykład TripCrudService odpowiada wyłącznie za operacje CRUD na podróżach, TripImageService wyłącznie za zarządzanie zdjęciami, a TripDeletionService wyłącznie za usuwanie podróży. Dzięki temu klasy są małe, łatwe do zrozumienia i modyfikacji.

### Zasada otwarte-zamknięte (Open/Closed Principle)

Aplikacja jest otwarta na rozszerzenia, ale zamknięta na modyfikacje. Dodanie nowej funkcjonalności nie wymaga zmian w istniejących modułach. Nowy feature jest po prostu kolejnym folderem w katalogu features.

### Zasada segregacji interfejsów (Interface Segregation Principle)

Fasada TripService eksponuje tylko te metody, które są potrzebne klientom. Wewnętrzna złożoność jest ukryta, a każdy serwis wewnętrzny implementuje minimalny, spójny zestaw operacji.

### Zasada odwrócenia zależności (Dependency Inversion Principle)

Serwisy przyjmują zależności przez konstruktor, co umożliwia wstrzykiwanie różnych implementacji. Dzięki temu logika biznesowa nie tworzy bezpośrednio instancji zależności i może być testowana w izolacji.

## Zależności między modułami

W architekturze Feature-First obowiązują ścisłe reguły dotyczące zależności. Moduł core nie zależy od żadnego feature i zawiera tylko kod współdzielony. Każdy feature może zależeć od modułu core. Feature może również zależeć od innego feature, jeśli jest to uzasadnione biznesowo - na przykład moduł budget zależy od modułu trip, ponieważ wydatki są przypisane do podróży. Zależności cykliczne między modułami są niedozwolone.
