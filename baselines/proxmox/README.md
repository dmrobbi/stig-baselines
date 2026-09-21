# Proxmox VE baseline (PVE-STIG v0.1)

STIG-style control set for Proxmox VE, built because no DISA STIG (or CIS
benchmark) exists for PVE. The layered control model and full program plan:
[docs/PROXMOX-PROGRAM.md](../../docs/PROXMOX-PROGRAM.md); control mapping:
[docs/proxmox/layered-controls.md](../../docs/proxmox/layered-controls.md);
continuous-audit wiring:
[docs/proxmox/wazuh-sca-integration.md](../../docs/proxmox/wazuh-sca-integration.md).

**Status: seeded v0.1.0** — 19 controls across three layers (L0 base OS,
L1 hypervisor, L2 Proxmox services); the scanner covers 14 with automated
evidence, the rest are Phase C targets. Scanner and fixer are syntax-checked
and smoke-tested; the set is ready for the pilot once the host inventory is
filled (Phase A). Pilot runbook:
[docs/proxmox/PILOT-TEST-PLAN.md](../../docs/proxmox/PILOT-TEST-PLAN.md);
test kit: [examples/proxmox/](../../examples/proxmox/README.md).

## Install

Plain bash against stock PVE tooling — no packages, no pip. Three routes to
get the files onto a node (or anywhere, for a smoke test):

```bash
# 1) clone the repo (it is small)
git clone https://github.com/dmrobbi/stig-baselines.git
cd stig-baselines/baselines/proxmox

# 2) copy just the baseline directory
scp -r baselines/proxmox root@<pve-node>:/root/pve-stig/

# 3) air-gapped: tarball + sha256 from a connected machine
make dist                       # dist/stig-baselines.tar.gz + .sha256
# carry both files over (USB/sneakernet), then on the node:
sha256sum -c stig-baselines.tar.gz.sha256 && tar xzf stig-baselines.tar.gz
```

Prerequisites: root on a PVE node; bash + coreutils (`findmnt`, `systemctl`,
`ss`, `sshd` — all stock on PVE). The PVE-specific probes (`pct`, `pveum`,
`pvesh`, `pve-firewall`) SKIP politely when absent, which is also why the
scanner runs on any Debian/Ubuntu host for smoke tests.

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
Scanner notes: the banner goes to stderr; the report table (or `--json`
data) goes to stdout, so pipes stay clean; `sshd -T`-based evidence needs
root to populate.

Cluster hosts: hardening can break corosync / root-SSH-between-nodes — see the
program plan §7 (risks) and §5 Phase E before applying anything.

## Companion systems

The baseline is one arm of a home SOC — and it plugs into the same telemetry
loop it feeds:

- **Wazuh** — the continuous-audit layer: the SCA policy here runs daily and
  reports per-rule pass/fail; wiring in
  [docs/proxmox/wazuh-sca-integration.md](../../docs/proxmox/wazuh-sca-integration.md).
- **[soc-openclaw](https://github.com/dmrobbi/soc-openclaw)** — running the
  SOC with an OpenClaw AI analyst: log watchers, scheduled sweeps, alert
  triage (guide gist:
  [18e21539](https://gist.github.com/dmrobbi/18e21539075a3fd3c228eb2978768dd2)).
- **[agentic-ai](https://github.com/dmrobbi/agentic-ai)** — the multi-agent
  system whose SOC agents ingest Wazuh alerts end-to-end (brute-force
correlation → auto-incident).

## Host inventory (Phase A — fill before the pilot)

| Host | PVE version | Role | Pilot? |
|---|---|---|---|
| *(pending)* | | | |