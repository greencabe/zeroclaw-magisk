#!/system/bin/sh

URL=${ZEROCLAW_DASHBOARD_URL:-http://127.0.0.1:42617/}

am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1 || {
  echo "ZeroClaw dashboard: $URL"
  exit 1
}
