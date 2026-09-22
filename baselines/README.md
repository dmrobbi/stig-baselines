# Baselines

Two kinds of baseline live here, one directory per system:

1. **Generated DISA CKLs** — the platform directories (`rhel7/` … `windows/`)
   hold checklist files generated from the official DISA XCCDF sources via
   `make baselines`, ready for DISA STIG Viewer. Full table in the
   [root README](../README.md).
2. **Custom STIG-style baselines** — for systems with no official STIG: a
   machine-readable control set (`controls.yaml`), a read-only scanner, an
   idempotent fixer (dry-run by default), and a Wazuh SCA policy for
   continuous audit. The program plan for each system lives in `docs/`.

> **Status:** building. Custom baselines are the newer kind — Proxmox VE is
> first, with more planned.

| Baseline | Status | Artifacts |
|----------|--------|-----------|
| `proxmox/` | v0.1.1 — pilot-validated on a real PVE VE 9.2.20 node (2026-09-22): T1–T6 + SCA go-live green, seven kit fixes; remaining: real-fleet host inventory (Phase A) | `controls.yaml`, `proxmox-scan.sh`, `proxmox-harden.sh`, `sca_pve_stig_policy.yml`, `README.md` |
| *(next: thing1 (Wazuh manager host), gus2 (llama/app host), sandbox-remote-debug hosts…)* | planned | — |