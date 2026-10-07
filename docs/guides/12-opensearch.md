# OpenSearch (inside wazuh-indexer 4.14.8) — hardening guide

_Sources: OpenSearch security documentation (vendor, no STIG/CIS). Fleet: Wazuh indexer 4.14.8 on thing1 (docker). Cred-rotation tooling already exists: the wazuh-indexer-rotation skill (workshop) covers indexer/dashboard internal-user credential rotation in the docker stack._

## What's already tooling (don't freehand)

- Default users (admin/admin-class) rotated: use the rotation skill — it does config + secret store + restart cleanly. Ad-hoc sed'ing of `/usr/share/wazuh-indexer` files inside the container fights the image and gets eaten on re-create.
- Certificates: the stack ships its own CA generation (wazuh-cert-tool); pin the certs, don't regenerate on every boot.

## Controls (either in volume-mounted config or via the skill's flow)

1. `internal_users.yml` — strip everything unused (demo users, test users); per-component hashed passwords only.
2. `opensearch.yml` (via config volume):

```
plugins.security.ssl.http.enabled: true
plugins.security.ssl.http.pemtrustedcas_filepath: <root-ca>
plugins.security.ssl.transport.* : pinned (node-to-node mutual TLS)
plugins.security.audit.type: internal              # security-audit trail inside the cluster
```

3. dashboards: bind 127.0.0.1 (or VPN-only interface) — never 0.0.0.0; if remote access is needed it goes through nginx/Caddy with auth (NGINX guide controls).
4. Filebeat-side TLS from the manager: pinned CA + client cert (the stack's default) — verify not silently downgraded.

## Data-plane hygiene

- Index retention/ISM: rollover + delete for noise indexes (`wazuh-alerts` retention matches the SOC ticketing history norms; no infinite keeps).
- Snapshot repos: off-host, encrypted restage (restic/borg over the snapshot dir) — same drill cadence as PG (quarterly restore test).
- API: never expose 9200 publicly; container networks keep it internal.

## Verify

```
docker inspect wazuh-stack-wazuh.indexer-1 --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -cE 'OPENSEARCH|PASSWORD'    # count only — never print values
curl -sku <admin> https://127.0.0.1:9200/_plugins/_security/authinfo         # roles/user mapping sane
curl -s https://127.0.0.1:9200/_plugins/_security/audit                      # audit logging enabled
ss -tlnp | grep 9200                                                         # bound interface right
```

## Change risk

- Rotation of internal users restarts the indexer; dashboards re-auth mid-scan drops in-flight agent queries — do rotations in a quiet window (skill already sequences this).
- Stripping internal_users.yml: leave the ones the manager/dashboards actually authenticate with or the whole SOC goes down together with everything else.