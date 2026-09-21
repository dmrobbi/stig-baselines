# Layered control mapping — seed skeleton for the PVE-STIG control set

> Phase C expands this into the full control set (~60–80 rules). Each rule gets:
> **Rule ID · Title · Severity (CAT I/II/III) · Discussion · Check (evidence
> command) · Fix · Source reference** — in STIG format. The seeds below are
> concrete enough to start writing checks from.

## Layer 0 — Base OS (Debian 12/13, CIS Debian Benchmark)

| Rule ID | Title | Sev | Check (evidence) | Fix | Source |
|---|---|---|---|---|---|
| PVE-STIG-0010 | Separate filesystems for /tmp, /var, /var/log | CAT II | `findmnt -t tmpfs` + `lsblk` layout | fstab + tmpfs options | CIS Debian §1.1 |
| PVE-STIG-0020 | File-integrity monitoring (Aide) installed and scheduled | CAT II | `systemctl status aidecheck.timer` | install + daily cron | CIS §1.3 |
| PVE-STIG-0030 | auditd running with baseline rules | CAT II | `auditctl -l`, `systemctl is-active auditd` | apt install auditd + baseline rules | CIS §4.1 |
| PVE-STIG-0040 | sshd: no password root login, MaxAuthTries ≤ 4, AllowUsers list | CAT I | `sshd -T` grep | sshd_config drop-in | CIS §5.2 |
| PVE-STIG-0050 | Password quality (pwquality) + aging policy | CAT II | `grep` /etc/security/pwquality.conf | pam config | CIS §5.3 |
| PVE-STIG-0060 | Unattended security updates enabled | CAT II | `systemctl is-enabled unattended-upgrades` | apt config | CIS §1.9 |
| PVE-STIG-0070 | Kernel network hardening (rp_filter, syncookies, no forwarding unless needed) | CAT II | `sysctl` values | sysctl.d file | CIS §3.2 |
| PVE-STIG-0070b | Time sync (chrony/systemd-timesyncd) active | CAT II | `systemctl is-active chrony` | install + config | CIS §2.1 |
| PVE-STIG-0090 | Unnecessary services disabled (list from `systemctl list-unit-files --state=enabled`) | CAT II | service inventory vs allowlist | mask/disable | CIS §2.2 |

## Layer 1 — Hypervisor (libvirt/KVM/LXC)

| Rule ID | Title | Sev | Check | Fix | Source |
|---|---|---|---|---|---|
| PVE-STIG-0110 | libvirtd TCP listeners disabled (no unauthenticated remote) | CAT I | `ss -tlnp \| grep 16509` / libvirtd.conf | set listen_tls=1, tcp_port off or SASL | DISA KVM STIG analog |
| PVE-STIG-0120 | LXC containers unprivileged by default | CAT II | `pct config` per CT (unprivileged=1) | recreate/migrate privileged CTs | Proxmox docs |
| PVE-STIG-0130 | AppArmor enabled for libvirt guests | CAT II | `aa-status`, guest XML `<seclabel>` | enable in guest XML | DISA KVM analog |
| PVE-STIG-0140 | qemu process limits (cgroup memory/cpu caps) for tenant VMs | CAT III | `systemctl status machine.slice` | cgroup config | best practice |

## Layer 2 — Proxmox services

| Rule ID | Title | Sev | Check | Fix | Source |
|---|---|---|---|---|---|
| PVE-STIG-0210 | pveproxy TLS: TLSv1.2+ only, strong cipher list | CAT I | `openssl s_client` against :8006 | /etc/default/pveproxy | Proxmox admin guide |
| PVE-STIG-0220 | 2FA (TOTP/WebAuthn) enforced for root@pam and all UI users | CAT II | `pveum user list` TFA field | `pveum` + realm config | Proxmox user mgmt |
| PVE-STIG-0230 | Automation uses API tokens, not passwords | CAT II | token inventory in /etc/pve/user.cfg | pveum aclmodify | Proxmox docs |
| PVE-STIG-0240 | RBAC: least-privilege roles; root@pam not used for daily ops | CAT II | user/privilege review | pveum aclmodify | Proxmox docs |
| PVE-STIG-0250 | Corosync on a dedicated network/VLAN | CAT II | `corosync-cfgtool`, ring addresses | cluster config | Proxmox cluster docs |
| PVE-STIG-0255 | Root SSH between cluster nodes constrained (match hosts, key-only) — **documented deviation**: cluster tooling requires it | CAT II | sshd Match blocks | config + accepted-finding | fawraw deviations |
| PVE-STIG-0260 | /etc/pve (pmxcfs) changes audited (auditd watch) | CAT II | `auditctl -l` | auditd rule | Wazuh SCA seed |
| PVE-STIG-0270 | Backups land on a hardened target (PBS with encryption) | CAT II | storage.cfg + PBS config | pvesr/pbs config | Proxmox + PBS guide |
| PVE-STIG-0280 | pve-firewall active; :8006 restricted to mgmt ranges | CAT I | `pve-firewall status` | datacenter.cfg + rules | Proxmox firewall docs |
| PVE-STIG-0290 | Logs forwarded to Wazuh (thing1 manager) | CAT II | ossec.conf in agent | Wazuh agent deploy | see Wazuh doc |
| PVE-STIG-0300 | Subscription/repo hygiene: no unsigned repos; enterprise key removed from exposure | CAT III | sources.list review | repo config | guide-dependent |

## Layer 3 — Guest/ops (monitoring items, not host config)

| Item | How monitored |
|---|---|
| Guest inventory current (VMs + CTs, tags, owners) | Wazuh + `pvesh get /cluster/resources` on schedule |
| PBS backup jobs verified + restore-tested monthly | manual + Wazuh log rule on backup events |
| Drift: any new privileged CT / new root SSH key | Wazuh alert rules |

## Deviation pattern (STIG-style)

Every intentional deviation (cluster-required root SSH, KSM, swappiness, NFS/iSCSI
helpers) gets an **accepted finding** entry in
[`accepted-findings-template.md`](accepted-findings-template.md) with rationale,
compensating control, owner, and review date — the fawraw collected guide models this
exact workflow.