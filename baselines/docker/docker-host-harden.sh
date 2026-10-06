#!/usr/bin/env bash
# docker-host-harden.sh — remediate file-level Container Platform SRG controls (v0.1.1)
# DRY-RUN default: prints keys that would change; changes NOTHING. --apply merges the
# hardening plan into daemon.json (backs it up as .stig-backup). Never restarts docker.
# Usage: sudo ./docker-host-harden.sh [--apply]
set -u
VERSION="0.1.1"
APPLY=0; [[ "${1:-}" == "--apply" ]] && APPLY=1
DAEMON_JSON="${DOCKER_DAEMON_JSON:-/etc/docker/daemon.json}"
ROWS=(); CHANGES=0; WOULD=0
note() { printf '%s\n' "$*" >&2; }
row() { ROWS+=("$1"); }
has() { command -v "$1" >/dev/null 2>&1; }

if [ "$APPLY" = 1 ] && [ "$(id -u)" != "0" ]; then
  note "ERROR: --apply requires root; rerun with sudo. (Nothing was changed.)"
  exit 2
fi
if ! has docker && [ ! -f "$DAEMON_JSON" ]; then
  note "docker absent and no daemon.json — nothing to do"
  exit 0
fi

PLAN='{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"3"},"live-restore":true}'

run_py() { DAEMON_JSON="$DAEMON_JSON" PLAN="$PLAN" python3 - "$1" <<'PY'
import json, os, sys
mode = sys.argv[1]
path = os.environ["DAEMON_JSON"]
plan = json.loads(os.environ["PLAN"])
try:
    with open(path) as f:
        cur = json.load(f)
except Exception:
    cur = {}
changed = [k for k, want in plan.items() if cur.get(k) != want]
if mode == "apply":
    for k in changed:
        cur[k] = plan[k]
    with open(path, "w") as f:
        f.write(json.dumps(cur, indent=2) + "\n")
print(",".join(changed))
PY
}

if [ "$APPLY" = 1 ]; then
  if [ ! -f "$DAEMON_JSON" ]; then
    note "no daemon.json at $DAEMON_JSON — nothing written (create the file first if intended)"
    exit 1
  fi
  cp "$DAEMON_JSON" "$DAEMON_JSON.stig-backup"
  OUT=$(run_py apply)
  for k in $(echo "$OUT" | tr ',' '\n'); do
    [ -n "$k" ] && { row "FIXED|daemon.json|ensure $k|$(basename "$DAEMON_JSON")"; ((CHANGES++)); }
  done
  note "NOTE: restart docker to load the new daemon.json (not done by this script)"
else
  OUT=$(run_py dry)
  for k in $(echo "$OUT" | tr ',' '\n'); do
    [ -n "$k" ] && { row "WOULD|daemon.json|ensure $k|$DAEMON_JSON"; ((WOULD++)); }
  done
fi

for r in "${ROWS[@]}"; do printf '%s\n' "$r"; done
note "DOCKER-HARDEN-SUMMARY applied=$CHANGES would=$WOULD (v$VERSION$([ "$APPLY" = 1 ] && echo ' — restart docker separately'))"
exit 0