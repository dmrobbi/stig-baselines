# Accepted findings / exceptions register — live

STIG-style workflow: every deviation from the control set gets a numbered finding
with rationale, compensating control, owner, and a review date. Findings are NOT
silent — they live in this register and get re-reviewed on the Phase F cadence.
Template: [`accepted-findings-template.md`](accepted-findings-template.md).
Example filled register: [`examples/proxmox/findings-register-example.md`](../../examples/proxmox/findings-register-example.md).

## Register — pilot node pve-pilot (opened 2026-09-22)

Pilot context: Proxmox VE 9.2.20 VM ("pve-pilot", Wazuh agent 021), T1–T6 +
SCA go-live executed 2026-09-22 — see
[PILOT-TEST-PLAN.md](PILOT-TEST-PLAN.md) run log. Post-remediation scan: 11 PASS
/ 3 FAIL / 1 SKIP. The four items below are those 3 FAILs + the SKIP — every one
a deliberate manual-guidance control (the fixer never auto-applies them).

Status values: OPEN · ACCEPTED · REMEDIATED · CLOSED.

| Finding | Rule ID | Title | Sev | Status | Rationale | Compensating control | Owner | Review date |
|---|---|---|---|---|---|---|---|---|
| AF-0001 | PVE-STIG-0220 | 2FA enforced for root@pam and all UI users | CAT II | OPEN | Requires realm + TOTP decisions in the PVE UI (pveum tfa + realm config) — operator action, not automatable | Management network LAN-only; root SSH key-only (PermitRootLogin prohibit-password) | Dawn | hardening-depth decision (program §9 item 3) |
| AF-0002 | PVE-STIG-0280 | pve-firewall active; management port 8006 restricted | CAT I | OPEN | Deliberate: enabling pve-firewall on the management plane risks lockout on :8006 — needs a rules review before enablement (manual-guidance by design) | Pilot is LAN-reachable only; node is a disposable test VM until promoted | Dawn | with AF-0001 |
| AF-0003 | PVE-STIG-0050 | Password quality policy (pwquality minlen >= 12) | CAT II | OPEN | v0.1 fixer covers 14 controls; pwquality needs PAM decisions (minlen/class/enforce_for_root) — Phase C candidate | No password logins: root SSH key-only, UI behind AF-0002 decision | Dawn | Phase C control-set authoring |
| AF-0004 | PVE-STIG-0210 | pveproxy explicit TLS hardening (TLSv1.2+, strong ciphers) | CAT I | OPEN | /etc/default/pveproxy not yet authored; fix is manual-guidance (CIPHERS/TLS pinning + pveproxy restart) | Management plane LAN-only; SCA check 100504 will verify once applied | Dawn | with AF-0001 |

## Validation notes (2026-09-22 pilot)

- Baseline (T1) on the fresh node: 5 PASS / 8 FAIL / 1 SKIP, exit=8 (failing-first
  baseline recorded before remediation, as the plan requires).
- Post-remediation (T5/T6 + all tool fixes): 11 PASS / 3 FAIL / 1 SKIP, exit=3;
  fixer idempotency verified — 0 re-applies on re-run.
- SCA live in Wazuh: policy loaded, scanned, manager emitted rule-19003
  "SCA summary: PVE-STIG — Proxmox VE STIG-style baseline" — the register's
  SCA-verdict source is operational.
- Seven kit bugs found by the pilot were fixed in-repo (commits
  56ce359..f98ea46) — scanner/harden guard spelling, sysctl precedence,
  SCA requirements block, masked printf, aide timer unit name, docs.