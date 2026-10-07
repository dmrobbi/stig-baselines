# HARD-2 apply — docker kit live pass (thing1)

_2026-10-07 evening. Owner go ("Do Hard-2"); **miner parked per owner hold** — not touched. Scope: `baselines/docker` kit + per-stack compose edits per [guides/06-docker.md](../guides/06-docker.md). Companions: [HARD-1-PREFLIGHT.md](HARD-1-PREFLIGHT.md) / [HARD-1-APPLY.md](HARD-1-APPLY.md) (the OS wave, already delivered)._

## Applied

### Kit controls C-03/C-04 (daemon.json)
- `docker-host-harden.sh --apply` merged: `log-driver json-file` + `log-opts {max-size 10m, max-file 3}` + `live-restore true`. Backup: `/etc/docker/daemon.json.stig-backup`; existing `insecure-registries` + `dns` preserved intact.
- dockerd restarted once (deliberate): `docker info` confirms **live-restore=true** — this was the LAST container-blipping daemon restart ever; future daemon restarts hold the containers.

### Owner-approved interface binds (the publishes decision)
All five `0.0.0.0` publishes → interface binds, per the owner's ask answer:

| Port | Binds |
|---|---|
| wazuh agent 1514 / 1515 / 514-udp | {127.0.0.1, 192.168.1.106 (br1), 100.94.13.51 (tailscale0)} |
| manager API 55000 | {127.0.0.1, 192.168.1.106, 100.94.13.51} (loopback = local-consumer insurance) |
| dashboard 5601 | {192.168.1.106, 100.94.13.51} |
| minecraft 25565 | {192.168.1.106, 100.94.13.51} |

Evidence basis: five agents registered on Tailscale IPs (`client.keys`: vader, darth, mail.stsgym.com, gus2, cactus), mc player `Cdopy` on 192.168.1.104 (LAN), router-forwarded WAN traffic lands on br1, host-local MCP consumers address the manager via 192.168.1.106 (role design) — the `172.19.0.1` docker-proxy source pattern in ossec.log confirms the path. Loopback rows = insurance for anything configured to `127.0.0.1`; never externally exposed.

Changed **via the Ansible role** (`templates/docker-compose.yml.j2`) — the rendered compose carries a do-not-hand-edit contract, so the binds went in as a template change, not an edit of the rendered file.

### Per-service log rotation (the discovery)
- Daemon default log-opts verified active (bare `docker create` inherits `10m/3`) — yet recreated wazuh/mc containers showed **empty LogConfig**: compose v2 emits an explicit empty `logging` section that overrides daemon defaults. Fix: per-service `logging:` blocks on manager/indexer/dashboard (+mc). Recorded in the role.

### no-new-privileges (C-08)
- `security_opt: ["no-new-privileges:true"]` on manager/indexer/dashboard (role template) + mc (compose).
- **gitlab-runner: EXCEPT row** — docker.sock mount by design; the off-root-equivalence architecture move is owned by HARD-5; re-check the control after that lands.

## The rehearsal catches (would have silently regressed deployed behavior)

The repo template was stale against the live file at four points — **all re-encoded (role commits `1638770` + `b6536c8`) before any recreation**:

1. **integration level 12 → 10** — the owner's 2026-09-17 decision (SOC-high band L10-11 reaches classify→ticket→ingest). Defaults + comment.
2. **agentic loop shadow → live** — `shadow_mode: true` (Phase 3) retired; `agentic_loop_mode: live` (Phase 4 flip, operator consent 2026-08-17 17:55 UTC) re-encoded with the consent comment verbatim; the shadow branch preserved as the documented rollback.
3. **OPENCLAW_GATEWAY_TOKEN** — stale literal default in role defaults; now sourced from a wez-owned 0600 file (`~/.openclaw/soc/secrets/openclaw-gateway.env`, single bare-token line) via a fails-loud lookup. The live token existed in NO secrets file before this (it lived only in the deployment); round-trip-verified against the running container.
4. **SOC tickets/manager/memory MCP URLs** — `host_lan_ip` → `bridge_mcp_host` (172.19.0.1): the 2026-09-27 ConnectionRefused decision (loopback-bound host MCPs are unreachable from bridge-network containers via the LAN IP); rationale comment carried verbatim into the template.
5. (cosmetic) static SOC-A1 comment line removed for byte-parity; the manager-conf "Fires on every rule level" comment self-corrects via the level var (→10).

## Mid-cycle race + repair

- The compose `--force-recreate` raced the minutes-old daemon restart: the manager's stop threw "tried to kill container, but did not receive an exit event" (dashboard stopped, indexer recreated, manager half-created).
- Repair: plain, idempotent `up -d` (no force needed — the SHA marker had already recorded the change) started all three; the follow-up render cycle (logging blocks) re-canonicalized the manager's container name.
- Lesson: a dockerd restart + an immediate compose recreate = a shim-race window; sequence them apart or expect one retry.

## Final verified state

- **Re-scan: exit = 0** — pass=6 / fail=0 / skip=2 / except=1 (the reasoned runner row) — `docker-host-scan v0.1.0`.
- Containers 5/5 Up: manager (canonical name restored, secOpt ✓, log 10m/3 ✓, 12 bind entries), indexer (✓, 127.0.0.1:9200), dashboard (✓, 2-IP binds), mc (healthy, binds br1+ts0), runner (old object, excepted, untouched).
- Manager↔indexer: `IndexerConnector initialized successfully` (ossec.log) — SOC pipeline re-armed; agents reconnect on their keepalive windows.
- Endpoints: dashboard :5601 serving (404 on `/` is its normal root behavior via HTTPS), indexer :9200 → 401 (auth-gated, alive), REST API :55000 → 401 (alive).

## New findings routed onward (not touched in this wave)

1. **INDEXER_PASSWORD plaintext inside the rendered compose** (and a `SecretPassword` repo default) → HARD-4: run the indexer-credential rotation skill, then switch the template to env-file injection (the API_PASSWORD precedent lives in the same template).
2. **mc image = `itzg/minecraft-server:latest`** — digest pinning = the C-09/OPT-K17 policy work; documented, not executed.
3. **The manager container defines NO healthcheck** (no image-level, no compose-level): the role's health gate now falls back to `running` — a real `docker compose healthcheck:` should be added at HARD-4 so "healthy" becomes measurable.
4. **gitlab-runner's logs remain unbounded** until its HARD-5 recreation (log config pins at container create).

## Acceptance (per todo.md HARD-2)

- Kit scan exit 0 **or** documented EXCEPT list: ✓ (exit 0 + reasoned EXCEPT row)
- wazuh stack + gitlab-runner + mc healthy: ✓
- no unapproved `0.0.0.0` publishes: ✓ (all five bound, owner-approved; zero 0.0.0.0 left)
- miner: n/a (owner hold-off)