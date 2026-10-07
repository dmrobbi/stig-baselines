# Proxmox VE (pve fleet) — hardening guide

_Sources: our own PVE-STIG program (no DISA STIG or CIS exists for PVE): [baselines/proxmox/](../../baselines/proxmox/) — `controls.yaml`, `proxmox-scan.sh`, `proxmox-harden.sh` (dry-run default), Wazuh SCA policy `sca_pve_stig_policy.yml`; program plan [PROXMOX-PROGRAM.md](../PROXMOX-PROGRAM.md). All T1–T6 controls already validated live (v0.1.1, real PVE 9.2.20 node, 2026-09-22)._

## Use the kit first

Every host-level control is already coded and piloted — do not freehand this:

```
cd baselines/proxmox
sudo ./proxmox-scan.sh                # read-only; exit code = fail count
sudo ./proxmox-harden.sh              # dry-run always; --apply gated to root
```

Continuous audit runs through the Wazuh SCA policy in the proxmox agent group. Remaining kit work is the real-fleet host inventory (Phase A of the program doc).

## Operational supplements (not all in the kit)

Management plane:

1. `pveproxy` binds 8006 everywhere by default — restrict it to the management interface if the nodes have one (`pveproxy` `LISTEN` in `/etc/default/pveproxy`), and/or firewall 8006 to mgmt CIDR.
2. Two-factor on the PVE realm for all admins (Datacenter → Permissions → Two Factor); note API tokens don't honor 2FA — scope tokens tightly instead.
3. SSH to nodes: root via keys only (`PermitRootLogin prohibit-password`), and keep the cluster's shared `/etc/pve/` idempotent — changes go through one node.

Guest/storage hygiene:

4. LXC: unprivileged containers by default; nesting/privileged only with a written reason.
5. `vzdump`: backups to PBS/NFS off-host, prune policy on, and verify restore quarterly (the demo player already depends on mail-host backups — same discipline).
6. Backup `/etc/pve/corosync.conf`, `/etc/pve/authkey*` perms (0600) stay untouched; the cluster ports (5405–5412 UDP) stay node-internal.
7. `qemu-guest-agent` installed in every VM (the STIG mapping to the vSphere Virtual Machine STIG needs the agent for accurate state).

Cluster/HA:

8. HA fencing: watch qdevice/quorum state — `pvecm status` quarterly (the HA-failure lessons from gus2 pve-lab live in memory: test migration paths after KVM accel changes).

## Verify

```
baselines/proxmox/proxmox-scan.sh               # 0 fails (or approved EXCEPT list)
pvecm status ; pvecm nodes
pve2fa present for root@pam + admin accounts
grep LISTEN /etc/default/pveproxy               # restricted if intended
vzdump jobs visible + last run OK in the UI
```

## Change risk

- `proxmox-harden.sh --apply` edits live cluster files — run dry-run output review first (that's the T1–T6 discipline that already worked).
- Restricting 8006 before confirming mgmt-CIDR reachability is a self-lockout classic — firewall rules last, from a node you can still reach.