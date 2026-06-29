#!/system/bin/sh

MODDIR=${0%/*}
DATA_DIR=/data/adb/zeroclaw
LOG_DIR=/data/local/tmp/zeroclaw
LOG_FILE=$LOG_DIR/zeroclaw.log
PID_FILE=$DATA_DIR/zeroclaw.pid
DISABLE_FILE=$DATA_DIR/disable-autostart
BIN=$MODDIR/system/bin/zeroclaw
MAX_LOG_BYTES=1048576

export HOME=$DATA_DIR
export PATH=/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin:/data/adb/ksu/bin:$PATH

mkdir -p "$DATA_DIR" "$LOG_DIR"

until [ "$(getprop sys.boot_completed 2>/dev/null)" = "1" ]; do
  sleep 5
done

if [ -f "$DISABLE_FILE" ]; then
  echo "$(date): autostart disabled by $DISABLE_FILE" >> "$LOG_FILE"
  exit 0
fi

if [ -f "$PID_FILE" ]; then
  old_pid=$(cat "$PID_FILE" 2>/dev/null || true)
  if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
    echo "$(date): zeroclaw already running as pid $old_pid" >> "$LOG_FILE"
    exit 0
  fi
fi

rotate_log() {
  size=$(wc -c < "$LOG_FILE" 2>/dev/null || echo 0)
  if [ "$size" -gt "$MAX_LOG_BYTES" ]; then
    mv "$LOG_FILE" "$LOG_FILE.1" 2>/dev/null || true
  fi
}

backoff=5
while [ ! -f "$DISABLE_FILE" ]; do
  rotate_log
  echo "$(date): starting zeroclaw daemon via $BIN" >> "$LOG_FILE"
  "$BIN" --config-dir "$DATA_DIR" daemon >> "$LOG_FILE" 2>&1 &
  child=$!
  echo "$child" > "$PID_FILE"
  wait "$child"
  status=$?
  rm -f "$PID_FILE"
  echo "$(date): zeroclaw exited status=$status; restart in ${backoff}s" >> "$LOG_FILE"
  sleep "$backoff"
  if [ "$backoff" -lt 60 ]; then
    backoff=$((backoff * 2))
    if [ "$backoff" -gt 60 ]; then
      backoff=60
    fi
  fi
done

echo "$(date): autostart disabled; watchdog stopped" >> "$LOG_FILE"
