# PostgreSQL — hardening guide

_Sources: PostgreSQL STIG (9.x-era baseline) + Crunchy Data PostgreSQL STIG V3R2 (both named in the roadmap Tier 1 #4), CIS PostgreSQL Benchmark. Fleet: Patroni cluster (miner/lab), GitLab-bundled PG on the forge._

## Instance config (`postgresql.conf` or Patroni bootstrap)

```
listen_addresses = '<mgmt-ip>, <cluster-ips>'   # never '*'
ssl = on
ssl_min_protocol_version = 'TLSv1.2'
ssl_cert_file / ssl_key_file  (key 0600, owner postgres)
password_encryption = 'scram-sha-256'
log_connections = on
log_disconnections = on
log_lock_waits = on
log_min_duration_statement = 1000     # ms — statement-level telemetry without spam
log_statement = 'ddl'
log_line_prefix = '%m [%p] %u@%d %h '
shared_preload_libraries = 'pgaudit'  # pgaudit.log = 'ddl, write' for the audit trail the STIG wants
```

File perms: data dir `0700 postgres:postgres`; `postgresql.conf` / `pg_hba.conf` `0640 postgres:postgres`.

## pg_hba.conf discipline

- Re-hash: every line `md5` → `scram-sha-256`; no `trust` anywhere (incl. `local` — keep `peer postgres` only).
- No `0.0.0.0/0` sources; replication lines restricted to the actual cluster node IPs.
- App connects via a dedicated DB user, no peer/ident shortcuts into app roles.

## Roles / least privilege

- App roles: `LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION`; ownership separation (owner ≠ connector).
- PG15+ `public` schema already revoked from PUBLIC — confirm via `\dn+ public` (older branches: `REVOKE ALL ON SCHEMA public FROM PUBLIC`).
- Admin sessions: separate role, `SET ROLE` practice, no interactive psql as superuser for routine work; superuser password stored with the secrets store (600), rotate like the indexer creds (same pattern as the Wazuh rotation skill).

## Patroni specifics

- `restapi`: TLS + `restapi.auth` set; `etcd3`: TLS (`ca_file`/`cert_file`) — plaintext etcd = cluster takeover path.
- `postgresql.create_replica_methods` reviewed; superuser_password in the Patroni env files at 0600, not in `patroni.yml` in git.

## Backups / PITR

- WAL archiving on (`archive_mode=on`) to an encrypted off-host restage; pgBackRest or wal-g; retention documented; **restore drill quarterly** — a backup without a drill is a rumour (SOC data is the crown jewel).
- Snapshots for the drill come from the tool, not file copies of the data dir.

## GitLab-bundled PG (forge)

- Config via `gitlab.rb` only (versioned here = drift detection per the roadmap): `postgresql['listen_address']`, `postgresql['sql_user_password']` (bcrypt), `postgresql['ssl_*']` keys.
- Never hand-edit `/var/opt/gitlab/postgresql/` — `gitlab-ctl reconfigure` will eat it.

## Verify

```
psql -Atc "SHOW password_encryption; SHOW ssl; SHOW log_connections;"
SELECT rolname, rolsuper, rolreplication FROM pg_roles WHERE rolcanlogin;   -- audit the list
SELECT version();   -- track 14/15/16 line, no EOL majors
grep -n 'md5\|trust' $PGDATA/pg_hba.conf          -- empty is the goal
Tenable PostgreSQL audit file run (roadmap tooling) + Crunchy STIG V3R2 checklist pass
```

## Change risk

- SCRAM flip: users whose stored verifier is md5 fail until they log in once with a valid password — set SCRAM verifiers explicitly for service accounts before the cutover.
- `ssl_min_protocol_version` breaks ancient clients (none currently known on the fleet — psql/odbc all fine).