# Wazuh 4.14.8 stack — hardening guide

_Sources: vendor documentation (documentation.wazuh.com — "Securing the Wazuh installation"); no DISA STIG or CIS exists — the **first social-stack custom benchmark** after GitLab (catalog note: biggest no-guidance gap on the live stack). Fleet: manager/indexer/dashboard 4.14.8 (docker on thing1), agents across hosts (PVE fleet audited by the proxmox SCA policy; soc-* MCPs integrate). Skills already covering pieces: wazuh-indexer-rotation (cred rotation), soc-manager-container (MCP integration), soc-fleet-monitoring (SCA/data-join)._

## Manager

1. **API creds rotated**: default `wazuh`/`wazuh-wui` passwords changed to store-managed values; rotation flows through the existing skill (updates soc-* MCP configs in the same pass) — never rotate API creds solo, it strands the MCPs.
2. Agent enrollment: production groups use password/certificate-based enrollment — auto-enroll open only on the LAN segment, and the agent-group assignment reviewed (no group hopping via re-enroll).
3. `agent.conf` distribution: central FIM/logcollector limits tuned to host class (there are live performance lessons from the sts monitoring path — thresholds exist, do not re-tune blindly; change → soak → review).
4. Ruleset: pinned wazuh-releases rules + our local rules are diff-reviewed (no blind overwrite on upgrades); custom rule tests (log samples) before merge.
5. Active response: only the responses we validated (allowlist-driven, not blanket-block); firewalld/DOCKER-USER integration per the Docker guide so it can't lock out the proxy.
6. `internal.conf`/ossec perms: manager config dirs 0600-class ownership inside the container; log rotation (`monitord`) sized.
7. Vulnerability detector: enabled with feeds update cadence — findings flow to soc remediation tickets (existing pipeline).

## Indexer / dashboard

- Indexer controls in [12-opensearch.md](12-opensearch.md) (internal users, TLS pins, audit logging, binds).
- Dashboard: bind 127.0.0.1/VPN interface only (never 0.0.0.0); session timeout; if remote UI needed → it sits behind nginx with auth per [13-nginx.md](13-nginx.md).

## Containers (compose)

- Standard container hardening per [06-docker.md](06-docker.md): ports bound to internal/LAN interfaces only, cap drops where image tolerates, no `docker.sock` mounted, env files 0600 outside git, restart policies + healthchecks (already present), **separate compose networks** for manager↔indexer vs indexer↔dashboard so a dashboard compromise can't reach enrollment.
- Wazuh images ship root defaults — compensating controls: volume perms (0700/0750 ossec-owned), no host mounts beyond the data dirs.

## Agents (fleet)

- Agent keys: `/var/ossec/etc/authd.pass`-class files 0600 on hosts; agent-name hygiene (no free-form names that collide with infra naming).
- SCA policies per host class live in this repo (`baselines/proxmox/sca_pve_stig_policy.yml` the pattern) — extend the same format for Ubuntu/mail-host classes.
- WPK upgrade cadence: match the manager version line (4.14.x) — version skew = silent query misses.

## Config-as-code + backups

- Compose files + manager/indexer config volumes **versioned in this repo** (drift detection like gitlab.rb).
- Config backups: `/var/ossec/etc` + compose + indexer internal_users snapshot (encrypted, off-host) before any rotation/upgrade.
- Indexer snapshots: per [12-opensearch.md](12-opensearch.md) — off-host encrypted, quarterly restore drill.

## Upgrades

- Stay on the 4.14.x line; major jumps (4.8-era bases → 4.14) have multi-step upgrade paths (Wazuh documents per-version routes) — run in a window with the indexer snapshot first, re-check MCP integration after (soc-manager-container skill).

## Verify

```
docker exec wazuh-stack-wazuh.manager-1 /wazuh/bin/wazuh-control info    # version + status
docker exec wazuh-stack-wazuh.manager-1 /wazuh/bin/agent_control -l    # fleet view: agent name, IP, status
filebeat test output (manager → indexer TLS/creds green)
curl -sku <rotated-admin> https://127.0.0.1:9200/_plugins/_security/authinfo
grep -c '' /var/ossec/etc/shared/*/agent.conf   (agent.conf diff vs repo copy)
```

## Change risk

- Cred rotation without the MCP config pass = SOC tools down (skill sequences; solo `docker exec` password change is the classic mistake).
- FIM/logcollector re-tunes ripple into disk + CPU on monitored hosts — one host, soak 24h, then fleet.