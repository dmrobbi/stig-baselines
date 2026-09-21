#!/usr/bin/env bash
# proxmox-scan.sh — read-only assessment for the PVE-STIG control set (v0.1.0)
# Safe to run any time: changes NOTHING. Run as root on a Proxmox VE node.
# Usage: sudo ./proxmox-scan.sh [--json]
# Exit code: number of FAIL controls.
set -u
VERSION="0.1.0"
JSON=0; [[ "${1:-}" == "--json" ]] && JSON=1
RESULTS=(); FAILS=0; PASSES=0; SKIPS=0

note() { printf '%s\n' "$*" >&2; }
pass() { ((PASSES++)); RESULTS+=("PASS|$1|$2|${3:-}"); }
fail() { ((FAILS++)); RESULTS+=("FAIL|$1|$2|${3:-}"); }
skip() { ((SKIPS++)); RESULTS+=("SKIP|$1|$2|${3:-tool missing}"); }

has() { command -v "$1" >/dev/null 2>&1; }

# PVE-STIG-0010 — separate /tmp filesystem (pass if /tmp is its own mount,
# tmpfs or dedicated partition alike — compare mount sources, not fstypes)
c0010() { local t r; t=$(findmnt -n -o SOURCE /tmp 2>/dev/null); r=$(findmnt -n -o SOURCE / 2>/dev/null); if [ -n "$t" ] && [ "$t" != "$r" ]; then pass "$1" "separate filesystem on /tmp" "source $t"; else fail "$1" "/tmp not a separate filesystem" "/tmp and / share $r"; fi; }

# PVE-STIG-0020 — Aide integrity monitoring
c0020() { if dpkg -s aide >/dev/null 2>&1; then local t; t=$(systemctl is-active aidecheck.timer 2>/dev/null || echo inactive); if [ "$t" = active ]; then pass "$1" "aide + timer"; else fail "$1" "aide installed but timer $t"; fi; else fail "$1" "aide not installed"; fi; }

# PVE-STIG-0030 — auditd active
c0030() { local t; t=$(systemctl is-active auditd 2>/dev/null || echo missing); [ "$t" = active ] && pass "$1" "auditd active" || fail "$1" "auditd $t"; }

# PVE-STIG-0040 — sshd hardening
c0040() { local pr mt; pr=$(sshd -T 2>/dev/null | awk '/^permitrootlogin/{print $2}'); mt=$(sshd -T 2>/dev/null | awk '/^maxauthtries/{print $2}'); if [ "${pr:-}" = "prohibit-password" ] && [ "${mt:-0}" -le 4 ] 2>/dev/null; then pass "$1" "root=prohibit-password tries=$mt"; else fail "$1" "permitrootlogin=${pr:-?} maxauthtries=${mt:-?}"; fi; }

# PVE-STIG-0050 — pwquality minlen
c0050() { local m; m=$(grep -oP '^minlen\s*=\s*\K\d+' /etc/security/pwquality.conf 2>/dev/null || echo 0); [ "${m:-0}" -ge 12 ] 2>/dev/null && pass "$1" "minlen=$m" || fail "$1" "minlen=${m:-unset} (want >=12)"; }

# PVE-STIG-0060 — unattended-upgrades
c0060() { local e; e=$(systemctl is-enabled unattended-upgrades 2>/dev/null || echo absent); [ "$e" = enabled ] && pass "$1" "enabled" || fail "$1" "$e"; }

# PVE-STIG-0070 — sysctl network hardening
c0070() { local rf sc; rf=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null); sc=$(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null); if [ "${rf:-0}" = 1 ] && [ "${sc:-0}" = 1 ]; then pass "$1" "rp_filter=$rf syncookies=$sc"; else fail "$1" "rp_filter=${rf:-?} syncookies=${sc:-?}"; fi; }

# PVE-STIG-0070b — time sync
c0070b() { local c s; c=$(systemctl is-active chrony 2>/dev/null || echo no); s=$(systemctl is-active systemd-timesyncd 2>/dev/null || echo no); [ "$c" = active ] || [ "$s" = active ] && pass "$1" "sync active" || fail "$1" "no active sync service"; }

# PVE-STIG-0110 — libvirtd TCP listeners
c0110() { if ss -tln 2>/dev/null | grep -q ':16509 '; then fail "$1" "libvirtd TCP 16509 listening"; else pass "$1" "no libvirtd TCP listener"; fi; }

# PVE-STIG-0120 — unprivileged LXC (needs pct)
c0120() { if ! has pct; then skip "$1" "pct"; return; fi; local bad; bad=$(for ct in $(pct list 2>/dev/null | awk 'NR>1{print $1}'); do pct config "$ct" 2>/dev/null | grep -q 'unprivileged: 1' || echo "$ct"; done | tr '\n' ' '); [ -z "${bad// }" ] && pass "$1" "all CTs unprivileged" || fail "$1" "privileged CTs: $bad"; }

# PVE-STIG-0210 — pveproxy TLS config
c0210() { if [ -f /etc/default/pveproxy ]; then local c; c=$(grep -E '^(CIPHERS|TLS)' /etc/default/pveproxy | head -2); [ -n "$c" ] && pass "$1" "explicit TLS config: $c" || fail "$1" "no explicit pveproxy TLS hardening"; else skip "$1" "pveproxy"; fi; }

# PVE-STIG-0220 — 2FA for users
c0220() { if ! has pveum; then skip "$1" "pveum"; return; fi; local tfa; tfa=$(pvesh get /access/users --output-format json 2>/dev/null | python3 -c "import json,sys
u=json.load(sys.stdin)
print(sum(1 for x in u if x.get('tfa')))" 2>/dev/null || echo 0); [ "${tfa:-0}" -ge 1 ] 2>/dev/null && pass "$1" "2FA configured for $tfa user(s)" || fail "$1" "no TFA users found"; }

# PVE-STIG-0280 — pve-firewall
c0280() { if ! has pve-firewall; then skip "$1" "pve-firewall"; return; fi; local s; s=$(pve-firewall status 2>/dev/null | grep -oE 'enabled|disabled'); [ "$s" = enabled ] && pass "$1" "firewall enabled" || fail "$1" "firewall $s"; }

# PVE-STIG-0290 — Wazuh agent (log forwarding)
c0290() { local t; t=$(systemctl is-active wazuh-agent 2>/dev/null || echo absent); [ "$t" = active ] && pass "$1" "wazuh-agent active" || fail "$1" "wazuh-agent $t (deploy per plan doc)"; }

run() {
  note "PVE-STIG baseline scan v$VERSION — host $(hostname), $(date)"
  note ""
  c0010 PVE-STIG-0010; c0020 PVE-STIG-0020; c0030 PVE-STIG-0030; c0040 PVE-STIG-0040
  c0050 PVE-STIG-0050; c0060 PVE-STIG-0060; c0070 PVE-STIG-0070; c0070b PVE-STIG-0070b
  c0110 PVE-STIG-0110; c0120 PVE-STIG-0120; c0210 PVE-STIG-0210; c0220 PVE-STIG-0220
  c0280 PVE-STIG-0280; c0290 PVE-STIG-0290
  note ""
  note "RESULTS: $PASSES pass, $FAILS fail, $SKIPS skip"
  if [ $JSON -eq 1 ]; then
    printf '{\n'
    printf '  "host": "%s", "passes": %d, "fails": %d, "skips": %d, "results": [\n' "$(hostname)" "$PASSES" "$FAILS" "$SKIPS"
    local first=1
    for r in "${RESULTS[@]}"; do IFS='|' read -r st id ev2 ev3 <<< "$r"; [ $first -eq 1 ] && first=0 || printf ',\n'; printf '    {"id":"%s","result":"%s","evidence":"%s"}' "$id" "$st" "$ev2 $ev3"; done
    printf '\n  ]\n}\n'
  else
    for r in "${RESULTS[@]}"; do IFS='|' read -r st id ev2 ev3 <<< "$r"; printf '%-4s %-14s %s\n' "$st" "$id" "$ev2 $ev3"; done
  fi
}
run
exit "$FAILS"