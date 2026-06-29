#!/system/bin/sh

DATA_DIR=/data/adb/zeroclaw
MODULE_DIR=/data/adb/modules/zeroclaw
BIN=$MODULE_DIR/system/bin/zeroclaw
PID_FILE=$DATA_DIR/zeroclaw.pid
STATE_FILE=$DATA_DIR/state/daemon_state.json
LOG_FILE=/data/local/tmp/zeroclaw/zeroclaw.log
URL=http://127.0.0.1:42617/health

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
GRAY='\033[90m'

ok() { printf '%b\n' "${GREEN}✓${RESET} $*"; }
warn() { printf '%b\n' "${YELLOW}⚠${RESET} $*"; }
fail() { printf '%b\n' "${RED}✗${RESET} $*"; }
info() { printf '%b\n' "${CYAN}›${RESET} $*"; }

printf '%b\n' "${BOLD}${CYAN}ZeroClaw Health Check${RESET}"
printf '%b\n' "${GRAY}$(date)${RESET}"
echo

if [ ! -x "$BIN" ]; then
  fail "binary missing: $BIN"
  exit 1
fi
ok "binary installed: $($BIN --version 2>/dev/null || echo unknown)"

pid=''
if [ -f "$PID_FILE" ]; then
  pid=$(cat "$PID_FILE" 2>/dev/null || true)
fi
if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
  ok "process running: pid $pid"
else
  fail "process not running"
fi

if ss -ltn 2>/dev/null | grep -q '127.0.0.1:42617'; then
  ok "dashboard port listening: 127.0.0.1:42617"
else
  fail "dashboard port not listening: 127.0.0.1:42617"
fi

health=$(curl -sS --max-time 5 "$URL" 2>/dev/null || true)
if printf '%s' "$health" | grep -q '"status":"ok"'; then
  ok "gateway health: ok"
elif [ -n "$health" ]; then
  warn "gateway health returned non-ok response"
  printf '%s\n' "$health" | head -3
else
  fail "gateway health unreachable: $URL"
fi

if [ -f "$STATE_FILE" ]; then
  if grep -q '"daemon"' "$STATE_FILE" && grep -q '"status": "ok"' "$STATE_FILE"; then
    ok "daemon state file: ok"
  else
    warn "daemon state file exists but contains warnings/errors"
  fi
  info "state: $STATE_FILE"
else
  fail "daemon state file missing: $STATE_FILE"
fi

echo
printf '%b\n' "${BOLD}Dashboard${RESET}"
info "http://127.0.0.1:42617/"

echo
printf '%b\n' "${BOLD}Recent Log${RESET}"
if [ -f "$LOG_FILE" ]; then
  tail -20 "$LOG_FILE"
else
  warn "log not found: $LOG_FILE"
fi
