# Tailscale / WireGuard mesh — hardening guide

_Sources: Tailscale Security and ACL documentation (vendor — no product STIG; VPN SRG legacy per roadmap Tier 3), WireGuard's design docs (key hygiene). Fleet: tailscaled/WG mesh across home + hosts; the openvpn@red stays the raw-VPN surface (guide 20)._

## Tailscale controls

1. **ACLs least-privilege** first: review the admin-console ACL policy — default-deny posture, named grants per device group; the "everything can reach everything" starter ACL is not a fleet policy. Version the ACL JSON in this repo as config-as-code.
2. **Key expiry enforced** on devices (90-180d) with a documented re-auth runbook — expiry that surprises the owner is worse than weak keys; pair with the approval flow.
3. Device approval flow ON (new node = explicit approve), tags instead of user-as-identity for infra (tag:server/tag:soc patterns) — tag-owned nodes don't inherit a person's access.
4. Tailscale SSH: disabled unless a real use-case exists (shell over SSH stays the audited path — journald/session rules).
5. Funnel (public exposure of a node port): **off** fleet-wide; if ever needed it gets its own review + guide.
6. Exit nodes: only approved nodes offer exit routing; clients pick it deliberately (routing surprises = leaks).
7. MagicDNS: fine to keep; make sure no device publishes admin endpoints on it (the soc services stay 127.0.0.1 — guide 17).
8. Logging: Tailscale's config/audit logging (off-host by design) acknowledged; sensitive network layout still not committed anywhere public (repo-scrub rule).

## Raw WireGuard (any direct interface)

- Private keys: `0600` on-disk, per-device, never committed anywhere (same scrub rule).
- `[Peer]` blocks on the "server" side: minimal `AllowedIPs` (the peer's actual tunnel IP), not `0.0.0.0/0` unless it is the internet-exit peer by design.
- `PersistentKeepalive` on NAT-ed home peers only; Endpoint addresses stable; no shared keys across devices.
- Firewall: forward rules only for approved subnets; the WG interface is a zone, not the LAN (isolate from the red LAN segmentation unless deliberate).

## Verify

```
tailscale status                                    # devices, online, expiry visible
tailscale status --json | jq '.Peer[].KeyExpiry'    # rotation timeline reviewed
tailscale debug acl? (via admin console — ACL dump diffed vs the repo copy)
wg show                                             # per-interface: no missing handshakes, AllowedIPs sane
ss -tlnp | grep tailscaled                          # local API bound locally
```

## Change risk

- ACL tightening mid-flight cuts live access (including our own management paths) — stage: ACL apply is previewable in the console; review the diff, confirm the management device has a standing grant, then apply.
- Forced key expiry without an approval runbook = devices drop off silently — schedule expiry to business hours, not 3am.