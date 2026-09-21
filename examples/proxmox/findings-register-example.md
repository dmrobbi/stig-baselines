# Example: filled findings register (pilot run)

What the accepted-findings register looks like after a pilot run (test T3 in
[PILOT-TEST-PLAN.md](../../docs/proxmox/PILOT-TEST-PLAN.md)). Filled from
[`docs/proxmox/accepted-findings-template.md`](../../docs/proxmox/accepted-findings-template.md)
using the first scan output. **Illustrative rows** — the live register gets
created at `docs/proxmox/findings.md` during the real pilot.

Status values: OPEN · ACCEPTED · REMEDIATED · CLOSED.

| Finding | Rule ID | Title | Sev | Status | Rationale | Compensating control | Owner | Review date |
|---|---|---|---|---|---|---|---|---|
| AF-0001 | PVE-STIG-0255 | Root SSH between cluster nodes constrained | CAT II | ACCEPTED | Corosync/pvec tooling requires node-to-node root access for cluster operations | Key-only + Match-host restriction in sshd; Wazuh alert on new keys | Dawn | 2027-03-01 |
| AF-0002 | PVE-STIG-0010 | Separate filesystems for /tmp | CAT II | OPEN | Pilot node was installed with a single root LV; repartition deferred to next reinstall window | None yet — proposed: tmpfs on /tmp via fstab in Phase E | Dawn | — |
| AF-0003 | PVE-STIG-0020 | Aide scheduled integrity monitoring | CAT II | REMEDIATED | — (was: aidecheck.timer inactive on fresh install) | Fixed by `proxmox-harden.sh --apply`; re-scan confirms PASS | Dawn | — |
| AF-0004 | PVE-STIG-0070 | Kernel network hardening (rp_filter, syncookies) | CAT II | REMEDIATED | — (was: baseline sysctls not set) | Fixed via /etc/sysctl.d/99-pve-stig.conf; SCA check 100502 green | Dawn | — |
| AF-0005 | PVE-STIG-0220 | 2FA enforced for root@pam and all UI users | CAT II | OPEN | Requires realm + TOTP decisions (manual-guidance control); operator action pending | Management network restricted to jump host in the interim | Dawn | — |

Notes:

- Every ACCEPTED finding needs rationale + compensating control + owner +
  review date — "None" is not acceptable for CAT I (template rule 2).
- Findings expire after 12 months without re-approval; re-review every
  Phase F cycle (monthly).
- The workflow is modeled on
  [fawraw/proxmox-host-hardening](https://github.com/fawraw/proxmox-host-hardening)'s
  accepted-findings doc (collected copy:
  [`docs/proxmox/collected/fawraw-pve8-hardening.md`](../../docs/proxmox/collected/fawraw-pve8-hardening.md)).