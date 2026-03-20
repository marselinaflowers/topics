# topics

## commit: initialize firebase on app startup

This commit adds Firebase initialization to the Flutter app entrypoint.

### code in this commit

- `lib/main.dart`
	- imports `firebase_core` and `firebase_options.dart`
	- updates `main()` to `Future<void> main() async`
	- calls `WidgetsFlutterBinding.ensureInitialized()`
	- initializes Firebase with `DefaultFirebaseOptions.currentPlatform`
	- runs `MainApp` after Firebase init completes
- app UI remains a minimal `Hello World!` screen

### public repo note

This repository is intended to be used with each developer's own Firebase project.
Setup and clone instructions will be added in the final README version.
