# OpenVPN (@red) — hardening guide

_Sources: no product STIG; vendor security docs + community hardening consensus (this is our own checklist route). Fleet: openvpn@red server unit on thing1 — the red network is the VPN boundary._

## server.conf controls (per-instance, verified against the live config)

```
tls-version-min 1.2
data-ciphers AES-256-GCM:CHACHA20-POLY1305:AES-128-GCM       # AEAD only
auth SHA256                        # auth digest — never MD5/SHA1
tls-crypt /etc/openvpn/red/ta.key  # upgrade from tls-auth if clients allow (hides the TLS handshake)
duplicate-cn off                   # default — do NOT enable shared-cert reuse
client-to-client off               # unless a client mesh is an actual requirement (review if)
push "route <only what clients need>"        # minimal route pushes, no 0.0.0.0/0 unless it's the exit path by design
user nobody
group nogroup                      # + persist-key/persist-tun in place
status /var/log/openvpn/red-status.log 0600? (status file — perms minimal)
log-append /var/log/openvpn/red.log
management disable                  # or bind 127.0.0.1 with a password if tooling needs it
mlock
replay-window (defaults — do not widen)
keepalive 10 60
explicit-exit-notify 1
```

- Certs: CA + server cert ≥ EC/RSA-2048 (prefer ECDSA), key/cert files `0600 root`, `crl-verify` ACTIVE and the CRL actually rotated — an un-rotated CRL is decoration.
- Client certs: per-device certificates with sane lifetimes; revocation runbook documented (revoke = generate CRL + reload, test one client in, one revoked client out).
- Client configs distributed with private keys NOT embedded in shared docs/chats — single-user delivery, and the repo-scrub rule (no certs/keys/identifiers in public/shared repos) applies to any client template committed here.
- ufw/edge: the VPN port allowed ONLY where clients live; the OpenVPN port is not an advertised service — no port publishing on the WAN beyond what routing requires.

## Verify

```
openvpn --help | head -1                            # version current-ish (2.5+/2.6 series)
ss -tlnup | grep -E '1194|openvpn'                  # binds right interface(s) only
grep -EE 'tls-version-min|data-ciphers|auth |tls-crypt|crl-verify|duplicate-cn|client-to-client' /etc/openvpn/red/server.conf
openssl x509 -in <ca.crt> -noout -dates             # CA validity review
journalctl -u openvpn@red -n 100                    # no repeated VERIFY ERROR storms (brute force indicator)
fail2ban status                                     # jail optional for repeated TLS failures (phase 2)
```

## Change risk

- Cipher/tls-crypt changes require coordinated client updates — stage: server accepts old+new (`data-ciphers` list includes the old suite temporarily), flip clients, then drop the legacy from the list.
- `crl-verify` with a stale path after a config move = hard outage; run `openvpn --config test` + one live client after any cert change.