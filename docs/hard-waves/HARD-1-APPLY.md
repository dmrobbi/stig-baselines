# HARD-1 apply — Ubuntu fleet hardening wave

_2026-10-07 evening. Owner go received ("do #1"); **miner held off by owner** — no contact made. Companion to [HARD-1-PREFLIGHT.md](HARD-1-PREFLIGHT.md) (the "before" state). Method: staged drop-ins over BatchMode ssh with NOPASSWD sudo (thing1 executed locally), post-verify sweep per host, zero reboots, zero service disruption._

## Applied per host

### thing1 (gateway, executed locally)

- `/etc/sysctl.d/60-hardening.conf` — 14-control durable set (kptr 2, send_redirects 0, bpf 2, yama 1, protected_*, mmap_min_addr). `ip_forward`/`rp_filter` untouched (gateway/asymmetric-routing roles).
- `/etc/ssh/sshd_config.d/10-hardening.conf` — MaxAuthTries 12→4, LoginGraceTime 120→30, X11Forwarding no reassert. **PasswordAuthentication left yes — gate fail (see Holds).**
- ModemManager apt-removed (was active noise on a gateway).
- auditd: unchanged — already at the fleet template (61 rules, active+enabled; this host's template seeded the others).
- sysctl reload via targeted `sysctl -p`; sshd via `ssh -t && reload`; both green, docker/k3s/wazuh stack untouched (ports identical to preflight).

### trooper2

- sysctl drop-in (same file) — loaded clean.
- sshd `10-hardening.conf` full flip: **passwordauthentication no**, kbdinteractive no, maxauthtries 6→4, logingrace 120→30, x11 yes→no. Cloud-init's `50-cloud-init.conf` (which ships `PasswordAuthentication yes`) now loses under first-value-wins semantics — 10- precedes it. Gate evidence: one password login in 30d (Sep 15, one-off); keys in active use; `wez` has 6 authorized keys.
- auditd: **was absent** — installed via apt, rules pushed to BOTH `/etc/audit/rules.d/50-hard1.rules` and `/etc/audit/audit.rules` (thing1's generated template, 67 lines incl. `-e 2`), `augenrules --load` → 61 rules active + enabled.
- ModemManager removed.
- Verify: post-flip BatchMode round-trip from thing1 = `ok`; full sweep green.

### gus2

- Same as trooper2 (sshd flip; sysctl; auditd installed + armed, 61 rules, active+enabled; ModemManager removed).
- Gate evidence: **zero password logins in 30d** — cleanest host; `wez` has 1 authorized key, in active use.
- Verify: round-trip ok; sweep green.

## Holds (evidence-gated, per the wave rules)

| Hold | Host | Evidence | Unhold path |
|---|---|---|---|
| `PasswordAuthentication no` | thing1 | 8 accepted **password** logins in 30d from `10.8.0.1` (VPN-side source), 4 on apply day — an active access path, hours before the wave | install a key on the VPN-side device/user, verify it works, then flip in a follow-up |
| cups removal | trooper2 | printer `PDF` (cups-pdf virtual) configured and enabled since May — something may print via it | owner confirms no consumer → remove in a follow-up |
| everything miner | miner | owner hold-off | — |

## Still-open decision gates (pre-existing, untouched)

1. thing1 **ufw activation plan** — docker/k3s interplay (DOCKER-USER chain per guides/06); a wrong DROP cuts container ingress on the gateway.
2. thing1 docker `0.0.0.0` publishes — dashboard 5601, manager 1514-1515/514udp/55000, minecraft 25565 (indexer already 127.0.0.1). Bound-interface or DOCKER-USER allowlist, owner's call on intended reachability.

## Lessons folded into guides/01-ubuntu.md (this commit)

1. sshd drop-in **naming**: `10-hardening.conf`, not 50- — lexical load order + first-value-wins (cloud-init ships `PasswordAuthentication yes` in 50-).
2. `unprivileged_bpf_disabled = 2` (fleet-validated; stricter than the STIG's 1).
3. auditd durable path on Ubuntu 24.04: copy the generated `/etc/audit/audit.rules` template to targets as rules.d + audit.rules, `augenrules --load`; `-e 2` → later rule edits need a reboot; install auditd first where absent.
4. apt-over-ssh: a timeout-killed ssh leaves the remote apt running attached to nothing but the lock — poll and join, never collide (gus2's first install completed detached, mid-sweep).

## Post-state snapshot (all three hosts)

Sysctl green (send_redirects 0 / kptr 2 / bpf 2 / yama 1); auditd 61 rules, active+enabled; ssh active; fail2ban active; ModemManager inactive; passwordauth no (trooper2, gus2) / yes-held (thing1); ufw active (trooper2, gus2) / inactive-held (thing1); cups inactive except the held trooper2 one.