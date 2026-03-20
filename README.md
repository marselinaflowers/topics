# topics

## commit: auth flow and username locking

This commit adds the current auth flow and username reservation setup.

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

- `lib/home_screen.dart`
	- shows a basic signed-in screen with sign-out

- `lib/services/username_service.dart`
	- validates usernames for length, characters, and slur filtering
	- reserves unique lowercase username keys in Firestore

- `lib/services/alias_engine.dart`
	- generates fallback aliases

- `lib/services/slur_filter.dart`
	- blocks slur-based usernames

- `firestore.rules`
	- limits Firestore usage to `usernames/{normalizedName}` locks

- `firebase.json`
	- points Firebase to `firestore.rules`

### public repo note

This repository is intended to be used with each developer's own Firebase project.
Setup and clone instructions will be added in the final README version.
