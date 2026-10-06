#!/usr/bin/env bash
# kubernetes-harden.sh — remediate the fixable Kubernetes STIG V2R6 controls (v0.1.0)
# DRY-RUN default: prints planned changes, changes NOTHING. --apply = real changes.
# Coverage v0.1.0: file ownership + permission ceilings + the kubelet-config
# authentication flags. Control-plane manifest flags (admission plugins, etcd
# encryption, TLS pins) print recommendations = they restart the control plane and
# are operator decisions, not blind fixes.
# Usage: sudo ./kubernetes-harden.sh [--apply]
set -u
VERSION="0.1.0"
APPLY=0; [[ "${1:-}" == "--apply" ]] && APPLY=1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT="${K8S_ROOT:-}"

if [ "$APPLY" = 1 ] && [ "$(id -u)" != "0" ]; then
  note "ERROR: --apply requires root; rerun with sudo. (Nothing was changed.)"
  exit 2
fi
KUBEADM_DIR="${KUBEADM_DIR:-$ROOT/etc/kubernetes}"
PKI_DIR="$KUBEADM_DIR/pki"
ETCD_DIR="${ETCD_DIR:-$ROOT/var/lib/etcd}"
KUBELET_DIR="${KUBELET_DIR:-$ROOT/var/lib/kubelet}"

CHANGES=0; WOULD=0; ROWS=()
note() { printf '%s\n' "$*" >&2; }
row() { ROWS+=("$1"); }

fix_owner() { # $1 = control-id  $2... = files
  local cid="$1"; shift; local p
  for p in "$@"; do
    [ -e "$p" ] || continue
    if [ "$(stat -c '%U' "$p")" != root ]; then
      if [ "$APPLY" = 1 ]; then chown root:root "$p" && ((CHANGES++)) && row "FIXED|$cid|chown root:root|$p"; else ((WOULD++)); row "WOULD|$cid|chown root:root|$p"; fi
    fi
  done
}
fix_perm() { # $1 = control-id  $2 = ceiling  $3... = files
  local cid="$1" max="$2"; shift 2; local p
  for p in "$@"; do
    [ -e "$p" ] || continue
    local cur; cur=$(stat -c '%a' "$p" 2>/dev/null) || continue
    [ "$cur" -gt "$max" ] 2>/dev/null || continue
    if [ "$APPLY" = 1 ]; then chmod "$max" "$p" && ((CHANGES++)) && row "FIXED|$cid|chmod $max|$p"; else ((WOULD++)); row "WOULD|$cid|chmod $max|$p"; fi
  done
}
fix_kubelet_flag() { # $1=control-id  $2=desired replacement line  $3=bad-pattern (ERE, line-scoped)
  local cid="$1" want_line="$2" bad_pat="$3"
  local f="$KUBELET_DIR/config.yaml"
  [ -f "$f" ] || { row "SKIP|$cid|kubelet conf absent|$f"; return 0; }
  grep -qE "$bad_pat" "$f" || return 0
  if [ "$APPLY" = 1 ]; then
    cp "$f" "$f.stig-backup"
    sed -i -E "s|^[[:space:]]*($bad_pat)[[:space:]]*$|$want_line|" "$f"
    if grep -qE "$bad_pat" "$f"; then cp "$f.stig-backup" "$f"; row "ERROR|$cid|sed patch failed (restored)|$f"; return 0; fi
    ((CHANGES++)); row "FIXED|$cid|$bad_pat -> $want_line|$f"
    note "NOTE: kubelet restart required for flag changes ($f changed)"
  else
    ((WOULD++)); row "WOULD|$cid|$bad_pat -> $want_line|$f"
  fi
}

# ---- ownership families ---------------------------------------------------
fix_owner SV-242405r960960 "$KUBEADM_DIR"/manifests/*.yaml
fix_owner SV-242406r960960 "$KUBELET_DIR/config.yaml"
fix_owner SV-242453r961863 "$KUBEADM_DIR/kubelet.conf"
fix_owner SV-242448r961863 "$KUBEADM_DIR"/proxy
fix_owner SV-242450r961863 "$KUBELET_DIR/pki/ca.crt"
fix_owner SV-242451r961863 "$PKI_DIR"/ -R

# ---- permission ceilings ---------------------------------------------------
fix_perm SV-242407r960960 644 "$KUBELET_DIR/config.yaml"
fix_perm SV-242452r961863 644 "$KUBEADM_DIR/kubelet.conf"
fix_perm SV-242447r961863 644 "$KUBEADM_DIR"/proxy
fix_perm SV-242460r961863 644 "$KUBEADM_DIR/admin.conf"
fix_perm SV-242459r961863 644 -R "$ETCD_DIR" 2>/dev/null
fix_perm SV-242466r961863 644 "$PKI_DIR"/*.crt
fix_perm SV-242467r961863 600 "$PKI_DIR"/*.key

# ---- kubelet-config flags --------------------------------------------------
fix_kubelet_flag SV-242387r1137639 "readOnlyPort: 0" "readOnlyPort:\s*[1-9][0-9]*"
fix_kubelet_flag SV-242391r1137638 "  anonymous: false" "anonymous:\s*true"
fix_kubelet_flag SV-242392r1137639 "  mode: Webhook" "mode:\s*AlwaysAllow"

# ---- control-plane recommendations (not auto-applied in v0.1.0) ------------
for spec in \
  "SV-254800r961359|--enable-admission-plugins include PodSecurity namespace labels" \
  "SV-274882r1137640|--encryption-provider-config + re-encrypt all secrets" \
  "SV-245542r961632|--basic-auth-file must be absent" \
  "SV-245543r961632|--token-auth-file must be absent" \
  "SV-242378r960759|--tls-min-version=VersionTLS12 on apiserver" \
  "SV-242377r960759|--tls-min-version=VersionTLS12 on scheduler" \
  "SV-242376r960759|--tls-min-version on controller-manager"; do
  IFS='|' read -r cid rec <<< "$spec"
  row "RECOMMEND|$cid|$rec|operator decision (restarts control plane)"
done

for r in "${ROWS[@]}"; do printf '%s\n' "$r"; done
note "K8S-HARDEN-SUMMARY applied=$CHANGES would=$WOULD (v$VERSION dry-run$([ "$APPLY" = 1 ] || echo ' — rerun with --apply'))"
exit 0