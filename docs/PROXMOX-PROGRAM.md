# Proxmox VE — STIG-style Compliance Program

> **Status:** Planning (no hardening applied yet). This document collects the plan,
> the reference material, and the control mapping needed to run a DISA-STIG-style
> compliance program for the fleet's Proxmox VE hosts. Execution follows the phases
> in §5 when scheduled.

## 1. Objective

Give the Proxmox VE hosts a **STIG-style security compliance program**: a written
control set with rule IDs and severities (CAT I/II/III), a repeatable hardening
process, **continuous audit through Wazuh**, and STIG-style
findings/accepted-findings documentation — without depending on a DISA STIG that
does not exist for this product.

## 2. The constraint that shapes this plan

**There is no official DISA STIG for Proxmox VE** (verified 2026-09-21 — the DISA
catalog covers VMware, Hyper-V, RHEL-KVM, Docker/K8s; PVE is absent), and no official
CIS Benchmark either. The community-standard substitute is a layered stack:

| Layer | What it covers | Primary source |
|---|---|---|
| L0 — Base OS | Debian 12/13 under PVE | CIS Debian 12/13 Benchmark |
| L1 — Hypervisor | libvirt/KVM/LXC host controls | DISA KVM/VMware STIG controls (mapped where applicable) |
| L2 — Proxmox services | pveproxy, pvedaemon, cluster, corosync, backup | Proxmox official docs + community guides |
| L3 — Guest/ops | bridge networking, backup integrity, log forwarding | Proxmox + Wazuh integration docs |

Full link inventory: [`proxmox/references.md`](proxmox/references.md).
Rule-to-source mapping: [`proxmox/layered-controls.md`](proxmox/layered-controls.md).

## 3. Scope

**In scope:** PVE nodes (host OS + PVE services + cluster), PBS nodes if deployed,
LXC containers as guest-policy items. **Out of scope (this program):** inside-guest
OS hardening (each guest keeps its own OS-level program), Ceph cluster compliance
(separate track, noted in Phase A).

## 4. Host inventory (to be filled — Phase A input)

| Host | PVE version | Role | Notes |
|---|---|---|---|
| *(pending)* | | | |

Fill from: `pveversion`, `pvecm status`, `cat /etc/pve/storage.cfg`, network plan.
The host table also lives at [`baselines/proxmox/README.md`](../baselines/proxmox/README.md) —
keep the two in sync. Dawn confirms the host list before Phase B.

## 5. Phases

### Phase A — Inventory & scoping (½ day)
Enumerate hosts + versions + roles; pick the pilot node (non-production); agree
the accepted-risk owner (Dawn). Output: filled §4 table.

### Phase B — Baseline assessment (1 day)
Run the current-state scan on the pilot: manual checklist + first Wazuh SCA scan.
Output: baseline findings list mapped to the layer model.
Runbook: [`proxmox/PILOT-TEST-PLAN.md`](proxmox/PILOT-TEST-PLAN.md); test kit:
[`examples/proxmox/`](../examples/proxmox/README.md) (pilot VM bootstrap, example
scan/harden output, filled findings register, SCA ossec.conf snippet).

### Phase C — Author the PVE-STIG control set (2–3 days)
Write the ruleset: rule ID, title, severity, discussion, check (evidence command),
fix. Seed skeleton lives in [`proxmox/layered-controls.md`](proxmox/layered-controls.md).
Target ~60–80 rules across L0–L2 (L3 rules become monitoring items, not host config).

### Phase D — Tooling (2–3 days)
1. **Idempotent hardening script/role** (shell or Ansible) — every rule's fix as a
   checkable, re-runnable step; per-node staging (pilot → rest). First cut:
   `baselines/proxmox/proxmox-harden.sh` (dry-run by default).
2. **Wazuh SCA policy** (`sca_pve_stig_policy.yml` in
   [`baselines/proxmox/`](../baselines/proxmox/README.md)) deployed from the thing1
   manager to the Proxmox agents — see
   [`proxmox/wazuh-sca-integration.md`](proxmox/wazuh-sca-integration.md).

### Phase E — Execution (1–2 days)
Apply to the pilot node, re-scan, fix drift, then roll out node-by-node with
cluster-change care (root-SSH-between-nodes and corosync constraints are the two
known breakage points — see collected fawraw notes).

### Phase F — Continuous compliance (1 day)
Wazuh SCA on schedule (daily), compliance dashboards, drift alerts, monthly
re-baseline. Findings registry + accepted findings kept in this repo.

### Phase G — Documentation & maintenance (½ day)
Findings registry, exception register, re-assessment cadence, version-update
re-runs (PVE major upgrades re-open the control set).

## 6. Acceptance criteria (per phase gate)

- Phase B: baseline findings exist, each mapped to a rule ID.
- Phase C: control set reviewed by Dawn (rules + severities).
- Phase D: hardening re-runs clean twice on the pilot (idempotency); Wazuh SCA
  returns pass/fail per rule on the pilot.
- Phase E: pilot node passes ≥90% of applicable rules; every failure is either
  fixed or in the accepted-findings register with rationale + owner.
- Phase F: SCA scan results visible in the Wazuh dashboard; drift alert fires on
  a deliberate test change.

## 7. Risks

| Risk | Mitigation |
|---|---|
| Cluster breakage from host hardening (corosync, root SSH between nodes) | Pilot node only; change one control at a time; documented deviations for cluster-required settings |
| CIS Debian defaults conflict with PVE (KSM, swappiness, NFS/iSCSI, root-between-nodes) | Follow the collected guides' deviations pattern — document each with rationale (accepted-findings) |
| LXC/guest blast radius | Layer-3 rules are monitoring-only in this program |
| Control set drift as PVE updates | Re-run Phase B scan after every PVE upgrade |

## 8. Artifacts

- This program plan — `docs/PROXMOX-PROGRAM.md`
- Control model + seeded rule skeleton — [`proxmox/layered-controls.md`](proxmox/layered-controls.md)
- Source/link inventory — [`proxmox/references.md`](proxmox/references.md)
- Continuous-audit wiring — [`proxmox/wazuh-sca-integration.md`](proxmox/wazuh-sca-integration.md)
- Findings/exceptions register template — [`proxmox/accepted-findings-template.md`](proxmox/accepted-findings-template.md)
- Collected reference material (community guides) — [`proxmox/collected/`](proxmox/collected/README.md)
- Baseline artifacts (control set, scanner, fixer, SCA policy) — [`baselines/proxmox/`](../baselines/proxmox/README.md)
- Pilot test kit (VM bootstrap, example outputs, SCA ossec.conf) — [`examples/proxmox/`](../examples/proxmox/README.md)
- Pilot runbook — [`proxmox/PILOT-TEST-PLAN.md`](proxmox/PILOT-TEST-PLAN.md)

## 9. Decision points for Dawn

1. Host list + versions (Phase A input).
2. Pilot node choice.
3. Hardening depth: CIS L1 only vs L1+L2 (L2 adds sshd/crypto hardening that can
   break legacy tooling).
4. Whether PBS nodes are in scope.
5. Wazuh SCA scan cadence (suggested: daily, alert on regressions).

## 10. Status

- [x] Plan written (this document)
- [x] References collected (`proxmox/collected/`, `proxmox/references.md`)
- [x] Control mapping seeded (`proxmox/layered-controls.md`)
- [x] Wazuh integration notes (`proxmox/wazuh-sca-integration.md`)
- [x] Baseline artifacts seeded v0.1.0 — control set, scanner, fixer, SCA policy
      (`baselines/proxmox/`; scanner + fixer syntax-checked and smoke-tested on a
      non-PVE host)
- [x] Pilot test kit staged (`examples/proxmox/` + `proxmox/PILOT-TEST-PLAN.md`)
      — **ready for testing once Phase A closes**
- [ ] Phase A — host inventory
- [ ] Phase B — baseline assessment
- [ ] Phase C — control set authored
- [ ] Phase D — tooling built
- [ ] Phase E — applied
- [ ] Phase F — continuous audit live