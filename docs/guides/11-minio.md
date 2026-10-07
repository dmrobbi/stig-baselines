# MinIO / object storage — hardening guide

_Sources: no product STIG — custom benchmark from the General Application SRG + encryption CCIs (roadmap Tier 3) + MinIO's own docs/checklist. Fleet: miner stack object storage (trading data)._

## Transport / network

- TLS mandatory from day one: `MINIO_CERT_DIR` with server cert+key (0600), no plaintext endpoint in prod; `tls-min-version` via MinIO's config if pinned older builds (current builds: TLS 1.2+).
- Bind to the interfaces that matter (`MINIO_OPTS`/args — not 0.0.0.0 when only miner apps are clients); keep the console port off the public interface.
- Console: disable entirely if unused (`MINIO_BROWSER=off`), else TLS + auth behind the nginx proxy (HSTS/CSP per the NGINX guide).

## Identity / access

- **Root creds are break-glass, not app creds**: after setup, generate per-app service accounts (`mc admin user add`) with least-privilege policies (`mc admin policy` per bucket), disable root access keys; root password lives in the secrets store (0600), not in compose env committed to git.
- Bucket policies: closed by default; explicit per-app allows; no `s3:*` on `arn:*:*:*/*`.
- Versioning + object-lock (compliance mode) on audit/finance-adjacent buckets — immutable evidence beats "oops".
- Access keys rotated on schedule (same cadence decision as PG/Wazuh creds), documented in the kit controls when built.

## Encryption / data

- Encryption at rest: SSE-S3 (built-in) at minimum; KES/vault integration is the full-fat path if key custody requirements grow.
- Replication/version pruning documented; snapshots off-host encrypted (the PG drill discipline applies).

## Runtime (container on miner)

- cap_drop ALL, no host network, explicit memory limit (IO-heavy — don't OOM the node), data volume 0700 owner matching the container user; log to file/json with rotation (audit access logs ON: `MINIO_AUDIT_CONSOLE`? keep the console off, file audit enabled).

## Verify

```
mc admin info <alias>            # TLS up, mode sane, version current-ish
mc admin user list <alias>       # root not in daily use; per-app users present
mc anonymous get <alias>/<bucket>    # no bucket is world-downloadable
curl -sI https://<s3-host>/      # TLS min version via testssl.sh spot check
docker inspect minio (cap_drop, port binds)
```

## Change risk

- Disabling root access keys breaks old scripts still embedded with root creds — migrate scripts to service accounts first (the `mc` alias files under `~/.mc/` on the hosts are the usual suspects).
- Object-lock/compliance mode is irreversible per object once set — apply only to buckets whose retention policy is signed off.