# AGENTS.md

Compact guidance for agent sessions.

## Commands

```bash
flutter run                                          # development
flutter build apk --release                          # release build
flutter analyze                                      # lint
```

## Architecture

- **State:** Riverpod (StreamProviders for real-time Firestore)
- **Backend:** Firebase Auth + Firestore
- **Models:** `AppUser`, `FamilyGroup`, `ShoppingItem`

## Key files

- `lib/services/firebase_service.dart` — all Firebase calls
- `lib/providers/providers.dart` — Riverpod providers
- `lib/screens/auth_screen.dart` — login + auth gate
- `lib/screens/group_detail_screen.dart` — main shopping list UI

## Setup needed

- `google-services.json` in `android/app/`
- Firebase Phone Auth + Firestore enabled
