# flutter_assignment_group

A new Flutter project.

## Firebase Firestore setup

- This project now initializes Firebase on Android/Web at app startup.
- Sample collections and documents are seeded automatically once (see `lib/data/firestore_seeder.dart`).

### Seed data by running the app

```bash
flutter run
```

Collections created by seed:

- `users`
- `assets`
- `asset_types`
- `locations`
- `asset_logs`
- `maintenance_tickets`

### Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Configured files:

- `firestore.rules`
- `firestore.indexes.json`

> `firestore.rules` is currently configured for development (`allow read, write: if true`).
> Update rules before production.
