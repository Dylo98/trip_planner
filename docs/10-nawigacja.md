# Nawigacja

## Przegląd

TripPlanner wykorzystuje **GoRouter** do zarządzania nawigacją. GoRouter to deklaratywny router wspierający deep linking, nested routes i automatyczne przekierowania.

---

## Konfiguracja

**Lokalizacja:** `lib/core/navigation/app_router.dart`

### Podstawowa struktura

```dart
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: _handleRedirect,
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  routes: [
    // ... definicje tras
  ],
);
```

### Nasłuchiwanie zmian Auth

```dart
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

GoRouter automatycznie odświeża routing gdy zmieni się stan autoryzacji Firebase.

---

## Automatyczne przekierowania

```dart
String? _handleRedirect(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  final isAuthScreen = state.matchedLocation == '/auth';

  // Niezalogowany użytkownik próbuje dostać się do chronionej trasy
  if (user == null && !isAuthScreen) {
    return '/auth';
  }

  // Zalogowany użytkownik próbuje wejść na ekran logowania
  if (user != null && isAuthScreen) {
    return '/';
  }

  // Brak przekierowania
  return null;
}
```

### Diagram przekierowań

```
                    ┌─────────────────────┐
                    │  Dowolna ścieżka    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
              ┌─────│   Czy zalogowany?   │─────┐
              │     └─────────────────────┘     │
              │ NIE                         TAK │
              ▼                                 ▼
     ┌─────────────────┐               ┌─────────────────┐
     │ Czy /auth?      │               │ Czy /auth?      │
     └────────┬────────┘               └────────┬────────┘
        │           │                      │           │
       TAK         NIE                    TAK         NIE
        │           │                      │           │
        ▼           ▼                      ▼           ▼
    ┌───────┐  ┌─────────┐            ┌───────┐  ┌─────────┐
    │Zostań │  │Redirect │            │Redirect│  │ Zostań  │
    │na/auth│  │do /auth │            │ do /   │  │na ścież.│
    └───────┘  └─────────┘            └────────┘  └─────────┘
```

---

## Definicje tras

### Pełna lista tras

```dart
routes: [
  // Autoryzacja
  GoRoute(
    path: '/auth',
    builder: (context, state) => const AuthScreen(),
  ),

  // Ekran główny
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeScreen(),
  ),

  // Tworzenie podróży
  GoRoute(
    path: '/add-trip',
    builder: (context, state) => const NewTripScreen(),
  ),

  // Lista podróży
  GoRoute(
    path: '/my-trips',
    builder: (context, state) => const MyTripsScreen(),
  ),

  // Znajomi
  GoRoute(
    path: '/friends',
    builder: (context, state) => const FriendsScreen(),
  ),

  // Statystyki
  GoRoute(
    path: '/statistics',
    builder: (context, state) => const StatisticsScreen(),
  ),

  // Profil z nested routes
  GoRoute(
    path: '/profile',
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: 'edit',  // Pełna ścieżka: /profile/edit
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: 'change-password',  // Pełna ścieżka: /profile/change-password
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  ),
],
```

### Tabela tras

| Ścieżka | Ekran | Opis | Wymaga auth |
|---------|-------|------|-------------|
| `/auth` | AuthScreen | Logowanie/rejestracja | ❌ |
| `/` | HomeScreen | Dashboard | ✅ |
| `/add-trip` | NewTripScreen | Tworzenie podróży | ✅ |
| `/my-trips` | MyTripsScreen | Lista podróży | ✅ |
| `/friends` | FriendsScreen | Znajomi | ✅ |
| `/statistics` | StatisticsScreen | Statystyki | ✅ |
| `/profile` | ProfileScreen | Profil | ✅ |
| `/profile/edit` | EditProfileScreen | Edycja profilu | ✅ |
| `/profile/change-password` | ChangePasswordScreen | Zmiana hasła | ✅ |

---

## Użycie w aplikacji

### Konfiguracja MaterialApp

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,  // GoRouter configuration
    );
  }
}
```

### Nawigacja do ścieżki

```dart
// Podstawowa nawigacja
context.go('/my-trips');

// Lub przez GoRouter
GoRouter.of(context).go('/my-trips');

// Z extension method
context.push('/add-trip');
```

### Różnica między go() i push()

```dart
// go() - zastępuje całą historię nawigacji
context.go('/my-trips');
// Stack: [/my-trips]

// push() - dodaje do stosu nawigacji
context.push('/add-trip');
// Stack: [/my-trips, /add-trip]
```

### Powrót

```dart
// Wstecz o jeden ekran
context.pop();

// Lub
Navigator.of(context).pop();

// Sprawdzenie czy można wrócić
if (context.canPop()) {
  context.pop();
} else {
  context.go('/');
}
```

---

## Przekazywanie parametrów

### Path parameters

```dart
// Definicja
GoRoute(
  path: '/trip/:tripId',
  builder: (context, state) {
    final tripId = state.pathParameters['tripId']!;
    return TripDetailsScreen(tripId: tripId);
  },
),

// Użycie
context.go('/trip/abc123');
```

### Query parameters

```dart
// Definicja
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    return SearchScreen(query: query);
  },
),

// Użycie
context.go('/search?q=paris');
```

### Extra (obiekty)

```dart
// Nawigacja z obiektem
context.push('/trip-details', extra: trip);

// Odbiór
GoRoute(
  path: '/trip-details',
  builder: (context, state) {
    final trip = state.extra as Trip;
    return TripDetailsScreen(trip: trip);
  },
),
```

---

## Szuflada nawigacyjna (Drawer)

**Lokalizacja:** `lib/core/widgets/drawer/`

### Struktura

```dart
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Nagłówek z avatarem użytkownika
          DrawerHeader(
            child: UserInfo(),
          ),

          // Elementy menu
          DrawerMenuItem(
            icon: Icons.home,
            title: 'Strona główna',
            onTap: () => context.go('/'),
          ),
          DrawerMenuItem(
            icon: Icons.map,
            title: 'Moje podróże',
            onTap: () => context.go('/my-trips'),
          ),
          DrawerMenuItem(
            icon: Icons.people,
            title: 'Znajomi',
            onTap: () => context.go('/friends'),
          ),
          DrawerMenuItem(
            icon: Icons.bar_chart,
            title: 'Statystyki',
            onTap: () => context.go('/statistics'),
          ),
          DrawerMenuItem(
            icon: Icons.person,
            title: 'Profil',
            onTap: () => context.go('/profile'),
          ),

          const Divider(),

          // Wylogowanie
          DrawerLogoutItem(),
        ],
      ),
    );
  }
}
```

### DrawerMenuItem

```dart
class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);  // Zamknij drawer
        onTap();
      },
    );
  }
}
```

### DrawerLogoutItem

```dart
class DrawerLogoutItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
      onTap: () async {
        Navigator.pop(context);
        await FirebaseAuth.instance.signOut();
        // GoRouter automatycznie przekieruje do /auth
      },
    );
  }
}
```

---

## Deep Linking

GoRouter automatycznie obsługuje deep linking.

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<activity ...>
  <intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
      android:scheme="tripplanner"
      android:host="app"/>
  </intent-filter>
</activity>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>tripplanner</string>
    </array>
  </dict>
</array>
```

### Przykłady deep links

```
tripplanner://app/my-trips
tripplanner://app/trip/abc123
tripplanner://app/profile
```

---

## Animacje przejść

### Niestandardowa animacja

```dart
GoRoute(
  path: '/add-trip',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: const NewTripScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  },
),
```

### Fade transition

```dart
pageBuilder: (context, state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: const MyScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
},
```

---

## Obsługa błędów (404)

```dart
final appRouter = GoRouter(
  // ... inne opcje
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Nie znaleziono strony'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Wróć do strony głównej'),
            ),
          ],
        ),
      ),
    );
  },
);
```

---

## Nawigacja programowa

### Sprawdzenie aktualnej lokalizacji

```dart
final currentLocation = GoRouterState.of(context).matchedLocation;

if (currentLocation == '/my-trips') {
  // Jesteśmy na liście podróży
}
```

### Nawigacja warunkowa

```dart
void navigateToTrip(String tripId) {
  if (tripId.isEmpty) {
    context.go('/my-trips');
  } else {
    context.go('/trip/$tripId');
  }
}
```

### Nawigacja z wynikiem

```dart
// Ekran A - wysłanie
final result = await context.push<bool>('/confirm-delete');
if (result == true) {
  // Użytkownik potwierdził
}

// Ekran B - zwrócenie wyniku
context.pop(true);
```
