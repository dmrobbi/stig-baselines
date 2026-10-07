# NGINX — hardening guide

_Sources: **F5 NGINX STIG V1R1** (product STIG, pub. 2025-11-25 — 32 rules; the "no product STIG" note in the roadmap is obsolete) + **CIS NGINX Benchmark v3.0.0**. Fleet: thing1 reverse proxy, mail-host vhosts (apex/landing pattern per the mail-host skill), forge-bundled nginx (GitLab owns that one — changes go through `gitlab.rb`, not files)._

## Baseline block (per vhost/server)

In `server_tokens`/headers territory first:

```
server_tokens off;
add_header X-Frame-Options "DENY";            # or SAMEORIGIN per app — pick and apply consistently
add_header X-Content-Type-Options "nosniff";
add_header Referrer-Policy "strict-origin-when-cross-origin";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;   # HSTS: on TLS vhosts only
# CSP per app (the demo player needed 'wasm-unsafe-eval' — pattern: tighten to the app, allowlist, verify)

ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...';   # STIG/CIS-acceptable set; no CBC/AES-CCM? follow F5 STIG list
ssl_session_tickets off;
ssl_stapling on; ssl_stapling_verify on;       # where the cert chain allows
autoindex off;
```

- Deny-dotfile block: `location ~ /\.

{ deny all; }` (covers `.git`, `.env`, etc. — the WordPress/mail vhosts carry sensitive dirs).

## Runtime/systemd sandboxing on the host (`/etc/systemd/system/nginx.service.d/override.conf`)

```
[Service]
NoNewPrivileges=true
ProtectSystem=full
PrivateTmp=true
ProtectHome=read-only            # "true" blocks webroots under /home/wez (mail-host player class) — read-only keeps them servable; verify a curl round-trip per vhost after tightening
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX AF_NETLINK
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID CAP_CHOWN CAP_DAC_OVERRIDE   # nginx needs binds <1024 + master setuid dance
UMask=0027
```

`sudo systemctl daemon-reload && sudo systemctl restart nginx`.

## Per-fleet specifics

- **thing1 proxy**: only the app ports (site-status 8881, soc dashboard, canvas) are proxied; publish nothing wide-open; `limit_req` zones on login-ish endpoints.
- **mail-host vhosts**: apex→www 301 + per-vhost access_log already the pattern (per the mail-host skill) — keep; `client_max_body_size` per vhost (WordPress uploads), `resolver` timeouts set (proxying quirks), block direct IP:80/443 default vhost.
- **forge-bundled**: don't touch `/var/opt/gitlab/nginx` — `gitlab.rb nginx['...']` keys only (TLS min version there via `nginx['ssl_protocols']`).

## Verify

```
nginx -T | grep -nE 'server_tokens|ssl_protocols|add_header'    # effective config review
testssl.sh --protocols <host>                                   # TLS1.0/1.1 must fail
curl -sI https://<vhost>/ | grep -Ei 'strict-transport|x-frame|x-content-type|server'
systemd-analyze security nginx.service                          # target: high score w/o breaking
```

## Change risk

- HSTS is a loaded gun (broken TLS = broken domain for max-age) — enable per vhost after TLS is stable, short max-age first.
- CapabilityBoundingSet without NET_BIND_SERVICE = nginx can't bind 80/443 → total outage; test with `nginx -t` + a curl round-trip before closing the SSH session.