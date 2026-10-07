# Custom services (soc-*, laya-bridge, imap-watcher, realtime-soc-server) — hardening guide

_Sources: Application Security and Development STIG V6R4 (applies to our in-house apps — roadmap Tier 1 #5), OWASP ASVS for the dev checklist, systemd sandboxing (RHEL/CIS service hardening pattern). Fleet: the soc-* bridge/MCP services, soc-dashboard, realtime-soc-server, laya-bridge, imap-watcher running as systemd units on thing1._

## Systemd sandboxing (per service unit — same template everywhere)

```
/etc/systemd/system/<svc>.service.d/harden.conf
[Service]
User=<dedicated-user>            # or DynamicUser=true where the service holds no shared state
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=<the service's actual state dirs>   # e.g. /home/wez/.openclaw/soc/data — per service, minimal
ProtectHome=true                  # per-unit check: state under /home/wez must be re-exposed via ReadWritePaths — verify the real startup flow, else drop this line for that unit
PrivateTmp=true
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
CapabilityBoundingSet=
UMask=0027
MemoryMax=1G                     # per service profile
RestrictSUIDSGID=true
```

`systemctl daemon-reload && systemctl restart <svc>` then exercise the real path (a triage decision, an MCP call) before moving to the next unit — one service at a time.

- EnvironmentFile files: `0600`, owned root or the service user; no secrets in unit files.

## Application controls (App-Sec-Dev STIG V6R4 walkthrough for the code)

1. **Input validation**: every externally-fed field (Wazuh alerts via MCP, mailbox JSON, ticket payloads) parsed via schema (pydantic/JSON Schema) before use — not regex-hope.
2. No `eval`/`exec`/`os.system` with built strings; subprocess calls use arg lists, no shell=True.
3. **Crypto**: TLS everywhere outbound; no custom hashing; secrets from env/secret store only (grep the trees for hardcoded tokens — the repo-scrub discipline already proved this class of issue exists).
4. **Authorization checks** on every endpoint the services expose to each other — local-only does not mean unauthenticated: a token constant per pair, or unix-socket peer creds.
5. Error handling: never leak stack traces/paths into MCP responses, dashboards, or tickets (paths leak = recon gift — lesson visible in prior scrub work).
6. Logging: journald, no credentials/tokens in logs; `journalctl -u <svc>` usable as the audit trail.
7. Dependencies: pinned via lockfiles; `pip-audit` (or `safety`) in CI per repo; renovate/dependabot cadence for the SDKs (openclaw, wazuh-api, google-api libs).

## Network

- All these services bind `127.0.0.1` (MCP/soc ports — 8771/8765 class endpoints; verify with `ss -tlnp`): anything needing remote reach goes behind nginx with auth (guide 13), never a raw published port.
- soc-dashboard: same rule; token/session auth, session timeout set.

## Verify

```
systemd-analyze security <each-unit>          # score trend; explainable misses OK with reason
systemctl cat <unit> | grep -vE '^#'          # effective hardening block present
ss -tlnp | grep -E '8771|8765|soc'            # 127.0.0.1 binds only
pip-audit -r <repo>/requirements.txt          # no known-CVE deps at pinned versions
bandit -r <service-source> -q                 # baseline findings reviewed, count recorded
```

## Change risk

- `ProtectSystem=strict` without the right `ReadWritePaths` makes a service that can't write its state (silent failure mode: the service runs, then breaks on first write — exercise real flows after each restart).
- Token-based neighbor auth: a wrong constant breaks the pair silently — rotate one pair at a time.