#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
TARGET=${TARGET:-aarch64-linux-android}
PROFILE=${PROFILE:-release}
FEATURES=${FEATURES:-default,embedded-web}
MODULE_DIR="$ROOT/target/magisk/zeroclaw"
OUT_DIR="$ROOT/dist/magisk"
BIN="$ROOT/target/$TARGET/$PROFILE/zeroclaw"

version=$(awk -F '"' '/^version = / { print $2; exit }' "$ROOT/Cargo.toml")
version_code=$(printf '%s' "$version" | awk -F. '{ printf "%d%02d%02d", $1, $2, $3 }')

if [ "$TARGET" = "aarch64-linux-android" ] && command -v aarch64-linux-android-clang >/dev/null 2>&1; then
  export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=${CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER:-aarch64-linux-android-clang}
fi

if command -v npm >/dev/null 2>&1; then
  (cd "$ROOT/web" && npm ci)
  cargo run -p xtask --bin web -- gen-api
  (cd "$ROOT/web" && npm run build)
else
  echo "npm missing; using existing web/dist if present" >&2
fi

if [ ! -f "$ROOT/web/dist/index.html" ]; then
  echo "web/dist/index.html missing; install Node/npm and build dashboard first" >&2
  exit 1
fi

rustup target add "$TARGET" >/dev/null 2>&1 || true
cargo build --release --target "$TARGET" --features "$FEATURES" --bin zeroclaw

rm -rf "$MODULE_DIR"
mkdir -p "$MODULE_DIR/system/bin" "$OUT_DIR"
cp "$BIN" "$MODULE_DIR/system/bin/zeroclaw"
sed \
  -e "s/@VERSION@/$version/g" \
  -e "s/@VERSION_CODE@/$version_code/g" \
  "$ROOT/packaging/magisk/module.prop.in" > "$MODULE_DIR/module.prop"
cp "$ROOT/packaging/magisk/customize.sh" "$MODULE_DIR/customize.sh"
cp "$ROOT/packaging/magisk/service.sh" "$MODULE_DIR/service.sh"
cp "$ROOT/packaging/magisk/post-fs-data.sh" "$MODULE_DIR/post-fs-data.sh"
cp "$ROOT/packaging/magisk/uninstall.sh" "$MODULE_DIR/uninstall.sh"
cp "$ROOT/packaging/magisk/action.sh" "$MODULE_DIR/action.sh"
cp -a "$ROOT/packaging/magisk/webroot" "$MODULE_DIR/webroot"
cp "$ROOT/packaging/termux/zeroclaw" "$MODULE_DIR/termux-wrapper.sh"
chmod 0755 "$MODULE_DIR/system/bin/zeroclaw" "$MODULE_DIR/customize.sh" "$MODULE_DIR/service.sh" "$MODULE_DIR/post-fs-data.sh" "$MODULE_DIR/uninstall.sh" "$MODULE_DIR/action.sh" "$MODULE_DIR/termux-wrapper.sh"

( cd "$MODULE_DIR" && zip -r9 "$OUT_DIR/zeroclaw-magisk.zip" . )

echo "$OUT_DIR/zeroclaw-magisk.zip"
