# Reference inventory — everything this plan is built from

> Collected 2026-09-21. Nothing here is auto-trusted: each source is cited where a
> rule or phase uses it, so every control can be traced to its origin.

## Official / authoritative

| Source | Link | Use |
|---|---|---|
| DISA STIG catalog | https://public.cyber.mil/stigs/ | Confirm (re-check each quarter) that no Proxmox STIG has been published; pull KVM/VMware STIG controls for L1 mapping |
| KVM RHEL STIG (nearest hypervisor analogue) | DISA catalog → "KVM" | L1 control seeds |
| CIS Debian 12/13 Benchmarks | https://www.cisecurity.org/cis-benchmarks/ | L0 control set (the benchmark PDF is free after registration) |
| CIS × DISA STIG benchmark page | https://www.cisecurity.org/benchmark/stig_bm | Explains CIS↔STIG overlap for cross-referencing |
| Proxmox VE Administration Guide | https://pve.proxmox.com/pve-docs/ | L2 authoritative source (pveproxy, 2FA, tokens, firewall, cluster) |
| Proxmox Backup Server docs | https://pbs.proxmox.com/docs/ | L2/PBS rules |
| Proxmox wiki (admin notes) | https://pve.proxmox.com/wiki/ | practical notes |
| Wazuh SCA documentation | https://documentation.wazuh.com/current/user-manual/capabilities/sec-config-assessment/index.html | The continuous-audit layer format + deployment |

## Community (collected copies in `collected/`)

| Source | Local copy | Notes |
|---|---|---|
| HomeSecExplorer/Proxmox-Hardening-Guide (~508★) | `collected/homesecexplorer-hardening-guide.md` | CIS Debian + Proxmox-specific guides for PVE 9/8 and PBS 4/3; upstream also ships per-release guide docs — fetch `docs/pve9-hardening-guide.md` etc. from the repo when Phase C starts |
| fawraw/proxmox-host-hardening | `collected/fawraw-pve8-hardening.md` | CIS-aligned PVE 8 playbook: `harden.sh` + `docs/walkthrough.md` + `docs/cis-mapping.md` + `docs/accepted-findings.md` — the workflow model for our findings register |
| PVE-9-Hardening (experimental) | `collected/pve9-hardening.md` | PVE 9.1 tooling; **use with care** (author marks it experimental, no support) |
| Solideinfo: SOC on Proxmox + hardened Debian 13 | https://solideinfo.com/proxmox-soc-infrastructure-debian-hardening-guide/ | Architecture context |

## Tooling references

| Tool | Link | Role |
|---|---|---|
| OpenSCAP + SCAP Security Guide | https://www.open-scap.org/ / https://github.com/ComplianceAsCode/content | Optional SCAP rendering of the control set; Debian content is thin — the plan prefers Wazuh SCA |
| Ansible devsec hardening role | https://github.com/dev-sec/ansible-os-hardening | Phase D option for L0 rules |
| git-lfs | https://git-lfs.github.com/ | if evidence packages are committed later |

## Open questions logged

- Does any upstream effort start a Proxmox STIG mapping? Re-check the DISA catalog + CIS releases each quarter (Phase F cadence).