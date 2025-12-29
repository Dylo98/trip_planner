# 2.3. Wzorce projektowe

W aplikacji TripPlanner wykorzystano szereg sprawdzonych wzorców projektowych, które wspólnie tworzą spójną i łatwą w utrzymaniu architekturę. Dobór wzorców był podyktowany specyfiką aplikacji mobilnej opartej na Firebase oraz wymogami dotyczącymi synchronizacji danych w czasie rzeczywistym między wieloma użytkownikami.

## 2.3.1. Facade Pattern (Wzorzec Fasady)

Wzorzec Fasady udostępnia jednolity interfejs dla zbioru interfejsów z podsystemu, definiując interfejs wyższego poziomu ułatwiający korzystanie z tego podsystemu. Podział systemu na podsystemy pomaga zmniejszyć jego złożoność, a standardowym celem projektowym jest zminimalizowanie komunikacji i zależności między nimi. Jednym ze sposobów na uzyskanie tego efektu jest wprowadzenie obiektu fasadowego udostępniającego jeden uproszczony interfejs dla ogólniejszych mechanizmów podsystemu.

W aplikacji TripPlanner podsystemem wymagającym fasady jest Firebase Firestore SDK. Podsystem ten obejmuje liczne klasy niskopoziomowe, takie jak `FirebaseFirestore`, `CollectionReference`, `DocumentReference`, `DocumentSnapshot`, `QuerySnapshot`, `WriteBatch` oraz `Transaction`. Składają się one na implementację dostępu do nierelacyjnej bazy danych. Bezpośrednie korzystanie z tych klas wymaga znajomości struktury kolekcji, formatu ścieżek dokumentów, mechanizmów serializacji oraz obsługi strumieni danych. Dla większości komponentów aplikacji szczegóły te nie mają znaczenia — komponenty chcą jedynie zapisać podróż, pobrać listę znajomych czy zaktualizować plan dnia.

Aby udostępnić wysokopoziomowy interfejs, który ukryje wyspecjalizowane klasy Firebase przed resztą aplikacji, utworzono warstwę serwisów fasadowych. Klasy takie jak `TripCrudService`, `FriendService`, `DayPlanService` czy `SharedTripService` pełnią rolę fasad — udostępniają klientom prosty interfejs do podsystemu Firebase, łącząc klasy obejmujące implementację funkcji dostępu do danych bez całkowitego ich ukrywania.

Przykładowo, zapisanie podróży bez fasady wymagałoby od klienta znajomości struktury kolekcji, pobrania identyfikatora zalogowanego użytkownika, zbudowania odpowiedniej ścieżki oraz przeprowadzenia serializacji obiektu. Fasada `TripCrudService` redukuje tę operację do pojedynczego wywołania metody `saveTrip(trip)`, ukrywając całą złożoność wewnątrz implementacji.

Dla zachowania zasady DRY oraz uniknięcia powielania kodu wspólnego dla wielu fasad, utworzono abstrakcyjną klasę bazową `BaseTripService`. Klasa ta enkapsuluje współdzielone zależności oraz metody pomocnicze, takie jak walidacja zalogowanego użytkownika czy budowanie referencji do dokumentów. Fasady `TripCrudService`, `MarkerCrudService`, `TripImageService` oraz `TripDeletionService` dziedziczą po klasie bazowej, koncentrując się wyłącznie na operacjach specyficznych dla swojego obszaru odpowiedzialności.

Fasady w aplikacji TripPlanner ułatwiają pracę przy rozwoju funkcjonalności, a przy tym nie ukrywają niskopoziomowych mechanizmów Firebase przed sytuacjami, które ich wymagają. W razie potrzeby programista może sięgnąć bezpośrednio do API Firestore, jednak w typowych przypadkach użycia warstwa fasadowa zapewnia wystarczającą funkcjonalność przy znacznie niższym progu wejścia.

Zastosowanie wzorca Fasady przynosi wymierne korzyści: zmniejsza liczbę zależności między komponentami aplikacji a biblioteką Firebase, centralizuje logikę dostępu do danych w jednym miejscu oraz znacząco ułatwia proces testowania poprzez możliwość wstrzykiwania zamiennych implementacji podsystemu.

## 2.3.2. Provider Pattern (Wzorzec Dostawcy Stanu)

Zarządzanie stanem aplikacji oparto na bibliotece Riverpod, która implementuje wzorzec Provider w zaawansowanej formie. Wzorzec ten umożliwia reaktywne zarządzanie stanem, gdzie zmiany danych automatycznie propagują się do komponentów interfejsu użytkownika, eliminując konieczność manualnego odświeżania widoków.

W aplikacji TripPlanner każda funkcjonalność posiada dedykowane providery obsługujące strumienie danych oraz logikę biznesową. Wykorzystano wariant `StreamProvider` z modyfikatorem `autoDispose`, który automatycznie zwalnia zasoby w momencie, gdy provider przestaje być obserwowany przez jakikolwiek komponent. Rozwiązanie to jest szczególnie istotne w kontekście aplikacji mobilnych, gdzie efektywne zarządzanie pamięcią ma kluczowe znaczenie dla płynności działania.

Architektura providerów umożliwia również kompozycję, czyli budowanie złożonych providerów na bazie prostszych. Przykładem jest `allTripsProvider`, który łączy dane z providera własnych podróży użytkownika oraz providera podróży udostępnionych, tworząc zunifikowany strumień wszystkich dostępnych podróży.

Wzorzec Provider w połączeniu z Riverpod zapewnia reaktywność interfejsu, wstrzykiwanie zależności bez konieczności stosowania singletonów, promowanie niemutowalności stanu oraz łatwość testowania poprzez możliwość nadpisywania providerów w środowisku testowym.

## 2.3.3. Observer Pattern (Wzorzec Obserwatora)

Wzorzec Obserwatora został zaimplementowany na dwóch poziomach architektury aplikacji. Na poziomie źródła danych wykorzystano natywne wsparcie Firebase Firestore dla strumieni zmian, natomiast na poziomie zarządzania stanem wzorzec jest realizowany przez mechanizm `StreamProvider` biblioteki Riverpod.

Firestore udostępnia metodę `snapshots()`, która zwraca strumień automatycznie emitujący nowe wartości przy każdej zmianie danych w obserwowanej kolekcji lub dokumencie. Mechanizm ten jest wykorzystywany w metodach fasadowych takich jak `watchTrip()` do obserwowania pojedynczej podróży czy `watchFriends()` do śledzenia listy znajomych użytkownika.

Dzięki zastosowaniu wzorca Obserwatora aplikacja oferuje aktualizacje w czasie rzeczywistym bez konieczności manualnego odświeżania, co jest szczególnie istotne w kontekście współdzielenia podróży między użytkownikami. Gdy jeden użytkownik modyfikuje szczegóły podróży, wszyscy pozostali uczestnicy natychmiast widzą wprowadzone zmiany. Dodatkową zaletą jest luźne powiązanie między źródłem danych a interfejsem użytkownika, co zwiększa modularność i testowalność kodu.

## 2.3.4. Factory Pattern (Wzorzec Fabryki)

Wzorzec Fabryki znalazł zastosowanie w modelach danych aplikacji, gdzie służy do tworzenia obiektów z różnych źródeł. Język Dart wspiera ten wzorzec poprzez konstruktory fabryczne oznaczone słowem kluczowym `factory`, które w przeciwieństwie do standardowych konstruktorów mogą zwracać istniejące instancje lub instancje podtypów.

Każdy model danych w aplikacji, taki jak `Trip`, `Friend` czy `ExpenseItem`, posiada dwa konstruktory fabryczne: `fromFirestore()` oraz `fromJson()`. Rozróżnienie to wynika z różnic w formacie danych — Firebase Firestore reprezentuje daty jako obiekty typu `Timestamp`, podczas gdy standardowy format JSON wykorzystuje łańcuchy znaków w formacie ISO 8601. Konstruktory fabryczne enkapsulują logikę konwersji, zapewniając spójne tworzenie obiektów niezależnie od źródła danych.

Uzupełnieniem wzorca jest metoda `toJson()` realizująca serializację obiektu do formatu zapisywalnego w bazie danych oraz metoda `copyWith()` umożliwiająca tworzenie zmodyfikowanych kopii obiektu bez naruszania zasady niemutowalności. Takie podejście zapewnia elastyczność w obsłudze różnych źródeł danych, enkapsulację szczegółów parsowania oraz łatwość rozszerzania o nowe formaty wejściowe.

## 2.3.5. Singleton Pattern z Dependency Injection

Instancje usług Firebase, takich jak `FirebaseAuth`, `FirebaseFirestore` oraz `FirebaseStorage`, są z natury singletonami udostępnianymi przez właściwość statyczną `instance`. W aplikacji TripPlanner zastosowano jednak zmodyfikowaną wersję wzorca Singleton, łącząc go z wzorcem Dependency Injection.

Każdy serwis fasadowy przyjmuje w konstruktorze opcjonalne parametry reprezentujące zależności Firebase. Jeśli parametry nie zostaną przekazane, serwis wykorzystuje domyślne instancje singleton. Takie podejście zachowuje efektywność współdzielenia połączeń w środowisku produkcyjnym, jednocześnie umożliwiając wstrzykiwanie zamiennych implementacji podczas testowania.

Rozwiązanie to stanowi kompromis między prostotą wzorca Singleton a elastycznością wymaganą przez nowoczesne praktyki testowania. Serwisy pozostają łatwe w użyciu w kodzie produkcyjnym, gdzie wystarczy utworzyć instancję bez parametrów, a jednocześnie są w pełni testowalne poprzez wstrzykiwanie mocków przez konstruktor.

## 2.3.6. Template Method Pattern (Wzorzec Metody Szablonowej)

Wzorzec Metody Szablonowej został zastosowany w abstrakcyjnej klasie `BaseTripService`, która definiuje szkielet algorytmów dostępu do danych podróży. Klasa bazowa implementuje wspólne kroki algorytmu, takie jak walidacja zalogowanego użytkownika czy budowanie ścieżek do dokumentów w bazie danych, pozostawiając implementację szczegółowych operacji klasom pochodnym.

Metoda `requireUserId()` stanowi przykład kroku szablonowego realizującego walidację stanu uwierzytelnienia. Metoda `getTripRef()` buduje referencję do dokumentu podróży w kontekście bieżącego użytkownika, podczas gdy `getTripOwnerId()` implementuje złożoną logikę określania właściciela podróży z uwzględnieniem mechanizmu współdzielenia.

Klasy pochodne, takie jak `TripCrudService`, `MarkerCrudService`, `TripImageService` czy `TripDeletionService`, dziedziczą po klasie bazowej i koncentrują się wyłącznie na implementacji operacji specyficznych dla swojego obszaru odpowiedzialności. Wzorzec ten eliminuje duplikację kodu, zapewnia spójność zachowania wszystkich serwisów fasadowych oraz ułatwia dodawanie nowych fasad poprzez dziedziczenie.

## 2.3.7. Batch Operations Pattern (Wzorzec Operacji Wsadowych)

W kontekście bazy danych Firebase Firestore szczególnego znaczenia nabiera wzorzec Operacji Wsadowych, który umożliwia atomowe wykonanie wielu operacji na różnych dokumentach. Firestore udostępnia mechanizm `WriteBatch`, gwarantujący, że wszystkie operacje w ramach wsadu zostaną wykonane pomyślnie lub żadna z nich nie zostanie zatwierdzona.

Wzorzec ten jest niezbędny w sytuacjach wymagających zachowania spójności danych rozproszonych w wielu dokumentach. Przykładem jest operacja akceptacji zaproszenia do znajomych, która wymaga jednoczesnej aktualizacji statusu zaproszenia, dodania wpisu do listy znajomych bieżącego użytkownika oraz dodania symetrycznego wpisu do listy znajomych nadawcy zaproszenia. Wykonanie tych operacji pojedynczo stwarzałoby ryzyko niespójności danych w przypadku błędu którejkolwiek z nich.

Analogicznie, usuwanie znajomego wymaga atomowego usunięcia wpisów z list znajomych obu użytkowników. Zastosowanie operacji wsadowych gwarantuje, że relacja znajomości zostanie usunięta w całości lub pozostanie nienaruszona, eliminując możliwość powstania jednostronnych relacji.

## Podsumowanie

Zastosowane wzorce projektowe tworzą spójną architekturę aplikacji, w której każdy wzorzec pełni określoną rolę. Wzorzec Fasady stanowi fundament warstwy dostępu do danych, udostępniając uproszczony interfejs do złożonego podsystemu Firebase Firestore. Provider Pattern odpowiada za reaktywne zarządzanie stanem, Observer Pattern umożliwia synchronizację w czasie rzeczywistym, Factory Pattern standaryzuje tworzenie obiektów domenowych, Singleton z Dependency Injection balansuje między efektywnością a testowalnością, Template Method eliminuje duplikację w hierarchii fasad, a Batch Operations gwarantują atomowość złożonych transakcji.

Kombinacja tych wzorców zapewnia wysoką testowalność kodu dzięki konsekwentnemu stosowaniu wstrzykiwania zależności, skalowalność wynikającą z separacji odpowiedzialności, responsywność interfejsu użytkownika dzięki reaktywnemu zarządzaniu stanem oraz niezawodność operacji na danych dzięki atomowym transakcjom wsadowym.
