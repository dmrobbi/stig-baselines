# proxmox-host-hardening

[![Lint](https://github.com/fawraw/proxmox-host-hardening/actions/workflows/lint.yml/badge.svg)](https://github.com/fawraw/proxmox-host-hardening/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/github/license/fawraw/proxmox-host-hardening)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/fawraw/proxmox-host-hardening)](https://github.com/fawraw/proxmox-host-hardening/releases)
![Proxmox VE](https://img.shields.io/badge/Proxmox%20VE-8-orange)
![Debian](https://img.shields.io/badge/Debian-12%20%7C%2013-red)

CIS-aligned hardening playbook for Proxmox VE 8 hosts (Debian 12 / 13 base). Distilled from a production cluster running mixed workloads (Linux + Windows VMs, dozens of LXC containers, NetApp iSCSI shared storage).

The goal is a host that:

- passes CIS Debian benchmark checks where they don't conflict with PVE
- ships with sensible defaults for clustered Proxmox (root SSH between nodes, NFS / iSCSI multipath, KSM, low swappiness)
- documents every deviation from CIS with a one-line rationale

## What's in the box

| File | Purpose |
|------|---------|
| [`harden.sh`](harden.sh) | Idempotent shell script that applies every section of this playbook |
| [`docs/walkthrough.md`](docs/walkthrough.md) | Step-by-step explanation of each section, with the why |
| [`docs/cis-mapping.md`](docs/cis-mapping.md) | Which CIS Debian controls each section addresses |
| [`docs/accepted-findings.md`](docs/accepted-findings.md) | Findings deliberately not addressed and why |

## When to use

- Provisioning a new Proxmox VE node and you want a known-good baseline
- Bringing an existing node up to a documented standard before an audit
- Reproducing a hardening configuration across nodes in a cluster

## Quick start

```bash
git clone https://github.com/fawraw/proxmox-host-hardening.git
cd proxmox-host-hardening

# Review what it will do
less harden.sh

# Dry-run (prints actions without applying)
sudo ./harden.sh --dry-run

# Apply
sudo ./harden.sh
```

The script is **idempotent**: running it twice is safe and produces no diff on the second run. Backups of every modified config are written under `/root/hardening-backups/<timestamp>/`.

## What gets hardened

### Users and access
- Dedicated low-privilege admin user with `NOPASSWD: ALL` sudo (audited via Wazuh / syslog)
- SSH key-only login
- Banner / motd

### SSH server
- `PermitRootLogin prohibit-password` (root keys only: required for PVE cluster operations)
- Password authentication disabled
- Strong cipher / MAC / KEX algorithms only
- 5-minute idle timeout
- `AllowUsers` whitelist

### fail2ban
- Default `sshd` jail with `systemd` backend
- Auto-enabled on boot

### Kernel and sysctl
- `accept_redirects = 0` on all interfaces
- `tcp_syncookies`, `rp_filter`, `log_martians`
- IPv6 disabled (if not in use)
- `ip_forward = 1` (required for VMs)
- `suid_dumpable = 0`

### Filesystem
- `/dev/shm` mounted `noexec,nosuid,nodev`
- Cron directories `chmod 600 / 700`
- Hard limit on core dumps

### Kernel module blacklist
- Filesystems unused on a server: `cramfs`, `freevxfs`, `jffs2`, `hfs`, `hfsplus`, `squashfs`, `udf`
- Network protocols unused on a server: `dccp`, `sctp`, `rds`, `tipc`
- USB storage (`usb-storage`, `uas`): comment out if you need USB on the node

### Password quality (PAM)
- `pwquality.conf` with `minlen=12`, at least one of each class

### Audit and logging
- Persistent `journald` storage (`/var/log/journal`)
- Default umask `027`

### Proxmox-specific
- Disable `spiceproxy` if SPICE consoles aren't used
- Disable `ksmtuned` (replaced by a deterministic KSM toggle)
- Disable enterprise repos, enable `pve-no-subscription`
- TFA enabled on admin users (manual step in the GUI; documented)

### Memory tuning for hypervisors
- `vm.swappiness = 10` to reduce proactive swapping with plenty of RAM headroom
- KSM enabled with a moderate scan interval (200 ms) to dedupe pages across Windows VMs

### Multipath iSCSI (NetApp template)
- `multipath.conf` for NetApp LUNs with ALUA, round-robin
- VLAN-tagged storage interfaces template

## Designed for clusters

Two PVE-specific notes that trip people up the first time:

1. **Root SSH must remain enabled** between cluster nodes. The script sets `PermitRootLogin prohibit-password` (key-only), not `no`. `AllowUsers` always includes `root`.
2. **`rpcbind` stays running**: required for NFS client mounts (typical NetApp backup / ISO repository).

Both are documented in [`docs/accepted-findings.md`](docs/accepted-findings.md).

## What this playbook does NOT do

- Configure firewall rules (you have a perimeter firewall, right?)
- Install a host IDS (Wazuh agent recommended; out of scope here)
- Configure backup (PBS is the obvious choice but out of scope)
- Patch / update the running kernel (`apt upgrade && reboot`)

For monitoring and backup onboarding, see the post-hardening checklist at the bottom of [`docs/walkthrough.md`](docs/walkthrough.md).

## License

MIT. See [LICENSE](LICENSE).
