# Docker Engine + containers — hardening guide

_Sources: Container Platform SRG (active route — the Docker Enterprise STIG is legacy) + CIS Docker Engine Benchmark. Primary procedure is the committed kit `baselines/docker/` (PACK-4, done): run `docker-host-scan.sh` (read-only) first, `docker-host-harden.sh` dry-run then reviewed `--apply`; this guide is the control map behind the kit. Fleet: Docker 29.1.3 CE on thing1 + miner; containers: Wazuh stack, minecraft, gitlab-runner._

## Daemon (`/etc/docker/daemon.json`, owner root, 0644)

```
{
  "log-driver": "json-file",
  "log-opts":      { "max-size": "10m", "max-file": "3" },
  "live-restore": true,
  "default-ulimits": { "nofile": { "Name": "nofile", "Hard": 65536, "Soft": 65536 } },
  "icc": false          // per-stack decision: wazuh manager<->indexer talk internally; keep icc true there, false where not needed
}
```

`sudo systemctl restart docker` (rolling — announce; live-restore keeps containers up).

- Socket: `/var/run/docker.sock` `root:docker 0660`; nothing else — the socket is root-equivalent. Anyone in `docker` group = de-facto root: audit group membership.
- TLS-secured tcp:// API: not currently needed — keep the daemon on the socket only.

## Per-compose hardening (apply to wazuh-stack, miner, gitlab-runner, mc)

```
security_opt: ["no-new-privileges:true"]
cap_drop: ["ALL"]                 # then cap_add the minimum (e.g. NET_BIND_SERVICE for <1024 binds)
read_only: true + tmpfs: ["/tmp"] # where the image tolerates it; wazuh manager needs writable state — read_only off there
user: "<non-root-uid>"            # where the image supports it (mc/itzg do; wazuh images ship root defaults — container hardening is a Wazuh-side task, see 16)
ports: "127.0.0.1:8081:8081"      # never 0.0.0.0 unless the service is meant to be exposed
mem_limit / pids_limit           # each container; miner trading bots especially (blast radius)
```

No `privileged: true`, no `network_mode: host`, no bind-mounts of `/var/run/docker.sock` into containers (gitlab-runner shell executor is the known offender — fixed by the Runner section of the GitLab guide).

## Image supply chain

- Pin by **digest** (`image: repo/name@sha256:...`) for anything long-lived; tags only in dev.
- Pull only from allowlisted registries; roadmap already prefers Iron Bank where we rebuild.
- No root-owned secrets inside images; inject via env files (0600, outside git) or mounted secrets.
- `docker history` spot-check on third-party images; re-pull quarterly to catch base fixes (wazuh 4.14.8 → follow the 4.14.x line, not :latest).

## Host-level

- auditd on the docker control plane:

```
-w /usr/bin/docker -p x -k docker
-w /var/lib/docker -p wa -k docker
-w /etc/docker -p wa -k docker
-w /usr/bin/dockerd -p x -k docker
-w /var/run/docker.sock -p wa -k docker
```

- `docker-bench-security` (CIS Docker mapping): `docker run --rm ... docker/docker-bench-security` — triage each finding into `baselines/docker/controls.yaml` (fix via the kit, or `ignore_list.yml` with a reason line).

## Verify

```
docker info --format '{{json .SecurityOptions}}'
docker ps --format '{{.Names}}\t{{.Ports}}'          # any 0.0.0.0 publish is a review flag
docker inspect --format '{{.Name}} {{.HostConfig.Privileged}} {{.HostConfig.NetworkMode}}' $(docker ps -q)
auditctl -l | grep docker
ss -tulpn | grep dockerd                            # daemon listens only on the socket
```

## Change risk

- `icc:false` globally breaks the Wazuh internal network — set per-stack network, not daemon-wide.
- `userns-remap` rewrites bind-mount UID semantics (wazuh volumes + mail-host patterns) — phase 2, per host, tested first.
- Rootless docker: same UID issues + needs runc changes — schedule only after the kit exists so we can measure.