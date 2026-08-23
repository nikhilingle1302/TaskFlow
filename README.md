# TaskFlow

TaskFlow is a Flutter project-management app built for a technical assignment. It uses local mock JSON data, simulated JWT authentication, and a layered architecture so the data layer could be swapped for real HTTP later.

## Requirements

- Flutter 3.x (SDK `^3.6.0`)
- Dart 3.x

## Setup

```bash
flutter pub get
flutter run
```

## Test credentials

Password for all accounts: `Password123!`

| Email | Organization | Role |
|-------|--------------|------|
| `ava.admin@nimbusdigital.test` | Nimbus Digital | org_admin |
| `marcus.member@nimbusdigital.test` | Nimbus Digital | member |
| `daniel.admin@harborlightstudios.test` | Harborlight Studios | org_admin |
| `elena.member@harborlightstudios.test` | Harborlight Studios | member |

## Commands

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

Integration tests (requires a device or emulator):

```bash
flutter test integration_test/app_flow_test.dart
```

## Architecture

```
UI (pages/widgets)
  → Bloc/Cubit
    → Repository (interface)
      → MockDataStore + OfflineCache
        → assets/mock_data/taskflow_mock_data.json
```

- **State management:** `flutter_bloc` (AuthBloc + feature Cubits)
- **DI:** `get_it`
- **Navigation:** `go_router`
- **Secure session:** `flutter_secure_storage`
- **Settings / cache:** `shared_preferences`

See [docs/architecture.md](docs/architecture.md) for more detail.

## Auth / token flow (simulated)

1. Login validates credentials from `auth_mock` in the mock JSON (via the auth repository — not hardcoded in UI).
2. On success, access + refresh tokens and session metadata are stored in **secure storage** (passwords are never stored).
3. Access tokens expire after **15 minutes** (`access_token_expires_in_seconds = 900`).
4. On app launch, splash restores the session; if access is expired but refresh is valid, a **mock refresh** issues a new access token.
5. Logout clears secure storage and blocks authenticated routes.

## Mock data & simulated conditions

All data is read from `assets/mock_data/taskflow_mock_data.json` through repositories — never directly from widgets.

### Artificial delay

Every simulated network call waits **100–250 ms** so loading states are still visible without feeling slow.

### Offline mode

1. Sign in and open **Profile**
2. Turn on **Simulate offline mode**
3. Pull to refresh on Home, Projects, or Tasks

**Expected behavior:**
- Already loaded project/task lists stay visible
- Banner shows last sync time
- Create/edit/delete actions fail with an offline message
- Data is restored from local cache after app restart while offline

### Simulate network error

1. Open **Profile**
2. Turn on **Simulate network error**
3. Refresh any main list screen

Shows a retryable error state.

### Simulated 404 (task not found)

Open task detail for ID `task_force_404` (via deep link or by temporarily using that ID in code during review).

### Simulated timeout (project load)

Load project detail for ID `proj_force_timeout`.

## Folder structure

```
lib/
  core/           theme, router, errors, mock store, storage
  features/       auth, home, projects, tasks, notifications, profile
  shared/         reusable widgets
  injection.dart  GetIt setup
test/             unit + widget tests
integration_test/ end-to-end flows
assets/mock_data/ bundled JSON
docs/             architecture notes, recording + submission checklists
```

## Screen recording & submission

- APK Link: https://drive.google.com/file/d/1ZU_v19pfUl-PXBjFzZd0Wg1l3pjLjcvf/view
- Demo Video: https://drive.google.com/file/d/1b2XW8u745NabqZ5CZ-GiYjdgJolCKs7a/view?usp=drive_link

## Known limitations

- No real backend; `dio` / `retrofit` are listed for future API swap but not wired yet
- Register creates a local session only (not persisted to JSON file)
- Offline cache stores org-scoped projects/tasks in SharedPreferences (not a full offline-first sync queue)
- Release APK uses debug signing config (fine for assignment demo)


## License

Assignment/demo project — not published to pub.dev.
