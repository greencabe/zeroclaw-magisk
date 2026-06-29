#!/system/bin/sh

BIN_DIR=/data/adb/zeroclaw/bin
TERMUX_BIN=/data/data/com.termux/files/usr/bin

mkdir -p "$BIN_DIR"

for tool in git rg python python3 node npm npx curl wget tar unzip zip sh; do
  if [ -x "$TERMUX_BIN/$tool" ]; then
    ln -sf "$TERMUX_BIN/$tool" "$BIN_DIR/$tool"
  fi
done

chmod 0755 "$BIN_DIR"
