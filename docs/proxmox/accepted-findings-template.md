# Accepted findings / exceptions register — template

STIG-style workflow: every deviation from the control set gets a numbered finding
with rationale, compensating control, owner, and a review date. Findings are NOT
silent — they live in this register and get re-reviewed on the Phase F cadence.

> **Status values:** OPEN (finding exists, not yet dispositioned) · ACCEPTED
> (documented + signed) · REMEDIATED (fixed, kept for history) · CLOSED.

| Finding | Rule ID | Title | Sev | Status | Rationale | Compensating control | Owner | Review date |
|---|---|---|---|---|---|---|---|---|
| AF-0001 | PVE-STIG-0255 | Root SSH between cluster nodes constrained | CAT II | ACCEPTED | Corosync/pvec tooling requires node-to-node root access for cluster operations | Key-only + Match-host restriction in sshd; Wazuh alert on new keys | Dawn | 2027-03-01 |
| *(template row — replace)* | | | | | | | | |

## Entry requirements

1. **Rationale** — one paragraph, why the control cannot apply as written.
2. **Compensating control** — what reduces the risk instead (monitoring, network
   segregation, procedure). "None" is not an acceptable compensating control for
   CAT I.
3. **Owner + review date** — findings are re-reviewed every Phase F cycle
   (monthly) and expire after 12 months without re-approval.

## Reference model

The accepted-findings workflow is modeled on
[fawraw/proxmox-host-hardening](https://github.com/fawraw/proxmox-host-hardening)
(`docs/accepted-findings.md` in that repo — collected copy in
[`collected/fawraw-pve8-hardening.md`](collected/fawraw-pve8-hardening.md)).
Known deviations already documented by that model (confirm against our hosts in
Phase B):

- Root SSH between cluster nodes (cluster requirement)
- KSM enabled (PVE memory overcommit) — conflicts with CIS swap/ksm posture
- Low swappiness (10) vs CIS default — PVE performance guidance
- NFS/iSCSI services where storage roles require them
- Sudo NOPASSWD for the PVE web-interface service account (if used)