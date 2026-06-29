#!/system/bin/sh

BIN_DIR=/data/adb/zeroclaw/bin
TERMUX_BIN=/data/data/com.termux/files/usr/bin

mkdir -p "$BIN_DIR"

if [ -d "$TERMUX_BIN" ]; then
  find "$TERMUX_BIN" -maxdepth 1 \( -type f -o -type l \) 2>/dev/null | while IFS= read -r tool; do
    name=${tool##*/}
    case "$name" in
      ''|.*|su|sudo|login|run-as)
        continue
        ;;
    esac
    if [ -x "$tool" ]; then
      ln -sf "$tool" "$BIN_DIR/$name"
    fi
  done
fi

chmod 0755 "$BIN_DIR"
