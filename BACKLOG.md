# Backlog

Picked-up-later items. Newest on top.

## Features

- **Pro tier / payment rail (offline license key).** The MRR blocker — app has
  no monetization surface today. Design settled, build deferred. On-brand for a
  no-server/privacy-first app: checkout on Gumroad/Stripe (no payment code, no
  PCI), app verifies a **signed license key offline** (no phone-home, no secret
  in the APK). Shape:
  1. Add `cryptography` dep (pure-Dart Ed25519). HMAC is wrong here — a shared
     secret would be extractable from the APK; asymmetric verify is the money-
     path-correct choice.
  2. `tool/sign_license.dart` (seller-side): `genkey` mints an Ed25519 keypair;
     `sign <privB64> <buyerId> [expEpochMs]` mints a key to email the buyer.
     Key format: `base64Url(payload).base64Url(sig)`, payload = `"id|exp"`
     (empty exp = perpetual; epoch-ms = subscription period for recurring MRR).
  3. Bake the PUBLIC key into a `LicenseService` (or `--dart-define=LICENSE_PUBKEY`).
     Keep PRIVATE key out of the repo.
  4. `LicenseService`: pure `verifyLicense(key, pubKeyB64, {now})` (unit-test:
     valid / tampered / expired), `activate(key)` + `isPro()` persisted via the
     existing `DbService.getSetting`/`setSetting`. Add an `isProProvider`.
  5. Gate one real Pro feature first. Explore ("generate new concepts from this
     node", uses Gemini) is the natural premium hook — free users get the base
     map, Pro gets Explore + (later) larger vaults. Free path shows an upgrade
     dialog with the buy link (`url_launcher` already a dep) + a license-key
     field.
  Open question before building: offline keys can't be revoked and expiry checks
  the device clock (spoofable) — fine for indie scale, but it means recurring
  subscriptions need re-issued keys monthly (clunky). Decide perpetual one-time
  (~$29–49, simpler) vs. dated keys vs. eventually Play Billing (true recurring,
  but needs a published app + Play Console setup, untestable locally).

- **Edit a node in-place.** The node detail sheet supports label/summary/
  definition edits today and persists them via `DbService.updateNode`. The
  canvas itself doesn't reflect the edit until the tree is reloaded — wire
  `ref.invalidate(activeTreeProvider)` after save so the card re-renders.
  Low effort; turns the app from a viewer into a tool.

- **Export / import a map as JSON.** Maps live only in on-device SQLite today;
  lose the phone, lose everything. `DbService.saveTree` already round-trips and
  `TreeNode.toMap`/`fromMap` exist, so serialization is `toMap` + `jsonEncode`.
  Gives backup + share in one feature; foundation for sync later. (Note: the
  app already has full-DB export/import via the home screen's backup/restore
  buttons — this item is per-map share.)

## Play Store readiness

### Blocks release

- **Real signing config.** `android/app/build.gradle.kts:29` signs release
  with `signingConfigs.getByName("debug")`. Play Store requires a release keystore
  you control. First step: generate a keystore, wire
  `signingConfig = signingConfigs.create("release")` reading pwd from
  `key.properties` (gitignored).
- **Ship `.aab`, not `.apk`.** Play Store requires App Bundles. Switch to
  `flutter build appbundle --release`.
- **App icon + splash.** Play Store rejects the default Flutter logo icon.
  Use `flutter_launcher_icons` + `flutter_native_splash`.
- **Version code discipline.** Every Play upload needs a monotonic `versionCode` bump.
  Set a real policy in `pubspec.yaml` instead of relying on `flutter.versionCode`.
- **Privacy policy.** Required because the app calls the Gemini API. Must mention
  Google AI Studio as the endpoint.
- **Data safety form + content rating questionnaire.** Required in Play Console
  before publishing. App collects no data; rating will be "Everyone".

### Scale / UX

- **Crash reporting.** Add `firebase_crashlytics` or `sentry_flutter` for
  network/Gemini failures that are hard to reproduce without telemetry.
- **R8 / `minifyEnabled`.** Low priority — shrinks the Java/Kotlin layer but
  not the native libs.
