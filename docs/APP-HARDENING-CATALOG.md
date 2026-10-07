# Application STIG / hardening guidance catalog

_Compiled 2026-10-07. Companion to [HARDENING-ROADMAP.md](HARDENING-ROADMAP.md). Purpose: one reviewable list of every application we run (or may run) and what formal guidance exists for it — DISA STIG, CIS Benchmark, SRG, or vendor hardening docs — so kit-building decisions are made against facts, not memory._

Legend — **STIG**: DISA product STIG published. **CIS**: official CIS Benchmark. **SRG**: no product STIG; DISA SRG applies (custom benchmark route). **Vendor**: official vendor hardening/secure-config docs. Versions in our fleet are from the 2026-10-07 inventory scan unless noted.

## 1. Deployed in the environment

### 1.1 Operating systems

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| Ubuntu LTS (24.04 / 22.04 / 20.04) | thing1, trooper2, miner, lab VMs | Canonical Ubuntu 24.04 / 22.04 / 20.04 LTS STIGs | Yes (per release) | Canonical FIPS/security guides | `baselines/ubuntu20.04|22.04|24.04` (generated CKLs) |
| RHEL 8 / 9 | infra hosts | RHEL 8 V2R9 / RHEL 9 V2R10 (RHEL 7 V3R15 archived 2026-10-06, EOL) | Yes | Red Hat docs + ansible-lockdown | **Done** |
| Proxmox VE 9.x | pve1–pve4 fleet | None | None | Proxmox docs; custom PVE-STIG | **Done** (v0.1.1, real-node validated) |
| Windows 10 / 11 / Server 2019 / Server 2022 | workstations / hosts | Win10 V3R6, Win11 V2R9, Srv2019 V3R9, Srv2022 V2R10 | Yes | Microsoft + NSA guidance | `baselines/windows` (CKLs) |
| Apple macOS | Mac fleet | macOS 15 Sequoia V1R6, macOS 26 Tahoe V1R3 | Yes | Apple Platform Security + NSA Apple guidance | `baselines/macos` (CKLs) |

### 1.2 Containers / runtime

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| Docker Engine 29.1.3 (CE) | all container hosts | Docker Enterprise 2.x STIG is **legacy**; Container Platform SRG is the active route | Yes (CIS Docker Engine) | Docker hardening docs | Roadmap Tier 1 #3 (custom benchmark planned) |
| containerd | thing1 (k3s/docker runtime) | covered via Kubernetes STIG/CIS containerd sections | — | containerd docs | via K8s kit |
| Kubernetes (kind-gms) | bare-metal k8s | Kubernetes STIG V2R6 | Yes (kube-bench) | k8s security docs | **Done** 2026-10-06 |
| k3s | thing1 | Kubernetes STIG V2R6 (k3s applicability: most node/Kube controls) | Yes (Rancher k3s CIS profile) | Rancher k3s hardening guide | candidate row for the K8s kit |

### 1.3 Data services

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| PostgreSQL (Patroni cluster; GitLab-bundled) | miner/lab, forge | PostgreSQL STIG (9.x-era) + Crunchy Data PostgreSQL STIG V3R2 | Yes (current major) | PostgreSQL docs | Roadmap Tier 1 #4 |
| Redis (GitLab-bundled) | forge | None | Yes | Redis hardening guide | Tier 2 layer 2 |
| Apache Kafka | miner stack (FORGE topics) | None | Verify in CIS catalog (not confirmed at compile time) | Confluent/Kafka security docs | Tier 3 custom benchmark |
| MinIO | miner stack | None | — | MinIO security checklist | Tier 3 custom benchmark |
| OpenSearch 2.x (inside wazuh-indexer 4.14.8) | thing1 | None | — | OpenSearch security docs | via SOC-stack benchmark below |

### 1.4 Web / proxy / content

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| NGINX | thing1 reverse proxy, forge (bundled), mail-host vhosts | **F5 NGINX STIG V1R1** — new product STIG, pub. 2025-11-25 (32 rules, SCAP 1.4 in NCP) | Yes (v3.0.0) | F5 ADSP hardening blueprint | **Not covered — roadmap Tier 2 note "no product STIG" is now obsolete (row updated 2026-10-07)** |
| WordPress | bedimsecurity.com, stsphotos.com | None | None official (community benchmark exists: dknauss/wp-security-benchmark) | WordPress.org hardening documentation | Not covered |
| Node.js services (web player, openclaw runtime, soc-* apps) | mail host, thing1 | None (OS STIG covers the host) | — | OWASP Node.js Security Cheat Sheet; OpenSSF | under App-SecDev coverage below |

### 1.5 Forge / dev pipeline

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| GitLab | idm.wezzel.com | None | None | **GitLab official hardening recommendations** (docs.gitlab.com/security/hardening) | Roadmap Tier 2 — custom GitLab benchmark (flagship custom-pipeline product) |
| GitLab Runner | thing1 | None | — | covered by GitLab runner-isolation items (shell executor is the top finding) | within GitLab benchmark |

### 1.6 SOC / detection stack

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| Wazuh 4.14.8 (manager / indexer / dashboard, docker) | thing1 | None | None | Wazuh docs "Securing the Wazuh installation" | Not covered — likely first SOC-stack custom benchmark |
| soc-* bridge/MCP services, realtime-soc-server, laya-bridge, imap-watcher | thing1 | **Application Security and Development STIG V6R4** applies (286 findings, 2025-09-09) | — | OWASP ASVS / VSG for the dev review | Roadmap Tier 1 #5 (planned) |
| Ollama 0.x (local LLM server) | thing1, gus2 | None | none | vendor docs minimal — treat as app under App-SecDev SRG | Not covered |
| GitLab Runner, minecraft (itzg/minecraft-server) | thing1 | None | — | container isolation only (low priority) | — |

### 1.7 Network / mail

| Application | Where it runs | DISA STIG | CIS | Vendor / other | stig-baselines status |
|---|---|---|---|---|---|
| OpenVPN (@red) | thing1 gateway | None | None | OpenVPN docs + community guides | Not covered |
| Tailscale / WireGuard | infra mesh | None (VPN SRG legacy) | — | Tailscale security docs | Tier 3 |
| BIND 9 DNS | idm (if deployed) | BIND 9.x STIG | — | ISC docs | Tier 1 #8 (conditional) |
| Postfix / Dovecot / OpenDKIM / rspamd mail stack | mail VPS | None | None | NIST SP 800-45 (postal-system guidance) + community guides | Not covered |
| Host daemons: ssh/OpenSSH, auditd, chrony, fail2ban, rsyslog, clamav, OVS, libvirt/QEMU, snapd, cups | all Ubuntu hosts | inside the OS STIGs | inside CIS OS benchmarks | per-daemon docs | via OS kits |

## 2. Not deployed — catalog reference (future kit candidates)

Product STIGs exist (verify current release at [public.cyber.mil/stigs](https://public.cyber.mil/stigs/) or the NIST NCP mirror) for:

- **Web/app servers:** Apache HTTP Server 2.4 (Linux & Windows), Apache Tomcat 8/9, IIS 8.5/10.0
- **Databases:** Microsoft SQL Server (2016/2019), Oracle Database 12c/19c, MongoDB (Enterprise)
- **No STIG but official CIS:** MySQL/MariaDB, RabbitMQ, Elasticsearch family (check current catalog)
- **Collaboration:** MS Exchange 2016/2019, SharePoint, MS Outlook (kit in repo), Skype for Business/Teams-era STIGs
- **VMware family:** vSphere 6.5/6.7/7.0/8.0 (+ Virtual Machine STIG), vCenter, Horizon, NSX, vRA 7, vROps 6, Workspace ONE, Citrix (kits in repo)
- **Browsers:** Google Chrome Current Windows (V2R11), Microsoft Edge, Mozilla Firefox (V6R8 — done in repo)
- **Network/security products:** Cisco IOS/IOS-XE, PAN-OS (Palo Alto), Fortinet FortiGate, Palo Alto GlobalProtect-era VPN STIGs
- **Mobile:** Android (AOSP/Android), iOS/iPadOS — only if fleet devices reach SOC scope
- **Other Unix:** Solaris 11, AIX — nothing deployed

## 3. Sources

- DISA STIG catalog: https://public.cyber.mil/stigs/ ; NIST NCP mirror with SCAP downloads: https://ncp.nist.gov/checklist/1320 (F5 NGINX V1R1)
- STIG Viewer summaries: https://stigui.com/stigs/F5_NGINX_STIG (V1, 32 rules) ; F5 blog: https://www.f5.com/company/blog/f5-nginx-stigs-a-security-blueprint-for-public-sector-and-regulated-environments
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks (NGINX v3.0.0 confirmed there)
- GitLab hardening: https://docs.gitlab.com/security/hardening/
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/ ; OWASP Node.js cheat sheet: https://cheatsheetseries.owasp.org/
- Community WordPress benchmark: https://github.com/dknauss/wp-security-benchmark

## 4. Review notes (2026-10-07)

1. **NGINX correction (drives a roadmap row edit today):** HARDENING-ROADMAP.md said "Web Server SRG (no product STIG)" for bundled NGINX. A real product STIG now exists — F5 NGINX STIG V1R1 (published 2025-11-25, F5+DISA, 32 rules). Roadmap Tier 2 layer-2 row updated same day.
2. **WordPress** has no official STIG or CIS benchmark; the only formal-format option is the community benchmark above, otherwise WordPress.org hardening docs.
3. **Wazuh 4.x is the biggest no-guidance gap on the live stack** — suggested first custom benchmark after GitLab (it holds the crown jewels of the SOC).
4. Verify CIS claims marked "Verify"/"check" against the CIS catalog before kit work; DISA/CIS pages shift releases often.