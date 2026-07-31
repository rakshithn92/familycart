# FamilyCart

Shared real-time shopping list for family — plan orders together, skip the junk.

## The Problem

Need a ₹50 item? Delivery fee is ₹40, minimum order is ₹200. So you add random chips, gum, and weird sauce you'll never use. **Wasteful spending disguised as "saving on delivery."**

## The Solution

FamilyCart lets your family maintain a shared shopping list in real-time. When someone's about to place an order, they pick items from the list instead of impulse-buying junk to fill the cart.

## Features

- **Real-time sync** — add an item, everyone sees it instantly
- **Family groups** — create a group, share the invite code
- **Categories** — Groceries, Snacks, Beverages, Household, etc.
- **Quantity tracking** — "we need 3 packs of milk"
- **Status flow** — Pending → In Cart → Bought
- **Notes** — add details per item ("blue bottle, not green")

## Requirements

- Any **Android device**
- A **Firebase project** (free tier works fine)

## Setup

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Add an Android app with package name `com.familycart.app`
3. Download `google-services.json` and place it in `android/app/`
4. Enable **Phone Authentication** and **Firestore Database** in Firebase Console

## Run

```bash
flutter pub get
flutter run
```

## Build

```bash
flutter build apk --release
```
