# FamilyCart

Shared real-time shopping list for family.

## Commands

```bash
flutter run                                          # development
flutter build apk --release                          # release build
flutter analyze                                      # lint
```

## Architecture

**State:** Riverpod (StreamProviders for real-time Firestore data)
**Backend:** Firebase Auth + Firestore
**Models:** `AppUser`, `FamilyGroup`, `ShoppingItem`

### Data flow

- `auth_screen` → Firebase Auth → `AuthGate` routes to `HomeScreen`
- `HomeScreen` → reads user profile → streams user's groups from Firestore
- `GroupDetailScreen` → streams items from Firestore subcollection
- Adding/toggling items writes directly to Firestore → all connected devices update in real-time

### Providers

- `authStateProvider` — Firebase auth stream
- `userProfileProvider` — user document stream
- `userGroupsProvider` — groups stream (by groupIds list)
- `groupProvider` — single group stream
- `itemsProvider` — items stream (by groupId)

## Setup

1. Create Firebase project, add Android app (`com.familycart.app`)
2. Place `google-services.json` in `android/app/`
3. Enable Phone Auth + Firestore in Firebase Console
