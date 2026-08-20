#!/bin/bash
# Deploy the Flutter fitness app from the GitHub repo.
# Usage:
#   ./deploy.sh           # pull + build web only (skips if already up to date)
#   ./deploy.sh force     # always pull + rebuild web
#   ./deploy.sh apk       # pull + build web + build APK
set -euo pipefail
export HOME="${HOME:-/root}"

export PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export FLUTTER_ALLOW_ROOT=1
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

APP_DIR=/opt/fitness-flutter
LOG=/var/log/fitness-flutter-deploy.log

log() { echo "[$(date '+%F %T')] $*"; }

FORCE=0
BUILD_APK=0
for arg in "$@"; do
  [ "$arg" = "force" ] && FORCE=1
  [ "$arg" = "apk" ] && BUILD_APK=1
done

cd "$APP_DIR"

log "== Pulling latest from origin/main =="
git fetch origin main
if [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] && [ "$FORCE" = "0" ]; then
  log "Already up to date at $(git rev-parse --short HEAD)."
  if [ "$BUILD_APK" = "0" ]; then
    log "Nothing to deploy."
    exit 0
  fi
else
  git reset --hard origin/main
  log "Updated to $(git rev-parse --short HEAD)."
fi

log "== flutter pub get =="
flutter pub get

log "== Building web (release) =="
flutter build web --release --no-tree-shake-icons
log "Web build ready: $APP_DIR/build/web"

if [ "$BUILD_APK" = "1" ]; then
  log "== Building APK (release) =="
  flutter build apk --release
  log "APK ready: $APP_DIR/build/app/outputs/flutter-apk/app-release.apk"
fi

log "== Done. Live at https://Fitness.hftv.qzz.io/ =="