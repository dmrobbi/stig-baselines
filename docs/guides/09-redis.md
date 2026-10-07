# Redis — hardening guide

_Sources: CIS Redis Benchmark, Redis.io security guidance (vendor). Fleet: GitLab-bundled Redis on the forge (roadmap Tier 2 layer 2: "no STIG; Redis hardening guide + SRG" — CIS is the checklist source since there's no Redis STIG)._

## Standalone pattern (if we ever run our own)

`/etc/redis/redis.conf`:

```
bind 127.0.0.1                  # or the service-facing IP + ACL — never 0.0.0.0
protected-mode yes
port 6379, tls-port if remote: tls-port 6379 + port 0, tls-min-protocol TLSv1.2
requirepass replaced by ACL (below)
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command CONFIG ""
rename-command DEBUG ""
rename-command SHUTDOWN "SHUTDOWN_<secret>"   # documented IN controls, breaks nothing day-to-day
maxmemory <size> + maxmemory-policy noeviction  (cache workloads differ — per-deploy)
appendonly yes
dir /var/lib/redis (owner redis, 0700)
```

ACL users (replaces blanket password):

```
user default off
user app on ><app-secret> ~<prefix>:* +@readwrite -@dangerous
```

(`@dangerous` = MONITOR, SCRIPT-type and admin classes per the ACL set — keep app users off them.)

Systemd sandbox for the standalone service: `ProtectSystem=full`, `ReadOnlyPaths=/etc/redis`, `PrivateTmp=true`, `NoNewPrivileges=true`, `StateDirectory=redis`.

## GitLab-bundled (the actual deployment)

Config belongs in `gitlab.rb` (versioned here = drift detection):

```
redis['password']          # set explicitly, hashed — do not rely on auto-generated unbounded defaults
redis['bind']              # default localhost — keep unless a dedicated split-redis layout says otherwise
redis['port'] = 0          # unix socket preferred when everything is co-located
redis['unixsocket'] / redis['unixsocket_perm'] = '0770' with group gitlab-redis+git
```

Never hand-edit `/var/opt/gitlab/redis/` — `gitlab-ctl reconfigure` owns it.

## Verify

```
redis-cli CONFIG GET protected-mode maxmemory appendonly      # expected safe values
redis-cli ACL LIST                                            # default user OFF, least-privilege users only
redis-cli INFO persistence | grep -E 'aof|rdb_last'
openssl s_client -connect <host>:6379                         # TLS enforced where remote
ss -tlnp | grep :6379                                         # bound to 127.0.0.1/socket only
```

## Change risk

- Renamed commands break upgrade tooling and some clients (redis-py migrations use `CONFIG`) — document the rename table in `controls.yaml` and re-add per tool with scoped ACL verbs instead of blanket CONFIG access.
- ACL flip with `user default off` locks out anything still using `requirepass`-style access — set ACLs first, then close the default user.