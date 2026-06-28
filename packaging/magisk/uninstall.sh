#!/system/bin/sh

pid_file=/data/adb/zeroclaw/zeroclaw.pid
pid=$(cat "$pid_file" 2>/dev/null || true)
if [ -n "$pid" ]; then
  kill "$pid" 2>/dev/null || true
fi
rm -f "$pid_file"
rm -rf /data/local/tmp/zeroclaw
