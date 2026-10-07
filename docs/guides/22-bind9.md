# BIND 9 (conditional — idm) — hardening guide

_Sources: BIND 9.x DNS STIG (roadmap Tier 1 #8 — conditional on running BIND on idm), ISC documentation. This guide activates only when the idm BIND deployment is real; do not run its controls as busywork on a host without named._

## named.conf controls

```
options {
  directory "/var/named";
  version "none";                                # never banner the version string
  listen-on port 53 { <lan-if-ip>; };            # NO 0.0.0.0/::0 catch-alls
  recursion yes;
  allow-recursion { localnets; <trusted-cidrs>; };
  allow-query { localnets; };                    # per-zone override for public zones
  allow-transfer { keys "secondary-key"; };       # TSIG keys for any secondaries — no IP-only, never any
  also-notify { <secondary ips>; };
  rate-limit { responses-per-second 10; window 5; };   # mitigation mode — RRL for reflection/amplification
  minimal-responses yes;
  minimal-any yes;
  dnssec-validation auto;                         # + sign authoritative zones per the DNSSEC runbook (kasp policy on 9.16+)
  empty-zones-enable yes;
  managed-keys-directory /var/named/dynamic;      # 0700 named:named
};
key "secondary-key" { algorithm hmac-sha256; ... };    # secret 0600, not committed
```

- Updates: `allow-update` **only** with TSIG keys on dynamic zones; no open `update` ever; journal files watched in auditd.
- named runs as `named` user (`named -u named` via unit), no chroot needed on modern distros; `named.conf` + zone file perms `0640 root:named` / master files owned named.
- Controls channel: `rndc` via local unix socket (or 127.0.0.1 + key 0600); rndc key never in shared docs.

## Zone hygiene

- Only the zones we own/serve; no secondary-for-others unless deliberate; SOA/serials managed with the repo's git-ops pattern.
- Public zones (the stsgym/stsphotos/bedimsecurity family): review record bloat + SPF/DMARC/MTA-STS in coordination with the mail guide (23) — DNS is half the mail story.

## Verify

```
named-checkconf -z                                  # config + zones valid
dig @localhost chaos version.bind txt +short        # "none" — no version banner
dig @localhost +dnssec <signed-zone>                # RRSIGs present (if signing enabled)
rndc status                                         # recursion/rate-limit stats sane
ss -tlnup | grep :53                                # bound to the intended interface(s) only
grep -E 'allow-(recursion|transfer|query|update)' /etc/named.conf
```

## Change risk

- Tight `allow-recursion` breaks resolvers we actually use (lab VMs, pve guests) — enumerate every resolver network BEFORE the ACL change; dig-test from each named client class.
- DNSSEC signing is a one-way-looking change (record bloat, validation failures on mistakes) — dry-sign one public zone, watch propagation, then continue.