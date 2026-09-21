# Proxmox pilot examples — the ready-for-testing kit

Concrete artifacts for the PVE-STIG pilot (Phase B/E of
[docs/PROXMOX-PROGRAM.md](../../docs/PROXMOX-PROGRAM.md)). Nothing here is
production guidance — this is what gets run on the pilot node, and what its
output looks like, for the moment the program is ready for testing.
Start at the runbook: [docs/proxmox/PILOT-TEST-PLAN.md](../../docs/proxmox/PILOT-TEST-PLAN.md).

| File | What it is |
|------|------------|
| `pilot-vm-bootstrap.sh` | Lab-only script to stand up an Ubuntu cloud-init VM on a PVE host — the pilot target. Password SSH is enabled on purpose: the pilot starts unhardened so the first scan produces real findings (T1). |
| `scan-report-example.md` | What `proxmox-scan.sh` output looks like (real captured run + how to read it) |
| `harden-dryrun-example.md` | What `proxmox-harden.sh` dry-run/apply output looks like, including the idempotency check (T4–T6) |
| `findings-register-example.md` | A filled accepted-findings register (from the template) — what the pilot's T3 output looks like |
| `wazuh-sca-ossec.conf` | The `<sca>` config snippet for the `proxmox` agent group on the thing1 manager (T8) |

The scripts these examples exercise live in
[baselines/proxmox/](../../baselines/proxmox/README.md); the SCA policy is
`baselines/proxmox/sca_pve_stig_policy.yml`.