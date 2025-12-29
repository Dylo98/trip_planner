# 2.3. Wzorce projektowe

W aplikacji TripPlanner wykorzystano szereg sprawdzonych wzorców projektowych, które wspólnie tworzą spójną i łatwą w utrzymaniu architekturę. Dobór wzorców był podyktowany specyfiką aplikacji mobilnej opartej na Firebase oraz wymogami dotyczącymi synchronizacji danych w czasie rzeczywistym między wieloma użytkownikami.

## 2.3.1. Repository Pattern

Wzorzec Repozytorium stanowi fundament warstwy dostępu do danych w aplikacji. Jego głównym zadaniem jest utworzenie warstwy abstrakcji pomiędzy logiką biznesową a szczegółami implementacyjnymi źródła danych, którym w przypadku aplikacji TripPlanner jest baza Firebase Firestore.

W projekcie każda główna encja domenowa posiada dedykowany serwis pełniący funkcję repozytorium. Dla zachowania zasady DRY oraz uniknięcia powielania kodu, utworzono abstrakcyjną klasę bazową `BaseTripService`, która enkapsuluje wspólne zależności i metody pomocnicze wykorzystywane przez wszystkie serwisy związane z obsługą podróży. Klasa ta udostępnia metody do walidacji zalogowanego użytkownika, budowania referencji do dokumentów w bazie danych oraz określania właściciela podróży w kontekście funkcjonalności współdzielenia.

Konkretne implementacje, takie jak `TripCrudService`, `MarkerCrudService` czy `TripImageService`, dziedziczą po klasie bazowej i implementują operacje specyficzne dla swojego obszaru odpowiedzialności. Przykładowo `TripCrudService` realizuje pełen zestaw operacji CRUD na encji podróży, podczas gdy `MarkerCrudService` koncentruje się na zarządzaniu punktami oznaczonymi na mapie.

Zastosowanie wzorca Repozytorium przynosi wymierne korzyści w postaci separacji odpowiedzialności, centralizacji logiki dostępu do danych oraz znacznego ułatwienia procesu testowania poprzez możliwość wstrzykiwania zamiennych implementacji źródła danych.

## 2.3.2. Provider Pattern

Zarządzanie stanem aplikacji oparto na bibliotece Riverpod, która implementuje wzorzec Provider w zaawansowanej formie. Wzorzec ten umożliwia reaktywne zarządzanie stanem, gdzie zmiany danych automatycznie propagują się do komponentów interfejsu użytkownika, eliminując konieczność manualnego odświeżania widoków.

W aplikacji TripPlanner każda funkcjonalność posiada dedykowane providery obsługujące strumienie danych oraz logikę biznesową. Wykorzystano wariant `StreamProvider` z modyfikatorem `autoDispose`, który automatycznie zwalnia zasoby w momencie, gdy provider przestaje być obserwowany przez jakikolwiek komponent. Rozwiązanie to jest szczególnie istotne w kontekście aplikacji mobilnych, gdzie efektywne zarządzanie pamięcią ma kluczowe znaczenie dla płynności działania.

Architektura providerów umożliwia również kompozycję, czyli budowanie złożonych providerów na bazie prostszych. Przykładem jest `allTripsProvider`, który łączy dane z providera własnych podróży użytkownika oraz providera podróży udostępnionych, tworząc zunifikowany strumień wszystkich dostępnych podróży.

Wzorzec Provider w połączeniu z Riverpod zapewnia reaktywność interfejsu, wstrzykiwanie zależności bez konieczności stosowania singletonów, promowanie niemutowalności stanu oraz łatwość testowania poprzez możliwość nadpisywania providerów w środowisku testowym.

## 2.3.3. Observer Pattern

Wzorzec Obserwatora został zaimplementowany na dwóch poziomach architektury aplikacji. Na poziomie źródła danych wykorzystano natywne wsparcie Firebase Firestore dla strumieni zmian, natomiast na poziomie zarządzania stanem wzorzec jest realizowany przez mechanizm `StreamProvider` biblioteki Riverpod.

Firestore udostępnia metodę `snapshots()`, która zwraca strumień automatycznie emitujący nowe wartości przy każdej zmianie danych w obserwowanej kolekcji lub dokumencie. Mechanizm ten jest wykorzystywany w metodach takich jak `watchTrip()` do obserwowania pojedynczej podróży czy `watchFriends()` do śledzenia listy znajomych użytkownika.

Dzięki zastosowaniu wzorca Obserwatora aplikacja oferuje aktualizacje w czasie rzeczywistym bez konieczności manualnego odświeżania, co jest szczególnie istotne w kontekście współdzielenia podróży między użytkownikami. Gdy jeden użytkownik modyfikuje szczegóły podróży, wszyscy pozostali uczestnicy natychmiast widzą wprowadzone zmiany. Dodatkową zaletą jest luźne powiązanie między źródłem danych a interfejsem użytkownika, co zwiększa modularność i testowalność kodu.

## 2.3.4. Factory Pattern

Wzorzec Fabryki znalazł zastosowanie w modelach danych aplikacji, gdzie służy do tworzenia obiektów z różnych źródeł. Język Dart wspiera ten wzorzec poprzez konstruktory fabryczne oznaczone słowem kluczowym `factory`, które w przeciwieństwie do standardowych konstruktorów mogą zwracać istniejące instancje lub instancje podtypów.

Każdy model danych w aplikacji, taki jak `Trip`, `Friend` czy `ExpenseItem`, posiada dwa konstruktory fabryczne: `fromFirestore()` oraz `fromJson()`. Rozróżnienie to wynika z różnic w formacie danych. Firebase Firestore reprezentuje daty jako obiekty typu `Timestamp`, podczas gdy standardowy format JSON wykorzystuje łańcuchy znaków w formacie ISO 8601. Konstruktory fabryczne enkapsulują logikę konwersji, zapewniając spójne tworzenie obiektów niezależnie od źródła danych.

Uzupełnieniem wzorca jest metoda `toJson()` realizująca serializację obiektu do formatu zapisywalnego w bazie danych oraz metoda `copyWith()` umożliwiająca tworzenie zmodyfikowanych kopii obiektu bez naruszania zasady niemutowalności. Takie podejście zapewnia elastyczność w obsłudze różnych źródeł danych, enkapsulację szczegółów parsowania oraz łatwość rozszerzania o nowe formaty wejściowe.

## 2.3.5. Singleton Pattern z Dependency Injection

Instancje usług Firebase, takich jak `FirebaseAuth`, `FirebaseFirestore` oraz `FirebaseStorage`, są z natury singletonami udostępnianymi przez właściwość statyczną `instance`. W aplikacji TripPlanner zastosowano jednak zmodyfikowaną wersję wzorca Singleton, łącząc go z wzorcem Dependency Injection.

Każdy serwis przyjmuje w konstruktorze opcjonalne parametry reprezentujące zależności Firebase. Jeśli parametry nie zostaną przekazane, serwis wykorzystuje domyślne instancje singleton. Takie podejście zachowuje efektywność współdzielenia połączeń w środowisku produkcyjnym, jednocześnie umożliwiając wstrzykiwanie zamiennych implementacji podczas testowania.

Rozwiązanie to stanowi kompromis między prostotą wzorca Singleton a elastycznością wymaganą przez nowoczesne praktyki testowania. Serwisy pozostają łatwe w użyciu w kodzie produkcyjnym, gdzie wystarczy utworzyć instancję bez parametrów, a jednocześnie są w pełni testowalne poprzez wstrzykiwanie mocków przez konstruktor.

## 2.3.6. Template Method Pattern

Wzorzec Metody Szablonowej został zastosowany w abstrakcyjnej klasie `BaseTripService`, która definiuje szkielet algorytmów dostępu do danych podróży. Klasa bazowa implementuje wspólne kroki algorytmu, takie jak walidacja zalogowanego użytkownika czy budowanie ścieżek do dokumentów w bazie danych, pozostawiając implementację szczegółowych operacji klasom pochodnym.

Metoda `requireUserId()` stanowi przykład kroku szablonowego realizującego walidację stanu uwierzytelnienia. Metoda `getTripRef()` buduje referencję do dokumentu podróży w kontekście bieżącego użytkownika, podczas gdy `getTripOwnerId()` implementuje złożoną logikę określania właściciela podróży z uwzględnieniem mechanizmu współdzielenia.

Klasy pochodne, takie jak `TripCrudService`, `MarkerCrudService`, `TripImageService` czy `TripDeletionService`, dziedziczą po klasie bazowej i koncentrują się wyłącznie na implementacji operacji specyficznych dla swojego obszaru odpowiedzialności. Wzorzec ten eliminuje duplikację kodu, zapewnia spójność zachowania wszystkich serwisów oraz ułatwia dodawanie nowych serwisów poprzez dziedziczenie.

## 2.3.7. Batch Operations Pattern

W kontekście bazy danych Firebase Firestore szczególnego znaczenia nabiera wzorzec Operacji Wsadowych, który umożliwia atomowe wykonanie wielu operacji na różnych dokumentach. Firestore udostępnia mechanizm `WriteBatch`, gwarantujący, że wszystkie operacje w ramach wsadu zostaną wykonane pomyślnie lub żadna z nich nie zostanie zatwierdzona.

Wzorzec ten jest niezbędny w sytuacjach wymagających zachowania spójności danych rozproszonych w wielu dokumentach. Przykładem jest operacja akceptacji zaproszenia do znajomych, która wymaga jednoczesnej aktualizacji statusu zaproszenia, dodania wpisu do listy znajomych bieżącego użytkownika oraz dodania symetrycznego wpisu do listy znajomych nadawcy zaproszenia. Wykonanie tych operacji pojedynczo stwarzałoby ryzyko niespójności danych w przypadku błędu którejkolwiek z nich.

Analogicznie, usuwanie znajomego wymaga atomowego usunięcia wpisów z list znajomych obu użytkowników. Zastosowanie operacji wsadowych gwarantuje, że relacja znajomości zostanie usunięta w całości lub pozostanie nienaruszona, eliminując możliwość powstania jednostronnych relacji.

## Podsumowanie

Zastosowane wzorce projektowe tworzą spójną architekturę aplikacji, w której każdy wzorzec pełni określoną rolę. Repository Pattern zapewnia separację warstwy dostępu do danych, Provider Pattern odpowiada za reaktywne zarządzanie stanem, Observer Pattern umożliwia synchronizację w czasie rzeczywistym, Factory Pattern standaryzuje tworzenie obiektów domenowych, Singleton z Dependency Injection balansuje między efektywnością a testowalnością, Template Method eliminuje duplikację w hierarchii serwisów, a Batch Operations gwarantują atomowość złożonych transakcji.

Kombinacja tych wzorców zapewnia wysoką testowalność kodu dzięki konsekwentnemu stosowaniu wstrzykiwania zależności, skalowalność wynikającą z separacji odpowiedzialności, responsywność interfejsu użytkownika dzięki reaktywnemu zarządzaniu stanem oraz niezawodność operacji na danych dzięki atomowym transakcjom wsadowym.
