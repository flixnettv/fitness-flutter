# FitPro — Flutter Fitness App

FitPro is a bilingual (Arabic / English, RTL-ready) fitness tracking application built with **Flutter**, powered by the **wger** workout-manager REST API. It runs as a web app (PWA) and as an Android APK from the same codebase.

## Live

| Resource | URL |
|---|---|
| Web app | https://Fitness.hftv.qzz.io/ |
| Stable app link | https://Fitness.hftv.qzz.io/app |
| Android APK download | https://Fitness.hftv.qzz.io/apk/app-release.apk |
| REST API | https://Fitness.hftv.qzz.io/api/v2/ |

## Features

- Login / registration against the wger backend (JWT via allauth headless).
- Home dashboard with today's target and quick stats.
- Exercise browser (872 exercises) with detail view, category and images.
- Routines / workout planning.
- Measurements: manual entry, measurement categories and history charts (fl_chart).
- Weight log and body composition tracking.
- Water intake tracking.
- Device sync (Health Connect / Apple Health + BLE wearables) via `health` and `flutter_blue_plus`.
- Dark mode + Arabic/English language switch (in-app).
- "Download App" button in the profile screen linking to the current APK.
- PWA support (manifest + service worker).

## Architecture

```
Flutter app (web + Android)
        │  REST (Dio, JWT)
        ▼
wger server (Django REST API, Docker Compose)
        ▼
PostgreSQL 15
```

- Frontend: `lib/` — pages, services, theme, l10n (see structure below).
- Backend: wger running in Docker on the VPS (managed by Coolify).
- Nginx (wger container) serves the Flutter web build from `/wger/flutter` at `/` and `/app`, proxies `/api/` and `/allauth/` to wger, and exposes the deploy webhook at `/deploy-hook`.

```
lib/
├── api/            # WgerApiClient (Dio, auth, endpoints)
├── l10n/           # AppStrings (ar/en maps) + t() helper
├── models/         # Exercise, etc.
├── pages/          # home, exercises, routines, measurements, devices, login, register, profile, today target
├── services/       # device_sync_service, api
├── theme/          # AppTheme (light/dark)
└── widgets/        # charts, water intake timeline
```

## Deployment

Deployment is fully server-side and self-contained on the VPS. Pushing to `main` on GitHub triggers an automatic rebuild and publish.

### Auto-deploy (webhook)

1. GitHub sends a `push` event to `https://Fitness.hftv.qzz.io/deploy-hook` (HMAC-signed with `X-Hub-Signature-256`).
2. The receiver (`/opt/fitness-deploy/webhook.py`, systemd unit `deploy-webhook.service`) validates the signature and runs `deploy.sh`.
3. `deploy.sh` (committed in this repo) pulls `origin/main`, runs `flutter pub get`, and builds:
   - `flutter build web --release` → served instantly from `/wger/flutter` (ro bind mount).
   - If `apk` arg is given: `flutter build apk --release` and publishes the APK to `build/web/apk/` for download.

```bash
./deploy.sh           # pull + build web (skips if already up to date)
./deploy.sh force     # always rebuild web
./deploy.sh apk       # also build + publish the Android APK
./deploy.sh force apk # full rebuild (web + APK)
```

> Note: pushing from the server itself makes `deploy.sh` see HEAD == origin/main, so a forced rebuild (`./deploy.sh force apk`) is used in that case.

### Build environment (VPS)

- Flutter 3.47.0 at `/opt/flutter` (`FLUTTER_ALLOW_ROOT=1`)
- Android SDK at `/opt/android-sdk`, JDK 21
- App `minSdk` 26 (required by the `health` plugin), release signed with the debug key
- Deploy log: `/var/log/fitness-flutter-deploy.log`

### Manual build

```bash
export PATH=/opt/flutter/bin:$PATH FLUTTER_ALLOW_ROOT=1
flutter pub get
flutter build web --release
flutter build apk --release
```

## Backups

Daily at 03:20 (cron, `/etc/cron.d/wger-backup`) the script `/opt/wger-backup/backup.sh`:

- Dumps the wger PostgreSQL database (`pg_dump` → gzip) into `/opt/wger-backup/`.
- Copies server config (`/opt/wger/nginx.conf`, `/opt/fitness-deploy/`, `deploy.sh`).
- Keeps the newest 14 backups, prunes older ones.

## Development

```bash
flutter pub get
flutter test        # currently verifies ar/en string key parity
flutter analyze     # target: no warnings/errors (style lints optional)
flutter run         # device/emulator
```

The app talks to the wger API; point the base URL in `lib/api/wger_api_client.dart` at your instance for local development.