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

## Mock data & simulated conditions

All data is read from `assets/mock_data/taskflow_mock_data.json` through repositories — never directly from widgets.

### Artificial delay

Every simulated network call waits **300–700 ms** so loading states are visible.

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
docs/             architecture notes
```

## Known limitations

- No real backend; `dio` / `retrofit` are listed for future API swap but not wired yet
- Register creates a local session only (not persisted to JSON file)
- Offline cache stores org-scoped projects/tasks in SharedPreferences (not a full offline-first sync queue)
- Release APK uses debug signing config (fine for assignment demo)
- Screen recording and GitHub submission are manual steps outside the repo

## License

Assignment/demo project — not published to pub.dev.
