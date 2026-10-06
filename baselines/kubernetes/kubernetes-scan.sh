#!/usr/bin/env bash
# kubernetes-scan.sh — read-only Kubernetes STIG V2R6 assessment (v0.1.0)
# Safe to run any time: changes NOTHING. Run as root on a kubeadm node.
# Usage: sudo ./kubernetes-scan.sh [--json]
# Exit code: number of FAIL controls.
# Paths follow kubeadm conventions; K8S_ROOT prefixes every fs path (fixture/test mode).
set -u
VERSION="0.1.0"
JSON=0; [[ "${1:-}" == "--json" ]] && JSON=1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IGNORE_LIST="$SCRIPT_DIR/ignore_list.yml"

ROOT="${K8S_ROOT:-}"
KUBEADM_DIR="${KUBEADM_DIR:-$ROOT/etc/kubernetes}"
PKI_DIR="$KUBEADM_DIR/pki"
ETCD_DIR="${ETCD_DIR:-$ROOT/var/lib/etcd}"
KUBELET_DIR="${KUBELET_DIR:-$ROOT/var/lib/kubelet}"

RESULTS=(); FAILS=0; PASSES=0; SKIPS=0; EXCEPT_COUNT=0

note() { printf '%s\n' "$*" >&2; }
add() { RESULTS+=("$1|$2|$3|$4"); }
pass() { ((PASSES++)); add "PASS" "$1" "$2" ""; }
skip() { ((SKIPS++)); add "SKIP" "$1" "$2" "${3:-not present}"; }
fail() {
  if [ -s "$IGNORE_LIST" ] && grep -q "^$1|" "$IGNORE_LIST" 2>/dev/null; then
    ((EXCEPT_COUNT++))
    local why; why=$(grep "^$1|" "$IGNORE_LIST" 2>/dev/null | head -1 | cut -d'|' -f2)
    add "EXCEPT" "$1" "$2" "excepted: ${why:-see ignore_list}"
  else
    ((FAILS++)); add "FAIL" "$1" "$2" "${3:-}"
  fi
}
has() { command -v "$1" >/dev/null 2>&1; }

# ---- discovery -----------------------------------------------------------
KUBELET_CONF=""
for f in "$KUBELET_DIR/config.yaml" "$KUBEADM_DIR/kubelet/config.yaml"; do
  [ -f "$f" ] && { KUBELET_CONF="$f"; break; }
done
KUBELET_ENV_FILE=""
for f in "$ROOT/etc/sysconfig/kubelet" "$ROOT/etc/default/kubelet"; do
  [ -f "$f" ] && { KUBELET_ENV_FILE="$f"; break; }
done
kubelet_flags() {
  [ -n "$KUBELET_ENV_FILE" ] && grep -hE '^KUBELET_(KUBEADM_)?ARGS=' "$KUBELET_ENV_FILE" 2>/dev/null; return 0
}
APISERVER_MAN=""
[ -f "$KUBEADM_DIR/manifests/kube-apiserver.yaml" ] && APISERVER_MAN="$KUBEADM_DIR/manifests/kube-apiserver.yaml"
SCHED_MAN="$KUBEADM_DIR/manifests/kube-scheduler.yaml"
CM_MAN="$KUBEADM_DIR/manifests/kube-controller-manager.yaml"
APIS_FLAGS=""
[ -n "$APISERVER_MAN" ] && APIS_FLAGS=$(grep -E '^\s+- --' "$APISERVER_MAN" | tr '\n' ' ')

owner_root() { stat -c '%U' "$1" 2>/dev/null | grep -qx root; }
perm_of() { stat -c '%a' "$1" 2>/dev/null || echo 999; }
files_ok_max() { # $1=max-perm  $2..=files; absent files ignored; returns 0 if all present files <= max
  local max="$1"; shift; local p
  for p in "$@"; do
    [ -e "$p" ] || continue
    [ "$(perm_of "$p")" -le "$max" ] 2>/dev/null || return 1
  done
  return 0
}
owner_ok() { # $@=files: all present files owned by root
  local p; for p in "$@"; do [ -e "$p" ] || continue; owner_root "$p" || return 1; done; return 0
}

# ---- static-file controls ------------------------------------------------
# ownership
for spec in \
  "SV-242405r960960|manifests owned root|$KUBEADM_DIR/manifests/kube-apiserver.yaml $KUBEADM_DIR/manifests/kube-scheduler.yaml $KUBEADM_DIR/manifests/kube-controller-manager.yaml $KUBEADM_DIR/manifests/etcd.yaml" \
  "SV-242406r960960|kubelet conf owned root|$KUBELET_DIR/config.yaml" \
  "SV-242453r961863|kubelet kubeconfig owned root|$KUBEADM_DIR/kubelet.conf" \
  "SV-242448r961863|kube-proxy kubeconfig owned root|$KUBEADM_DIR/proxy" \
  "SV-242450r961863|kubelet CA owned root|$KUBELET_DIR/pki/ca.crt" \
  "SV-242451r961863|PKI tree owned root|$PKI_DIR"; do
  IFS='|' read -r cid ctitle cpaths <<< "$spec"
  found=0; for p in $cpaths; do [ -e "$p" ] && found=1; done
  [ "$found" = 1 ] || { skip "$cid" "$ctitle"; continue; }
  owner_ok $cpaths && pass "$cid" "$ctitle" || fail "$cid" "$ctitle" "non-root owner"
done
# permission ceilings (644)
for spec in \
  "SV-242407r960960|kubelet conf 644|$KUBELET_DIR/config.yaml" \
  "SV-242452r961863|kubelet kubeconfig 644|$KUBEADM_DIR/kubelet.conf" \
  "SV-242447r961863|kube-proxy kubeconfig 644|$KUBEADM_DIR/proxy" \
  "SV-242449r961863|kubelet CA 644|$KUBELET_DIR/pki/ca.crt" \
  "SV-242460r961863|admin kubeconfig 644|$KUBEADM_DIR/admin.conf" \
  "SV-242459r961863|etcd data 644-restrictive|$ETCD_DIR/member/snap/db" ; do
  IFS='|' read -r cid ctitle cpaths <<< "$spec"
  found=0; for p in $cpaths; do [ -e "$p" ] && found=1; done
  [ "$found" = 1 ] || { skip "$cid" "$ctitle"; continue; }
  files_ok_max 644 $cpaths && pass "$cid" "$ctitle" || fail "$cid" "$ctitle" "looser than 644"
done
# PKI: certs 644, keys 600 (skip family if pki absent)
if [ -d "$PKI_DIR" ]; then
  CRTS=$(echo "$PKI_DIR"/*.crt 2>/dev/null); KEYS=$(echo "$PKI_DIR"/*.key 2>/dev/null)
  [ "$CRTS" != "$PKI_DIR/*.crt" ] && { files_ok_max 644 $CRTS && pass "SV-242466r961863" "PKI crt 644" || fail "SV-242466r961863" "PKI crt 644" "looser than 644"; } || skip "SV-242466r961863" "PKI crt 644" "no crt files"
  [ "$KEYS" != "$PKI_DIR/*.key" ] && { files_ok_max 600 $KEYS && pass "SV-242467r961863" "PKI keys 600" || fail "SV-242467r961863" "PKI keys 600" "looser than 600"; } || skip "SV-242467r961863" "PKI keys 600" "no key files"
else skip "SV-242466r961863" "PKI crt 644"; skip "SV-242467r961863" "PKI keys 600"; fi

# ---- kubelet controls ------------------------------------------------------
if [ -n "$KUBELET_CONF" ] || [ -n "$KUBELET_ENV_FILE" ]; then
  CONF=""; [ -n "$KUBELET_CONF" ] && CONF=$(cat "$KUBELET_CONF" 2>/dev/null)
  FLAGS=$(kubelet_flags)
  grep -qE 'readOnlyPort:\s*0' <<<"$CONF" || grep -qE 'read-only-port=0' <<<"$FLAGS" \
    && pass "SV-242387r1137639" "kubelet readOnlyPort disabled" \
    || fail "SV-242387r1137639" "kubelet readOnlyPort disabled" "not zero"
  grep -qE '--anonymous-auth=false' <<<"$FLAGS" || grep -qE 'anonymous:\s*false' <<<"$CONF" \
    && pass "SV-242391r1137638" "kubelet anonymous auth disabled" \
    || fail "SV-242391r1137638" "kubelet anonymous auth disabled" "anonymous on/default"
  grep -qE 'authorization-mode=Webhook' <<<"$FLAGS" || grep -qE 'mode:\s*Webhook' <<<"$CONF" \
    && pass "SV-242392r1137639" "kubelet explicit authorization" \
    || fail "SV-242392r1137639" "kubelet explicit authorization" "not Webhook"
  ! grep -qE 'staticPodPath:\s*\S+' <<<"$CONF" && ! grep -qE 'pod-manifest-path=\S+' <<<"$FLAGS" \
    && pass "SV-242397r1137639" "kubelet staticPodPath unset" \
    || fail "SV-242397r1137639" "kubelet staticPodPath unset" "static pods enabled"
  grep -qE 'DynamicKubeletConfig=true' <<<"$CONF$FLAGS" \
    && fail "SV-242399r1137639" "DynamicKubeletConfig disabled" "feature gate on" \
    || pass "SV-242399r1137639" "DynamicKubeletConfig disabled"
  grep -qE 'hostname-override=' <<<"$FLAGS" \
    && fail "SV-242404r960960" "kubelet hostname override denied" "override set" \
    || pass "SV-242404r960960" "kubelet hostname override denied"
  grep -qE 'node-status-update-frequency=0' <<<"$FLAGS" \
    && fail "SV-245541r1069469" "kubelet timeouts not disabled" "frequency zeroed" \
    || pass "SV-245541r1069469" "kubelet timeouts not disabled"
  grep -qE 'tlsCertFile:\s*\S+' <<<"$CONF" || grep -qE 'tls-cert-file=\S+' <<<"$FLAGS" \
    && pass "SV-242420r1043178" "kubelet TLS cert configured" \
    || fail "SV-242420r1043178" "kubelet TLS cert configured" "no tlsCertFile"
else
  for cid in SV-242387r1137639 SV-242391r1137638 SV-242392r1137639 SV-242397r1137639 SV-242399r1137639 SV-242404r960960 SV-245541r1069469 SV-242420r1043178; do
    skip "$cid" "kubelet control" "no kubelet config or args"
  done
fi

# ---- control-plane controls -----------------------------------------------
if [ -n "$APISERVER_MAN" ]; then
  grep -E -- '--authorization-mode=' <<<"$APIS_FLAGS" | grep -qE 'Node[,\s]+' && grep -E -- '--authorization-mode=' <<<"$APIS_FLAGS" | grep -qE 'RBAC' \
    && pass "SV-242382r1137638" "API server Node,RBAC" \
    || fail "SV-242382r1137638" "API server Node,RBAC" "mode missing Node,RBAC"
  grep -qE -- '--anonymous-auth=false' <<<"$APIS_FLAGS" \
    && pass "SV-242390r1137640" "API anonymous auth disabled" \
    || fail "SV-242390r1137640" "API anonymous auth disabled" "anonymous on/default"
  grep -qE 'feature-gates=.*AllAlpha=true' <<<"$APIS_FLAGS" \
    && fail "SV-242400r1137638" "alpha APIs disabled" "AllAlpha gate on" \
    || pass "SV-242400r1137638" "alpha APIs disabled"
  ! grep -qE -- '--basic-auth-file=' <<<"$APIS_FLAGS" \
    && pass "SV-245542r961632" "basic auth disabled" \
    || fail "SV-245542r961632" "basic auth disabled" "basic-auth-file set"
  ! grep -qE -- '--token-auth-file=' <<<"$APIS_FLAGS" \
    && pass "SV-245543r961632" "static token auth disabled" \
    || fail "SV-245543r961632" "static token auth disabled" "token-auth-file set"
  grep -qE -- '--enable-admission-plugins=.*PodSecurity' <<<"$APIS_FLAGS" \
    && pass "SV-254800r961359" "Pod Security Admission configured" \
    || fail "SV-254800r961359" "Pod Security Admission configured" "not in admission plugins"
  grep -qE -- '--encryption-provider-config=' <<<"$APIS_FLAGS" \
    && pass "SV-274882r1137640" "secrets encrypted at rest" \
    || fail "SV-274882r1137640" "secrets encrypted at rest" "no encryption config"
  grep -qE -- '--tls-min-version=VersionTLS12' <<<"$APIS_FLAGS" \
    && pass "SV-242378r960759" "apiserver TLS 1.2 min" \
    || fail "SV-242378r960759" "apiserver TLS 1.2 min" "no min pinned"
else
  for cid in SV-242382r1137638 SV-242390r1137640 SV-242400r1137638 SV-245542r961632 SV-245543r961632 SV-254800r961359 SV-274882r1137640 SV-242378r960759; do
    skip "$cid" "control-plane control" "apiserver manifest absent"
  done
fi
# scheduler + controller-manager TLS-min
for spec in "SV-242377r960759|scheduler TLS min|$SCHED_MAN" "SV-242376r960759|controller-manager TLS min|$CM_MAN"; do
  IFS='|' read -r cid ctitle cman <<< "$spec"
  if [ -n "$cman" ] && [ -f "$cman" ]; then
    grep -qE -- '--tls-min-version=VersionTLS12' "$cman" && pass "$cid" "$ctitle" || fail "$cid" "$ctitle" "no tls-min pinned"
  else skip "$cid" "$ctitle"; fi
done

# ---- live-API controls (clean skips without kubectl) ----------------------
if has kubectl && kubectl auth can-i get ns >/dev/null 2>&1; then
  kubectl get deploy -A 2>/dev/null | grep -q kubernetes-dashboard \
    && fail "SV-242395r1137639" "dashboard absent" "dashboard deployed" \
    || pass "SV-242395r1137639" "dashboard absent"
else
  skip "SV-242395r1137639" "dashboard absent" "kubectl absent/unauthorized"
fi
skip "SV-242415r1069466" "secrets not stored as env vars" "requires full workload spec evaluation (manual pass)"
skip "SV-242383r1137641" "user resources in dedicated namespaces" "policy decision per cluster (manual pass)"

# ---- output ---------------------------------------------------------------
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
print(json.dumps({"tool": "kubernetes-scan", "version": "0.1.0",
                  "pass": p, "fail": f, "skip": s, "except": e, "results": rows}))
PY
else
  printf '%s\n' "${RESULTS[@]}"
  note "SUMMARY pass=$PASSES fail=$FAILS skip=$SKIPS except=$EXCEPT_COUNT (kubernetes-scan v$VERSION)"
fi
exit "$FAILS"