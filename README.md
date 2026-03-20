# topics

## commit: auth-only usernames

This commit simplifies usernames to use only the Firebase Auth user profile.

### code in this commit

- `lib/main.dart`
	- initializes Firebase and starts the app with `AuthGate`

- `lib/auth_flow.dart`
	- keeps the auth gate and routes between `AuthScreen` and `HomeScreen`
	- uses `FirebaseAuth.instance.userChanges()` for post-login transition

- `lib/auth_screen.dart`
	- adds anonymous sign-in with username entry
	- shows the generated alias dialog with `Cancel`, `Change`, and `Proceed`
	- validates usernames and updates Firebase Auth `displayName`
	- uses Firebase Auth's own error text when auth operations fail

- `lib/home_screen.dart`
	- shows a basic signed-in screen with sign-out

- `lib/services/username_service.dart`
	- validates usernames for length, characters, and slur filtering

- `lib/services/alias_engine.dart`
	- generates fallback aliases

- `lib/services/slur_filter.dart`
	- blocks slur-based usernames

- `firebase.json`
	- keeps the FlutterFire project config only

- `pubspec.yaml`
	- includes only the currently used Firebase packages

### public repo note

This repository is intended to be used with each developer's own Firebase project.
Setup and clone instructions will be added in the final README version.
