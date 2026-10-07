# HARD-1 preflight — Ubuntu fleet baseline sweep

_Commit 2026-10-07. Read-only inspection only — no host was modified (per the wave gate in `todo.md`). thing1 inspected locally; trooper2/gus2 via BatchMode ssh (user wez); **miner** did not resolve from thing1 — needs the correct ssh alias before its apply pass. Source targets: [docs/guides/01-ubuntu.md](../guides/01-ubuntu.md) + the host layer of [06-docker.md](../guides/06-docker.md)._

## Findings vs guide targets

| Check | thing1 | trooper2 | gus2 | Target (guide-01) |
|---|---|---|---|---|
| OS | Ubuntu 24.04 gateway | Ubuntu 24.04.5 | Ubuntu 24.04.5 | — |
| PasswordAuthentication | **yes** | **yes** | **yes** | no (two-session gate) |
| MaxAuthTries | **12** | 6 | 6 | 4 |
| LoginGraceTime | **120** | **120** | **120** | 30 |
| X11Forwarding | no ✓ | **yes** | **yes** | no |
| PermitRootLogin | no ✓ | no ✓ | without-password ✓ (prohibit-password) | prohibit-password |
| ufw | **inactive** | active ✓ | active ✓ | deny-incoming + mgmt-only ssh |
| fail2ban | ✓ (sshd, nginx-http-auth) | active ✓ | active ✓ | sshd jail + recidive |
| auditd rules | full set ✓ (identity/exec/EACCES/EPERM) | **0 rules** | **0 rules** | baseline rule set |
| unattended-upgrades | ✓ "1" | ✓ | ✓ | on |
| needrestart | installed ✓ | — | — | installed |
| ModemManager | **active** | **active** | **active** | removed on servers |
| cups | inactive ✓ | **active** | inactive ✓ | removed on servers |
| docker published ports | **dashboard 5601, manager 1514-1515 + 514/udp + 55000, minecraft 25565 — all 0.0.0.0** | satellite stack bound 127.0.0.1:5006 + internal db/redis ✓ | (no ps output — needs root path) | 127/internal binds only |
| accept_redirects | 0 ✓ | 0 ✓ | 0 ✓ | 0 |
| send_redirects | **1** | (not swept — apply-phase check) | (not swept) | 0 |
| kptr_restrict | **1** | **1** | **1** | 2 |
| dmesg_restrict | 1 ✓ | 1 ✓ | 1 ✓ | 1 |
| unprivileged_bpf_disabled | 2 ✓ | 2 ✓ | 2 ✓ | 1 (2 = tighter) |
| yama.ptrace_scope | 1 ✓ | 1 ✓ | 1 ✓ | 1 |
| fs.protected_* | all ✓ | — | — | on |
| ip_forward | 1 (expected: gateway/docker/k3s) | — | — | keep on thing1 |

## Apply-wave deltas (staged here, applied only after owner go)

1. **sshd drop-in, all hosts** — `PasswordAuthentication no` **gated on key-verification of every access path + the two-session rule** (thing1 is a live gateway; a lockout here cuts off the fleet), `MaxAuthTries 4`, `LoginGraceTime 30`, `X11Forwarding no` (trooper2, gus2).
2. **auditd baseline rules** on trooper2 + gus2 (the thing1 set from `/etc/audit/rules.d/` is the template; identity/exec/EACCES/EPERM subset per guide-01).
3. **Service pruning** — ModemManager on all three; cups on trooper2 (confirm no printer use first).
4. **sysctl drop-in** — `kptr_restrict=2` (all three), `send_redirects=0` (thing1; verify remotely before applying to trooper2/gus2); keep `ip_forward=1` on thing1 (gateway/docker/k3s) and add the guide-01 `fs.protected_*`/syncookies set as a drop-in where not already effective.
5. **thing1 decision gates (owner input, not auto-apply)** — ufw activation plan on the gateway host (docker+k3s interplay: DOCKER-USER rules per guide-06; a wrong DROP cuts container ingress), and the three `0.0.0.0` docker publishes (bind 127.0.0.1/LAN iface, or DOCKER-USER allowlists). Exposure is currently gated by whatever NAT/VPN boundary the red network has — confirm the intended reachability of dashboard 5601 / manager 1514-1515/55000 / minecraft 25565 before touching binds.
6. **miner** — pending correct ssh alias from the host's known_hosts/manual config; same sweep runs on resolution.

## Notes

- unprivileged_bpf_disabled=2 on all hosts means "disabled permanently until reboot" — fine, but a kernel bump resets to the distro default; the sysctl drop-in makes the hardened state durable across reboots.
- thing1's auditd set is already better than the guide minimum — apply-wave copies it as the template for the other hosts rather than re-deriving.
- No host config was changed in this pass; the next artifact is the per-host diff files for the apply commit, built from guides/01 + guides/06 host layer.