# Ubuntu LTS hosts — hardening guide

_Covers thing1 (24.04), trooper2, miner, and lab VMs. Sources: Canonical Ubuntu 24.04 / 22.04 / 20.04 LTS STIGs (CKL baselines in `baselines/ubuntu24.04|22.04|20.04`), CIS Ubuntu Benchmarks, the SSG CIS profile as the oscap fallback (no DISA SCAP exists for Ubuntu)._

## Patching

1. `sudo apt install unattended-upgrades needrestart` and confirm `/etc/apt/apt.conf.d/20auto-upgrades` has both lines set to `"1"`.
2. Set `needrestart` to batch mode for unattended runs: edit `/etc/needrestart/needrestart.conf` → `$nrconf{restart} = 'i';` stays interactive, but run security-only restarts in maintenance windows.
3. Weekly: `sudo apt update && apt list --upgradable` review; kernel livepatch optional on servers.

## SSH (per OS-STIG controls)

Edit `/etc/ssh/sshd_config.d/50-hardening.conf`:

```
PermitRootLogin prohibit-password
PasswordAuthentication no          # ONLY after confirming every host/key path; verify in a second session
PermitEmptyPasswords no
MaxAuthTries 4
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no              # drop this only where tunnels are required (thing1 dev hosts)
UseDNS no
KbdInteractiveAuthentication no
```

Then `sudo sshd -t && sudo systemctl reload ssh`. Verify with `sudo sshd -T | grep -E 'permitrootlogin|passwordauth|maxauthtries'`.

## Firewall

- `sudo ufw default deny incoming; sudo ufw default allow outgoing`.
- Allow SSH from the management subnet only: `ufw allow from <mgmt-cidr> to any port 22 proto tcp`.
- Docker hosts (thing1, miner): `ufw` does NOT block published container ports (iptables precedes it). Bind published ports to `127.0.0.1` or a private interface in compose files, and add explicit rules in the `DOCKER-USER` chain:

```
sudo iptables -I DOCKER-USER -i eth0 ! -d <allowed-ip> -j DROP
```

- thing1 specifics: allow 22 (mgmt), 443 if nginx publishes, keep k3s API (6443) off the WAN; OpenVPN uses the existing `openvpn@red` port.

## Kernel sysctl — `/etc/sysctl.d/60-hardening.conf`

```
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1   # set 0 only where asymmetric routing exists (k3s/CNI edges)
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.unprivileged_bpf_disabled = 1
kernel.yama.ptrace_scope = 1
fs.protected_symlinks = 1
fs.protected_hardlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2
vm.mmap_min_addr = 65536
```

Apply with `sudo sysctl --system`. Careful on thing1: docker+k3s need `net.ipv4.ip_forward=1` and bridge netfilter — the guide does not touch those.

## Audit

- Install/confirm `auditd` (already running on thing1). Seed at minimum the identity/time/network rules (Ubuntu STIG controls live in the CKL baselines for the full set):

```
-w /etc/sudoers -p wa -k identity
-w /etc/passwd -w /etc/group -w /etc/shadow -w /etc/gshadow -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k sshd
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-a always,exit -F arch=b64 -S execve -k exec -F auid>=1000
```

- `sudo augenrules --check && sudo systemctl restart auditd`. Ship logs via the existing soc shippers where available.

## Fail2ban / ssh throttling

- `sudo apt install fail2ban` (already running on thing1), enable the `sshd` jail and `recidive` jail with escalating ban time; set `backend = systemd`.

## Misc per OS-STIG/CIS

- rsyslog: `/etc/rsyslog.conf` `$FileCreateMode 0640`, keep logs local (already shipped).
- chrony: ensure no `allow` lines on non-NTP servers; `chronyc sources` verifies.
- Sudo logging: `echo 'Defaults logfile="/var/log/sudo.log"' > /etc/sudoers.d/logging` (edit with visudo -f).
- Remove server-noise packages on headless hosts: `sudo apt purge snap-cups modemmanager` (cups + ModemManager are running on thing1; keep only if a printer/WWAN is actually attached).
- snap auto-refresh schedule: `sudo snap set system refresh.timer=4:00-5:00` (quiet hour; no holds).
- Optional integrity: AIDE with a weekly cron.

## Verify

```
sysctl --system --load /etc/sysctl.d/60-hardening.conf    # echo of effective values
sudo ufw status verbose
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|maxauthtries'
sudo auditctl -l ; sudo aureport --summary
lynis audit system --quick                                  # belt+suspenders, review warnings not totals
```

## Change risk

- `PasswordAuthentication no` is the lockout step — keep two sessions open and test a fresh key login before closing.
- `unprivileged_bpf_disabled` breaks non-root `bpftool`-class tooling; `ptrace_scope` limits attach to children (gdb on running daemons needs adjustments).
- ufw+Docker: wrong DROP rules in DOCKER-USER can cut container ingress — apply to one interface, test, then scale via the docker guide.