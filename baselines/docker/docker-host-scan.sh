#!/usr/bin/env bash
# docker-host-scan.sh — read-only Container Platform SRG assessment (v0.1.0)
# Safe any time: changes NOTHING. Run as root on a docker host.
# Usage: sudo ./docker-host-scan.sh [--json]
# Exit code: number of FAIL controls.
set -u
VERSION="0.1.0"
JSON=0; [[ "${1:-}" == "--json" ]] && JSON=1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IGNORE_LIST="$SCRIPT_DIR/ignore_list.yml"
DAEMON_JSON="${DOCKER_DAEMON_JSON:-/etc/docker/daemon.json}"

RESULTS=(); FAILS=0; PASSES=0; SKIPS=0; EXCEPT_COUNT=0

note() { printf '%s\n' "$*" >&2; }
add() { RESULTS+=("$1|$2|$3|$4"); }
pass() { ((PASSES++)); add "PASS" "$1" "${2:-}" ""; }
skip() { ((SKIPS++)); add "SKIP" "$1" "${2:-}" "${3:-not present}"; }
fail() {
  if [ -s "$IGNORE_LIST" ] && grep -q "^$1|" "$IGNORE_LIST" 2>/dev/null; then
    ((EXCEPT_COUNT++))
    local why; why=$(grep "^$1|" "$IGNORE_LIST" 2>/dev/null | head -1 | cut -d'|' -f2)
    add "EXCEPT" "$1" "${2:-}" "excepted: ${why:-see ignore_list}"
  else
    ((FAILS++)); add "FAIL" "$1" "$2" "${3:-}"
  fi
}
has() { command -v "$1" >/dev/null 2>&1; }

if ! has docker; then
  for cid in C-01-socket-perms C-02-remote-api-off C-03-log-rotation C-04-live-restore \
             C-05-socket-userns C-06-no-privileged C-07-no-host-network C-08-no-new-privileges-or-caps; do
    skip "$cid" "docker control" "docker absent"
  done
  skip "C-09-image-provenance-note" "policy note" "docker absent"
  printf '%s\n' "docker absent — all controls SKIP" >&2
  [ "$JSON" = 1 ] && echo '{"tool":"docker-host-scan","version":"0.1.0","pass":0,"fail":0,"skip":9,"except":0,"results":[]}'
  exit 0
fi

# C-01 socket perms
if [ -S /var/run/docker.sock ]; then
  o=$(stat -c '%U:%G' /var/run/docker.sock); p=$(stat -c '%a' /var/run/docker.sock)
  [ "$o" = "root:docker" ] && [ "$p" -le 660 ] 2>/dev/null \
    && pass C-01-socket-perms || fail C-01-socket-perms "$o $p"
else skip C-01-socket-perms "socket path absent"; fi

# C-02 remote API off
DJ=""
[ -f "$DAEMON_JSON" ] && DJ=$(cat "$DAEMON_JSON")
if echo "$DJ" | grep -q '"hosts"\|tcp://'; then
  fail C-02-remote-api-off "daemon.json carries hosts/tcp"
elif ss -ltn 2>/dev/null | grep -qE ':2375|:2376'; then
  fail C-02-remote-api-off "listener on 2375/2376"
else
  pass C-02-remote-api-off
fi

# C-03 log rotation
if echo "$DJ" | grep -q '"max-size"' && echo "$DJ" | grep -q '"max-file"'; then
  pass C-03-log-rotation
else fail C-03-log-rotation "daemon.json lacks log rotation limits"; fi

# C-04 live restore
if echo "$DJ" | grep -q '"live-restore": *true'; then
  pass C-04-live-restore
else fail C-04-live-restore "daemon.json live-restore not true"; fi

# C-05 userns decision (info-level: pass if configured, else info-skip note)
if echo "$DJ" | grep -q '"userns-remap"'; then
  pass C-05-socket-userns
else skip C-05-socket-userns "no userns-remap (document the decision or except)"; fi

# C-06 privileged containers
if [ -n "$(docker ps -q 2>/dev/null)" ]; then
  PRIV=$(docker ps -q | xargs docker inspect -f "{{.Name}}:{{.HostConfig.Privileged}}" 2>/dev/null | grep -E ':true' || true)
  [ -z "$PRIV" ] && pass C-06-no-privileged || fail C-06-no-privileged "privileged: ${PRIV// /; }"
else pass C-06-no-privileged "no containers running"; fi

# C-07 host network containers
HN=""
[ -n "$(docker ps -q 2>/dev/null)" ] && HN=$(docker ps -q | xargs docker inspect -f "{{.Name}}:{{.HostConfig.NetworkMode}}" 2>/dev/null | grep -E ':host' || true)
[ -z "$HN" ] && pass C-07-no-host-network || fail C-07-no-host-network "${HN// /; }"

# C-08 security opts evidence
MISS=""
[ -n "$(docker ps -q 2>/dev/null)" ] && MISS=$(docker ps -q | xargs docker inspect -f "{{.Name}}:{{join .HostConfig.SecurityOpt \",\"}}" 2>/dev/null | grep -vE 'no-new-privileges' || true)
[ -z "$MISS" ] && pass C-08-no-new-privileges-or-caps || fail C-08-no-new-privileges-or-caps "containers without no-new-privileges: ${MISS// /; }"

# C-09 provenance policy note
skip C-09-image-provenance-note "policy row: digest pulls + registry allowlist (see OPT-K17/K20)"

# ---- output ----------------------------------------------------------------
TMPF=$(mktemp); trap 'rm -f "$TMPF"' EXIT
printf '%s\n' "${RESULTS[@]}" > "$TMPF"
if [ "$JSON" = "1" ]; then
  python3 - "$PASSES" "$FAILS" "$SKIPS" "$EXCEPT_COUNT" "$TMPF" <<'PY'
import json, sys
p, f, s, e = map(int, sys.argv[1:5])
rows = []
for ln in open(sys.argv[5]):
    parts = ln.rstrip("\n").split("|", 3)
    if len(parts) >= 3:
        rows.append({"status": parts[0], "id": parts[1], "title": parts[2],
                     "detail": parts[3] if len(parts) > 3 else ""})
print(json.dumps({"tool": "docker-host-scan", "version": "0.1.0",
                  "pass": p, "fail": f, "skip": s, "except": e, "results": rows}))
PY
else
  printf '%s\n' "${RESULTS[@]}"
  note "SUMMARY pass=$PASSES fail=$FAILS skip=$SKIPS except=$EXCEPT_COUNT (docker-host-scan v$VERSION)"
fi
exit "$FAILS"