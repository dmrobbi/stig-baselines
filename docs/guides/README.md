# Hardening guides — one per deployed application

_Written 2026-10-07 from the fleet inventory and the published benchmarks. Companion to [APP-HARDENING-CATALOG.md](../APP-HARDENING-CATALOG.md) (what exists) — these guides say what we should actually do. Procedure style: every step is a config/command worth applying or verifying on our hosts._

**Scope:** the applications actually deployed (catalog Section 1). Catalog Section 2 (vSphere, Exchange, Outlook, Citrix, browsers, network products, etc.) is intentionally not given custom guides — DISA already authors those, and our `baselines/` CKLs + Tenable audits are the guidance. Build kits for those on arrival, per the roadmap.

**Sources discipline:** each guide cites the exact STIG / CIS / vendor document it follows. No fabricated rule IDs; if a control is ours, it says so. Verify current STIG releases at [public.cyber.mil/stigs](https://public.cyber.mil/stigs/) and the NIST NCP mirror before kit work.

| # | Guide | App / our deployment | Primary source | stig-baselines status |
|---|---|---|---|---|
| 01 | [ubuntu.md](01-ubuntu.md) | Ubuntu 24.04 hosts (thing1, trooper2, miner, lab) | Ubuntu LTS STIGs + CIS Ubuntu + SSG | CKLs in repo |
| 02 | [rhel.md](02-rhel.md) | RHEL 8/9 hosts | RHEL 8 V2R9 / 9 V2R10 STIGs | done, oscap-ready |
| 03 | [proxmox.md](03-proxmox.md) | pve1–pve4 PVE 9 fleet | custom PVE-STIG program | kit v0.1.1 done |
| 04 | [windows.md](04-windows.md) | Win10/11, Server 2019/2022 | Win STIGs + MS security baseline | CKLs in repo |
| 05 | [macos.md](05-macos.md) | Macs (15 / 26 Tahoe) | macOS STIGs + NSA + Apple | CKLs in repo |
| 06 | [docker.md](06-docker.md) | Docker Engine 29.1.3 + wazuh/mc/runner containers | Container Platform SRG + CIS Docker | kit done (`baselines/docker/`) — run it |
| 07 | [kubernetes.md](07-kubernetes.md) | kind-gms + k3s on thing1 | Kubernetes STIG V2R6 + CIS | kit + kube-bench done |
| 08 | [postgresql.md](08-postgresql.md) | Patroni cluster + GitLab-bundled PG | PostgreSQL STIG + Crunchy V3R2 | planned (roadmap T1#4) |
| 09 | [redis.md](09-redis.md) | GitLab-bundled Redis | CIS Redis + vendor | planned |
| 10 | [kafka.md](10-kafka.md) | miner FORGE topics | Custom from General Application SRG | Tier 3 |
| 11 | [minio.md](11-minio.md) | miner object storage | Custom SRG + MinIO docs | Tier 3 |
| 12 | [opensearch.md](12-opensearch.md) | wazuh-indexer 4.14.8 internals | OpenSearch security docs | via Wazuh guide |
| 13 | [nginx.md](13-nginx.md) | thing1 proxy, mail-host vhosts, forge-bundled | **F5 NGINX STIG V1R1** + CIS NGINX v3.0.0 | not started |
| 14 | [wordpress.md](14-wordpress.md) | bedimsecurity.com, stsphotos.com | wp.org hardening + community benchmark | not started |
| 15 | [gitlab.md](15-gitlab.md) | idm.wezzel.com (+ Runner section) | GitLab official hardening | flagship custom benchmark |
| 16 | [wazuh.md](16-wazuh.md) | Wazuh 4.14.8 stack on thing1 | vendor + our kit skills | no guidance elsewhere — biggest gap |
| 17 | [soc-custom-services.md](17-soc-custom-services.md) | soc-* services, laya-bridge, imap-watcher, realtime-soc-server | App-Sec-Dev STIG V6R4 + systemd sandboxing | planned (roadmap T1#5) |
| 18 | [ollama.md](18-ollama.md) | Ollama on thing1/gus2 | treat under App-Sec-Dev SRG | not started |
| 19 | [node-apps.md](19-node-apps.md) | player, openclaw runtime | OWASP Node cheat sheet | not started |
| 20 | [openvpn.md](20-openvpn.md) | openvpn@red on thing1 | community + vendor | not started |
| 21 | [tailscale-wireguard.md](21-tailscale-wireguard.md) | Tailscale/WireGuard mesh | Tailscale security docs | Tier 3 |
| 22 | [bind9.md](22-bind9.md) | BIND 9 (if deployed on idm) | BIND 9.x STIG | conditional |
| 23 | [mail-stack.md](23-mail-stack.md) | Postfix/Dovecot/ rspamd on mail VPS | NIST SP 800-45 + community | not started |
| 24 | [minecraft.md](24-minecraft.md) | itzg/minecraft-server on thing1 | container isolation only | low priority |

**Review flow:** read a guide, mark edits you want, and I apply them. Applied-harding waves are tracked in the [root todo.md](../../todo.md) once you approve the phasing.

**Not covered here on purpose:** Windows/macOS/VMware families beyond the CKL workflow — the DISA content and our generated baselines are the canonical procedure; the OS guides above add only fleet-specific glue.