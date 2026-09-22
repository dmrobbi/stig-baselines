#!/usr/bin/env bash
# proxmox-harden.sh — idempotent remediation for the PVE-STIG control set (v0.1.0)
# DRY-RUN BY DEFAULT: shows what would change. Pass --apply to actually change.
# Run as root on a Proxmox VE node. Re-run safe.
set -u
APPLY=0; [[ "${1:-}" == "--apply" ]] && APPLY=1
LOG=/tmp/pve-harden-$(date +%s).log
CHANGES=0

note() { printf '%s\n' "$*"; }
would() { printf '  [DRY-RUN] would: %s\n' "$*"; }
did()   { printf '  [APPLIED] %s\n' "$*"; CHANGES=$((CHANGES+1)); }

run_fix() { # $1 description, $2 command
  if [ $APPLY -eq 1 ]; then
    if eval "$2" >>"$LOG" 2>&1; then did "$1"; else printf '  [ERROR] %s (see %s)\n' "$1" "$LOG"; fi
  else
    would "$1"; CHANGES=$((CHANGES+1))
  fi
}

if [ $APPLY -eq 1 ]; then note "PVE-STIG remediation v0.1.0 — APPLY MODE (log: $LOG)"; else note "PVE-STIG remediation v0.1.0 — DRY-RUN (pass --apply to change anything)"; fi
note ""

# PVE-STIG-0060 — unattended-upgrades
note "[PVE-STIG-0060] unattended security updates"
if ! systemctl is-enabled unattended-upgrades >/dev/null 2>&1; then
  run_fix "install + enable unattended-upgrades" "DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades"
fi

# PVE-STIG-0070 — sysctl network hardening (zz- prefix: must sort AFTER PVE's own /usr/lib/sysctl.d/pve-firewall.conf, which resets rp_filter and would otherwise win the sysctl.d precedence battle)
note "[PVE-STIG-0070] kernel network hardening"
if ! grep -qs 'net.ipv4.tcp_syncookies = 1' /etc/sysctl.d/zz-pve-stig.conf 2>/dev/null; then
  run_fix "write /etc/sysctl.d/zz-pve-stig.conf (rp_filter, syncookies, syncookies retries)" \
    "printf 'net.ipv4.conf.all.rp_filter = 1\nnet.ipv4.default.rp_filter = 1\nnet.ipv4.tcp_syncookies = 1\n' > /etc/sysctl.d/zz-pve-stig.conf && sysctl --system"
fi

# PVE-STIG-0070b — time sync
note "[PVE-STIG-0070b] time synchronization"
if ! systemctl is-active chrony >/dev/null 2>&1 && ! systemctl is-active systemd-timesyncd >/dev/null 2>&1; then
  run_fix "install + enable chrony" "apt-get install -y chrony && systemctl enable --now chrony"
fi

# PVE-STIG-0040 — sshd hardening (accept both spellings in sshd -T: OpenSSH >= 9
# renders 'prohibit-password' as 'without-password'; guard must accept either or
# it re-applies on every run and breaks idempotency)
note "[PVE-STIG-0040] sshd hardening (root key-only, MaxAuthTries 4)"
if ! sshd -T 2>/dev/null | grep -qE '^permitrootlogin (prohibit-password|without-password)'; then
  run_fix "write /etc/ssh/sshd_config.d/10-pve-stig.conf + reload" \
    "mkdir -p /etc/ssh/sshd_config.d && printf 'PermitRootLogin prohibit-password\nMaxAuthTries 4\n' > /etc/ssh/sshd_config.d/10-pve-stig.conf && systemctl reload ssh"
fi

# PVE-STIG-0030 — auditd
note "[PVE-STIG-0030] auditd"
if ! systemctl is-active auditd >/dev/null 2>&1; then
  run_fix "install + enable auditd" "DEBIAN_FRONTEND=noninteractive apt-get install -y auditd && systemctl enable --now auditd"
fi
if [ -f /etc/audit/rules.d ] 2>/dev/null || [ -d /etc/audit/rules.d ]; then
  if ! grep -qs '/etc/pve' /etc/audit/rules.d/50-pve-stig.rules 2>/dev/null; then
    run_fix "auditd watch on /etc/pve (PVE-STIG-0260)" \
      "printf '-w /etc/pve/ -p wa -k pve-cfg\n-w /etc/ssh/sshd_config -p wa -k sshd\n' > /etc/audit/rules.d/50-pve-stig.rules && augenrules --load 2>/dev/null || true"
  fi
fi

# PVE-STIG-0020 — aide
note "[PVE-STIG-0020] Aide integrity monitoring"
if ! dpkg -s aide >/dev/null 2>&1; then
  run_fix "install aide + initialize + daily timer" \
    "DEBIAN_FRONTEND=noninteractive apt-get install -y aide aide-common && aideinit -y -f && systemctl enable --now aidecheck.timer"
fi

# Manual-guidance controls (not safe to auto-fix — printed for the operator)
note ""
note "== MANUAL-GUIDANCE CONTROLS (not auto-changed; see controls.yaml) =="
note "[PVE-STIG-0210] pveproxy TLS: set CIPHERS/TLS in /etc/default/pveproxy, then: systemctl restart pveproxy"
note "[PVE-STIG-0220] 2FA: pveum tfa + realm config (requires PVE UI/CLI decisions)"
note "[PVE-STIG-0230] API tokens: pveum user token add for automation identities"
note "[PVE-STIG-0280] pve-firewall: enable via datacenter.cfg — REVIEW rules first (lockout risk on :8006)"
note "[PVE-STIG-0120] unprivileged CTs: pct list + per-CT migration ( disruptive — plan separately)"
note "[PVE-STIG-0110] libvirtd TCP: edit /etc/libvirt/libvirtd.conf (listen_tcp=0) — safe fix, apply manually to stage"

note ""
if [ $APPLY -eq 1 ]; then printf 'Done. %s change(s) applied. Log: %s\n' "$CHANGES" "$LOG"; else printf 'Dry-run complete. Re-run with --apply to make these changes.\n'; fi