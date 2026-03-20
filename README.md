# topics

## commit: create topic and feed

This commit adds the main product feature: users can create conversation topics and view a live feed.

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
	- keeps slur filtering in username validation

- `lib/home_screen.dart`
	- shows a Firestore-backed topic feed (`topics` collection)
	- adds a create-topic dialog and post action
	- keeps sign-out from the app bar

- `lib/services/username_service.dart`
	- validates usernames for length, characters, and slur filtering

- `lib/services/topic_service.dart`
	- creates topics up to 50 characters with author info and server timestamp
	- provides a live stream query for feed retrieval

- `lib/services/alias_engine.dart`
	- generates fallback aliases

- `lib/services/slur_filter.dart`
	- blocks slur-based usernames

- `firebase.json`
	- points Firestore to `firestore.rules`

- `pubspec.yaml`
	- includes `cloud_firestore` for topic feed storage and reads

- `firestore.rules`
	- allows public read of topics feed
	- allows authenticated creation of topics with a 50-character text limit and schema checks
	- blocks updates/deletes and all other document paths by default

### public repo note

This repository is intended to be used with each developer's own Firebase project.
Setup and clone instructions will be added in the final README version.
