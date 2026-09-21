# Proxmox VE baseline (PVE-STIG v0.1)

STIG-style control set for Proxmox VE, built because no DISA STIG (or CIS
benchmark) exists for PVE. The layered control model and full program plan:
[docs/PROXMOX-PROGRAM.md](../../docs/PROXMOX-PROGRAM.md); control mapping:
[docs/proxmox/layered-controls.md](../../docs/proxmox/layered-controls.md);
continuous-audit wiring:
[docs/proxmox/wazuh-sca-integration.md](../../docs/proxmox/wazuh-sca-integration.md).

**Status: seeded v0.1.0** — 16 controls across three layers (L0 base OS,
L1 hypervisor, L2 Proxmox services). Scanner and fixer are syntax-checked and
smoke-tested; the set is ready for the pilot once the host inventory is
filled (Phase A). Pilot runbook:
[docs/proxmox/PILOT-TEST-PLAN.md](../../docs/proxmox/PILOT-TEST-PLAN.md);
test kit: [examples/proxmox/](../../examples/proxmox/README.md).

## Usage

On a Proxmox VE node (root):

```bash
# Phase B — assessment (read-only; safe to run any time)
sudo ./proxmox-scan.sh            # markdown report + exit code = # failing controls
sudo ./proxmox-scan.sh --json      # machine-readable for the findings pipeline

# Phase E — remediation (DRY-RUN by default; applies nothing until --apply)
sudo ./proxmox-harden.sh          # shows what it would change
sudo ./proxmox-harden.sh --apply  # actually fix (cluster care: read the warnings below)
```

`controls.yaml` is the source of truth — the scanner, the fixer, and the Wazuh
SCA policy (`sca_pve_stig_policy.yml`) each implement the controls it defines.
Scanner notes: human-readable output goes to stderr, `--json` data to stdout
(pipes stay clean); `sshd -T`-based evidence needs root to populate.

Cluster hosts: hardening can break corosync / root-SSH-between-nodes — see the
program plan §7 (risks) and §5 Phase E before applying anything.

## Host inventory (Phase A — fill before the pilot)

| Host | PVE version | Role | Pilot? |
|---|---|---|---|
| *(pending)* | | | |