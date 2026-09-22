# Example: proxmox-harden.sh output

Captured 2026-09-21 with the fixed v0.1.0 fixer on **thing1** (non-PVE
Ubuntu smoke host). The fixer is **dry-run by default** — it applies nothing
until `--apply`.

## Dry-run (default — test T4)

```text
PVE-STIG remediation v0.1.0 — DRY-RUN (pass --apply to change anything)

[PVE-STIG-0060] unattended security updates
[PVE-STIG-0070] kernel network hardening
  [DRY-RUN] would: write /etc/sysctl.d/zz-pve-stig.conf (rp_filter, syncookies, syncookies retries)
[PVE-STIG-0070b] time synchronization
[PVE-STIG-0040] sshd hardening (root key-only, MaxAuthTries 4)
  [DRY-RUN] would: write /etc/ssh/sshd_config.d/10-pve-stig.conf + reload
[PVE-STIG-0030] auditd
[PVE-STIG-0020] Aide integrity monitoring

== MANUAL-GUIDANCE CONTROLS (not auto-changed; see controls.yaml) ==
[PVE-STIG-0210] pveproxy TLS: set CIPHERS/TLS in /etc/default/pveproxy, then: systemctl restart pveproxy
[PVE-STIG-0220] 2FA: pveum tfa + realm config (requires PVE UI/CLI decisions)
[PVE-STIG-0230] API tokens: pveum user token add for automation identities
[PVE-STIG-0280] pve-firewall: enable via datacenter.cfg — REVIEW rules first (lockout risk on :8006)
[PVE-STIG-0120] unprivileged CTs: pct list + per-CT migration ( disruptive — plan separately)
[PVE-STIG-0110] libvirtd TCP: edit /etc/libvirt/libvirtd.conf (listen_tcp=0) — safe fix, apply manually to stage

Dry-run complete. Re-run with --apply to make these changes.
```

How to read it:

- Controls already in shape print only their header line (0060, 0070b, 0030,
  0020 on this host) — the guard checks are read-only.
- `[DRY-RUN] would:` lines are the planned changes; a re-scan after a dry-run
  must be byte-identical (T4 pass criteria: it applied nothing).
- The `== MANUAL-GUIDANCE ==` block lists controls that need operator
  decisions (firewall lockout risk on :8006, cluster breakage risk) — the
  fixer never auto-applies them.

## Apply mode (test T5) and idempotency (test T6)

```text
PVE-STIG remediation v0.1.0 — APPLY MODE (log: /tmp/pve-harden-1763777458.log)
...
  [APPLIED] write /etc/sysctl.d/zz-pve-stig.conf (rp_filter, syncookies, syncookies retries)
  [APPLIED] write /etc/ssh/sshd_config.d/10-pve-stig.conf + reload
...
Done. 2 change(s) applied. Log: /tmp/pve-harden-1763777458.log
```

The second `--apply` run must print **zero new `[APPLIED]` lines** (T6 —
idempotency: guards skip what is already fixed). Failures during apply show
`[ERROR] description (see <log>)` and never abort the run — check the log,
fix, re-apply.

Cluster care before apply (program plan §7): on cluster nodes, review
corosync / root-SSH-between-nodes impact first; the pilot is the only node
that gets `--apply` until Phase E rolls out.